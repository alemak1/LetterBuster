//
//  HUDManager.swift
//  Alien Sniper Defense 3D
//
//  Created by Aleksander Makedonski on 10/28/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//


import Foundation
import SceneKit
import SpriteKit

public enum GameStateType {
    case Playing
    case TapToPlay
    case GameOver
}

class HUDManager {
    
    var score:Int
    
    var targetWord: String = String("LOVING")
    var wordInProgress: String = String("LOVING")
    
    var highScore:Int
    var lastScore:Int
    var lives:Int
    var state = GameStateType.TapToPlay
    
    var hudNode:SCNNode!
    var labelNode1:SKLabelNode!
    var labelNode2:SKLabelNode!
    var labelNode3:SKLabelNode!

    
    static let sharedInstance = HUDManager()
    
    var sounds:[String:SCNAudioSource] = [:]
    
    private init() {
        score = 0
        lastScore = 0
        highScore = 0
        lives = 3
        let defaults = UserDefaults.standard
        score = defaults.integer(forKey: "lastScore")
        highScore = defaults.integer(forKey: "highScore")
        
        initHUD()
    }
    
    func saveState() {
        
        lastScore = score
        highScore = max(score, highScore)
        let defaults = UserDefaults.standard
        defaults.set(lastScore, forKey: "lastScore")
        defaults.set(highScore, forKey: "highScore")
    }
    
    func getScoreString(_ length:Int) -> String {
        return String(format: "%0\(length)d", score)
    }
    
    func initHUD() {
        
        let skScene = SKScene(size: CGSize(width: 800, height: 300))
        skScene.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        skScene.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        labelNode1 = SKLabelNode(fontNamed: "Avenir-Bold")
        labelNode1.fontSize = 50
        labelNode1.position.y = 10
        labelNode1.position.x = 0.0
        
        labelNode2 = SKLabelNode(fontNamed: "Avenir-Bold")
        labelNode2.fontSize = 50
        labelNode2.position.y = 90
        labelNode2.position.x = 0.0
        
        labelNode3 = SKLabelNode(fontNamed: "Didot")
        labelNode3.fontSize = 90
        labelNode3.position.y = 170
        labelNode3.position.x = 0.0
        
        
        skScene.addChild(labelNode1)
        skScene.addChild(labelNode2)
        skScene.addChild(labelNode3)

        let plane = SCNPlane(width: 5, height: 1)
        let material = SCNMaterial()
        material.lightingModel = SCNMaterial.LightingModel.constant
        material.isDoubleSided = true
        material.diffuse.contents = skScene
        plane.materials = [material]
        
        hudNode = SCNNode(geometry: plane)
        hudNode.name = "HUD"
        hudNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: 3.14159265)

    }
    
    func setTargetWord(targetWord: String){
            self.targetWord = targetWord
    }
    
    func setWordInProgress(wordInProgress: String){
         self.wordInProgress = wordInProgress
    }
    
    func setLives(lives: Int){
        self.lives = lives
    }
    
    func updateHUD() {
        let targetWordUpperCased = self.targetWord.uppercased()
        let wordInProgressUpperCased = self.wordInProgress.uppercased()
        
        labelNode1.text = "Target Word: \(targetWordUpperCased) "
        labelNode2.text = "Word-in-Progress: \(wordInProgressUpperCased)"
        labelNode3.text = "❤️\(lives)"

    }
    
    func loadSound(_ name:String, fileNamed:String) {
        if let sound = SCNAudioSource(fileNamed: fileNamed) {
            sound.load()
            sounds[name] = sound
        }
    }
    
    func playSound(_ node:SCNNode, name:String) {
        let sound = sounds[name]
        node.runAction(SCNAction.playAudio(sound!, waitForCompletion: false))
    }
    
    func reset() {
        self.targetWord = String()
        self.wordInProgress = String()
        lives = 3
    }
    
    func shakeNode(_ node:SCNNode) {
        let left = SCNAction.move(by: SCNVector3(x: -0.2, y: 0.0, z: 0.0), duration: 0.05)
        let right = SCNAction.move(by: SCNVector3(x: 0.2, y: 0.0, z: 0.0), duration: 0.05)
        let up = SCNAction.move(by: SCNVector3(x: 0.0, y: 0.2, z: 0.0), duration: 0.05)
        let down = SCNAction.move(by: SCNVector3(x: 0.0, y: -0.2, z: 0.0), duration: 0.05)
        
        node.runAction(SCNAction.sequence([
            left, up, down, right, left, right, down, up, right, down, left, up,
            left, up, down, right, left, right, down, up, right, down, left, up]))
    }
    
    
}

