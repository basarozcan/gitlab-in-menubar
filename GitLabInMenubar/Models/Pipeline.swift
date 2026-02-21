import Foundation

struct PipelineInfo: Codable, Hashable, Sendable {
    let id: Int
    let status: PipelineStatus
    let webUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, status
        case webUrl = "web_url"
    }
}

struct MRPipeline: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let sha: String
    let ref: String
    let status: PipelineStatus
}

enum PipelineStatus: String, Codable, Sendable {
    case created, waiting, preparing, pending, running
    case success, failed, canceled, skipped, manual, scheduled
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = PipelineStatus(rawValue: value) ?? .unknown
    }
}
