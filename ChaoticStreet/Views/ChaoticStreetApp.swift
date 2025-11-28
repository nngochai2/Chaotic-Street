/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author:
	Nguyen Danh Bao, S3978319
	Bui Minh Duc, S4070921
	Nguyen Ngoc Hai, S3978281
	Nguyen Tuan Minh Khoi, S3995060
	Nguyen Huy Hoang, S4041847
  Created date: 19/08/2025
  Last modified: 03/09/2025
  Acknowledgement: See README

  Base parent view for Chaotic Street.
*/

import SwiftUI
import FirebaseCore

@main
struct ChaoticStreetApp: App {
	// Boolean @State variable to control the appearance of the splash screen.
	@State private var showSplash: Bool = true
	@StateObject private var user = UserViewModel()
	@AppStorage("language") private var language: String = "en"
	@AppStorage("theme") private var theme: String = "system" // "light", "dark", "system"
	@StateObject private var engine = GameEngine()
	
	init() {
		FirebaseApp.configure()
		Bundle.setLanguage(language)
	}

    var body: some Scene {
		WindowGroup {
			ZStack {
				// Display a splash screen before the main menu appears.
				// If showSplash is false, go directly to the main menu. Else show SplashView and
				// change the boolean value after 3s.
				if showSplash {
					SplashView()
						.onAppear {
							DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
								withAnimation(.easeInOut(duration: 0.5)) {
									self.showSplash = false
								}
							}
						}
				} else {
					SplashZoomView {
						GameView()
							.environmentObject(user)
					}
				}
			}
		}
    }
}
