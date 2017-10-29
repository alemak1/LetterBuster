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
    
    enum State{
            case playing
            case tapToPlay
            case gameOver
    }
    
    static let sharedInstance = GameHelper()
    
    private init(){
        
    }
    
    var state: State = .tapToPlay
    
    func setupSounds(){
        
    }
    
    func reset(){
        
    }
    
}
