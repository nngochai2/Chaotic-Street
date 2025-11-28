/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author:
	Nguyen Danh Bao, S3978319
	Bui Minh Duc, S4070921
  Created date: 09/09/2025
  Last modified: 09/09/2025
  Acknowledgement: See README
 
  Display a view on top of another view.
*/

import SwiftUI

struct Dialog<Content: View>: View {
	@Binding var isPresented: Bool
	let content: Content
	
	// Inherit the isPresented state and the context view of the object calling this view
	init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
		self._isPresented = isPresented
		self.content = content()
	}
	
	var body: some View {
		if isPresented {
			ZStack {
				// Semi-transparent black background. Close the overlay if user presses on it.
				Color.black.opacity(0.5)
					.ignoresSafeArea()
					.onTapGesture { isPresented = false }
				
				content
				
				// Button to close the overlay
				VStack {
					HStack {
						Spacer()
						
						Button(action: { isPresented = false }) {
							Image(systemName: "xmark.circle.fill")
								.foregroundStyle(.white)
								.font(.system(size: 28))
								.padding(16)
						}
					}
					
					Spacer()
				}
			}
			.animation(.easeInOut, value: isPresented)
		}
	}
}
