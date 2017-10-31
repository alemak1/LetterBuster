//
//  GameHelper.swift
//  Alien Sniper Defense 3D
//
//  Created by Aleksander Makedonski on 10/29/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import Foundation
import SceneKit

class GameHelper{
    
    enum Difficulty: String{
        case Easy
        case Medium
        case Hard
    }
    
    enum State{
            case playing
            case tapToPlay
            case gameOver
            case missionCompleted
    }
    
    static let sharedInstance = GameHelper()
    
    static let backgroundPaths: [String] = [
     "art.scnassets/Backgrounds/sky1_front.jpg",
     "art.scnassets/Backgrounds/sky2_front.jpg",
     "art.scnassets/Backgrounds/sky3_front.jpg",
     "art.scnassets/Backgrounds/sky4_front.jpg",
     "art.scnassets/Backgrounds/sky5_front.jpg",
     "art.scnassets/Backgrounds/sky1_top.jpg",
     "art.scnassets/Backgrounds/sky2_top.jpg",
     "art.scnassets/Backgrounds/sky3_top.jpg",
     "art.scnassets/Backgrounds/sky4_top.jpg",
     "art.scnassets/Backgrounds/sky5_top.jpg",
    ]
    
    
    private init(){
        
    }
    
    var state: State = .tapToPlay
    var difficultyLevel: Difficulty = .Medium
    var level: Int = 1
    
    func getSpawnLimit() -> Int{
        
        switch self.level {
        case 1...10 where difficultyLevel == .Easy:
            return 15
        case 1...10 where difficultyLevel == .Medium:
            return 25
        case 1...10 where difficultyLevel == .Hard:
            return 35
        default:
            return 50
        }
    }
    
    
    func getRandomBackgroundPath() -> String{
        
        let randomIndex = Int(arc4random_uniform(UInt32(GameHelper.backgroundPaths.count)))
        
        return GameHelper.backgroundPaths[randomIndex]
    }
   
    
}
