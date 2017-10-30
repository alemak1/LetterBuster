//
//  Cloud.swift
//  Alien Sniper Defense 3D
//
//  Created by Aleksander Makedonski on 10/29/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

class CloudGenerator{
    
    
    enum MenuNodeType: String{
        
        case restartGameCloud
        case saveGameCloud
        case nextLevelCloud
        case pauseGameCloud
        case backMainMenuCloud
        
        func getImagePath() -> String{
            
            return "/art.scnassets/MenuClouds/\(self.rawValue).png"
            
        }
        
        
        
    }
    
    enum CloudType:Int{
    
        case Cloud19 = 19
        case Cloud20
        case Cloud21
        case Cloud22
        case Cloud23
        case Cloud24
        case Cloud25
        case Cloud26
        case Cloud27
        case Cloud28
        case Cloud29
        case Cloud30
        
        
        static let allCloudTypes: [CloudType] = [
            .Cloud19, .Cloud20, .Cloud21, .Cloud22, .Cloud23, .Cloud24, .Cloud25,
            .Cloud26, .Cloud27, .Cloud28, .Cloud29, .Cloud30
        ]
        
        func getImagePath() -> String{
            
           return "/art.scnassets/Clouds/cloud\(self.rawValue).png"
        
        }
        
        
        func getSize() -> CGSize{
            switch self {
            case .Cloud19:
                return CGSize(width: 5.02, height: 0.71)
            case .Cloud20:
                return CGSize(width: 2.73, height: 2.10)
            case .Cloud21:
                return CGSize(width: 3.96, height: 2.30)
            case .Cloud22:
                return CGSize(width: 3.02, height: 2.61)
            case .Cloud23:
                return CGSize(width: 4.06, height: 2.52)
            case .Cloud24:
                return CGSize(width: 3.84, height: 2.74)
            case .Cloud25:
                return CGSize(width: 4.00, height: 3.07)
            case .Cloud26:
                return CGSize(width: 4.54, height: 1.24)
            case .Cloud27:
                return CGSize(width: 5.11, height: 0.65)
            case .Cloud28:
                return CGSize(width: 4.12, height: 0.54)
            case .Cloud29:
                return CGSize(width: 4.45, height: 3.66)
            case .Cloud30:
                return CGSize(width: 3.02, height: 4.22)

            }
        }
    }
    

    static func CreateRandomCloudNode() -> SCNNode{
        
        let xPos = -4 + Int(arc4random_uniform(UInt32(8)))
        let yPos = 1 + Int(arc4random_uniform(UInt32(10)))
        let zPos = -5 - Int(arc4random_uniform(UInt32(10)))
        
        let spawnPoint = SCNVector3(xPos, yPos, zPos)
        
        
        let cloud = CloudGenerator.CreateRandomCloud()
        let cloudNode = SCNNode(geometry: cloud)
        cloudNode.name = "Cloud"
        
        cloudNode.position = spawnPoint
        
        return cloudNode
    }
    
    
    static func CreateRandomCloud() -> SCNPlane{
        
        let randomIdx = Int(arc4random_uniform(UInt32(CloudType.allCloudTypes.count)))
        
        let randomCloudType =  CloudType.allCloudTypes[randomIdx]
        
        
        return CreateCloud(ofType: randomCloudType)
    }
    
    static func CreateCloud(ofType cloudType: CloudType) -> SCNPlane{
        
        
        let size = cloudType.getSize()
        let plane = SCNPlane(width: size.width, height: size.height)
        let material = SCNMaterial()
        material.lightingModel = SCNMaterial.LightingModel.constant
        material.isDoubleSided = true
        material.diffuse.contents = cloudType.getImagePath()
        plane.materials = [material]
        
        return plane
    }
    
    
    static func CreateMenuCloudNode(withMenuNodeType menuNodeType: MenuNodeType) -> SCNNode{
        
        let plane = CreateMenuCloud(withMenuNodeType: menuNodeType)
        let node = SCNNode(geometry: plane)
        node.name = menuNodeType.rawValue
        
        return node
    }
    
    static func CreateMenuCloud(withMenuNodeType menuNodeType: MenuNodeType) -> SCNPlane{
        
        var size = CloudType.Cloud26.getSize()
        
        if(menuNodeType == .pauseGameCloud){
            size = CGSize(width: size.width/4.00, height: size.height/4.00)
        }
        
        let plane = SCNPlane(width: size.width, height: size.height)
        
        let material = SCNMaterial()
        
        material.lightingModel = SCNMaterial.LightingModel.constant
        material.isDoubleSided = true
        material.diffuse.contents = menuNodeType.getImagePath()
        plane.materials = [material]
        
        print("Plane created: \(plane.description)")
        
        return plane
    }
}
