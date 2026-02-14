import Foundation

struct FlightResponse: Codable {
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
    let departureTerminal: String?
    let arrivalTerminal: String?
    let departureGate: String?
    let arrivalGate: String?
    let distanceKm: Double?
    let durationMinutes: Int?
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

final class FlightService {
    private let apiClient = APIClient()

    func lookupPNR(pnr: String) async throws -> FlightResponse {
        try await apiClient.request(FlightEndpoint.pnrLookup(pnr: pnr))
    }

    func getFlights(page: Int = 1, limit: Int = 20) async throws -> [FlightResponse] {
        try await apiClient.request(FlightEndpoint.list(page: page, limit: limit))
    }

    func getFlightStatus(id: String) async throws -> FlightStatusResponse {
        try await apiClient.request(FlightEndpoint.status(id: id))
    }

    func searchAirports(query: String) async throws -> [Airport] {
        try await apiClient.request(FlightEndpoint.searchAirports(query: query))
    }

    func searchAirlines(query: String) async throws -> [Airline] {
        try await apiClient.request(FlightEndpoint.searchAirlines(query: query))
    }
}
