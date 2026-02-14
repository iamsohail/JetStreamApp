import Foundation
import SwiftData

enum FlightStatus: String, Codable, CaseIterable {
    case scheduled, boarding, departed, inAir, landed, cancelled, delayed, diverted

    var displayName: String {
        switch self {
        case .inAir: return "In Air"
        default: return rawValue.capitalized
        }
    }

    var color: String {
        switch self {
        case .scheduled: return "skyBlue"
        case .boarding: return "amber"
        case .departed, .inAir: return "emerald"
        case .landed: return "skyBlue"
        case .cancelled: return "jetRed"
        case .delayed: return "amber"
        case .diverted: return "amber"
        }
    }
}

enum CabinClass: String, Codable, CaseIterable {
    case economy, premiumEconomy, business, first

    var displayName: String {
        switch self {
        case .premiumEconomy: return "Premium Economy"
        default: return rawValue.capitalized
        }
    }
}

@Model
final class Flight {
    var id: UUID
    var pnr: String?
    var flightNumber: String
    var airlineCode: String
    var airlineName: String
    var departureAirportCode: String
    var departureAirportName: String
    var departureCity: String
    var arrivalAirportCode: String
    var arrivalAirportName: String
    var arrivalCity: String
    var scheduledDeparture: Date
    var scheduledArrival: Date
    var actualDeparture: Date?
    var actualArrival: Date?
    var statusRaw: String
    var aircraftType: String?
    var seatNumber: String?
    var cabinClassRaw: String
    var bookingReference: String?
    var distanceKm: Double
    var durationMinutes: Int
    var departureTerminal: String?
    var arrivalTerminal: String?
    var departureGate: String?
    var arrivalGate: String?
    var notes: String?
    var isManualEntry: Bool
    var createdAt: Date
    var updatedAt: Date

    var status: FlightStatus {
        get { FlightStatus(rawValue: statusRaw) ?? .scheduled }
        set { statusRaw = newValue.rawValue }
    }

    var cabinClass: CabinClass {
        get { CabinClass(rawValue: cabinClassRaw) ?? .economy }
        set { cabinClassRaw = newValue.rawValue }
    }

    // Computed properties
    var durationFormatted: String {
        let hours = durationMinutes / 60
        let mins = durationMinutes % 60
        return "\(hours)h \(mins)m"
    }

    var isUpcoming: Bool {
        scheduledDeparture > Date()
    }

    var isPast: Bool {
        status == .landed || (actualArrival ?? scheduledArrival) < Date()
    }

    var route: String {
        "\(departureAirportCode) → \(arrivalAirportCode)"
    }

    var delayMinutes: Int? {
        guard let actual = actualDeparture else { return nil }
        let diff = Calendar.current.dateComponents([.minute], from: scheduledDeparture, to: actual)
        return diff.minute
    }

    init(
        id: UUID = UUID(),
        pnr: String? = nil,
        flightNumber: String,
        airlineCode: String,
        airlineName: String,
        departureAirportCode: String,
        departureAirportName: String,
        departureCity: String,
        arrivalAirportCode: String,
        arrivalAirportName: String,
        arrivalCity: String,
        scheduledDeparture: Date,
        scheduledArrival: Date,
        actualDeparture: Date? = nil,
        actualArrival: Date? = nil,
        status: FlightStatus = .scheduled,
        aircraftType: String? = nil,
        seatNumber: String? = nil,
        cabinClass: CabinClass = .economy,
        bookingReference: String? = nil,
        distanceKm: Double = 0,
        durationMinutes: Int = 0,
        departureTerminal: String? = nil,
        arrivalTerminal: String? = nil,
        departureGate: String? = nil,
        arrivalGate: String? = nil,
        notes: String? = nil,
        isManualEntry: Bool = false
    ) {
        self.id = id
        self.pnr = pnr
        self.flightNumber = flightNumber
        self.airlineCode = airlineCode
        self.airlineName = airlineName
        self.departureAirportCode = departureAirportCode
        self.departureAirportName = departureAirportName
        self.departureCity = departureCity
        self.arrivalAirportCode = arrivalAirportCode
        self.arrivalAirportName = arrivalAirportName
        self.arrivalCity = arrivalCity
        self.scheduledDeparture = scheduledDeparture
        self.scheduledArrival = scheduledArrival
        self.actualDeparture = actualDeparture
        self.actualArrival = actualArrival
        self.statusRaw = status.rawValue
        self.aircraftType = aircraftType
        self.seatNumber = seatNumber
        self.cabinClassRaw = cabinClass.rawValue
        self.bookingReference = bookingReference
        self.distanceKm = distanceKm
        self.durationMinutes = durationMinutes
        self.departureTerminal = departureTerminal
        self.arrivalTerminal = arrivalTerminal
        self.departureGate = departureGate
        self.arrivalGate = arrivalGate
        self.notes = notes
        self.isManualEntry = isManualEntry
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
