/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author:
	Nguyen Ngoc Hai, S3978281
  Created date: 19/08/2025
  Last modified: 16/09/2025
  Acknowledgement: See README
 
  Functions for controlling the game state, player movement, vehicle spawning, collision detection and scoring.
  Game Engine with optimized vehicle updates and lane generation for smoother gameplay.
*/

import SwiftUI
import Combine
import AVFoundation

class GameEngine: ObservableObject {
    @Published var gameState: GameState = .menu
    @Published var player: Player = Player()
    @Published var vehicles: [Vehicle] = []
    @Published var score: Int = 0
    @Published var isGameRunning: Bool = false
    @Published var currentDifficulty: DifficultyLevel = .easy
    @Published var progressPercentage: Double = 0.0
    @Published var currentTrafficScenario: String = "Starting Position"
	@Published var maxReachedY: Int = 0 // Added for score fix
	
	// MARK: - Background and sound volume control (synced from SettingsView)
	@AppStorage("bgVolume") var backgroundVolume: Double = 0.3
	@AppStorage("sfxVolume") var soundEffectsVolume: Double = 0.8

    // MARK: - Private Properties
    private var gameTimer: AnyCancellable?
    private var vehicleSpawnTimer: AnyCancellable?
    private var startTime: Date?
    private var lastUpdateTime: Date = Date() // For smooth vehicle updates
    
    private let settingsSpeedMultiplier: CGFloat
    
    // Audio players
    private var audioPlayer: AVAudioPlayer?
    private var soundPlayers: [String: AVAudioPlayer] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    // Endless lane system
    @Published var laneManager = EndlessLaneManager()
    
    // ScoreViewModel integration
    var scoreViewModel: ScoreViewModel?
    
    // Vehicle spawning tracking
    private var vehicleSpawner = VehicleSpawner()
    
    // Performance tracking
    private var frameCount: Int = 0
    private var lastFrameTime: Date = Date()
    
    // MARK: - Expose active lanes for GameView
    var activeLanes: [Lane] {
        return laneManager.activeLanes
    }
    
    func getLanesAroundPlayer(range: Int = 12) -> [Lane] {
        let playerY = player.gridPosition.y
        laneManager.generateLanesForPlayerPosition(playerY)
        return laneManager.activeLanes.filter { lane in
            abs(lane.index - playerY) <= range
        }.sorted { $0.index < $1.index }
    }

    // MARK: - Init
    init() {
        // Load difficulty setting from UserDefaults (0: Easy, 1: Medium, 2: Hard)
        let selectedDifficulty = UserDefaults.standard.integer(forKey: "difficulty")
        switch selectedDifficulty {
        case 0: // Easy
            settingsSpeedMultiplier = 0.8
        case 1: // Medium
            settingsSpeedMultiplier = 1.0
        case 2: // Hard
            settingsSpeedMultiplier = 1.3
        default:
            settingsSpeedMultiplier = 1.0
        }
        setupGame()
    }

    func startGame() {
        // Stop any existing timers to avoid overlap
        stopTimers()
        gameTimer = nil
        vehicleSpawnTimer = nil
        
        gameState = .playing
        isGameRunning = true
        startTime = Date()
        lastUpdateTime = Date()
        vehicles.removeAll()
        score = 0
        maxReachedY = 0
        currentDifficulty = .easy
        progressPercentage = 0.0
        player.reset()

        laneManager.cleanup()
        laneManager.generateLanesForPlayerPosition(player.gridPosition.y)
        laneManager.preloadLanesAhead(of: player.gridPosition.y, distance: GameConstants.laneGenerationLookahead)

        // Force restart timers
        startGameLoop()
        startVehicleSpawning()

        AudioManager.shared.playBackgroundMusic(named: "Sounds/music1.caf", volume: backgroundVolume)

        updateGameStatus()
        DispatchQueue.main.async { [weak self] in
            self?.updateGameStatus() // Ensure UI sync
            print("Game started at \(Date()), state: \(self?.gameState ?? .menu), playerY: \(self?.player.gridPosition.y ?? 0)")
        }
    }
    
    func pauseGame() {
        guard gameState == .playing else { return }
        gameState = .paused
        stopTimers()
        AudioManager.shared.pauseBackgroundMusic()
    }

    func resumeGame() {
        guard gameState == .paused else { return }
        gameState = .playing
        lastUpdateTime = Date()
        startGameLoop()
        startVehicleSpawning()
        // startScoreTimer()
        AudioManager.shared.resumeBackgroundMusic()
    }

    func gameOver() {
        player.die()
        stopTimers()
        gameState = .gameOver
        isGameRunning = false
        AudioManager.shared.stopBackgroundMusic()

        saveScoreToDatabase()
    }

    func resetGame() {
        isGameRunning = false
        player.reset()
        vehicles.removeAll()
        score = 0
        maxReachedY = 0 // Reset maxReachedY
        currentDifficulty = .easy
        progressPercentage = 0.0
        currentTrafficScenario = "Starting Position"
        stopTimers()
        AudioManager.shared.stopBackgroundMusic()

        laneManager.cleanup()
    }

    // MARK: - Game Loop System
    private func startGameLoop() {
        gameTimer = Timer.publish(every: GameConstants.gameLoopInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let now = Date()
                let deltaTime = now.timeIntervalSince(self.lastUpdateTime)
                self.lastUpdateTime = now
                self.updateGame(deltaTime: deltaTime)
            }
    }

    private func updateGame(deltaTime: TimeInterval) {
        guard gameState == .playing else { return }
        
        updateVehicles(deltaTime: deltaTime)
        checkCollisions()
        cleanupVehicles()
        updateGameStatus()
        updatePerformanceMetrics()
        
        laneManager.preloadLanesAhead(of: player.gridPosition.y, distance: GameConstants.laneGenerationLookahead)
    }

    private func startVehicleSpawning() {
        vehicleSpawnTimer = Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.spawnVehiclesIfNeeded()
            }
    }

    private func spawnVehiclesIfNeeded() {
        spawnVehiclesForEndlessGame()
        
        if vehicles.count > GameConstants.maxActiveVehicles {
            vehicles.removeFirst(vehicles.count - GameConstants.maxActiveVehicles)
        }
    }

    private func spawnVehiclesForEndlessGame() {
        let playerY = player.gridPosition.y
        laneManager.generateLanesForPlayerPosition(playerY)
        
        let nearbyTrafficLanes = laneManager.getTrafficLanes().filter { lane in
            abs(lane.index - playerY) <= GameConstants.laneGenerationLookahead
        }
        
        for lane in nearbyTrafficLanes {
            if shouldSpawnVehicleInEndlessLane(lane) {
                spawnVehicleInEndlessLane(lane)
            }
        }
    }

    private func shouldSpawnVehicleInEndlessLane(_ lane: Lane) -> Bool {
        let vehiclesInLane = vehicles.filter { $0.lane == lane.index }
        
        // Check vehicle count limit
        guard vehiclesInLane.count < lane.maxVehiclesInLane else {
            return false
        }
        
        // Calculate required spacing based on lane speed
        let requiredSpacing = calculateRequiredSpacing(for: lane)
        
        // Check spacing with existing vehicles
        for vehicle in vehiclesInLane {
            let spawnX = lane.direction.startX
            if abs(vehicle.position.x - spawnX) < requiredSpacing {
                return false
            }
        }
        
        // Use spawn rate probability
        return Double.random(in: 0...1) < lane.vehicleSpawnRate
    }

    // In GameEngine.swift
    private func spawnVehicleInEndlessLane(_ lane: Lane) {
        guard let type = lane.vehicleTypes.randomElement() else { return }
        
        let laneMultiplier = lane.difficulty.speedMultiplier
        let totalMultiplier = laneMultiplier * settingsSpeedMultiplier
        
        let newVehicle = vehicleSpawner.createVehicleWithLaneSpeed(
            for: lane,
            baseType: type,
            additionalSpeedMultiplier: totalMultiplier
        )
        vehicles.append(newVehicle)
    }
    
    private func updateVehicles(deltaTime: TimeInterval) {
        for i in vehicles.indices {
            vehicles[i].update(deltaTime: deltaTime)
        }
    }

    private func cleanupVehicles() {
        vehicles.removeAll { !$0.isActive }
    }

    func movePlayerForward() {
        guard gameState == .playing && !player.isMoving && player.isAlive else { return }
        
        let oldY = player.gridPosition.y
        player.moveForward()
        
        if player.gridPosition.y > oldY {
            if player.gridPosition.y > maxReachedY {
                score += GameConstants.pointsPerStep
                maxReachedY = player.gridPosition.y
            }
            updateGameStatus()
//            updateScore()
            
            //Play movement sound
			AudioManager.shared.playSound(named: "Sounds/jump1.caf", volume: soundEffectsVolume)
                
            // Trigger movement animation
            DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.fastAnimationDuration) {
                self.player.finishMoving()
            }
        }
    }

    func movePlayerLeft() {
        guard gameState == .playing && !player.isMoving && player.isAlive else { return }
        
        player.moveLeft()
        
		AudioManager.shared.playSound(named: "Sounds/jump1.caf", volume: soundEffectsVolume)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.animationDuration) {
            self.player.finishMoving()
        }
    }

    func movePlayerRight() {
        guard gameState == .playing && !player.isMoving && player.isAlive else { return }
        
        player.moveRight()
        
		AudioManager.shared.playSound(named: "Sounds/jump1.caf", volume: soundEffectsVolume)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.animationDuration) {
            self.player.finishMoving()
        }
    }

    func movePlayerBackward() {
        guard gameState == .playing && !player.isMoving && player.isAlive else { return }
        
        player.moveBackward()
        
		AudioManager.shared.playSound(named: "Sounds/jump1.caf", volume: soundEffectsVolume)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.animationDuration) {
            self.player.finishMoving()
        }
    }

    private func checkCollisions() {
        guard player.isAlive else { return }
        
        for vehicle in vehicles {
            if vehicle.intersects(with: player) {
                handleCollision(with: vehicle)
                return
            }
        }
    }

    private func checkNearMisses() {
        for vehicle in vehicles {
            let distance = sqrt(
                pow(vehicle.position.x - player.screenPosition.x, 2) +
                pow(vehicle.position.y - player.screenPosition.y, 2)
            )
            
            if distance < 80 && distance > 40 {
                if !vehicle.id.uuidString.contains("bonus") {
                    score += GameConstants.bonusPointsForNearMiss
                }
            }
        }
    }
    
    private func calculateRequiredSpacing(for lane: Lane) -> CGFloat {
        // Spacing based on lane speed - faster lanes need more spacing
        let baseSpacing: CGFloat = 20.0
        let speedFactor = lane.laneSpeed / 2.0 // Normalize around base speed of 2.0
        return baseSpacing * max(speedFactor, 0.8) // Minimum spacing factor
    }

    private func handleCollision(with vehicle: Vehicle) {
        gameOver()
        // Show lesson immediately or queue it without changing state
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showTrafficLesson(for: vehicle.type)
        }
        playCollisionSound(for: vehicle.type)
    }

    private func showTrafficLesson(for vehicleType: GameConstants.VehicleType) {
        print("Traffic safety lesson:")
        print("You collided with a \(vehicleType.rawValue)")
        print("Rule: always look both ways before crossing!")
    }
    
    // MARK: - Game status updates
    private func updateGameStatus() {
        let playerY = player.gridPosition.y
        currentDifficulty = laneManager.getCurrentDifficulty(for: playerY)
        progressPercentage = laneManager.getProgressPercentage(for: playerY)
    }

    private func updatePerformanceMetrics() {
        frameCount += 1
        let now = Date()
        
        if now.timeIntervalSince(lastFrameTime) >= 1.0 {
            let fps = Double(frameCount) / now.timeIntervalSince(lastFrameTime)
            
            if fps < 25 {
                optimizePerformance()
            }
            
            frameCount = 0
            lastFrameTime = now
        }
    }

    private func optimizePerformance() {
        if vehicles.count > 30 {
            vehicles.removeFirst(10)
        }
        
        laneManager.activeLanes.removeAll { lane in
            abs(lane.index - player.gridPosition.y) > GameConstants.laneGenerationLookahead
        }
    }

    private func stopTimers() {
        gameTimer?.cancel()
        vehicleSpawnTimer?.cancel()
        gameTimer = nil
        vehicleSpawnTimer = nil
    }

    func getCurrentDifficulty() -> DifficultyLevel {
        return currentDifficulty
    }

    func getProgressPercentage() -> Double {
        return progressPercentage
    }

    func getCurrentTrafficScenario() -> String {
        return currentTrafficScenario
    }

    func getActiveLaneCount() -> Int {
        return laneManager.activeLanes.count
    }

    func getActiveVehicleCount() -> Int {
        return vehicles.count
    }

    func isPlayerInSafeZone() -> Bool {
        let currentLane = laneManager.getLane(at: player.gridPosition.y)
        return currentLane.laneType == .safe || currentLane.laneType == .start
    }
    
    // MARK: - INTEGRATION POINTS
    private func saveScoreToDatabase() {
        guard let scoreViewModel = scoreViewModel,
              let user = scoreViewModel.user else {
            print("No scoreViewModel or user - cannot save score")
            return
        }
        
        let scoreEntry = ScoreEntry(
            score: self.score,
            distance: player.gridPosition.y,
            difficulty: currentDifficulty.rawValue,
            timeAlive: startTime.map { Date().timeIntervalSince($0) } ?? 0,
            userId: user.uid,
            email: user.email ?? ""
        )
        
        scoreViewModel.saveScore(scoreEntry: scoreEntry)
        print("Score saved: \(score) points, \(player.gridPosition.y)m distance")
    }

    private func getCurrentUserId() -> String {
        return "user_id"
    }

    private func playCollisionSound(for vehicleType: GameConstants.VehicleType) {
        let soundFile: String
            
            switch vehicleType {
            case .car:
                soundFile = "deadbyvehicle"
            case .bus:
                soundFile = "deadbyvehicle"
            case .motorbike:
                soundFile = "deadbyvehicle"
            default:
                soundFile = "deadbyvehicle"
            }
            
            AudioManager.shared.playSound(named: "Sounds/\(soundFile).caf", volume: soundEffectsVolume)
        print("Playing collision sound for \(vehicleType.rawValue)")
    }

    func getScoreEntry() -> ScoreEntry {
        // TODO: Return detailed game statistics (for Mem 4 - Leaderboard)
        return ScoreEntry(
            score: score,
            distance: player.gridPosition.y,
            difficulty: currentDifficulty.displayName,
            // vehiclesAvoided: vehicles.count, // PLACEHOLDER
            timeAlive: startTime.map{ Date().timeIntervalSince($0) } ?? 0,
			userId: ScoreViewModel().user?.uid ?? "",
            email: ""
            )
    }

    private func setupGame() {
        resetGame()
    }

    deinit {
        stopTimers()
    }
}

// struct GameStatistics {
//     let score: Int
//     let distance: Int
//     let difficulty: String
//     let vehiclesAvoided: Int
//     let timeAlive: TimeInterval
// }
