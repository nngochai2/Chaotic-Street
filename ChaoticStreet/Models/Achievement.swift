import Foundation

struct Achievement: Codable, Identifiable {
    var id: String { milestoneId }
    let milestoneId: String
    let name: String
    let description: String
    let achievedAt: Date
}