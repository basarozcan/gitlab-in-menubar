import Foundation

protocol MergeRequestServiceProtocol: Sendable {
    func configure(baseURL: String, accessToken: String) async
    func fetchAllMRs(
        projects: [ProjectConfig],
        state: String,
        scope: String,
        authorUsername: String?,
        hideDrafts: Bool
    ) async throws -> [EnrichedMR]
    func testConnection(baseURL: String, accessToken: String) async throws -> GitLabUser
}
