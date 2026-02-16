import Foundation

struct DiscussionStats: Sendable {
    let resolved: Int
    let total: Int
}

struct EnrichedMR: Identifiable, Sendable {
    let id: Int
    let mr: MergeRequest
    let approvalState: ApprovalStateResponse?
    let discussionStats: DiscussionStats?
    let latestPipeline: MRPipeline?
    let projectName: String
    let gitlabBaseURL: String

    var totalApprovalsReceived: Int {
        approvalState?.rules.flatMap(\.approvedBy).count ?? 0
    }

    var totalApprovalsRequired: Int {
        approvalState?.rules.map(\.approvalsRequired).max() ?? 0
    }

    var isFullyApproved: Bool {
        guard let rules = approvalState?.rules, !rules.isEmpty else { return false }
        return rules.allSatisfy(\.approved)
    }

    var pipelineStatus: PipelineStatus? {
        latestPipeline?.status ?? mr.headPipeline?.status
    }

    var pipelineURL: URL? {
        guard let pipeline = latestPipeline else {
            if let webUrl = mr.headPipeline?.webUrl { return URL(string: webUrl) }
            return nil
        }
        // Build URL from base: {gitlab}/{namespace/project}/-/pipelines/{id}
        // Extract project path from MR web_url: everything before /-/merge_requests
        if let range = mr.webUrl.range(of: "/-/merge_requests") {
            let projectURL = String(mr.webUrl[mr.webUrl.startIndex..<range.lowerBound])
            return URL(string: "\(projectURL)/-/pipelines/\(pipeline.id)")
        }
        return nil
    }
}

actor MergeRequestService {
    private let apiClient = GitLabAPIClient()

    private var baseURL: String = ""

    func configure(baseURL: String, accessToken: String) async {
        self.baseURL = baseURL
        await apiClient.configure(baseURL: baseURL, accessToken: accessToken)
    }

    func fetchAllMRs(
        projects: [ProjectConfig],
        state: String = "opened",
        scope: String = "all",
        authorUsername: String? = nil,
        hideDrafts: Bool = false
    ) async throws -> [EnrichedMR] {
        try await withThrowingTaskGroup(of: [EnrichedMR].self) { group in
            for project in projects {
                group.addTask {
                    let mrs = try await self.apiClient.fetchMergeRequests(
                        projectId: project.projectId,
                        state: state,
                        scope: scope,
                        authorUsername: authorUsername
                    )
                    let filtered = hideDrafts ? mrs.filter { !$0.draft } : mrs
                    return await self.enrichMRs(filtered, projectName: project.name)
                }
            }
            var allMRs: [EnrichedMR] = []
            for try await projectMRs in group {
                allMRs.append(contentsOf: projectMRs)
            }
            return allMRs.sorted { ($0.mr.iid, $0.mr.projectId) > ($1.mr.iid, $1.mr.projectId) }
        }
    }

    private func enrichMRs(_ mrs: [MergeRequest], projectName: String) async -> [EnrichedMR] {
        let currentBaseURL = self.baseURL
        return await withTaskGroup(of: EnrichedMR.self) { group in
            for mr in mrs {
                group.addTask {
                    async let approval = try? self.apiClient.fetchApprovalState(
                        projectId: mr.projectId,
                        mrIid: mr.iid
                    )
                    async let discussions = try? self.apiClient.fetchDiscussions(
                        projectId: mr.projectId,
                        mrIid: mr.iid
                    )
                    async let pipelines = try? self.apiClient.fetchPipelines(
                        projectId: mr.projectId,
                        mergeRequestIid: mr.iid
                    )

                    let stats: DiscussionStats?
                    if let discs = await discussions {
                        let resolvableThreads = discs.filter { disc in
                            disc.notes.contains(where: \.resolvable)
                        }
                        let resolvedThreads = resolvableThreads.filter { disc in
                            disc.notes.filter(\.resolvable).allSatisfy { $0.resolved == true }
                        }
                        stats = DiscussionStats(resolved: resolvedThreads.count, total: resolvableThreads.count)
                    } else {
                        stats = nil
                    }

                    let latest = await pipelines?.first

                    return EnrichedMR(
                        id: mr.id,
                        mr: mr,
                        approvalState: await approval,
                        discussionStats: stats,
                        latestPipeline: latest,
                        projectName: projectName,
                        gitlabBaseURL: currentBaseURL
                    )
                }
            }
            var results: [EnrichedMR] = []
            for await enriched in group {
                results.append(enriched)
            }
            return results
        }
    }

    func testConnection(baseURL: String, accessToken: String) async throws -> GitLabUser {
        let testClient = GitLabAPIClient()
        await testClient.configure(baseURL: baseURL, accessToken: accessToken)
        return try await testClient.fetchCurrentUser()
    }
}
