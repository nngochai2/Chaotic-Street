/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author:
	Bui Minh Duc, S4070921
  Created date: 03/09/2025
  Last modified: 03/09/2025
  Acknowledgement: See README
 
  Splash screen at app launch. The RMIT pixel is centered and the text below fades out
  after 2s so SplashZoomView can do the zoom-in transition and reveal the main menu.
*/

import SwiftUI

struct SplashView: View {
	// Boolean @State variable as timeout to fade out the text
	@State private var splashEnded: Bool = false
	
    var body: some View {
		ZStack {
			Color.black
				.ignoresSafeArea()
			
			Image("rmit-pixel")
				.resizable()
				.scaledToFit()
				.frame(width: 100, height: 100)
			
			Text("splash.subtitle")
				.font(.subheadline)
				.foregroundStyle(.white)
				.multilineTextAlignment(.center)
				.offset(y: 100)
				.opacity(splashEnded ? 0 : 1)
				.onAppear {
					DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
						withAnimation(.easeOut(duration: 0.5)) {
							self.splashEnded = true
						}
					}
				}
		}
    }
}

#Preview {
    SplashView()
}
