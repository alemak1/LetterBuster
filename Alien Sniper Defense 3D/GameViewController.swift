//
//  GameViewController.swift
//  Alien Sniper Defense 3D
//
//  Created by Aleksander Makedonski on 10/27/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import GameplayKit

class GameViewController: UIViewController {

    
    var scnView: SCNView!
    
    var currentScene: SCNScene{
        set(newScene){
                scnView.scene = newScene
        }
        
        get{
            return scnView.scene!
        }
    }
    
    var cloudSpawnPoints: [SCNVector3]?
    
    var preambleScene: SCNScene!
    var gameScene: SCNScene!

    var cameraNode: SCNNode!
    
    var game = GameHelper.sharedInstance
    
    var hudManager = HUDManager.sharedInstance
    
    var spawnTime: TimeInterval = 3.00
    var randomTimeDist = GKRandomDistribution(lowestValue: 1, highestValue: 3)
    
    var targetWord: String!
    var tempWord: String!
    var wordInProgress: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.targetWord = "Chinese"
        self.wordInProgress = ""
        self.tempWord = self.targetWord
        
        setupView()
        setupInitialScene()
        


    }
    
    func startGame(){
        
        preambleScene.isPaused = true
        let transition = SKTransition.doorsOpenVertical(withDuration: 1.00)
        
        gameScene.background.contents = GameLevel.Level5.getBackgroundPath()
        
        scnView.present(gameScene, with: transition, incomingPointOfView: nil, completionHandler: {
            
            self.game.state = .playing
            self.game.setupSounds()
            self.gameScene.isPaused = false
            self.setupCamera()
            self.setupHUD()
            self.createRandomClouds(number: 5)

        })
    }
    
    func startPreamble(){
        //preambleScene.isPaused = true
        
        let transition = SKTransition.doorsOpenVertical(withDuration: 1.00)
        
        scnView.present(preambleScene, with: transition, incomingPointOfView: nil, completionHandler: {
            
            self.game.state = .tapToPlay
            self.game.setupSounds()
        })
    }
    
    func setupView(){
        scnView = self.view as! SCNView
        scnView.delegate = self
        scnView.isPlaying = true
        
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
    }
   
    func setupInitialScene(){
        
        preambleScene = SCNScene(named: "/art.scnassets/PreambleScene.scn")
        gameScene = SCNScene()
        currentScene = preambleScene
        currentScene.isPaused = false
        game.state = .tapToPlay
    }
    
    func setupLights(){
                // create and add a light to the scene
                let lightNode = SCNNode()
                lightNode.light = SCNLight()
                lightNode.light!.type = .omni
                lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
                gameScene.rootNode.addChildNode(lightNode)
        
                // create and add an ambient light to the scene
                let ambientLightNode = SCNNode()
                ambientLightNode.light = SCNLight()
                ambientLightNode.light!.type = .ambient
                ambientLightNode.light!.color = UIColor.darkGray
                gameScene.rootNode.addChildNode(ambientLightNode)
    }
    
    func setupCamera(){
        
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0.0, 5.0, 10.0)
        gameScene.rootNode.addChildNode(cameraNode)
        
    }
    
    
    func setupHUD(){
        
        self.gameScene.rootNode.addChildNode(hudManager.hudNode)
        hudManager.hudNode.position = SCNVector3(0.0, 10.0, 0.0)
        hudManager.setTargetWord(targetWord: self.targetWord)
    }
    
    
    func spawnLetterRandomSpawnPoint(){
        
        if(game.state != .playing){
            return
        }
        
        let spawnPoints: [SpawnPoint] = [
            .BehindCamera(self.cameraNode.position),
            .Top(self.cameraNode.position),
            .Bottom(self.cameraNode.position),
            .Left(self.cameraNode.position),
            .Right(self.cameraNode.position),

        ]
        
        let randomIdx = Int(arc4random_uniform(UInt32(spawnPoints.count)))
        let randomSpawnPoint = spawnPoints[randomIdx]
        
        spawnLetter(fromSpawnPoint: randomSpawnPoint)
        
    }
    
    func spawnLetter(fromSpawnPoint spawnPoint: SpawnPoint){
        
        if(game.state != .playing){
            return
        }
        
        let spawnPosition = spawnPoint.getRandomPoint()
        
        let randomLetter = LetterBoxGenerator.GetRandomLetterExNihilo(forWord: self.targetWord)
        randomLetter.position = spawnPosition
        
        gameScene.rootNode.addChildNode(randomLetter)
        
       
        let (direction, position) = spawnPoint.getImpulseParameters()
        randomLetter.physicsBody?.applyForce(direction, at: position, asImpulse: true)
        
            

    }
    
    
    func createExplosionParticles() -> SCNParticleSystem{
        
        let explosion = SCNParticleSystem(named: "explosion.scnp", inDirectory: nil)!
        
        return explosion
    }
    
    func createRandomClouds(number: Int){
        
        print("Creating \(number) random clouds")
        
        for idx in 0..<number{
            print("Creating cloud number \(idx)")
            createSingleRandomCloud()
        }
        
        if let cloudSpawnPoints = self.cloudSpawnPoints{
            cloudSpawnPoints.forEach({
                
                print("A cloud spawn point exists at x: \($0.x), y: \($0.y), z: \($0.z)")
            })
        }
    }
    
    func createSingleRandomCloud(){
        
        let cloudNode = CloudGenerator.CreateRandomCloudNode()
        
        self.gameScene.rootNode.addChildNode(cloudNode)
        
        let spawnPoint = SCNVector3(cloudNode.position.x, cloudNode.position.y, cloudNode.position.z-2)
        
        if self.cloudSpawnPoints == nil{
            self.cloudSpawnPoints = [SCNVector3]()
            self.cloudSpawnPoints!.append(spawnPoint)

        } else {
            self.cloudSpawnPoints!.append(spawnPoint)
        }
    }
    
    func handleTouchFor(node: SCNNode){
        
        let letter = node.name!
        
        let nextLetter = "\(self.tempWord.uppercased().first!)"
        
        if letter == nextLetter{
            print("Yes, you got the corret letter")
            self.wordInProgress = self.wordInProgress.appending(letter)
            
            self.tempWord.removeFirst()
            
            hudManager.setWordInProgress(wordInProgress: self.wordInProgress)
        } else {
            print("Wrong letter, you lost a life")
            hudManager.lives -= 1
        }
        
        let explosion = createExplosionParticles()
    
        node.addParticleSystem(explosion)
        
        node.runAction(SCNAction.wait(duration: 0.50), completionHandler: {
            node.removeFromParentNode()

        })
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    
        
        
            let touch = touches.first!
            let location = touch.location(in: scnView)
        
            let hitResults = scnView.hitTest(location, options: nil)
        
            if let node = hitResults.first?.node{
            
               
                if(game.state == .tapToPlay){
                    if(node.name == "StartGame"){
                        print("Touched the start game button")
                        startGame()
                    }
                        
                    if(node.name == "DifficultyBox"){
                        print("Touched the diffiuclt box")
                        
                    
                        let axisAngle = SCNVector4(x: 10.0, y: 10.0, z: 0.0, w: 90.0)
                        node.runAction(SCNAction.rotate(toAxisAngle: axisAngle, duration: 1.00))
                    }
                }
                
        
                
                if(game.state == .playing){
                    
                    
                    if(node.name == "HUD" || node.name == "Cloud"){
                        return
                    }
                    
                    
                    handleTouchFor(node: node)

                }
            
            
            }
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func removeExcessNodes(){
        for node in gameScene.rootNode.childNodes{
            if node.presentation.position.y < -2{
                node.removeFromParentNode()
            }
        }
    }

}


extension GameViewController: SCNSceneRendererDelegate{
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if(time > spawnTime){
            
            spawnLetterRandomSpawnPoint()
            spawnTime = time + Double(randomTimeDist.nextUniform())
        }
        
        removeExcessNodes()
        
        hudManager.updateHUD()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
    }
}
