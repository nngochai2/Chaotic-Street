/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author: [Your Name Here]
  ID: [Your Student ID]
  Created date: 19/08/2025
  Last modified: 15/09/2025
  Acknowledgement: Updated Vehicle with time-based movement for smoother gameplay
*/

import SwiftUI

// MARK: - Vehicle Model
struct Vehicle: Identifiable {
    let id = UUID()
    
    // MARK: - Position Properties
    var position: CGPoint
    var lane: Int
    
    // MARK: - Vehicle Properties
    var type: GameConstants.VehicleType
    var direction: Direction
    var speed: CGFloat
    var size: CGSize
    var color: Color
    
    // MARK: - State Properties
    var isActive: Bool
    
    // MARK: - Initialization
    init(lane: Int, direction: Direction, type: GameConstants.VehicleType) {
        self.lane = lane
        self.direction = direction
        self.type = type
        self.speed = self.type.speed * direction.speedMultiplier
        self.size = self.type.size
        self.color = self.type.color
        self.isActive = true
        
        // Set initial position
        self.position = CGPoint(
            x: direction.startX,
            y: Vehicle.calculateLaneYPosition(lane: lane)
        )
    }
    
    // MARK: - Movement Method
    mutating func update(deltaTime: TimeInterval) {
        let dx = speed * CGFloat(deltaTime) * (direction == .rightToLeft ? -1 : 1) // Negative for right-to-left
        position.x += dx
        
        if direction == .leftToRight && position.x > GameConstants.currentScreenWidth + size.width {
            isActive = false
        } else if direction == .rightToLeft && position.x < -size.width {
            isActive = false
        }
    }
    
    static func calculateLaneYPosition(lane: Int) -> CGFloat {
        let laneHeight = GameConstants.laneHeight
        let startY = GameConstants.sidewalkHeight
        return startY + CGFloat(lane) * laneHeight + laneHeight / 2
    }
    
    static func randomDirection() -> Direction {
        return Direction.allCases.randomElement() ?? .leftToRight
    }
    
    // MARK: - Collision Detection
    func getBoundingBox() -> CGRect {
        return CGRect(
            x: position.x - size.width / 2,
            y: position.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }
    
    func intersects(with player: Player) -> Bool {
        guard self.lane == player.gridPosition.y else { return false }
      
        let playerScreenX = CGFloat(player.gridPosition.x) * (GameConstants.currentScreenWidth / CGFloat(GameConstants.tilesPerRow)) + (GameConstants.currentScreenWidth / CGFloat(GameConstants.tilesPerRow)) / 2
      
        let horizontalDistance = abs(self.position.x - playerScreenX)
      
        let collisionDistance: CGFloat = 30.0
      
        let isColliding = horizontalDistance < collisionDistance
      
        if isColliding {
            print("COLLISION: Vehicle at x:\(Int(self.position.x)) vs Player at x:\(Int(playerScreenX)), distance: \(Int(horizontalDistance))")
        }
      
        return isColliding
    }
    
    // MARK: - Perspective Effects
    func getScale() -> CGFloat {
        let perspectiveDistance = min(lane, GameConstants.maxPerspectiveDistance)
        return 1.0 - CGFloat(perspectiveDistance) * GameConstants.perspectiveScale
    }
    
    func getZIndex() -> Double {
        return Double(GameConstants.maxPerspectiveDistance - lane)
    }
    
    func getOpacity() -> Double {
        let perspectiveDistance = min(lane, GameConstants.maxPerspectiveDistance)
        return 1.0 - Double(perspectiveDistance) * 0.1
    }
    
    // MARK: - Vietnamese Vehicle Characteristics
    var vietnameseDisplayName: String {
        switch type {
        case .motorbike: return "Xe máy"
        case .car: return "Ô tô"
        case .bus: return "Xe buýt"
        case .cyclo: return "Xích lô"
        }
    }
    
    var hornSound: String {
        switch type {
        case .motorbike: return "motorbike_horn"
        case .car: return "car_horn"
        case .bus: return "bus_horn"
        case .cyclo: return "bell_sound"
        }
    }
    
    // MARK: - Animation Properties
    var engineAnimation: String {
        switch type {
        case .motorbike: return "motorbike_animation"
        case .car: return "car_animation"
        case .bus: return "bus_animation"
        case .cyclo: return "cyclo_animation"
        }
    }
}

// MARK: - Vehicle Extensions
extension Vehicle: Equatable {
    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Vehicle: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Vehicle {
    
    // MARK: - Updated Vehicle Initialization
    init(lane: Int, direction: Direction, type: GameConstants.VehicleType, useConsistentSpeed: Bool = true) {
        self.lane = lane
        self.direction = direction
        self.type = type
        self.size = self.type.size
        self.color = self.type.color
        self.isActive = true
        
        // IMPORTANT: Don't set random speed here anymore
        // Speed will be set by VehicleSpawner based on lane
        if useConsistentSpeed {
            self.speed = 2.0 * direction.speedMultiplier // Temporary, will be overridden
        } else {
            self.speed = self.type.speed * direction.speedMultiplier // Old random method
        }
        
        // Set initial position
        self.position = CGPoint(
            x: direction.startX,
            y: Vehicle.calculateLaneYPosition(lane: lane)
        )
    }
}
