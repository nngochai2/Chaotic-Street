/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author: [Your Name Here]
  ID: [Your Student ID]
  Created date: 19/08/2025
  Last modified: 19/08/2025
  Acknowledgement: Lane system
*/

import SwiftUI

// MARK: - Lane Configuration
struct Lane {
    let index: Int
    let yPosition: CGFloat
    let laneType: LaneType
    let direction: Direction
    let vehicleTypes: [GameConstants.VehicleType]
    let difficulty: DifficultyLevel
    
    init(index: Int) {
        self.index = index
        self.yPosition = Vehicle.calculateLaneYPosition(lane: index)
        
        // Generate lane type based on row pattern
        self.laneType = Lane.generateLaneType(for: index)
        
        // Set direction (alternating for traffic lanes)
        self.direction = Lane.generateDirection(for: index, type: laneType)
        
        // Set vehicle types based on distance from start
        self.vehicleTypes = Lane.generateVehicleTypes(for: index)
        
        // Increase difficulty as player progresses
        self.difficulty = Lane.calculateDifficulty(for: index)
    }
    
    // MARK: - Lane Type Generation
    static func generateLaneType(for index: Int) -> LaneType {
        // Pattern: Start, Traffic, Safe, Traffic, Traffic, Safe, Traffic, Safe...
        switch index {
        case 0:
            return .start // Player starting position
        case 1:
            return .safe  // First safe zone after start
        default:
            // Alternating pattern with occasional safe zones
            if index % 4 == 0 {
                return .safe  // Safe zone every 4th row
            } else {
                return .traffic // Traffic lanes
            }
        }
    }
    
    static func generateDirection(for index: Int, type: LaneType) -> Direction {
        guard type == .traffic else { return .leftToRight }
            
        // Change from simple alternating to more variety:
        switch index % 3 {
            case 0, 1: return .leftToRight    // 2/3 lanes go left-to-right
            case 2: return .rightToLeft       // 1/3 lanes go right-to-left
            default: return .leftToRight
        }
    }
    
    // MARK: - Vehicle Type Distribution by Distance
    static func generateVehicleTypes(for index: Int) -> [GameConstants.VehicleType] {
        let distanceFromStart = index
        
        switch distanceFromStart {
        case 0...5:
            // Early game - mostly motorbikes and cars (easier)
            return [.motorbike, .car]
            
        case 6...15:
            // Mid game - add buses
            return [.motorbike, .car, .bus]
            
        case 16...25:
            // Late game - add cyclos (unpredictable movement)
            return [.motorbike, .car, .bus, .cyclo]
            
        default:
            // Expert level - all vehicle types with different frequencies
            return GameConstants.VehicleType.allCases
        }
    }
    
    // MARK: - Dynamic Difficulty Scaling
    static func calculateDifficulty(for index: Int) -> DifficultyLevel {
        switch index {
        case 0...10: return .easy
        case 11...25: return .medium
        case 26...50: return .hard
        default: return .expert
        }
    }
    
    // MARK: - Traffic Density by Difficulty
    var vehicleSpawnRate: Double {
        switch difficulty {
        case .easy: return 0.3      // 30% chance per spawn cycle
        case .medium: return 0.8   // 50% chance
        case .hard: return 0.9     // 70% chance
        case .expert: return 1.0    // 90% chance - very dense traffic
        }
    }
    
    var maxVehiclesInLane: Int {
        switch difficulty {
        case .easy: return 5
        case .medium: return 6
        case .hard: return 7
        case .expert: return 8
        }
    }
    
    // MARK: - Vietnamese Traffic Patterns
    var hasSpecialTrafficPattern: Bool {
        // Rush hour simulation - certain rows have extra dense traffic
        return index % 7 == 0 && index > 20
    }
    
    var vietnameseTrafficScenario: String {
        switch index % 10 {
        case 0: return "Quiet residential street"
        case 1: return "School zone - careful crossing"
        case 2: return "Market area - mixed traffic"
        case 3: return "Bus route - large vehicles"
        case 4: return "Motorbike alley - dense scooters"
        case 5: return "Main road - fast cars"
        case 6: return "Tourist area - cyclos present"
        case 7: return "Rush hour - heavy traffic"
        case 8: return "Industrial zone - trucks and buses"
        case 9: return "Traditional quarter - all vehicle types"
        default: return "Mixed urban traffic"
        }
    }
    
    // MARK: - Educational Content Integration
    var educationalContext: String {
        switch laneType {
        case .start:
            return "Starting position - Look both ways!"
        case .safe:
            return "Safe sidewalk - Plan your next move"
        case .traffic:
            return "Active traffic lane - \(vietnameseTrafficScenario)"
        }
    }
    
    var safetyTip: String {
        switch difficulty {
        case .easy:
            return "Take your time, vehicles are slow"
        case .medium:
            return "Watch for faster vehicles and buses"
        case .hard:
            return "Dense traffic - wait for safe gaps"
        case .expert:
            return "Expert level - unpredictable cyclos present!"
        }
    }
}

// MARK: - Lane Types
enum LaneType {
    case start      // Player starting position
    case safe       // Sidewalk, no vehicles
    case traffic    // Road with vehicles
    
    var description: String {
        switch self {
        case .start: return "Starting Position"
        case .safe: return "Safe Sidewalk"
        case .traffic: return "Traffic Lane"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .start: return .green.opacity(0.3)
        case .safe: return .gray.opacity(0.2)
        case .traffic: return .black.opacity(0.1)
        }
    }
    
    var icon: String {
        switch self {
        case .start: return "figure.walk"
        case .safe: return "checkmark.shield"
        case .traffic: return "car"
        }
    }
}

// MARK: - Difficulty Levels
enum DifficultyLevel: String, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    case expert = "expert"
    
    var speedMultiplier: CGFloat {
        switch self {
        case .easy: return 0.8
        case .medium: return 1.0
        case .hard: return 1.3
        case .expert: return 1.6
        }
    }
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .expert: return "Expert"
        }
    }
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .expert: return .red
        }
    }
    
    var vietnameseName: String {
        switch self {
        case .easy: return "Dễ"
        case .medium: return "Trung bình"
        case .hard: return "Khó"
        case .expert: return "Chuyên gia"
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "Perfect for learning traffic rules"
        case .medium: return "Mixed traffic with some buses"
        case .hard: return "Dense traffic, requires skill"
        case .expert: return "Expert level - all vehicle types!"
        }
    }
}

// MARK: - Lane Extensions
extension Lane {
    
    // MARK: - Lane Statistics
    func getExpectedVehicleCount() -> Int {
        return Int(Double(maxVehiclesInLane) * vehicleSpawnRate)
    }
    
    func isPlayerSafe() -> Bool {
        return laneType == .safe || laneType == .start
    }
    
    func requiresCarefulCrossing() -> Bool {
        return laneType == .traffic && difficulty != .easy
    }
    
    // MARK: - UI Helpers
    func getLaneDisplayInfo() -> (title: String, subtitle: String, color: Color) {
        let title = "Lane \(index)"
        let subtitle = "\(laneType.description) - \(difficulty.displayName)"
        let color = difficulty.color
        return (title, subtitle, color)
    }
    
    // MARK: - Game Balance
    func getRecommendedPlayerStrategy() -> String {
        switch difficulty {
        case .easy:
            return "Move steadily forward, vehicles are predictable"
        case .medium:
            return "Watch for buses - they're larger and slower"
        case .hard:
            return "Wait for safe gaps, traffic is getting dense"
        case .expert:
            return "Be very careful! Cyclos can be unpredictable"
        }
    }
}

// MARK: - Lane Validation
extension Lane {
    
    func isValid() -> Bool {
        // Validate lane configuration
        guard index >= 0 else { return false }
        guard !vehicleTypes.isEmpty || laneType != .traffic else { return false }
        return true
    }
    
    func debugDescription() -> String {
        return """
        Lane \(index): \(laneType.description)
        Difficulty: \(difficulty.displayName)
        Vehicles: \(vehicleTypes.map { $0.rawValue }.joined(separator: ", "))
        Spawn Rate: \(Int(vehicleSpawnRate * 100))%
        Max Vehicles: \(maxVehiclesInLane)
        Scenario: \(vietnameseTrafficScenario)
        """
    }
}

extension Lane {
    
    // MARK: - Lane Speed Management
    var laneSpeed: CGFloat {
        // Base speed determined by difficulty and lane characteristics
        let baseSpeed: CGFloat = 200.0
        
        // Apply difficulty multiplier
        let difficultySpeed = baseSpeed * difficulty.speedMultiplier
        
        // Add lane-specific variation (but consistent within lane)
        let laneVariation = getLaneSpeedVariation()
        
        return difficultySpeed * laneVariation
    }
    
    private func getLaneSpeedVariation() -> CGFloat {
        // Use lane index to create consistent but varied speeds
        let seedValue = index % 7 // Creates 7 different speed patterns
        
        switch seedValue {
        case 0: return 0.8  // Slow lane
        case 1: return 1.0  // Normal speed
        case 2: return 1.2  // Fast lane
        case 3: return 0.9  // Slightly slow
        case 4: return 1.1  // Slightly fast
        case 5: return 0.7  // Very slow (good for beginners)
        case 6: return 1.3  // Very fast (challenging)
        default: return 1.0
        }
    }
    
    // MARK: - Traffic Flow Characteristics
    var trafficFlowDescription: String {
        let speed = laneSpeed
        switch speed {
        case 0...1.0: return "Slow traffic"
        case 1.0...1.2: return "Normal flow"
        case 1.2...1.5: return "Fast traffic"
        default: return "Rush hour"
        }
    }
}
