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
    
    private init(){
        
    }
    
    var state: State = .tapToPlay
    var difficultyLevel: Difficulty = .Medium
    var level: Int = 1
    
    
   
    
}
