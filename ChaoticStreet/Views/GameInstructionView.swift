/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author:
	Nguyen Danh Bao, S3978319
	Bui Minh Duc, S4070921
  Created date: 22/08/2025
  Last modified: 09/09/2025
  Acknowledgement: See README
 
  Pop-up displaying the instructions on how to play the game.
*/

import SwiftUI

struct GameInstructionView: View {
    @State private var currentPage = 0
    @State private var isAnimating = false
    
	// MARK: - Content of the instruction pages
    let instructions = [
        InstructionPage(
            emoji: "👣",
			title: "instructions.title",
            backgroundColor: "colorLightGrey",
            content: .controls([
                ControlInstruction(action: "instructions.tap", description: "instructions.moveForward", icon: "👆"),
                ControlInstruction(action: "instructions.swipeLeft", description: "instructions.turnLeft", icon: "👈"),
                ControlInstruction(action: "instructions.swipeRight", description: "instructions.turnRight", icon: "👉"),
                ControlInstruction(action: "instructions.swipeDown", description: "instructions.moveBackward", icon: "👇")
            ])
        ),
        InstructionPage(
            emoji: "🚕",
            title: "instructions.caution",
            backgroundColor: "colorYellow",
            content: .text("instructions.caution.info")
        ),
        InstructionPage(
            emoji: "✨",
            title: "instructions.tip",
            backgroundColor: "colorLightBrown",
            content: .text("instructions.tip.info")
        )
    ]
    
	// MARK: - Main view
    var body: some View {
        VStack {            
            // Swipeable content
            TabView(selection: $currentPage) {
                ForEach(0..<instructions.count, id: \.self) { index in
                    InstructionPageView(instruction: instructions[index])
                        .tag(index)
                        .scaleEffect(isAnimating ? 0.95 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isAnimating)
                }
            }
			.frame(maxHeight: 450)
			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: currentPage) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    isAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isAnimating = false
                    }
                }
            }
			
			// Page indicator
			HStack(spacing: 8) {
				ForEach(0..<instructions.count, id: \.self) { index in
					Circle()
						.fill(index == currentPage ? Color("colorDarkBlue") : Color("colorLightGrey"))
						.frame(width: 6, height: 6)
						.scaleEffect(index == currentPage ? 1.2 : 1.0)
						.animation(.spring(response: 0.5, dampingFraction: 0.6), value: currentPage)
				}
			}
			.padding(.vertical, 8)
            
            // Navigation hints
            HStack {
                if currentPage > 0 {
                    Button(action: {
                        withAnimation(.spring()) {
                            currentPage -= 1
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("instructions.previousPage")
                        }
                        .foregroundColor(Color("colorDarkBlue"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color("colorLightGrey").opacity(0.3))
                        .cornerRadius(20)
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
                
                Spacer()
                
                if currentPage < instructions.count - 1 {
                    Button(action: {
                        withAnimation(.spring()) {
                            currentPage += 1
                        }
                    }) {
                        HStack {
                            Text("instructions.nextPage")
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(Color("colorDarkBlue"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color("colorLightGrey").opacity(0.3))
                        .cornerRadius(20)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
                isAnimating = false
            }
        }
    }
}

struct InstructionPage {
    let emoji: String
    let title: LocalizedStringKey
    let backgroundColor: String
    let content: InstructionContent
}

enum InstructionContent {
    case controls([ControlInstruction])
    case text(LocalizedStringKey)
}

struct ControlInstruction {
    let action: String
    let description: LocalizedStringKey
    let icon: String
}

struct InstructionPageView: View {
    let instruction: InstructionPage
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with emoji and title
            VStack(spacing: 12) {
                Text(instruction.emoji)
                    .font(.system(size: 60))
                    .scaleEffect(isVisible ? 1.0 : 0.5)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1), value: isVisible)
                
                Text(instruction.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("colorDarkRed"))
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.6).delay(0.3), value: isVisible)
            }
            
            // Content
            switch instruction.content {
            case .controls(let controls):
                VStack(spacing: 16) {
                    ForEach(Array(controls.enumerated()), id: \.offset) { index, control in
                        AnimatedControlRow(control: control, delay: Double(index) * 0.1)
                            .opacity(isVisible ? 1.0 : 0.0)
                            .offset(x: isVisible ? 0 : 30)
                            .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.5 + Double(index) * 0.1), value: isVisible)
                    }
                }
                
            case .text(let text):
                Text(text)
                    .font(.body)
                    .foregroundColor(Color("colorDarkBlue"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .offset(y: isVisible ? 0 : 20)
                    .animation(.easeInOut(duration: 0.8).delay(0.5), value: isVisible)
            }
        }
        .padding(24)
        .background(Color(instruction.backgroundColor))
        .cornerRadius(20)
        .padding(.horizontal)
        .shadow(color: Color("colorDarkBlue").opacity(0.1), radius: 10, x: 0, y: 5)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
}

struct AnimatedControlRow: View {
    let control: ControlInstruction
    let delay: Double
    @State private var isHighlighted = false
    
    var body: some View {
        HStack(spacing: 16) {
            Text(control.icon)
                .font(.title2)
                .frame(width: 30)
                .scaleEffect(isHighlighted ? 1.2 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHighlighted)
            
			Text(LocalizedStringKey(control.action))
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(Color("colorDarkBlue"))
                .frame(width: 100, alignment: .leading)
            
            Text("→")
                .font(.body)
                .foregroundColor(Color("colorRed"))
                .scaleEffect(isHighlighted ? 1.3 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isHighlighted)
            
            Text(control.description)
                .font(.body)
                .foregroundColor(Color("colorDarkRed"))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
		.background(Color.white.opacity(0.6))
        .cornerRadius(12)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isHighlighted = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    isHighlighted = false
                }
            }
        }
    }
}

#Preview {
	GameInstructionView()
}
