import Foundation
import FirebaseAuth

struct ScoreEntry: Hashable, Codable {
    let score: Int
    let distance: Int
    let difficulty: String
    let timeAlive: TimeInterval
	let userId: String
	let email: String

    init(score: Int, distance: Int, difficulty: String, timeAlive: TimeInterval, userId: String, email: String) {
        self.score = score
        self.distance = distance
        self.difficulty = difficulty
        self.timeAlive = timeAlive
		self.userId = userId
		self.email = email
    }
}
