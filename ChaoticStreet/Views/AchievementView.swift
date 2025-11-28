import SwiftUI
import FirebaseFirestore

struct AchievementView: View {
    @ObservedObject var scoreViewModel: ScoreViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Achievements")
                .font(.title)
                .bold()
            if scoreViewModel.isLoading {
                ProgressView()
            } else {
                List(scoreViewModel.achievementMilestones, id: \ .id) { milestone in
                    let unlocked = scoreViewModel.achievements.contains(where: { $0.milestoneId == milestone.id })
                    let achievement = scoreViewModel.achievements.first(where: { $0.milestoneId == milestone.id })
                    VStack(alignment: .leading) {
                        Group {
                            Text(milestone.name)
                                .font(.headline)
                            if let achievement = achievement {
                                Text("Achieved at: \(achievement.achievedAt.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            } else {
                                Text("Achieved at: ---")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .blur(radius: unlocked ? 0 : 8)
                        Text(milestone.description)
                            .font(.subheadline)
                    }
                }
            }
            Button("Fetch Achievements") {
                scoreViewModel.fetchAchievements()
            }
        }
        .padding()
        .onAppear {
            scoreViewModel.fetchAchievements()
        }
    }
}

#Preview {
    AchievementView(scoreViewModel: ScoreViewModel())
}
