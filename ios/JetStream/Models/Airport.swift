import Foundation

struct Airport: Codable, Identifiable, Hashable {
    let iataCode: String
    let icaoCode: String?
    let name: String
    let city: String
    let country: String
    let latitude: Double?
    let longitude: Double?
    let timezone: String?

    var id: String { iataCode }
}
