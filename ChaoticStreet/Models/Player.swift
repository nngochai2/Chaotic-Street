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

// MARK: - Player Model
struct Player {
    // MARK: - Position Properties
    var gridPosition: GridPosition
    var screenPosition: CGPoint
    
    // MARK: - State Properties
    var isAlive: Bool
    var isMoving: Bool
    var score: Int
    var livesRemaining: Int
    
    // MARK: - Movement Properties
    var facingDirection: PlayerDirection
    
    // MARK: - Initialization
    init() {
        self.gridPosition = GameConstants.playerStartPosition
        self.screenPosition = GameConstants.playerStartPosition.toScreenPosition()
        self.isAlive = true
        self.isMoving = false
        self.score = 0
        self.livesRemaining = 3
        self.facingDirection = .up
    }
    
    // MARK: - Movement Methods
    mutating func moveForward() {
        guard canMoveToPosition(GridPosition(x: gridPosition.x, y: gridPosition.y + 1)) else { return }
        
        gridPosition.y += 1
        updateScreenPosition()
        facingDirection = .up
        score += GameConstants.pointsPerStep
        isMoving = true
    }
    
    mutating func moveLeft() {
        guard canMoveToPosition(GridPosition(x: gridPosition.x - 1, y: gridPosition.y)) else { return }
        
        gridPosition.x -= 1
        updateScreenPosition()
        facingDirection = .left
        isMoving = true
    }
    
    mutating func moveRight() {
        guard canMoveToPosition(GridPosition(x: gridPosition.x + 1, y: gridPosition.y)) else { return }
        
        gridPosition.x += 1
        updateScreenPosition()
        facingDirection = .right
        isMoving = true
    }
    
    mutating func moveBackward() {
        guard canMoveToPosition(GridPosition(x: gridPosition.x, y: gridPosition.y - 1)) else { return }
        
        gridPosition.y -= 1
        updateScreenPosition()
        facingDirection = .down
        isMoving = true
    }
    
    // MARK: - Helper Methods
    private mutating func updateScreenPosition() {
        screenPosition = gridPosition.toScreenPosition()
    }
    
    private func canMoveToPosition(_ position: GridPosition) -> Bool {
        // Check bounds
        return position.x >= 0 &&
               position.x < GameConstants.tilesPerRow &&
               position.y >= 0
    }
    
    // MARK: - Game State Methods
    mutating func die() {
        isAlive = false
        livesRemaining -= 1
    }
    
    mutating func respawn() {
        gridPosition = GameConstants.playerStartPosition
        updateScreenPosition()
        isAlive = true
        isMoving = false
        facingDirection = .up
    }
    
    mutating func reset() {
        gridPosition = GameConstants.playerStartPosition
        updateScreenPosition()
        isAlive = true
        isMoving = false
        score = 0
        livesRemaining = 3
        facingDirection = .up
    }
    
    mutating func finishMoving() {
        isMoving = false
    }
    
    // MARK: - Collision Detection
    func getBoundingBox() -> CGRect {
        return CGRect(
            x: screenPosition.x - GameConstants.playerSize/2,
            y: screenPosition.y - GameConstants.playerSize/2,
            width: GameConstants.playerSize,
            height: GameConstants.playerSize
        )
    }
    
    // MARK: - Perspective Scaling
    func getScale() -> CGFloat {
        let perspectiveDistance = min(gridPosition.y, GameConstants.maxPerspectiveDistance)
        return 1.0 - CGFloat(perspectiveDistance) * GameConstants.perspectiveScale
    }
    
    func getZIndex() -> Double {
        return Double(GameConstants.maxPerspectiveDistance - gridPosition.y + 100)
    }
}

// MARK: - Player Direction
enum PlayerDirection {
    case up
    case down
    case left
    case right
    
    var rotation: Double {
        switch self {
        case .up: return 0
        case .down: return 180
        case .left: return -90
        case .right: return 90
        }
    }
    
    var systemImageName: String {
        switch self {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .left: return "arrow.left"
        case .right: return "arrow.right"
        }
    }
}

// MARK: - Player Extensions
extension Player: Equatable {
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.gridPosition == rhs.gridPosition &&
               lhs.isAlive == rhs.isAlive &&
               lhs.score == rhs.score
    }
}
