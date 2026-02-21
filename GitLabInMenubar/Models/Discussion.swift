import Foundation

struct Discussion: Codable, Sendable {
    let id: String
    let notes: [Note]
}

struct Note: Codable, Sendable {
    let id: Int
    let resolvable: Bool
    let resolved: Bool?
}
