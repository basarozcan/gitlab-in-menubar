import Foundation

struct MergeRequest: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let iid: Int
    let projectId: Int
    let title: String
    let description: String?
    let state: MRState
    let detailedMergeStatus: DetailedMergeStatus?
    let draft: Bool
    let webUrl: String
    let sourceBranch: String
    let targetBranch: String
    let author: GitLabUser
    let assignees: [GitLabUser]?
    let reviewers: [GitLabUser]?
    let hasConflicts: Bool?
    let userNotesCount: Int
    let upvotes: Int
    let downvotes: Int
    let labels: [String]
    let mergeWhenPipelineSucceeds: Bool
    let headPipeline: PipelineInfo?

    enum CodingKeys: String, CodingKey {
        case id, iid, title, description, state, draft
        case projectId = "project_id"
        case detailedMergeStatus = "detailed_merge_status"
        case webUrl = "web_url"
        case sourceBranch = "source_branch"
        case targetBranch = "target_branch"
        case author, assignees, reviewers
        case hasConflicts = "has_conflicts"
        case userNotesCount = "user_notes_count"
        case upvotes, downvotes, labels
        case mergeWhenPipelineSucceeds = "merge_when_pipeline_succeeds"
        case headPipeline = "head_pipeline"
    }
}

enum MRState: String, Codable, Sendable {
    case opened, closed, merged, locked
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = MRState(rawValue: value) ?? .unknown
    }
}

enum DetailedMergeStatus: String, Codable, Sendable {
    case mergeable
    case checking
    case ciMustPass = "ci_must_pass"
    case ciStillRunning = "ci_still_running"
    case commitsStatus = "commits_status"
    case conflict
    case discussionsNotResolved = "discussions_not_resolved"
    case draftStatus = "draft_status"
    case mergeRequestBlocked = "merge_request_blocked"
    case approvalsSyncing = "approvals_syncing"
    case blocked = "blocked_status"
    case jiraAssociationMissing = "jira_association_missing"
    case notOpen = "not_open"
    case notApproved = "not_approved"
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = DetailedMergeStatus(rawValue: value) ?? .unknown
    }
}
