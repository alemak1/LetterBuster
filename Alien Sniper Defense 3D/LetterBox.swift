//
//  LetterBox.swift
//  Alien Sniper Defense 3D
//
//  Created by Aleksander Makedonski on 10/28/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import Foundation
import SceneKit


class LetterBoxGenerator{
    
    enum LetterStyle: String{
        case Blue
        case Brown
        case Metal
        case Yellow
        case Marble
        case Wood
        case SolidLetterWithYellowBorder
        case EmptyLetterWithYellowBorder
        
        static let allLetterStyles: [LetterStyle] = [.Blue, .Brown,.Metal,.Yellow,.Marble,.Wood,.SolidLetterWithYellowBorder, .EmptyLetterWithYellowBorder]
        
        static func GetRandomLetterStyle() -> LetterStyle{
            
            let randomIdx = Int(arc4random_uniform(UInt32(LetterStyle.allLetterStyles.count)))
            
            return LetterStyle.allLetterStyles[randomIdx]
        }
        
    }
    
    enum LetterType: String{
        case letter_A, letter_B, letter_C, letter_D, letter_E, letter_F, letter_G, letter_H, letter_I
        case letter_J, letter_K, letter_L, letter_M, letter_N, letter_O, letter_P, letter_Q, letter_R
        case letter_S, letter_T, letter_U, letter_V, letter_W, letter_X, letter_Y, letter_Z
    
        static let allLetters: [LetterType] = [
            .letter_A, .letter_B, .letter_C, .letter_D, .letter_E, .letter_F, .letter_G, .letter_H, .letter_I, .letter_J, .letter_K, .letter_L, .letter_M, .letter_N, .letter_O, .letter_P, .letter_Q, .letter_R, .letter_S, .letter_T, .letter_U, .letter_V, .letter_W, .letter_X, .letter_Y, .letter_Z
        ]
        
        static func GetRandomLetterType() -> LetterType{
            
            let randomIdx = Int(arc4random_uniform(UInt32(LetterType.allLetters.count)))
            
            return LetterType.allLetters[randomIdx]
        }
    }
    
   
    
    static func GetRandomLetterBox() -> SCNNode?{
        
        let randomLetterType = LetterType.GetRandomLetterType()
        
        print("The random letter obtained is: \(randomLetterType.rawValue)")
        
        return GetLetterBox(ofType: randomLetterType)
    }
    
    
    static func GetLetterBox(ofType letterType: LetterType) -> SCNNode?{
        
        guard let scene = SCNScene(named: "letters.scn") else {
            print("Error: failed to locate file contained reference nodes for letters ")
            return nil }
        
        guard let letterNode = scene.rootNode.childNode(withName: letterType.rawValue, recursively: false) else { return nil }
        
       letterNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        return letterNode
        
    }
    
  
    
    static func GetRandomLetterExNihilo(forWord word: String?, withAdditionalLetterTypes extraLetterTypes: [LetterType]? = nil) -> SCNNode{
        
        let randomLetterStyle = LetterStyle.GetRandomLetterStyle()
        
        
        var letterType: LetterType? = nil
        
        if let word = word{
            
            var letterTypes: [LetterType] = word.uppercased().characters.map({
                let rawValue = "letter_".appending("\($0)")
                return LetterType(rawValue: rawValue)!
            })
            
            if let extraLetterTypes = extraLetterTypes{
                letterTypes = letterTypes + extraLetterTypes
            }
            
            let idx = Int(arc4random_uniform(UInt32(letterTypes.count)))
            let randomLetterType = letterTypes[idx]
            
            letterType = randomLetterType
           
        } else {
            
            letterType = LetterType.GetRandomLetterType()
            
        }
        

        
        print("The random letter obtained is: \(letterType!.rawValue)")
        
        return LetterBoxGenerator.GetLetterBoxExNihilo(ofType: letterType!, andOfStyle: randomLetterStyle)
    }
    
    static func GetLetterBoxExNihilo(ofType letterType: LetterType, andOfStyle letterStyle: LetterStyle) -> SCNNode{
        
        
        let letterGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        
       
        let textureBasePath =  String("art.scnassets/").appending(letterStyle.rawValue).appending("/")
        let texturePath = textureBasePath.appending(letterType.rawValue)
        let fullTexturePath = texturePath.appending(".png")
        
        letterGeometry.materials.first?.diffuse.contents = fullTexturePath
        
        let letterNode = SCNNode(geometry: letterGeometry)
        
        letterNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        letterNode.name = "\(letterType.rawValue.characters.last!)"

        return letterNode
    }
    
}
