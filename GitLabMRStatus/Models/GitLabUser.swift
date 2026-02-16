import Foundation

struct GitLabUser: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let username: String
    let avatarUrl: String?
    let webUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name, username
        case avatarUrl = "avatar_url"
        case webUrl = "web_url"
    }
}
