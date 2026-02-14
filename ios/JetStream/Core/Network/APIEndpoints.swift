import Foundation

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
    var body: Encodable? { get }
    var requiresAuth: Bool { get }
}

extension APIEndpoint {
    var headers: [String: String]? { nil }
    var queryParameters: [String: String]? { nil }
    var body: Encodable? { nil }
    var requiresAuth: Bool { true }
}

// MARK: - Auth Endpoints

enum AuthEndpoint: APIEndpoint {
    case register(email: String, password: String, name: String)
    case login(email: String, password: String)
    case socialLogin(provider: String, token: String)
    case refreshToken(refreshToken: String)

    var path: String {
        switch self {
        case .register: return "/auth/register"
        case .login: return "/auth/login"
        case .socialLogin: return "/auth/social"
        case .refreshToken: return "/auth/refresh"
        }
    }

    var method: HTTPMethod {
        .post
    }

    var body: Encodable? {
        switch self {
        case .register(let email, let password, let name):
            return ["email": email, "password": password, "name": name]
        case .login(let email, let password):
            return ["email": email, "password": password]
        case .socialLogin(let provider, let token):
            return ["provider": provider, "token": token]
        case .refreshToken(let refreshToken):
            return ["refresh_token": refreshToken]
        }
    }

    var requiresAuth: Bool { false }
}

// MARK: - User Endpoints

enum UserEndpoint: APIEndpoint {
    case getProfile
    case updateProfile(name: String?, avatarUrl: String?)

    var path: String {
        switch self {
        case .getProfile, .updateProfile: return "/users/profile"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getProfile: return .get
        case .updateProfile: return .put
        }
    }

    var body: Encodable? {
        switch self {
        case .updateProfile(let name, let avatarUrl):
            return ["name": name, "avatar_url": avatarUrl]
        default: return nil
        }
    }
}

// MARK: - Flight Endpoints

enum FlightEndpoint: APIEndpoint {
    case pnrLookup(pnr: String)
    case list(page: Int, limit: Int)
    case detail(id: String)
    case create(FlightCreateRequest)
    case update(id: String, FlightUpdateRequest)
    case delete(id: String)
    case status(id: String)
    case searchAirports(query: String)
    case searchAirlines(query: String)

    var path: String {
        switch self {
        case .pnrLookup: return "/flights/pnr-lookup"
        case .list: return "/flights"
        case .detail(let id): return "/flights/\(id)"
        case .create: return "/flights"
        case .update(let id, _): return "/flights/\(id)"
        case .delete(let id): return "/flights/\(id)"
        case .status(let id): return "/flights/\(id)/status"
        case .searchAirports: return "/airports/search"
        case .searchAirlines: return "/airlines/search"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .pnrLookup, .create: return .post
        case .list, .detail, .status, .searchAirports, .searchAirlines: return .get
        case .update: return .put
        case .delete: return .delete
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case .list(let page, let limit):
            return ["page": "\(page)", "limit": "\(limit)"]
        case .searchAirports(let query), .searchAirlines(let query):
            return ["q": query]
        default: return nil
        }
    }

    var body: Encodable? {
        switch self {
        case .pnrLookup(let pnr):
            return ["pnr": pnr]
        case .create(let request):
            return request
        case .update(_, let request):
            return request
        default: return nil
        }
    }
}

// MARK: - Analytics Endpoints

enum AnalyticsEndpoint: APIEndpoint {
    case summary
    case airlines
    case airports
    case trends
    case records

    var path: String {
        switch self {
        case .summary: return "/analytics/summary"
        case .airlines: return "/analytics/airlines"
        case .airports: return "/analytics/airports"
        case .trends: return "/analytics/trends"
        case .records: return "/analytics/records"
        }
    }

    var method: HTTPMethod { .get }
}

// MARK: - Request Models

struct FlightCreateRequest: Encodable {
    let pnr: String?
    let flightNumber: String
    let airlineCode: String
    let airlineName: String
    let departureAirport: String
    let departureCity: String?
    let arrivalAirport: String
    let arrivalCity: String?
    let scheduledDeparture: Date
    let scheduledArrival: Date
    let cabinClass: String?
    let seatNumber: String?
    let notes: String?
    let isManualEntry: Bool
}

struct FlightUpdateRequest: Encodable {
    let seatNumber: String?
    let cabinClass: String?
    let notes: String?
}
