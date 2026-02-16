import Foundation

struct ApprovalStateResponse: Codable, Sendable {
    let approvalRulesOverwritten: Bool?
    let rules: [ApprovalRule]

    enum CodingKeys: String, CodingKey {
        case approvalRulesOverwritten = "approval_rules_overwritten"
        case rules
    }
}

struct ApprovalRule: Codable, Sendable {
    let id: Int
    let name: String
    let approvalsRequired: Int
    let approved: Bool
    let approvedBy: [ApproverInfo]

    enum CodingKeys: String, CodingKey {
        case id, name, approved
        case approvalsRequired = "approvals_required"
        case approvedBy = "approved_by"
    }
}

struct ApproverInfo: Codable, Identifiable, Sendable {
    let id: Int
    let name: String
    let username: String
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name, username
        case avatarUrl = "avatar_url"
    }
}
