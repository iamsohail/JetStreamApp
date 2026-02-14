import Foundation

struct FlightResponse: Codable, Identifiable {
    let id: String?
    let flightNumber: String
    let airlineCode: String
    let airlineName: String
    let departureAirport: String
    let departureAirportName: String?
    let departureCity: String?
    let arrivalAirport: String
    let arrivalAirportName: String?
    let arrivalCity: String?
    let scheduledDeparture: Date
    let scheduledArrival: Date
    let actualDeparture: Date?
    let actualArrival: Date?
    let status: String?
    let aircraftType: String?
    let seatNumber: String?
    let cabinClass: String?
    let bookingReference: String?
    let departureTerminal: String?
    let arrivalTerminal: String?
    let departureGate: String?
    let arrivalGate: String?
    let distanceKm: Double?
    let durationMinutes: Int?
    let notes: String?
    let isManualEntry: Bool?
    let pnr: String?
    let createdAt: Date?
    let updatedAt: Date?

    // Display helpers
    var route: String {
        "\(departureAirport) → \(arrivalAirport)"
    }

    var durationFormatted: String {
        guard let mins = durationMinutes, mins > 0 else { return "--" }
        return "\(mins / 60)h \(mins % 60)m"
    }

    var isUpcoming: Bool {
        scheduledDeparture > Date()
    }

    var isPast: Bool {
        status == "landed" || scheduledArrival < Date()
    }

    var flightStatus: FlightStatus {
        FlightStatus(rawValue: status ?? "scheduled") ?? .scheduled
    }

    var cabin: CabinClass {
        CabinClass(rawValue: cabinClass ?? "economy") ?? .economy
    }

    var displayId: String {
        id ?? UUID().uuidString
    }
}

struct FlightStatusResponse: Codable {
    let status: String
    let actualDeparture: Date?
    let actualArrival: Date?
    let departureGate: String?
    let arrivalGate: String?
    let departureTerminal: String?
    let arrivalTerminal: String?
    let delayMinutes: Int?
}

// MARK: - Analytics Response Models

struct AnalyticsSummary: Codable {
    let totalFlights: String
    let totalDistanceKm: String
    let totalMinutes: String
    let uniqueAirports: String
    let uniqueAirlines: String

    var flightCount: Int { Int(totalFlights) ?? 0 }
    var distanceKm: Double { Double(totalDistanceKm) ?? 0 }
    var totalHours: Int { (Int(totalMinutes) ?? 0) / 60 }
}

struct AirlineBreakdown: Codable, Identifiable {
    let airlineName: String
    let airlineCode: String
    let flightCount: String
    let totalDistance: String

    var id: String { airlineCode }
    var count: Int { Int(flightCount) ?? 0 }
}

struct AirportStat: Codable, Identifiable {
    let airport: String
    let city: String?
    let visitCount: String

    var id: String { airport }
    var count: Int { Int(visitCount) ?? 0 }
}

struct TrendData: Codable, Identifiable {
    let month: String
    let flightCount: String

    var id: String { month }
    var count: Int { Int(flightCount) ?? 0 }
}

struct RecordsData: Codable {
    let longestFlight: RecordFlight?
    let shortestFlight: RecordFlight?
    let mostFlownRoute: MostFlownRoute?
}

struct RecordFlight: Codable {
    let flightNumber: String
    let airlineName: String
    let departureAirport: String
    let arrivalAirport: String
    let distanceKm: String?

    var route: String { "\(departureAirport) → \(arrivalAirport)" }
}

struct MostFlownRoute: Codable {
    let route: String
    let count: String

    var flightCount: Int { Int(count) ?? 0 }
}

// MARK: - Profile Response

struct ProfileResponse: Codable {
    let id: String
    let email: String
    let name: String
    let avatarUrl: String?
    let authProvider: String?
    let createdAt: Date?
}

final class FlightService {
    private let apiClient = APIClient()

    // MARK: - Flight CRUD

    func getFlights(page: Int = 1, limit: Int = 50) async throws -> [FlightResponse] {
        try await apiClient.request(FlightEndpoint.list(page: page, limit: limit))
    }

    func createFlight(_ request: FlightCreateRequest) async throws -> FlightResponse {
        try await apiClient.request(FlightEndpoint.create(request))
    }

    func deleteFlight(id: String) async throws {
        try await apiClient.request(FlightEndpoint.delete(id: id))
    }

    func getFlightStatus(id: String) async throws -> FlightStatusResponse {
        try await apiClient.request(FlightEndpoint.status(id: id))
    }

    // MARK: - Search

    func searchByFlightNumber(_ flightNumber: String, date: String? = nil) async throws -> [FlightResponse] {
        try await apiClient.request(FlightEndpoint.searchByNumber(flightNumber: flightNumber, date: date))
    }

    func searchAirports(query: String) async throws -> [Airport] {
        try await apiClient.request(FlightEndpoint.searchAirports(query: query))
    }

    func searchAirlines(query: String) async throws -> [Airline] {
        try await apiClient.request(FlightEndpoint.searchAirlines(query: query))
    }

    // MARK: - Analytics

    func getAnalyticsSummary() async throws -> AnalyticsSummary {
        try await apiClient.request(AnalyticsEndpoint.summary)
    }

    func getAirlineBreakdown() async throws -> [AirlineBreakdown] {
        try await apiClient.request(AnalyticsEndpoint.airlines)
    }

    func getAirportStats() async throws -> [AirportStat] {
        try await apiClient.request(AnalyticsEndpoint.airports)
    }

    func getTrends() async throws -> [TrendData] {
        try await apiClient.request(AnalyticsEndpoint.trends)
    }

    func getRecords() async throws -> RecordsData {
        try await apiClient.request(AnalyticsEndpoint.records)
    }

    // MARK: - Profile

    func getProfile() async throws -> ProfileResponse {
        try await apiClient.request(UserEndpoint.getProfile)
    }
}
