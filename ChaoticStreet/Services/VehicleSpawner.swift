/*
  RMIT University Vietnam
  Course: COSC3062|COSC3063 iPhone Software Engineering
  Semester: 2025B
  Assessment: Assignment 2
  Author: Nguyen Ngoc Hai
  ID: s3978281
  Created date: 23/08/2025
  Last modified: 23/08/2025
  Acknowledgement: Vehicle Spawning Service
*/

import SwiftUI

class VehicleSpawner {
    
    // MARK: - Spawn Config
    private struct SpawnConfig {
        static let minimumSpacing: CGFloat = 10.0
        static let maxAttemptsPerLane: Int = 3
        static let rushHourMultiplier: Double = 1.5 // Used for difficult lanes
    }
    
    // Track last spawn time for each lane (centralized timing logic
    private var lastSpawnTime: [Int: Date] = [:]
    
    // MARK: - Main Vehicle Creation
    func createVehicle(for lane: Lane) -> Vehicle {
        let vehicleType = selectVehicleType(for: lane)
        var vehicle = Vehicle(lane: lane.index, direction: lane.direction, type: vehicleType)
        
        // Apply lane-specific modifications
        applyLaneModifications(to: &vehicle, lane: lane)
        
        return vehicle
    }
    
    private func selectVehicleType(for lane: Lane) -> GameConstants.VehicleType {
        // Use lane-specific vehicle types if available
        let availableTypes = lane.vehicleTypes.isEmpty ? GameConstants.VehicleType.allCases : lane.vehicleTypes
        
        // Apply traffic distribution
        return selectWithDistribution(from: availableTypes, lane: lane)
    }
    
    private func selectWithDistribution(from types: [GameConstants.VehicleType], lane: Lane) -> GameConstants.VehicleType {
        // Create weighted selection based on traffic patterns
        var weightTypes: [(GameConstants.VehicleType, Double)] = []
        
        for vehicleType in types {
            var weight = GameConstants.vehicleDistribution[vehicleType] ?? 0.1
            
            // Modify weights based on lane characteristics
            weight = adjustWeightForLane(weight, vehicleType: vehicleType, lane: lane)
            
            weightTypes.append((vehicleType, weight))
        }
        
        // Select vehicle(s) using weighted random
        return weightedRandomSelection(from: weightTypes) ?? types.first ?? .motorbike
    }
    
    private func adjustWeightForLane(_ baseWeight: Double, vehicleType: GameConstants.VehicleType, lane: Lane) -> Double {
        var adjustedWeight = baseWeight
        
        // Rush hour increases all vehicle density
        if lane.hasSpecialTrafficPattern {
            adjustedWeight *= SpawnConfig.rushHourMultiplier
        }
        
        // Difficulty affects vehicle type distribution
        switch lane.difficulty {
        case .easy:
            // More motorbike and cars in easy mode
            if vehicleType == .motorbike || vehicleType == .car {
                adjustedWeight *= 1.2
            }
        case .medium:
            // Balance distribution
            break
        case .hard:
			break
            // More buses and variety
            if vehicleType == .bus {
                adjustedWeight *= 1.3
            }
        case .expert:
            // More unpredictable cyclos
            if vehicleType == .cyclo {
                adjustedWeight *= 2.0
            }
        }
        
        return adjustedWeight
    }
    
    private func weightedRandomSelection(from weightedTypes: [(GameConstants.VehicleType, Double)]) -> GameConstants.VehicleType? {
        // Calculate the total weights of all vehicle types
        let totalWeight = weightedTypes.map { $0.1 }.reduce(0, +)
        
        // Generate random number between 0 and the total weight
        let random = Double.random(in: 0...totalWeight)
        
        var cumulative: Double = 0
        for (vehicleType, weight) in weightedTypes {
            cumulative += weight
            if random <= cumulative {
                return vehicleType
            }
        }
        
        return weightedTypes.first?.0 // Fallback
    }
    
    // MARK: - Vehicle Modifications
    private func applyLaneModifications(to vehicle: inout Vehicle, lane: Lane) {
        // Apply difficulty speed multiplier
        vehicle.speed *= lane.difficulty.speedMultiplier
        
        // Add Vietnamese-specific behaviour modifications
        applyVietnameseTrafficBehaviour(to: &vehicle, lane: lane)
        
        // Apply random variation for realism
        applyRandomVariation(to: &vehicle)
    }
    
    private func applyVietnameseTrafficBehaviour(to vehicle: inout Vehicle, lane: Lane) {
        switch vehicle.type {
        case .motorbike:
            // Motorbikes are faster and more erratic
            vehicle.speed *= CGFloat.random(in: 1.0...1.3)
        
        case .car:
            // Steady speed
            vehicle.speed *= CGFloat.random(in: 0.9...1.1)
            
        case .bus:
            // Slower and more predictable
            vehicle.speed *= CGFloat.random(in: 0.7...0.9)
            
        case .cyclo:
            // Very slow but unpredictable
            vehicle.speed *= CGFloat.random(in: 0.6...0.8)
        }
    }
    
    private func applyRandomVariation(to vehicle: inout Vehicle) {
        // Small random speed variation - for natural traffic flow
        let speedVariation = CGFloat.random(in: 0.85...1.15)
        vehicle.speed *= speedVariation
    }
    
    // MARK: - Vehicle creation with spawn time tracking
    func createVehicleAndUpdateTime(for lane: Lane) -> Vehicle {
        // Update spawn time when vehicle is actually created
        lastSpawnTime[lane.index] = Date()
        return createVehicle(for: lane)
    }
    
    // MARK: - Batch Spawning (used for rush hour scenarios)
    func createVehicleGroup(for lane: Lane, count: Int = 2) -> [Vehicle] {
        var vehicles: [Vehicle] = []
        let spacing: CGFloat = 120.0
        
        for i in 0..<count {
            var vehicle = createVehicle(for: lane)
            
            // Position vehicles in formation - like a convoy
            // Each subsequent vehicle is postioned further back
            let offset = CGFloat(i) * spacing
            if lane.direction == .leftToRight {
                vehicle.position.x -= offset // Space them out to the left
            } else {
                vehicle.position.x += offset // Space to the right
            }
            
            vehicles.append(vehicle)
        }
        
        return vehicles
    }
    
    //====================================== MIGHT BE DEVELOPED LATER =========================================
    
    // MARK: - Rush Hour Traffic Scenario
    func createRushHourTraffic(for lane: Lane) -> [Vehicle] {
        return []
    }
    
    // MARK: - Create School Zone Traffic (slower, more careful traffic)
    func createSchoolZoneTraffic(for lane: Lane) -> Vehicle? {
        return nil
    }
    
    // MARK: - Market area traffic
    func createMarketAreaTraffic(for lane: Lane) -> Vehicle? {
        return nil
    }
    
    /**
     Should have debugs and statistics
     */
}

extension VehicleSpawner {
    
    // MARK: - Updated Vehicle Creation with Lane Speed and Additional Multiplier
    func createVehicleWithLaneSpeed(for lane: Lane, baseType: GameConstants.VehicleType, additionalSpeedMultiplier: CGFloat = 1.0) -> Vehicle {
        var vehicle = Vehicle(lane: lane.index, direction: lane.direction, type: baseType)
        
        let baseSpeed = lane.laneSpeed > 0 ? lane.laneSpeed : vehicle.type.speed
        let vehicleModifier = getVehicleSpeedModifier(for: baseType)
        // Use absolute speed, direction handled by startX and update logic
        vehicle.speed = abs(baseSpeed * vehicleModifier * additionalSpeedMultiplier)
        applyLaneModifications(to: &vehicle, lane: lane)
        
        return vehicle
    }
    
    private func getVehicleSpeedModifier(for vehicleType: GameConstants.VehicleType) -> CGFloat {
        switch vehicleType {
        case .motorbike: return 1.05  // Slightly faster
        case .car: return 1.0         // Base speed
        case .bus: return 0.95        // Slightly slower
        case .cyclo: return 0.9       // Slower but not much
        }
    }
}
