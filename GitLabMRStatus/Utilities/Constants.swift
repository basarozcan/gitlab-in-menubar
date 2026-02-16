import Foundation

enum AppConstants {
    static let defaultRefreshInterval: TimeInterval = 60
    static let minimumRefreshInterval: TimeInterval = 15
    static let maximumRefreshInterval: TimeInterval = 600
    static let maxMRsPerProject = 50
}

enum UserDefaultsKeys {
    static let gitlabBaseURL = "gitlabBaseURL"
    static let refreshIntervalSeconds = "refreshIntervalSeconds"
    static let notificationsEnabled = "notificationsEnabled"
    static let projectConfigs = "projectConfigs"
    static let filterState = "filterState"
    static let filterScope = "filterScope"
    static let filterAuthorUsername = "filterAuthorUsername"
    static let filterHideDrafts = "filterHideDrafts"
    static let showPipelineInfo = "showPipelineInfo"
}

enum MRFilterState: String, CaseIterable, Identifiable, Sendable {
    case opened = "opened"
    case merged = "merged"
    case closed = "closed"
    case all = "all"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .opened: return "Opened"
        case .merged: return "Merged"
        case .closed: return "Closed"
        case .all: return "All"
        }
    }
}

enum MRFilterScope: String, CaseIterable, Identifiable, Sendable {
    case all = "all"
    case assignedToMe = "assigned_to_me"
    case createdByMe = "created_by_me"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "All"
        case .assignedToMe: return "Assigned to me"
        case .createdByMe: return "Created by me"
        }
    }
}
