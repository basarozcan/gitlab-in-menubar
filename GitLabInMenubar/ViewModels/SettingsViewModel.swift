import Foundation
import SwiftUI

extension Notification.Name {
    static let settingsDidChange = Notification.Name("settingsDidChange")
}

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var gitlabURL: String = ""
    @Published var accessToken: String = ""
    @Published var projects: [ProjectConfig] = []
    @Published var refreshInterval: Double = AppConstants.defaultRefreshInterval
    @Published var notificationsEnabled: Bool = true
    @Published var connectionStatus: ConnectionStatus = .untested
    @Published var newProjectId: String = ""
    @Published var newProjectName: String = ""
    @Published var saveConfirmation: Bool = false
    @Published var filterState: MRFilterState = .opened
    @Published var filterScope: MRFilterScope = .all
    @Published var filterAuthorUsername: String = ""
    @Published var filterHideDrafts: Bool = false
    @Published var showPipelineInfo: Bool = true

    enum ConnectionStatus: Equatable {
        case untested
        case testing
        case success(username: String)
        case failed(String)
    }

    private let service = MergeRequestService()

    func load() {
        gitlabURL = UserDefaults.standard.string(forKey: UserDefaultsKeys.gitlabBaseURL) ?? ""
        accessToken = KeychainService.retrieve() ?? ""
        refreshInterval = UserDefaults.standard.double(forKey: UserDefaultsKeys.refreshIntervalSeconds)
        if refreshInterval == 0 { refreshInterval = AppConstants.defaultRefreshInterval }
        notificationsEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.notificationsEnabled)
        if let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.projectConfigs) {
            projects = (try? JSONDecoder().decode([ProjectConfig].self, from: data)) ?? []
        }
        if let raw = UserDefaults.standard.string(forKey: UserDefaultsKeys.filterState) {
            filterState = MRFilterState(rawValue: raw) ?? .opened
        }
        if let raw = UserDefaults.standard.string(forKey: UserDefaultsKeys.filterScope) {
            filterScope = MRFilterScope(rawValue: raw) ?? .all
        }
        filterAuthorUsername = UserDefaults.standard.string(forKey: UserDefaultsKeys.filterAuthorUsername) ?? ""
        filterHideDrafts = UserDefaults.standard.bool(forKey: UserDefaultsKeys.filterHideDrafts)
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.showPipelineInfo) != nil {
            showPipelineInfo = UserDefaults.standard.bool(forKey: UserDefaultsKeys.showPipelineInfo)
        }
    }

    func save() {
        UserDefaults.standard.set(gitlabURL, forKey: UserDefaultsKeys.gitlabBaseURL)
        try? KeychainService.save(token: accessToken)
        UserDefaults.standard.set(refreshInterval, forKey: UserDefaultsKeys.refreshIntervalSeconds)
        UserDefaults.standard.set(notificationsEnabled, forKey: UserDefaultsKeys.notificationsEnabled)
        if let data = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.projectConfigs)
        }
        UserDefaults.standard.set(filterState.rawValue, forKey: UserDefaultsKeys.filterState)
        UserDefaults.standard.set(filterScope.rawValue, forKey: UserDefaultsKeys.filterScope)
        UserDefaults.standard.set(filterAuthorUsername, forKey: UserDefaultsKeys.filterAuthorUsername)
        UserDefaults.standard.set(filterHideDrafts, forKey: UserDefaultsKeys.filterHideDrafts)
        UserDefaults.standard.set(showPipelineInfo, forKey: UserDefaultsKeys.showPipelineInfo)
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        saveConfirmation = true
    }

    func testConnection() async {
        connectionStatus = .testing
        do {
            let user = try await service.testConnection(baseURL: gitlabURL, accessToken: accessToken)
            connectionStatus = .success(username: user.username)
        } catch {
            connectionStatus = .failed(error.localizedDescription)
        }
    }

    func addProject() {
        guard let projectId = Int(newProjectId), !newProjectName.isEmpty else { return }
        let config = ProjectConfig(
            projectId: projectId,
            name: newProjectName,
            pathWithNamespace: newProjectName
        )
        projects.append(config)
        newProjectId = ""
        newProjectName = ""
    }

    func removeProject(at offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
    }
}
