import SwiftUI

struct SaveScoreView: View {
	@ObservedObject var scoreViewModel: ScoreViewModel
	@State private var score = 0
	@State private var distance = 0
	@State private var difficulty = "Easy"
	@State private var timeAlive = 0.0

	var body: some View {
		VStack(spacing: 16) {
			Text("Score")
				.frame(maxWidth: .infinity, alignment: .leading)
			TextField("Score",
				value: $score,
				formatter: NumberFormatter()
			)

			Text("Distance")
				.frame(maxWidth: .infinity, alignment: .leading)
			TextField("Distance",
				value: $distance,
				formatter: NumberFormatter()
			)

			Text("Difficulty")
				.frame(maxWidth: .infinity, alignment: .leading)
			TextField("Difficulty",
				text: $difficulty
			)

			Text("Time Alive")
				.frame(maxWidth: .infinity, alignment: .leading)
			TextField("Time Alive",
				value: $timeAlive,
				formatter: NumberFormatter()
			)
			
			Button("Save Score") {
				let entry = ScoreEntry(
					score: score,
					distance: distance,
					difficulty: difficulty,
					timeAlive: timeAlive,
					userId: scoreViewModel.user?.uid ?? "",
					email: ""
				)
				scoreViewModel.saveScore(scoreEntry: entry)
			}
		}
		.padding()
	}
}

#Preview {
	let mockViewModel = ScoreViewModel()
	SaveScoreView(scoreViewModel: mockViewModel)
}


