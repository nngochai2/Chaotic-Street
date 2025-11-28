/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author: [Your Name Here]
  ID: [Your Student ID]
  Created date: 19/08/2025
  Last modified: 19/08/2025
  Acknowledgement: Content View
*/

import SwiftUI

// MARK: - Game Constants
struct GameConstants {
    
    // MARK: - Grid System
    static var gridSize: CGFloat {
        currentScreenWidth / CGFloat(tilesPerRow)
    }
    static let tilesPerRow: Int = 8
    static var visibleRows: Int {
        Int(currentScreenHeight / laneHeight) + 15 // Add extra rows for buffer
    }
    
    // MARK: - Isometric projection constants
    static let isometricTileWidth: CGFloat = 60.0
    static let isometricTileHeight: CGFloat = 30.0
    
    // MARK: - Player Settings
    static var playerSize: CGFloat {
        gridSize * 0.8
    }
    static var playerWidth: CGFloat {
        gridSize * 1.2
    }
    
    static var playerHeight: CGFloat {
        gridSize * 0.8
    }

    static let playerStartPosition = GridPosition(x: 4, y: 0) // Center bottom
    
    // MARK: - Vehicle Settings
    static let vehicleWidth: CGFloat = 60.0
    static let vehicleHeight: CGFloat = 30.0
    
    // Vehicle spawn rates (per second)
    static let vehicleSpawnRate: Double = 0.5
    static let maxVehiclesPerLane: Int = 3
    
    // MARK: - Vietnamese Vehicle Types and Speeds
    enum VehicleType: String, CaseIterable {
        case motorbike = "motorbike"
        case car = "car"
        case bus = "bus"
        case cyclo = "cyclo"
        
        var speed: CGFloat {
            switch self {
            case .motorbike: return CGFloat.random(in: 80.0...120.0) // Increased for faster movement
            case .car: return CGFloat.random(in: 6.0...10.0)
            case .bus: return CGFloat.random(in: 4.0...8.0)
            case .cyclo: return CGFloat.random(in: 2.0...4.0)
            }
        }
        
        var color: Color {
            // FOR NOW
            switch self {
            case .motorbike: return .blue
            case .car: return .red
            case .bus: return .orange
            case .cyclo: return .green
            }
        }
        
        var size: CGSize {
            switch self {
            case .motorbike: return CGSize(width: gridSize * 1.8, height: gridSize * 1.2) // Larger
            case .car: return CGSize(width: gridSize * 1.5, height: gridSize * 0.8)
            case .bus: return CGSize(width: gridSize * 2.0, height: gridSize * 1.0)
            case .cyclo: return CGSize(width: gridSize * 1.1, height: gridSize * 0.8)
            }
        }
        
        var displayName: String {
            switch self {
            case .motorbike: return "Xe máy"
            case .car: return "Ô tô"
            case .bus: return "Xe buýt"
            case .cyclo: return "Xích lô"
            }
        }
    }
    
    // MARK: - Traffic Distribution
    static let vehicleDistribution: [VehicleType: Double] = [
        .motorbike: 0.70,   // 70% - Kind of true
        .car: 0.20,         // 20%
        .bus: 0.08,         // 8% 
        .cyclo: 0.02        // 2%
    ]
    
    
    // MARK: - Game Timing
    static let gameLoopInterval: Double = 1.0/60.0 // 60 FPS
    static let animationDuration: Double = 0.2
    static let fastAnimationDuration: Double = 0.15
    static let slowAnimationDuration: Double = 0.3
    
    // MARK: - Scoring System
    static let pointsPerStep: Int = 10
    static let pointsPerSecondAlive = 1
    static let bonusPointsForNearMiss: Int = 25
    static let milestoneBonus: Int = 100
    static let milestoneInterval: Int = 10
    static let progressDisplayInterval: Int = 10 // Show progress every 10 rows
    
    // MARK: - Lane Configuration
    static var laneHeight: CGFloat {
        min(gridSize * 1.0, 80.0) // Reduce multiplier to 1.0, cap at 80 for iPad
    }
    static let sidewalkHeight: CGFloat = 80.0
    static let safeZoneInterval: Int = 4 // Safe zone every 4th lane
    static let rushHourLaneInterval: Int = 7 // Rush hour traffic lane after row 20
    
    // MARK: - 3D Effect Settings
    static let perspectiveScale: CGFloat = 0.08 // How much smaller distant objects appear
    static let maxPerspectiveDistance: Int = 5  // Maxium distance for perspective effect
    static let perspectiveOpacityReduction: Double = 0.1 // How much opacity reduces with distance
    
    // MARK: - Default Screen Dimensions (fallback values)
    static let defaultScreenWidth: CGFloat = 393.0  // iPhone 14 Pro
    static let defaultScreenHeight: CGFloat = 852.0 // iPhone 14 Pro height
    
    // Screen dimensions will be set by GeometryReader in views
    static var currentScreenWidth: CGFloat = defaultScreenWidth
    static var currentScreenHeight: CGFloat = defaultScreenHeight
    
    static func updateScreenDimensions(width: CGFloat, height: CGFloat) {
        currentScreenWidth = width
        currentScreenHeight = height
    }
    
    // MARK: - Endless Game Settings
    static let maxVisibleLanes: Int = 15
    static let laneGenerationLookahead: Int = 10
    static let laneCleanupDistance: Int = 10
    static let minimumVehicleSpacing: CGFloat = 150.0
    
    // MARK: - Difficulty Progression
    static let easyGameRows: Int = 10
    static let mediumGameRows: Int = 25
    static let hardGameRows: Int = 50
    
    // MARK: - Performance Settings
    static let maxActiveVehicles: Int = 50 // Total vehicle limit for performance
    static let vehicleCleanupDistance: CGFloat = 200.0 // Clean up vehicles this far off screen
    static let maxFrameDrops: Int = 5 // Maximum consecutive frame drops before opimization
    static let targetFPS: Double = 30.0
    static let minimum: Double = 20.0
    
    // MARK: - Collision Detection
    static let collisionTolerance: CGFloat = 5.0 // Pixels of tolerance for collision detection
    static let nearMissDistance: CGFloat = 80.0 // Distance for near miss bonus
    static let nearMissMinDistance: CGFloat = 40.0 // Minimum distance still counts as near miss
    
    // MARK: - Audio Settings (for Member 5)
    static let soundEnabled: Bool = true
    static let musicEnabled: Bool = true
    static let soundVolume: Float = 0.8
    static let musicVolume: Float = 0.6
    
    // MARK: - UI Settings
    static let buttonCornerRadius: CGFloat = 12.0
    static let cardCornerRadius: CGFloat = 16.0
    static let shadowRadius: CGFloat = 4.0
    static let animationSpringResponse: Double = 0.6
    static let animationSpringDampingFraction: Double = 0.8
}

// MARK: - Grid Position
struct GridPosition: Equatable {
    var x: Int
    var y: Int
    
    func toScreenPosition() -> CGPoint {
        return CGPoint(
            x: CGFloat(x) * GameConstants.gridSize + GameConstants.gridSize/2,
            y: GameConstants.currentScreenHeight - CGFloat(y) * GameConstants.gridSize - GameConstants.gridSize/2
        )
    }

    // Converts grid coordinates to isometric screen position
    func toIsometricScreenPosition() -> CGPoint {
        // Classic isometric projection formula
        let isoX = (CGFloat(x) - CGFloat(y)) * GameConstants.isometricTileWidth / 2
        let isoY = (CGFloat(x) + CGFloat(y)) * GameConstants.isometricTileHeight / 2
        
        return CGPoint(
            x: GameConstants.currentScreenWidth / 2 + isoX,
            y: GameConstants.currentScreenHeight - 200 - isoY
        )
    }
    
    func isValid() -> Bool {
        return x >= 0 && x < GameConstants.tilesPerRow && y >= 0
    }
    
    func distanceTo(_ other: GridPosition) -> Double {
        let dx = Double(x - other.x)
        let dy = Double(y - other.y)
        return sqrt(dx * dx + dy * dy)
    }
}

// MARK: - Direction
enum Direction: CaseIterable {
    case leftToRight
    case rightToLeft
    
    var startX: CGFloat {
        switch self {
        case .leftToRight: return -GameConstants.vehicleWidth
        case .rightToLeft: return GameConstants.currentScreenWidth + GameConstants.vehicleWidth
        }
    }
    
    var speedMultiplier: CGFloat {
        switch self {
        case .leftToRight: return 1.0
        case .rightToLeft: return -1.0
        }
    }
}

// MARK: - Game State
enum GameState {
    case menu
    case playing
    case paused
    case gameOver
}
