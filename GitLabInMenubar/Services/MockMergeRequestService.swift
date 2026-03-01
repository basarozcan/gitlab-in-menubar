import Foundation

/// Mock service used in MOCK_MODE builds. Returns hardcoded fake data with no network calls.
actor MockMergeRequestService: MergeRequestServiceProtocol {

    func configure(baseURL: String, accessToken: String) async {
        // No-op in mock mode
    }

    func fetchAllMRs(
        projects: [ProjectConfig],
        state: String,
        scope: String,
        authorUsername: String?,
        hideDrafts: Bool
    ) async throws -> [EnrichedMR] {
        // Simulate a small network delay
        try? await Task.sleep(for: .milliseconds(400))
        var mrs = Self.mockEnrichedMRs
        if hideDrafts {
            mrs = mrs.filter { !$0.mr.draft }
        }
        return mrs
    }

    func testConnection(baseURL: String, accessToken: String) async throws -> GitLabUser {
        return Self.mockUser
    }

    // MARK: - Mock Data

    private static let mockUser = GitLabUser(
        id: 1,
        name: "Mock User",
        username: "mockuser",
        avatarUrl: nil,
        webUrl: "https://gitlab.com/mockuser"
    )

    static let mockEnrichedMRs: [EnrichedMR] = [
        // 1. Passed pipeline, fully approved, all discussions resolved
        EnrichedMR(
            id: 101,
            mr: makeMR(
                id: 101, iid: 1,
                title: "feat: Add dark mode support",
                sourceBranch: "feature/dark-mode",
                draft: false,
                pipelineStatus: .success,
                mergeStatus: .mergeable
            ),
            approvalState: makeApprovalState(required: 2, approvers: ["Alice", "Bob"]),
            discussionStats: DiscussionStats(resolved: 3, total: 3),
            latestPipeline: nil,
            projectName: "ios-app",
            gitlabBaseURL: "https://gitlab.com"
        ),

        // 2. Running pipeline, partially approved, open discussions
        EnrichedMR(
            id: 102,
            mr: makeMR(
                id: 102, iid: 2,
                title: "fix: Resolve memory leak in image cache",
                sourceBranch: "fix/image-cache-leak",
                draft: false,
                pipelineStatus: .running,
                mergeStatus: .ciStillRunning
            ),
            approvalState: makeApprovalState(required: 2, approvers: ["Alice"]),
            discussionStats: DiscussionStats(resolved: 1, total: 4),
            latestPipeline: nil,
            projectName: "ios-app",
            gitlabBaseURL: "https://gitlab.com"
        ),

        // 3. Failed pipeline, no approvals
        EnrichedMR(
            id: 103,
            mr: makeMR(
                id: 103, iid: 3,
                title: "refactor: Migrate networking layer to async/await",
                sourceBranch: "refactor/async-networking",
                draft: false,
                pipelineStatus: .failed,
                mergeStatus: .ciMustPass
            ),
            approvalState: makeApprovalState(required: 1, approvers: []),
            discussionStats: DiscussionStats(resolved: 0, total: 2),
            latestPipeline: nil,
            projectName: "backend-api",
            gitlabBaseURL: "https://gitlab.com"
        ),

        // 4. Draft MR, pending pipeline
        EnrichedMR(
            id: 104,
            mr: makeMR(
                id: 104, iid: 4,
                title: "WIP: Redesign onboarding flow",
                sourceBranch: "feature/onboarding-redesign",
                draft: true,
                pipelineStatus: .pending,
                mergeStatus: .draftStatus
            ),
            approvalState: makeApprovalState(required: 2, approvers: []),
            discussionStats: DiscussionStats(resolved: 0, total: 0),
            latestPipeline: nil,
            projectName: "ios-app",
            gitlabBaseURL: "https://gitlab.com"
        ),

        // 5. Merge conflict
        EnrichedMR(
            id: 105,
            mr: makeMR(
                id: 105, iid: 5,
                title: "chore: Bump dependencies to latest versions",
                sourceBranch: "chore/dependency-bump",
                draft: false,
                pipelineStatus: .success,
                mergeStatus: .conflict
            ),
            approvalState: makeApprovalState(required: 1, approvers: ["Charlie"]),
            discussionStats: DiscussionStats(resolved: 0, total: 0),
            latestPipeline: nil,
            projectName: "backend-api",
            gitlabBaseURL: "https://gitlab.com"
        ),

        // 6. Not approved, no pipeline
        EnrichedMR(
            id: 106,
            mr: makeMR(
                id: 106, iid: 6,
                title: "docs: Update API integration guide",
                sourceBranch: "docs/api-guide",
                draft: false,
                pipelineStatus: nil,
                mergeStatus: .notApproved
            ),
            approvalState: makeApprovalState(required: 1, approvers: []),
            discussionStats: DiscussionStats(resolved: 2, total: 2),
            latestPipeline: nil,
            projectName: "docs",
            gitlabBaseURL: "https://gitlab.com"
        ),

        // 7. Blocked, unresolved discussions
        EnrichedMR(
            id: 107,
            mr: makeMR(
                id: 107, iid: 7,
                title: "feat: Implement push notification deep linking",
                sourceBranch: "feature/push-deeplinks",
                draft: false,
                pipelineStatus: .success,
                mergeStatus: .discussionsNotResolved
            ),
            approvalState: makeApprovalState(required: 2, approvers: ["Alice", "Dave"]),
            discussionStats: DiscussionStats(resolved: 1, total: 5),
            latestPipeline: nil,
            projectName: "ios-app",
            gitlabBaseURL: "https://gitlab.com"
        ),

        // 8. Canceled pipeline, approved
        EnrichedMR(
            id: 108,
            mr: makeMR(
                id: 108, iid: 8,
                title: "fix: Correct date formatting in reports",
                sourceBranch: "fix/date-formatting",
                draft: false,
                pipelineStatus: .canceled,
                mergeStatus: .mergeable
            ),
            approvalState: makeApprovalState(required: 1, approvers: ["Bob"]),
            discussionStats: DiscussionStats(resolved: 0, total: 0),
            latestPipeline: nil,
            projectName: "backend-api",
            gitlabBaseURL: "https://gitlab.com"
        ),
    ]

    // MARK: - Helpers

    private static func makeMR(
        id: Int,
        iid: Int,
        title: String,
        sourceBranch: String,
        draft: Bool,
        pipelineStatus: PipelineStatus?,
        mergeStatus: DetailedMergeStatus
    ) -> MergeRequest {
        let pipeline: PipelineInfo? = pipelineStatus.map {
            PipelineInfo(
                id: id * 10,
                status: $0,
                webUrl: "https://gitlab.com/mock/project/-/pipelines/\(id * 10)"
            )
        }
        return MergeRequest(
            id: id,
            iid: iid,
            projectId: 1,
            title: title,
            description: "Mock description for \(title)",
            state: .opened,
            detailedMergeStatus: mergeStatus,
            draft: draft,
            webUrl: "https://gitlab.com/mock/project/-/merge_requests/\(iid)",
            sourceBranch: sourceBranch,
            targetBranch: "main",
            author: GitLabUser(id: 1, name: "Mock Author", username: "mockauthor", avatarUrl: nil, webUrl: nil),
            assignees: [],
            reviewers: [],
            hasConflicts: mergeStatus == .conflict,
            userNotesCount: 0,
            upvotes: 0,
            downvotes: 0,
            labels: [],
            mergeWhenPipelineSucceeds: false,
            headPipeline: pipeline
        )
    }

    private static func makeApprovalState(required: Int, approvers: [String]) -> ApprovalStateResponse {
        let approvedBy: [ApproverInfo] = approvers.enumerated().map { index, name in
            ApproverInfo(id: index + 10, name: name, username: name.lowercased(), avatarUrl: nil)
        }
        let rule = ApprovalRule(
            id: 1,
            name: "Default",
            approvalsRequired: required,
            approved: approvedBy.count >= required,
            approvedBy: approvedBy
        )
        return ApprovalStateResponse(approvalRulesOverwritten: false, rules: [rule])
    }
}
