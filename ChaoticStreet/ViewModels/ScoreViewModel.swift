import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ScoreViewModel: ObservableObject {
    @Published var user: AppUser? = nil
    @Published var achievements: [Achievement] = []
    @Published var isLoading: Bool = false

    func saveScore(scoreEntry: ScoreEntry) {
        guard let user = user else { return }
        let db = Firestore.firestore()
        let scoreData: [String: Any] = [
            "score": scoreEntry.score,
            "distance": scoreEntry.distance,
            "difficulty": scoreEntry.difficulty,
            "timeAlive": scoreEntry.timeAlive,
            "userId": user.uid,
            "timestamp": FieldValue.serverTimestamp()
        ]
        // Save only to global scores collection
        db.collection("scores").addDocument(data: scoreData)
        checkAndSaveAchievements(score: scoreEntry.score)
    }

    func fetchUserScores(completion: @escaping ([ScoreEntry]) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user logged in, cannot fetch user scores")
            completion([])
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("scores")
            .whereField("userId", isEqualTo: currentUser.uid)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                          
                var scoreEntries: [ScoreEntry] = []
                let group = DispatchGroup()
                for doc in docs {
                    let data = doc.data()
                    
                    guard let score = data["score"] as? Int,
                          let distance = data["distance"] as? Int,
                          let difficulty = data["difficulty"] as? String,
                          let timeAlive = data["timeAlive"] as? Double,
                          let userId = data["userId"] as? String else { continue }
                                        
                    group.enter()
                    self.fetchEmail(for: userId) { email in
                        let entry = ScoreEntry(score: score, distance: distance, difficulty: difficulty, timeAlive: timeAlive, userId: userId, email: email ?? "")
                        scoreEntries.append(entry)
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    completion(scoreEntries)
                }
            }
    }

    func fetchLeaderboard(completion: @escaping ([ScoreEntry]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("scores")
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }

                // Dictionary to store the highest score for each userId
                var highestScores: [String: ScoreEntry] = [:]

                // Iterate through each document to find the highest score for each user
                for doc in docs {
                    let data = doc.data()
                    guard let score = data["score"] as? Int,
                          let distance = data["distance"] as? Int,
                          let difficulty = data["difficulty"] as? String,
                          let timeAlive = data["timeAlive"] as? Double,
                          let userId = data["userId"] as? String else { continue }
                    
                    // Temporarily set email as empty
                    let scoreEntry = ScoreEntry(score: score, distance: distance, difficulty: difficulty, timeAlive: timeAlive, userId: userId, email: "")
                    
                    // Check if this score is higher than the previous highest score for this user
                    if let currentHighest = highestScores[userId] {
                        if score > currentHighest.score {
                            highestScores[userId] = scoreEntry
                        }
                    } else {
                        highestScores[userId] = scoreEntry
                    }
                }
                
                let leaderboard = Array(highestScores.values.sorted { $0.score > $1.score }.prefix(100))
                var leaderboardWithEmail: [ScoreEntry] = []

                let group = DispatchGroup()
                for entry in leaderboard {
                    group.enter()
                    self.fetchEmail(for: entry.userId) { email in
                        let updatedEntry = ScoreEntry(score: entry.score, distance: entry.distance, difficulty: entry.difficulty, timeAlive: entry.timeAlive, userId: entry.userId, email: email ?? "")
                        leaderboardWithEmail.append(updatedEntry)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(leaderboardWithEmail)
                }
            }
    }

    private func fetchEmail(for userId: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            let email = snapshot?.data()?["email"] as? String
            completion(email)
        }
    }

	let achievementMilestones: [(score: Int, id: String, name: String, description: String)] = [
        (1, "first_step", "First Step", "Play your first game!"),
        (100, "getting_started", "Getting Started", "Score 100 points."),
        (1000, "street_explorer", "Street Explorer", "Score 1000 points."),
        (5000, "urban_survivor", "Urban Survivor", "Score 5000 points."),
        (10000, "chaotic_legend", "Chaotic Legend", "Score 10000 points.")
    ]

    private func checkAndSaveAchievements(score: Int) {
       guard let user = user else {
           print("[Achievement] No user set, cannot save achievements.")
           return
       }
        let db = Firestore.firestore()
        for milestone in achievementMilestones {
            if score >= milestone.score {
                let achievementRef = db.collection("users")
                    .document(user.uid)
                    .collection("achievements")
                    .document(milestone.id)
                achievementRef.getDocument { snapshot, error in
                    if let error = error {
                        print("[Achievement] Error getting achievement document: \(error.localizedDescription)")
                        return
                    }
                    if !(snapshot?.exists ?? false) {
                        achievementRef.setData([
                            "milestoneId": milestone.id,
                            "achievedAt": FieldValue.serverTimestamp()
                        ]) { error in
                            if let error = error {
                                print("[Achievement] Error setting achievement data: \(error.localizedDescription)")
                            } else {
								print("[Achievement] Achievement \(milestone.id) saved for user \(Auth.auth().currentUser?.uid ?? "unknown")")
                            }
                        }
                    } else {
						print("[Achievement] Achievement \(milestone.id) already exists for user")
                    }
                }
            }
        }
    }

    func fetchAchievements() {
        guard let user = self.user else { return }
        isLoading = true
        let db = Firestore.firestore()
        db.collection("users")
            .document(user.uid)
            .collection("achievements")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                guard let docs = snapshot?.documents else {
                    self.achievements = []
                    return
                }
                self.achievements = docs.compactMap { doc in
                    let data = doc.data()
                    guard let milestoneId = data["milestoneId"] as? String,
                          let achievedAtTimestamp = data["achievedAt"] as? Timestamp else { return nil }
                    let achievedAt = achievedAtTimestamp.dateValue()
                    // Find milestone info from achievementMilestones
                    guard let milestone = self.achievementMilestones.first(where: { $0.id == milestoneId }) else { return nil }
                    return Achievement(milestoneId: milestoneId, name: milestone.name, description: milestone.description, achievedAt: achievedAt)
                }.sorted { $0.achievedAt < $1.achievedAt }
            }
    }
}
