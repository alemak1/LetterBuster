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
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    
    var hudManager = HUDManager.sharedInstance
    
    var spawnTime: TimeInterval = 3.00
    var randomTimeDist = GKRandomDistribution(lowestValue: 1, highestValue: 3)
    
    var currentWord = "chinese".uppercased()
    var currentLetterIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupView()
        setupScene()
        setupCamera()
        
        setupHUD()
     


    }
    
    func setupView(){
        scnView = self.view as! SCNView
        scnView.delegate = self
        scnView.isPlaying = true
        
        scnView.showsStatistics = true
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = true
    }
   
    func setupScene(){
        
        scnScene = SCNScene()
        scnView.scene = self.scnScene
        
        
        scnScene.background.contents = GameLevel.Level5.getBackgroundPath()
    }
    
    func setupLights(){
                // create and add a light to the scene
                let lightNode = SCNNode()
                lightNode.light = SCNLight()
                lightNode.light!.type = .omni
                lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
                scnScene.rootNode.addChildNode(lightNode)
        
                // create and add an ambient light to the scene
                let ambientLightNode = SCNNode()
                ambientLightNode.light = SCNLight()
                ambientLightNode.light!.type = .ambient
                ambientLightNode.light!.color = UIColor.darkGray
                scnScene.rootNode.addChildNode(ambientLightNode)
    }
    
    func setupCamera(){
        
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0.0, 5.0, 10.0)
        scnScene.rootNode.addChildNode(cameraNode)
        
    }
    
    
    func setupHUD(){
        
        self.scnScene.rootNode.addChildNode(hudManager.hudNode)
        hudManager.hudNode.position = SCNVector3(0.0, 10.0, 0.0)
    }
    
    
    func spawnLetterRandomSpawnPoint(){
        
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
        
        
        let spawnPosition = spawnPoint.getRandomPoint()
        
        let randomLetter = LetterBoxGenerator.GetRandomLetterExNihilo()
        randomLetter.position = spawnPosition
        
        scnScene.rootNode.addChildNode(randomLetter)
        
       
        let (direction, position) = spawnPoint.getImpulseParameters()
        randomLetter.physicsBody?.applyForce(direction, at: position, asImpulse: true)
        
            

    }
    
    
    func createExplosionParticles() -> SCNParticleSystem{
        
        let explosion = SCNParticleSystem(named: "explosion.scnp", inDirectory: nil)!
        
        return explosion
    }
    
    func handleTouchFor(node: SCNNode){
        
        let letter = node.name!
        print("You shot the letter \(letter)")
        
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
            
            if(node.name == "HUD"){
                return
            }
            
            handleTouchFor(node: node)
            
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
        for node in scnScene.rootNode.childNodes{
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
