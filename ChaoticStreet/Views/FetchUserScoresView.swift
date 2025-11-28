import SwiftUI
import Charts

struct FetchUserScoresView: View {
    @ObservedObject var scoreViewModel: ScoreViewModel
    @State private var userScores: [ScoreEntry] = []
    @State private var userId = "41TvdnKQ4ubnNRFMqSwuTISn4H72"

    var body: some View {
        VStack(spacing: 16) {
            Text("User ID")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("User ID", text: $userId)

            UserScoresBarChartView(userScores: userScores)

            Button("User Scores") {
                scoreViewModel.fetchUserScores() { scores in
                    userScores = scores
                }
            }
            List(userScores, id: \.self) { entry in
                VStack(alignment: .leading) {
                    Text("Score: \(entry.score)")
                    Text("Distance: \(entry.distance)")
                    Text("Difficulty: \(entry.difficulty)")
                    Text("Time Alive: \(entry.timeAlive)")
                    Text("User ID: \(entry.userId)")
                    Text("Email: \(entry.email)")
                }
            }
        }
        .padding()
    }
}

struct UserScoresBarChartView: View {
    var userScores: [ScoreEntry]

    var body: some View {
        Chart {
            ForEach(userScores.prefix(20).enumerated().map({ $0 }), id: \.offset) { index, entry in
                BarMark(
                    x: .value("Run", index + 1),
                    y: .value("Score", entry.score)
                )
                .foregroundStyle(Color.blue)
            }
        }
        .frame(height: 250)
        .padding()
        .chartXAxisLabel("Run")
        .chartYAxisLabel("Score")
    }
}

#Preview {
    let mockViewModel = ScoreViewModel()
    FetchUserScoresView(scoreViewModel: mockViewModel)
}

