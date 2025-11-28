/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author: Nguyen Ngoc Hai
  ID: s3978281
  Created date: 22/08/2025
  Last modified: 22/08/2025
  Acknowledgement: Endless lane system, generates infinite lanes as player progresses
*/

import SwiftUI

class EndlessLaneManager: ObservableObject {
    @Published var activeLanes: [Lane] = []
    @Published var currentDifficulty: DifficultyLevel = .easy
    
    private let maxVisibleLanes = 5 // Maybe??
    
    init() {
        activeLanes = []
        currentDifficulty = .easy
        // Generate initial lanes
        generateInitialLanes()
    }
    
    // MARK: - Lane generation
    private func generateInitialLanes() {
        activeLanes.removeAll()
        // Generate first few lanes for game start
        for index in 0...15 {
            let lane = Lane(index: index)
            activeLanes.append(lane)
        }
    }
    
    func generateLanesForPlayerPosition(_ playerY: Int) {
        let requiredLanes = (playerY - 5)...(playerY + GameConstants.laneGenerationLookahead) // Should be generated ahead of player
        
        for laneIndex in requiredLanes {
            // Only generate positive lane indices
            guard laneIndex >= 0 else { continue }
            
            // Check if lanes already exists
            if !activeLanes.contains(where: { $0.index == laneIndex }) {
                let newLane = Lane(index: laneIndex)
                activeLanes.append(newLane)
            }
        }
        
        // Clean up lanes that are too far behind
        let cleanupThreshold = playerY - GameConstants.laneCleanupDistance
        activeLanes.removeAll { $0.index < cleanupThreshold }
    }
    
    func getLane(at index: Int) -> Lane {
        // Try to find existing lane first
        if let existingLane = activeLanes.first(where: { $0.index == index }) {
            return existingLane
        } else {
            // Generate new lane if it doesn't exist
            let newLane = Lane(index: index)
            activeLanes.append(newLane)
            return newLane
        }
    }
    
    func getTrafficLanes() -> [Lane] {
        return activeLanes.filter{ $0.laneType == .traffic }
    }
    
    func getSafeLanes() -> [Lane] {
        return activeLanes.filter{ $0.laneType == .safe || $0.laneType == .start }
    }
    
    // MARK: - Isometric positioning helpers
    func calculateIsometricPosition(for lane: Lane, centerX: CGFloat, centerY: CGFloat, playerY: Int) -> CGPoint {
        let relativeY = lane.index - playerY
        let isoX = centerX
        let isoY = centerY + CGFloat(relativeY) * 50.0 // 50px spacing between lanes
        return CGPoint(x: isoX, y: isoY)
    }
    
    // MARK: - Game Progression
    func getProgressPercentage(for playerY: Int) -> Double {
        // Every 10 lanes = 10% milestone
        return min(Double(playerY) / 100.0 * 100, 100.0)
    }
    
    func getCurrentDifficulty(for playerY: Int) -> DifficultyLevel {
        return Lane.calculateDifficulty(for: playerY)
    }
    
    // MARK: - Lane Statistics
    func getActiveLaneStats() -> (total: Int, traffic: Int, safe: Int) {
        return (0, 0, 0)
    }
    
    // MARK: - Memory Management
    func cleanup() {
        // Remove all lanes except immediate vicinity
        activeLanes.removeAll()
        currentDifficulty = .easy
        generateInitialLanes()
    }
    
    // Pre-generate lanes ahead for smooth gameplay
    func preloadLanesAhead(of playerY: Int, distance: Int = 20) {
        for index in (playerY + 1)...(playerY + distance) {
            if !activeLanes.contains(where: { $0.index == index}) {
                let lane = Lane(index: index)
                activeLanes.append(lane)
            }
        }
        
        // Limit total active lanes for performance
        if activeLanes.count > GameConstants.maxVisibleLanes {
            // Keep only the lanes around the player
            let minLane = playerY - 5
            let maxLane = playerY + GameConstants.laneGenerationLookahead
            activeLanes = activeLanes.filter { $0.index >= minLane && $0.index <= maxLane }
        }
    }
}

extension EndlessLaneManager {
    func screenPosition(for lane: Lane, playerY: Int, centerY: CGFloat, tileSize: CGFloat) -> CGFloat {
        let relativeY = lane.index - playerY
        return centerY - CGFloat(relativeY) * tileSize
    }
}
