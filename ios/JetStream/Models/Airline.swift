import Foundation

struct Airline: Codable, Identifiable, Hashable {
    let iataCode: String
    let icaoCode: String?
    let name: String
    let country: String?
    let logoUrl: String?
    let isActive: Bool?

    var id: String { iataCode }
}
