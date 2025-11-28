/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author:
	Bui Minh Duc, S4070921
  Created date: 22/08/2025
  Last modified: 16/09/2025
  Acknowledgement: See README
*/

import SwiftUI

struct MenuView: View {
	@State var showSettings: Bool = false
	@State var showInstructions: Bool = false
	@State var showLeaderboard: Bool = false
	@EnvironmentObject var user: UserViewModel
	@EnvironmentObject var engine: GameEngine
	@StateObject private var scoreViewModel = ScoreViewModel()
	
	var body: some View {
		ZStack {
			GameView()
				.environmentObject(engine)
			
			if engine.gameState != .playing {
				VStack {
					HStack {
						Button(action: { showLeaderboard.toggle() }) {
							Image(systemName: "chart.bar.xaxis")
								.resizable()
								.frame(width: 28, height: 28)
						}
						.sheet(isPresented: $showLeaderboard) {
							FetchLeaderboardView(scoreViewModel: scoreViewModel, showLeaderboard: $showLeaderboard)
						}
						.accessibilityLabel(Text("leaderboard.title"))
						.padding([.top, .leading], 12)
						
						Spacer()
						
						Button(action: { showInstructions.toggle() }) {
							Image(systemName: "questionmark.circle")
								.resizable()
								.frame(width: 28, height: 28)
						}
						.accessibilityLabel(Text("instructions.title"))
						.padding([.top, .trailing], 12)
						
						Button(action: { showSettings.toggle() }) {
							Image(systemName: "gearshape")
								.resizable()
								.frame(width: 28, height: 28)
						}
						.sheet(isPresented: $showSettings) {
							SettingsView(showSettings: $showSettings)
						}
						.accessibilityLabel(Text("settings"))
						.padding([.top, .trailing], 12)
					}
					
					Spacer()
				}
			}
			
			Dialog(isPresented: $showInstructions) {
				GameInstructionView()
			}
		}
	}
}

#Preview {
	MenuView()
		.environmentObject(UserViewModel())
		.environmentObject(GameEngine())
}
