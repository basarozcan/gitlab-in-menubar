import Foundation

struct ProjectConfig: Codable, Identifiable, Hashable, Sendable {
    var id: String { "\(projectId)" }
    var projectId: Int
    var name: String
    var pathWithNamespace: String
}
