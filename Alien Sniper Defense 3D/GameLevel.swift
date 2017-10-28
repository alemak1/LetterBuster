//
//  GameLevel.swift
//  Alien Sniper Defense 3D
//
//  Created by Aleksander Makedonski on 10/28/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import Foundation

enum GameLevel{
    case Level1, Level2, Level3, Level4, Level5
    case Level6, Level7, Level8, Level9, Level10
    
    func getBackgroundPath() -> String{
        switch self {
        case .Level1:
            return "art.scnassets/Backgrounds/sky1_front.jpg"
        case .Level2:
            return "art.scnassets/Backgrounds/sky2_front.jpg"
        case .Level3:
            return "art.scnassets/Backgrounds/sky3_front.jpg"
        case .Level4:
            return "art.scnassets/Backgrounds/sky4_front.jpg"
        case .Level5:
            return "art.scnassets/Backgrounds/sky5_front.jpg"
        case .Level6:
            return "art.scnassets/Backgrounds/sky1_top.jpg"
        case .Level7:
            return "art.scnassets/Backgrounds/sky2_top.jpg"
        case .Level8:
            return "art.scnassets/Backgrounds/sky3_top.jpg"
        case .Level9:
            return "art.scnassets/Backgrounds/sky4_top.jpg"
        case .Level10:
            return "art.scnassets/Backgrounds/sky5_top.jpg"
        }
    }
}
