/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author:    Nguyen Ngoc Hai, S3978281; Bui Minh Duc, S4070921
  Created date: 01/09/2025
  Last modified: 16/09/2025
  Acknowledgement: Complete GameView with Settings and Leaderboard navigation
*/

import SwiftUI

struct GameView: View {
  
    @StateObject private var gameEngine = GameEngine()
    @StateObject private var scoreViewModel = ScoreViewModel()
    @EnvironmentObject var user: UserViewModel
    
    @State private var showPauseMenu = false
    @State private var showGameOverScreen = false
    @State private var showSettings = false
    @State private var showLeaderboard = false
    @State private var showInstructions = false
    @State private var showLesson = false
    @State private var lessonMessage = ""
    @State private var screenSize: CGSize = .zero
    @State private var cameraOffset: CGFloat = 0
    @State private var highScore: Int = UserDefaults.standard.integer(forKey: "highScore")
    @State private var selectedDifficulty: DifficultyLevel = .medium
    @Environment(\.locale) var locale

    private let visibleBehind: Int = 4
    private var visibleAhead: Int {
        GameConstants.visibleRows - visibleBehind // Use total visible rows minus behind
    }
    private let laneHeight = GameConstants.laneHeight
    
    // MARK: - Helper Method
    private func loadSelectedDifficulty() {
        let difficultyInt = UserDefaults.standard.integer(forKey: "difficulty")
        switch difficultyInt {
        case 0:
            selectedDifficulty = .easy
        case 1:
            selectedDifficulty = .medium
        case 2:
            selectedDifficulty = .hard
        default:
            selectedDifficulty = .medium
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with Vietnamese-inspired gradient
                LinearGradient(
                    gradient: Gradient(colors: [.green.opacity(0.4), .yellow.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Main game world
                gameWorld
                    .offset(y: cameraOffset)
                
                // UI Overlay
                if gameEngine.gameState == .playing || gameEngine.gameState == .paused {
                    gameUI
                }
            }
            .onAppear {
                gameEngine.scoreViewModel = scoreViewModel
                screenSize = geometry.size
                GameConstants.updateScreenDimensions(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                initializeGameState()
            }
            .onChange(of: gameEngine.gameState) { newState in
                handleGameStateChange(newState)
            }
            .onChange(of: gameEngine.score) { newScore in
                updateHighScore(newScore)
            }
            .simultaneousGesture(
                swipeGesture
            )
            // Present overlays as modals with navigation
            .fullScreenCover(isPresented: $showGameOverScreen) {
                GameOverPopup(
                    isPresented: $showGameOverScreen,
                    score: gameEngine.score,
                    highScore: highScore,
                    distance: gameEngine.player.gridPosition.y,
                    onRestart: restartGame,
                    onQuit: quitToMenu,
                    onShowLeaderboard: { showLeaderboard = true },
                    onShowSettings: { showSettings = true },
                    onShowInstructions: { showInstructions = true }
                )
            }
            .fullScreenCover(isPresented: $showPauseMenu) {
                PausePopup(
                    isPresented: $showPauseMenu,
                    onResume: resumeGame,
                    onRestart: restartGame,
                    onQuit: quitToMenu,
                    onShowLeaderboard: { showLeaderboard = true },
                    onShowSettings: { showSettings = true },
                    onShowInstructions: { showInstructions = true }
                )
            }
            .fullScreenCover(isPresented: Binding(
                get: { gameEngine.gameState == .menu },
                set: { if !$0 { gameEngine.gameState = .playing } }
            )) {
                MenuPopup(
                    isPresented: Binding(
                        get: { gameEngine.gameState == .menu },
                        set: { if !$0 { gameEngine.gameState = .playing } }
                    ),
                    onStart: startGame,
                    onShowLeaderboard: { showLeaderboard = true },
                    onShowSettings: { showSettings = true },
                    onShowInstructions: { showInstructions = true }
                )
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView(showSettings: $showSettings)
                    .environmentObject(user)
            }
            .fullScreenCover(isPresented: $showLeaderboard) {
                FetchLeaderboardView(scoreViewModel: scoreViewModel, showLeaderboard: $showLeaderboard)
            }
            .fullScreenCover(isPresented: $showInstructions) {
                NavigationView {
                    GameInstructionView()
                        .navigationTitle("How to Play")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showInstructions = false
                                }
                                .foregroundColor(.blue)
                            }
                        }
                }
            }
            .onChange(of: showSettings) { isShowing in
                if !isShowing { resetToMenu() }
            }

            .onChange(of: showSettings) { isShowing in
                if !isShowing {
                    // Reset to menu when settings is dismissed
                    resetToMenu()
                }
            }
            .onChange(of: showLeaderboard) { isShowing in
                if !isShowing {
                    // Reset to menu when leaderboard is dismissed
                    resetToMenu()
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Game World
    private var gameWorld: some View {
        ZStack {
            // Lanes in reversed order for bird's eye view
            VStack(spacing: 0) {
                ForEach(visibleLanes.reversed(), id: \.index) { lane in
                    SimpleLaneView(lane: lane)
                        .frame(height: laneHeight)
                }
            }

            // Vehicles with relative Y positioning, filtered to visible lanes only
            ForEach(gameEngine.vehicles.filter { $0.lane >= minVisibleLane && $0.lane <= maxVisibleLane }) { vehicle in
                SimpleVehicleView(vehicle: vehicle)
                    .position(x: vehicle.position.x, y: relativeY(for: vehicle.lane))
            }

            // Player with relative Y positioning
            SimplePlayerView(player: gameEngine.player)
                .position(x: playerXPosition, y: relativeY(for: gameEngine.player.gridPosition.y))
                .animation(.easeOut(duration: GameConstants.fastAnimationDuration), value: gameEngine.player.gridPosition)
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    if gameEngine.gameState == .playing {
                        gameEngine.movePlayerForward()
                        updateCameraPosition(for: gameEngine.player.gridPosition.y)
                        print("Tapped to move forward to y: \(gameEngine.player.gridPosition.y)")
                    }
                }
        )
    }

    // MARK: - Relative Y Calculation
    private func relativeY(for laneIndex: Int) -> CGFloat {
        let playerY = gameEngine.player.gridPosition.y
        let minLane = max(0, playerY - visibleBehind)
        let maxLane = minLane + visibleBehind + visibleAhead
        let relativeRow = maxLane - laneIndex
        return CGFloat(relativeRow) * laneHeight + laneHeight / 2
    }

    private var playerXPosition: CGFloat {
        CGFloat(gameEngine.player.gridPosition.x) * GameConstants.gridSize + GameConstants.gridSize / 2
    }

    // MARK: - Visible Lanes Calculation
    private var visibleLanes: [Lane] {
        let playerY = gameEngine.player.gridPosition.y
        let minLane = max(0, playerY - visibleBehind)
        let maxLane = minLane + visibleBehind + visibleAhead
        return (minLane...maxLane).map { Lane(index: $0) }
    }

    private var minVisibleLane: Int {
        max(0, gameEngine.player.gridPosition.y - visibleBehind)
    }

    private var maxVisibleLane: Int {
        minVisibleLane + visibleBehind + visibleAhead
    }

    // MARK: - Camera Positioning
    private func updateCameraPosition(for playerY: Int) {
        let targetLaneY = relativeY(for: playerY)
        let desiredPlayerScreenY = screenSize.height * 0.66
        let offset = targetLaneY - desiredPlayerScreenY
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            cameraOffset = -offset
        }
    }

    // MARK: - Game UI
    private var gameUI: some View {
        VStack {
            HStack(spacing: 15) {
                // Score Display
                VStack(spacing: 4) {
                    Text("game.score")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(gameEngine.score)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)

                // High Score
                VStack(spacing: 4) {
                    Text("game.highScore")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(highScore)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)

                // Difficulty Display
                VStack(spacing: 4) {
                    Text("game.difficultyLevel")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(selectedDifficulty.vietnameseName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(gameEngine.currentDifficulty.color)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)

                Spacer()

                // Pause Button
                Button(action: pauseGame) {
                    Image(systemName: "pause.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.gray)
                        .clipShape(Circle())
                }
            }
            .padding()

            Spacer()
        }
    }

    // MARK: - Gesture
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height

                if abs(horizontal) > abs(vertical) {
                    if horizontal > 0 {
                        gameEngine.movePlayerRight()
                    } else {
                        gameEngine.movePlayerLeft()
                    }
                } else {
                    if vertical > 0 {
                        gameEngine.movePlayerBackward()
                    } else {
                        gameEngine.movePlayerForward()
                        updateCameraPosition(for: gameEngine.player.gridPosition.y)
                    }
                }
            }
    }

    // MARK: - Game Lifecycle Methods
    private func initializeGameState() {
        loadSelectedDifficulty()
        updateCameraPosition(for: gameEngine.player.gridPosition.y)
        print("Game initialized at \(Date()) with screen size: \(screenSize)")
    }

    private func startGame() {
        showPauseMenu = false
        showGameOverScreen = false
        cameraOffset = 0
        loadSelectedDifficulty()
        gameEngine.resetGame()
        gameEngine.startGame()
        updateCameraPosition(for: gameEngine.player.gridPosition.y)
        print("Game started at \(Date()), state: \(gameEngine.gameState)")
    }

    private func pauseGame() {
        gameEngine.pauseGame()
        showPauseMenu = true
        print("Game paused at \(Date()), state: \(gameEngine.gameState)")
    }

    private func resumeGame() {
        showPauseMenu = false
        gameEngine.resumeGame()
        print("Game resumed at \(Date()), state: \(gameEngine.gameState)")
    }

    private func restartGame() {
        print("restartGame() called at \(Date())") // Debug start
        showPauseMenu = false
        showGameOverScreen = false
        cameraOffset = 0
        DispatchQueue.main.async {
            self.gameEngine.vehicles.removeAll() // Redundant but ensures cleanup
            self.gameEngine.laneManager.cleanup()
            self.gameEngine.startGame()
            self.updateCameraPosition(for: self.gameEngine.player.gridPosition.y)
            print("Game restarted at \(Date()), state: \(self.gameEngine.gameState), playerY: \(self.gameEngine.player.gridPosition.y)") // Debug end
        }
    }

    private func quitToMenu() {
        showPauseMenu = false
        showGameOverScreen = false
        cameraOffset = 0
        gameEngine.vehicles.removeAll()
        gameEngine.laneManager.cleanup()
        gameEngine.resetGame()
        gameEngine.gameState = .menu
        updateCameraPosition(for: gameEngine.player.gridPosition.y)
        print("Returned to menu at \(Date()), state: \(gameEngine.gameState)")
    }
    
    private func resetToMenu() {
        // Clean reset when returning from Settings/Leaderboard
        DispatchQueue.main.async {
            self.showPauseMenu = false
            self.showGameOverScreen = false
            self.showSettings = false
            self.showLeaderboard = false
            self.cameraOffset = 0
            self.gameEngine.vehicles.removeAll()
            self.gameEngine.laneManager.cleanup()
            self.gameEngine.resetGame()
            self.gameEngine.gameState = .menu
            self.updateCameraPosition(for: self.gameEngine.player.gridPosition.y)
            print("Reset to menu from external view at \(Date())")
        }
    }

    private func handleGameStateChange(_ newState: GameState) {
        print("State changed to \(newState) at \(Date())") // Debug
        switch newState {
        case .gameOver:
            showGameOverScreen = true
            showPauseMenu = false
        case .paused:
            showPauseMenu = true
            showGameOverScreen = false
        case .playing:
            showPauseMenu = false
            showGameOverScreen = false
            // Force camera update if restarting
            updateCameraPosition(for: gameEngine.player.gridPosition.y)
        case .menu:
            showPauseMenu = false
            showGameOverScreen = false
            cameraOffset = 0
            showLesson = false
            updateCameraPosition(for: gameEngine.player.gridPosition.y)

        default:
            break
        }
    }
    
    private func updateHighScore(_ newScore: Int) {
        if newScore > highScore {
            highScore = newScore
            UserDefaults.standard.set(highScore, forKey: "highScore")
            print("New high score: \(highScore) at \(Date())")
        }
    }
    
    private var randomLesson: String {
        LessonManager.shared.randomLesson(for: locale.identifier.hasPrefix("vi") ? "vi" : "en")
    }
}

// MARK: - Improved Menu Popup
struct MenuPopup: View {
    @Binding var isPresented: Bool
    let onStart: () -> Void
    let onShowLeaderboard: () -> Void
    let onShowSettings: () -> Void
    let onShowInstructions: () -> Void

    var body: some View {
        ZStack {
            // Blurred background
            Color.white.opacity(1)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)

            VStack(spacing: 24) {
                // Header section
                VStack(spacing: 12) {
                    HStack {
                        Spacer()
                        Button(action: {
                            onShowInstructions()
                            isPresented = false
                        }) {
                            Image(systemName: "questionmark.circle")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 0)
                    
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.3), radius: 10)
                    
                    Text("Chaotic Street")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2)
                    
                    Text("Navigate Vietnamese traffic safely!")
                        .font(.headline)
                        .foregroundColor(.yellow.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Buttons section with consistent sizing
                VStack(spacing: 16) {
                    Button("Start") {
                        onStart()
                        isPresented = false
                    }
                    .buttonStyle(PrimaryGameButtonStyle())
                    
                    HStack(spacing: 12) {
                        Button("Leaderboard") {
                            onShowLeaderboard()
                            isPresented = false
                        }
                        .buttonStyle(SecondaryGameButtonStyle())
                        
                        Button("Settings") {
                            onShowSettings()
                            isPresented = false
                        }
                        .buttonStyle(SecondaryGameButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: 300)
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.black.opacity(0.8))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
        }
    }
}

// MARK: - Improved Pause Popup
struct PausePopup: View {
    @Binding var isPresented: Bool
    let onResume: () -> Void
    let onRestart: () -> Void
    let onQuit: () -> Void
    let onShowLeaderboard: () -> Void
    let onShowSettings: () -> Void
    let onShowInstructions: () -> Void
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.7)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)

            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Spacer()
                        Button(action: {
                            onShowInstructions()
                            isPresented = false
                        }) {
                            Image(systemName: "questionmark.circle")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 0)
                    
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                        .shadow(color: .orange.opacity(0.3), radius: 10)
                    
                    Text("Game Paused")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Main action buttons
                VStack(spacing: 16) {
                    Button("Resume Game") {
                        onResume()
                        isPresented = false
                    }
                    .buttonStyle(PrimaryGameButtonStyle())
                    
                    Button("Restart Game") {
                        onRestart()
                        isPresented = false
                    }
                    .buttonStyle(WarningGameButtonStyle())
                }
                
                // Secondary actions
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button("Leaderboard") {
                            onShowLeaderboard()
                            isPresented = false
                        }
                        .buttonStyle(SecondaryGameButtonStyle())
                        
                        Button("Settings") {
                            onShowSettings()
                            isPresented = false
                        }
                        .buttonStyle(SecondaryGameButtonStyle())
                    }
                    
                    Button("Exit to Menu") {
                        onQuit()
                        isPresented = false
                    }
                    .buttonStyle(DangerGameButtonStyle())
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: 300)
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.black.opacity(0.8))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
        }
    }
}

// MARK: - Simplified Game Over Popup
struct GameOverPopup: View {
    @Binding var isPresented: Bool
    let score: Int
    let highScore: Int
    let distance: Int
    let onRestart: () -> Void
    let onQuit: () -> Void
    let onShowLeaderboard: () -> Void
    let onShowSettings: () -> Void
    let onShowInstructions: () -> Void
    @Environment(\.locale) var locale

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                
                HStack {
                    Spacer()
                    Button(action: {
                        onShowInstructions()
                        isPresented = false
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 0)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Game Over")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                Text(randomLesson)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Score section - simplified
                scoreSection
                
                // Buttons
                buttonSection
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    private var scoreSection: some View {
        VStack(spacing: 8) {
            Text("Final Score: \(score)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack {
                Text("Best: \(highScore)")
                    .foregroundColor(.yellow)
                
                Spacer()
                
                Text("Distance: \(distance)m")
                    .foregroundColor(.blue)
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color.black.opacity(0.4))
        .cornerRadius(12)
    }
    
    private var buttonSection: some View {
        VStack(spacing: 15) {
            Button("Play Again") {
                onRestart()
                isPresented = false
            }
            .buttonStyle(PrimaryGameButtonStyle())
            
            HStack(spacing: 12) {
                Button("Leaderboard") {
                    onShowLeaderboard()
                    isPresented = false
                }
                .buttonStyle(SecondaryGameButtonStyle())
                
                Button("Settings") {
                    onShowSettings()
                    isPresented = false
                }
                .buttonStyle(SecondaryGameButtonStyle())
            }
            
            Button("Back to Menu") {
                onQuit()
                isPresented = false
            }
            .buttonStyle(DangerGameButtonStyle())
        }
    }
    
    private var randomLesson: String {
        LessonManager.shared.randomLesson(for: locale.identifier.hasPrefix("vi") ? "vi" : "en")
    }
}

// MARK: - Simple Lane View
struct SimpleLaneView: View {
    let lane: Lane
    @State private var crossingIndices: Set<Int> = []

    var body: some View {
        ZStack {
            if lane.laneType == .traffic {
                HStack(spacing: 0) {
                    ForEach(0..<GameConstants.tilesPerRow, id: \.self) { index in
                        Image(crossingIndices.contains(index) ? "road_crossing" : "road")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    generateVerticalColumnCrossings()
                }
            } else {
                Rectangle()
                    .fill(Color(red: 0.8, green: 0.85, blue: 0.8))

                HStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.8))
                        .frame(width: 8, height: 8)
                        .padding(.leading, 10)
                    Spacer()
                    Circle()
                        .fill(Color.yellow.opacity(0.8))
                        .frame(width: 8, height: 8)
                        .padding(.trailing, 10)
                }
            }
        }
    }

    private func generateVerticalColumnCrossings() {
        crossingIndices.removeAll()
        let numColumns = GameConstants.tilesPerRow
        let patternIndex = (lane.index / 10) % 3
        let laneInPattern = lane.index % 10
        
        switch patternIndex {
        case 0:
            if laneInPattern >= 2 && laneInPattern <= 5 {
                crossingIndices.insert(1)
                crossingIndices.insert(numColumns / 2)
            }
        case 1:
            if laneInPattern >= 1 && laneInPattern <= 3 {
                crossingIndices.insert(0)
            }
            if laneInPattern >= 4 && laneInPattern <= 6 {
                crossingIndices.insert(2)
            }
            if laneInPattern >= 7 && laneInPattern <= 9 {
                crossingIndices.insert(numColumns - 1)
            }
        case 2:
            if laneInPattern >= 2 && laneInPattern <= 4 {
                crossingIndices.insert(3)
            }
            if laneInPattern >= 6 && laneInPattern <= 8 {
                crossingIndices.insert(5)
            }
        default:
            break
        }
    }
}

struct SimpleVehicleView: View {
    let vehicle: Vehicle

    var body: some View {
        Image(vehicleImageName)
            .resizable()
            .scaledToFit()
            .frame(width: vehicle.size.width, height: vehicle.size.height)
            .rotationEffect(.degrees(rotationAngle))
    }

    private var vehicleImageName: String {
        switch vehicle.type {
        case .motorbike: return "motorbike"
        case .car: return "car1"
        case .bus: return "bus"
        case .cyclo: return "cyclo"
        }
    }

    private var rotationAngle: Double {
        let baseRotation: Double = 90
        switch vehicle.direction {
        case .leftToRight: return baseRotation + 180
        case .rightToLeft: return baseRotation
        }
    }
}

// MARK: - Simple Player View
struct SimplePlayerView: View {
    let player: Player

    var body: some View {
        Image("player")
            .resizable()
            .scaledToFit()
            .frame(width: GameConstants.playerWidth, height: GameConstants.playerHeight)
            .rotationEffect(.degrees(0))
    }
}

// MARK: - Button Styles
struct VietnameseButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct CompactVietnameseButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Improved Button Styles

struct WarningGameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.orange.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DangerGameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.red.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .red.opacity(0.2), radius: 4, x: 0, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(UserViewModel())
    }
}
