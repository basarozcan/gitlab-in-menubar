import Foundation
import SwiftUI

enum MRTab: String, CaseIterable {
    case myMRs = "myMRs"
    case reviewing = "reviewing"

    var label: String {
        switch self {
        case .myMRs: return "My MRs"
        case .reviewing: return "Reviewing"
        }
    }
}

@MainActor
final class MRListViewModel: ObservableObject {
    @Published var enrichedMRs: [EnrichedMR] = []
    @Published var reviewerMRs: [EnrichedMR] = []
    @Published var selectedTab: MRTab = .myMRs
    @Published var isLoading = false
    @Published var lastRefresh: Date?
    @Published var errorMessage: String?
    @Published var searchText: String = ""

    var filteredMRs: [EnrichedMR] {
        guard !searchText.isEmpty else { return enrichedMRs }
        return enrichedMRs.filter { $0.mr.title.localizedCaseInsensitiveContains(searchText) }
    }

    var filteredReviewerMRs: [EnrichedMR] {
        guard !searchText.isEmpty else { return reviewerMRs }
        return reviewerMRs.filter { $0.mr.title.localizedCaseInsensitiveContains(searchText) }
    }

    var activeFilteredMRs: [EnrichedMR] {
        selectedTab == .reviewing ? filteredReviewerMRs : filteredMRs
    }

    var activeEnrichedMRs: [EnrichedMR] {
        selectedTab == .reviewing ? reviewerMRs : enrichedMRs
    }

    private let service = MergeRequestService()
    private var pollingTask: Task<Void, Never>?
    private var settingsObserver: Any?
    private var didStart = false

    @AppStorage(UserDefaultsKeys.refreshIntervalSeconds) var refreshInterval: Double = AppConstants.defaultRefreshInterval
    @AppStorage(UserDefaultsKeys.notificationsEnabled) var notificationsEnabled: Bool = true
    @AppStorage(UserDefaultsKeys.gitlabBaseURL) var gitlabBaseURL: String = ""
    @AppStorage(UserDefaultsKeys.filterState) var filterState: String = MRFilterState.opened.rawValue
    @AppStorage(UserDefaultsKeys.filterScope) var filterScope: String = MRFilterScope.all.rawValue
    @AppStorage(UserDefaultsKeys.filterAuthorUsername) var filterAuthorUsername: String = ""
    @AppStorage(UserDefaultsKeys.filterHideDrafts) var filterHideDrafts: Bool = false
    @AppStorage(UserDefaultsKeys.showPipelineInfo) var showPipelineInfo: Bool = true
    @AppStorage(UserDefaultsKeys.currentUserUsername) var currentUserUsername: String = ""

    var projects: [ProjectConfig] {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.projectConfigs) else { return [] }
        return (try? JSONDecoder().decode([ProjectConfig].self, from: data)) ?? []
    }

    var isConfigured: Bool {
        !gitlabBaseURL.isEmpty && KeychainService.retrieve() != nil && !projects.isEmpty
    }

    var menuBarSystemImage: String {
        if !isConfigured { return "arrow.triangle.merge" }
        if enrichedMRs.isEmpty { return "arrow.triangle.merge" }
        let hasFailure = enrichedMRs.contains { $0.mr.headPipeline?.status == .failed }
        if hasFailure { return "exclamationmark.circle.fill" }
        let hasRunning = enrichedMRs.contains {
            $0.mr.headPipeline?.status == .running || $0.mr.headPipeline?.status == .pending
        }
        if hasRunning { return "circle.dotted" }
        return "checkmark.circle.fill"
    }

    var menuBarCount: Int {
        enrichedMRs.count
    }

    private var isPolling: Bool { pollingTask != nil && !pollingTask!.isCancelled }

    func startIfNeeded() {
        guard !didStart else { return }
        didStart = true
        startPolling()

        settingsObserver = NotificationCenter.default.addObserver(
            forName: .settingsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.objectWillChange.send()
                self.stopPolling()
                self.startPolling()
            }
        }
    }

    private func startPolling() {
        guard !isPolling else { return }

        pollingTask = Task {
            await refresh()
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(refreshInterval))
                guard !Task.isCancelled else { break }
                await refresh()
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    func refresh() async {
        guard isConfigured, let token = KeychainService.retrieve() else {
            if !gitlabBaseURL.isEmpty {
                errorMessage = "Not configured. Open Settings to set up."
            }
            return
        }

        isLoading = true
        errorMessage = nil

        await service.configure(baseURL: gitlabBaseURL, accessToken: token)

        do {
            let author: String? = filterAuthorUsername.isEmpty ? nil : filterAuthorUsername
            async let myMRsFetch = service.fetchAllMRs(
                projects: projects,
                state: filterState,
                scope: filterScope,
                authorUsername: author,
                hideDrafts: filterHideDrafts
            )

            let reviewer: String? = currentUserUsername.isEmpty ? nil : currentUserUsername
            async let reviewerMRsFetch = reviewer != nil
                ? service.fetchAllMRs(
                    projects: projects,
                    state: "opened",
                    scope: "all",
                    reviewerUsername: reviewer,
                    hideDrafts: filterHideDrafts
                )
                : []

            let (newMRs, newReviewerMRs) = try await (myMRsFetch, reviewerMRsFetch)

            if notificationsEnabled && !enrichedMRs.isEmpty {
                detectChanges(old: enrichedMRs, new: newMRs)
            }

            enrichedMRs = newMRs
            reviewerMRs = newReviewerMRs
            lastRefresh = Date()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func detectChanges(old: [EnrichedMR], new: [EnrichedMR]) {
        let oldMap = Dictionary(uniqueKeysWithValues: old.map { ($0.id, $0) })
        for newMR in new {
            guard let oldMR = oldMap[newMR.id] else { continue }

            if let oldPipeline = oldMR.mr.headPipeline?.status,
               let newPipeline = newMR.mr.headPipeline?.status,
               oldPipeline != newPipeline {
                NotificationService.shared.notifyPipelineChange(
                    mrTitle: newMR.mr.title,
                    newStatus: newPipeline
                )
            }

            let oldApprovers = Set(oldMR.approvalState?.rules.flatMap(\.approvedBy).map(\.id) ?? [])
            let newApprovers = newMR.approvalState?.rules.flatMap(\.approvedBy) ?? []
            for approver in newApprovers where !oldApprovers.contains(approver.id) {
                NotificationService.shared.notifyApprovalChange(
                    mrTitle: newMR.mr.title,
                    approvedBy: approver.name
                )
            }
        }
    }
}
