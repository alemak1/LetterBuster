//
//  SpawnPoint.swift
//  Alien Sniper Defense 3D
//
//  Created by Aleksander Makedonski on 10/29/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit
import SceneKit

enum SpawnPoint{
    
    case Left(SCNVector3)
    case Right(SCNVector3)
    case Top(SCNVector3)
    case Bottom(SCNVector3)
    case BehindCamera(SCNVector3)
    
    func getRandomPoint() -> SCNVector3{
        
        
        switch self {
        case .Left(let cameraPosition):
            return SCNVector3(cameraPosition.x-7, -2, -5)
        case .Right(let cameraPosition):
            return SCNVector3(cameraPosition.x+7, -2, -10)
        case .BehindCamera(let cameraPosition):
            return SCNVector3(cameraPosition.x, cameraPosition.y-3, cameraPosition.z+2)
        case .Bottom(let cameraPosition):
            return SCNVector3(cameraPosition.x, cameraPosition.y-5.00, -10)
        case .Top(let cameraPosition):
            return SCNVector3(cameraPosition.x, cameraPosition.y+15.00, -10)
        }
        
    }
    
    func getImpulseParameters() -> (SCNVector3,SCNVector3){
        let randomSrc = GKRandomSource()
        
        var randomDistX: GKRandomDistribution!
        var randomDistY: GKRandomDistribution!
        var randomDistZ: GKRandomDistribution!
        
        switch self {
            /** Letters are dropped from the top of the screen, so no impulse is applied in the y or z direction **/
        case .Top( _):
            randomDistX = GKRandomDistribution(randomSource: randomSrc, lowestValue: -2, highestValue: 2)
            randomDistY = GKRandomDistribution(randomSource: randomSrc, lowestValue: 0, highestValue: 0)
            randomDistZ = GKRandomDistribution(randomSource: randomSrc, lowestValue: -2, highestValue: 2)
        case .BehindCamera( _):
            randomDistX = GKRandomDistribution(randomSource: randomSrc, lowestValue: -1, highestValue: 1)
            randomDistY = GKRandomDistribution(randomSource: randomSrc, lowestValue: 7, highestValue: 14)
            randomDistZ = GKRandomDistribution(randomSource: randomSrc, lowestValue: -10, highestValue: -2)
        case .Left( _):
            randomDistX = GKRandomDistribution(randomSource: randomSrc, lowestValue: 2, highestValue: 8)
            randomDistY = GKRandomDistribution(randomSource: randomSrc, lowestValue: 12, highestValue: 20)
            randomDistZ = GKRandomDistribution(randomSource: randomSrc, lowestValue: 0, highestValue: 0)
        case .Right( _):
            randomDistX = GKRandomDistribution(randomSource: randomSrc, lowestValue: -10, highestValue: -2)
            randomDistY = GKRandomDistribution(randomSource: randomSrc, lowestValue: 12, highestValue: 20)
            randomDistZ = GKRandomDistribution(randomSource: randomSrc, lowestValue: 0, highestValue: 0)
        case .Bottom(_):
            randomDistX = GKRandomDistribution(randomSource: randomSrc, lowestValue: -2, highestValue: 2)
            randomDistY = GKRandomDistribution(randomSource: randomSrc, lowestValue: 10, highestValue: 15)
            randomDistZ = GKRandomDistribution(randomSource: randomSrc, lowestValue: 0, highestValue: 0)
            
        }
        
        let randomX = randomDistX.nextInt()
        let randomY = randomDistY.nextInt()
        let randomZ = randomDistZ.nextInt()
        
        let direction = SCNVector3(randomX, randomY, randomZ)
        let position = SCNVector3(0.05, 0.05, 0.05)
        
        return (direction,position)
    }
}
