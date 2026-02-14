import XCTest
@testable import JetStream

final class JetStreamTests: XCTestCase {
    func testFlightRouteComputed() {
        let flight = Flight(
            flightNumber: "AI101",
            airlineCode: "AI",
            airlineName: "Air India",
            departureAirportCode: "DEL",
            departureAirportName: "Indira Gandhi International Airport",
            departureCity: "New Delhi",
            arrivalAirportCode: "BOM",
            arrivalAirportName: "Chhatrapati Shivaji Maharaj International Airport",
            arrivalCity: "Mumbai",
            scheduledDeparture: Date(),
            scheduledArrival: Date().addingTimeInterval(7200),
            durationMinutes: 120
        )
        XCTAssertEqual(flight.route, "DEL \u{2192} BOM")
        XCTAssertEqual(flight.durationFormatted, "2h 0m")
    }
}
