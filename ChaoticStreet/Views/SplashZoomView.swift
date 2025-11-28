/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author:
	Bui Minh Duc, S4070921
  Created date: 19/08/2025
  Last modified: 03/09/2025
  Acknowledgement: See README
 
  Transition between SplashView and MenuView. The RMIT pixel logo acts as
  the window that is quickly zoomed in to reveal the main menu.
*/

import SwiftUI

struct SplashZoomView<Content: View>: View {
	@ViewBuilder var content: Content
	// Boolean @State variable as timeout to do the zoom-in transition
	@State private var reveal = false
	// Boolean @State variable as timeout to remove the overlay
	@State private var finished = false
	
	var body: some View {
		if finished {
			// MARK: - Remove the overlay from blocking the content
			content
		} else {
			// MARK: - Display the overlay on top of content
			content
				.overlay {
					ZStack {
						// Black background
						Color.black
							.ignoresSafeArea()
						
						// RMIT pixel as the silhouette
						Image("rmit-pixel")
							.resizable()
							.scaledToFit()
							.frame(width: 100, height: 100)
							.scaleEffect(reveal ? 25 : 1)
							.blendMode(.destinationOut) // Reverse mask
					}
					.compositingGroup()
					.onAppear {
						// Reveal the new view in 1s, after 1s
						DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
							withAnimation(.easeOut(duration: 1.0)) {
								reveal = true
							}
						}
						
						// Remove the overlay after 2.5s
						DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
							finished = true
						}
					}
				}
		}
	}
}
