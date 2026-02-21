import SwiftUI

extension PipelineStatus {
    var displayName: String {
        switch self {
        case .success: return "Passed"
        case .failed: return "Failed"
        case .running: return "Running"
        case .pending: return "Pending"
        case .canceled: return "Canceled"
        case .manual: return "Manual"
        case .created: return "Created"
        case .waiting: return "Waiting"
        case .preparing: return "Preparing"
        case .skipped: return "Skipped"
        case .scheduled: return "Scheduled"
        case .unknown: return "Unknown"
        }
    }

    var color: Color {
        switch self {
        case .success: return .green
        case .failed: return .red
        case .running: return .orange
        case .pending, .waiting, .preparing, .created: return .yellow
        case .canceled: return .gray
        case .manual: return .blue
        case .skipped, .scheduled, .unknown: return .gray
        }
    }

    var iconName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .running: return "play.circle.fill"
        case .pending, .waiting, .preparing, .created: return "clock.fill"
        case .canceled: return "minus.circle.fill"
        case .manual: return "hand.raised.fill"
        case .skipped: return "forward.fill"
        case .scheduled: return "calendar"
        case .unknown: return "questionmark.circle.fill"
        }
    }
}

extension DetailedMergeStatus {
    var shortLabel: String {
        switch self {
        case .conflict: return "Conflict"
        case .ciMustPass: return "CI Required"
        case .ciStillRunning: return "CI Running"
        case .discussionsNotResolved: return "Discussions"
        case .draftStatus: return "Draft"
        case .mergeRequestBlocked, .blocked: return "Blocked"
        case .mergeable: return "Ready"
        case .checking: return "Checking"
        case .approvalsSyncing: return "Syncing"
        case .notApproved: return "Not Approved"
        case .notOpen: return "Not Open"
        case .commitsStatus: return "Commits"
        case .jiraAssociationMissing: return "Jira Missing"
        case .unknown: return "Unknown"
        }
    }

    var color: Color {
        switch self {
        case .mergeable: return .green
        case .conflict, .blocked, .mergeRequestBlocked: return .red
        case .ciStillRunning, .ciMustPass, .checking, .approvalsSyncing: return .orange
        case .discussionsNotResolved, .draftStatus, .notApproved: return .yellow
        default: return .secondary
        }
    }
}
