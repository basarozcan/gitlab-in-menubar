import Foundation

enum GitLabAPIError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case notFound
    case rateLimited(retryAfter: Int?)
    case serverError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .unauthorized: return "Invalid or expired access token"
        case .rateLimited: return "API rate limit exceeded"
        case .notFound: return "Resource not found"
        case .serverError(let code): return "Server error (\(code))"
        case .decodingError(let err): return "Failed to parse response: \(err.localizedDescription)"
        case .networkError(let err): return "Network error: \(err.localizedDescription)"
        }
    }
}

actor GitLabAPIClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    private var baseURL: String = ""
    private var accessToken: String = ""

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }

    func configure(baseURL: String, accessToken: String) {
        self.baseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.accessToken = accessToken
    }

    func fetchMergeRequests(
        projectId: Int,
        state: String = "opened",
        scope: String = "all",
        authorUsername: String? = nil,
        perPage: Int = AppConstants.maxMRsPerProject
    ) async throws -> [MergeRequest] {
        let path = "/api/v4/projects/\(projectId)/merge_requests"
        var query = [
            "state": state,
            "scope": scope,
            "per_page": "\(perPage)",
            "order_by": "updated_at",
            "sort": "desc"
        ]
        if let authorUsername, !authorUsername.isEmpty {
            query["author_username"] = authorUsername
        }
        return try await request(path: path, queryItems: query)
    }

    func fetchApprovalState(
        projectId: Int,
        mrIid: Int
    ) async throws -> ApprovalStateResponse {
        let path = "/api/v4/projects/\(projectId)/merge_requests/\(mrIid)/approval_state"
        return try await request(path: path)
    }

    func fetchDiscussions(
        projectId: Int,
        mrIid: Int
    ) async throws -> [Discussion] {
        let path = "/api/v4/projects/\(projectId)/merge_requests/\(mrIid)/discussions"
        return try await request(path: path, queryItems: ["per_page": "100"])
    }

    func fetchPipelines(
        projectId: Int,
        mergeRequestIid: Int
    ) async throws -> [MRPipeline] {
        let path = "/api/v4/projects/\(projectId)/merge_requests/\(mergeRequestIid)/pipelines"
        return try await request(path: path)
    }

    func fetchCurrentUser() async throws -> GitLabUser {
        return try await request(path: "/api/v4/user")
    }

    private func request<T: Decodable>(
        path: String,
        queryItems: [String: String] = [:]
    ) async throws -> T {
        guard var components = URLComponents(string: "\(baseURL)\(path)") else {
            throw GitLabAPIError.invalidURL
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        guard let url = components.url else {
            throw GitLabAPIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(accessToken, forHTTPHeaderField: "PRIVATE-TOKEN")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        #if DEBUG
        print("[GitLab API] → \(urlRequest.httpMethod ?? "GET") \(url)")
        #endif

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw GitLabAPIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitLabAPIError.networkError(
                NSError(domain: "GitLab", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            )
        }

        #if DEBUG
        let bodyPreview = String(data: data, encoding: .utf8) ?? "<binary>"
        print("[GitLab API] ← \(httpResponse.statusCode) \(path) (\(data.count) bytes)")
        print("[GitLab API]   \(bodyPreview)")
        #endif

        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                #if DEBUG
                print("[GitLab API] ✗ Decode error for \(path): \(error)")
                #endif
                throw GitLabAPIError.decodingError(error)
            }
        case 401:
            throw GitLabAPIError.unauthorized
        case 404:
            throw GitLabAPIError.notFound
        case 429:
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                .flatMap(Int.init)
            throw GitLabAPIError.rateLimited(retryAfter: retryAfter)
        default:
            throw GitLabAPIError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}
