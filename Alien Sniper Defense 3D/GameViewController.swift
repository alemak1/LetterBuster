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

class PreambleNodes{
    
    static let GameStartNodeActivePos = SCNVector3(-0.250, 1.50, -2.0)
    static let GameDifficultyNodeActivePos = SCNVector3(-0.250, -0.90, -2.0)
    static let GameTitleNodeActivePos = SCNVector3(-0.250, 0.385, -2.0)
    
    static let GameStartNodeInactivePos = SCNVector3(-0.2500, 1.50, -6.7)
    static let GameDifficultyNodeInactivePos = SCNVector3(-0.2500, -0.90, -6.7)
    static let GameTitleNodeInactivePos = SCNVector3(-0.2500, 0.385, -6.7)

}

struct SceneConfiguration{
    var numberOfSpawnPoints: Int
    var velocityLowerLimit: Int
    var velocityUpperLimit: Int
    var extraLetterTypes: [LetterBoxGenerator.LetterType]?
}



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
    var wordsArray = [String]()
    
    var gameStartNode: SCNNode!
    var gameDifficultyNode: SCNNode!
    var gameTitleNode: SCNNode!
    
    
    var worldNode: SCNNode!
    var overlayNode: SCNNode!
    
    var backToMainMenuPlane: SCNNode!
    var restartGamePlane: SCNNode!
    var nextLevelPlane: SCNNode!
    var pauseGamePlane: SCNNode!
    var saveGamePlane: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTargetWords()
        setupView()
        setupInitialScene()


    }
    
    
    func loadTargetWords(){
        
        let path = Bundle.main.path(forResource: "TargetWordsSimple", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)
        let key = game.difficultyLevel.rawValue
        
        self.wordsArray = dictionary![key] as! Array<String>
    }
    
    func startGame(){
        
        preambleScene.isPaused = true
        let transition = SKTransition.doorsOpenVertical(withDuration: 1.00)
        
        self.setupGameScene()
        self.setupGameSceneBackground()

        scnView.present(gameScene, with: transition, incomingPointOfView: nil, completionHandler: {
            
            self.game.state = .playing
            
            self.setRandomTargetWord()
            self.setupWorldNode()
            self.setupCamera()
            self.setupHUD()
            self.createRandomClouds(number: 5)
            self.setupOverlayNodes()

        })
    }
    
    func setRandomTargetWord(){
        let randomIndex = Int(arc4random_uniform(UInt32(self.wordsArray.count)))
        let randomWord = self.wordsArray[randomIndex]
        
        self.setTargetWord(targetWord: randomWord)
        
    }
    
    func setTargetWord(targetWord: String){
        self.targetWord = targetWord
        self.wordInProgress = ""
        self.tempWord = self.targetWord
        self.hudManager.configureHUDStrings(withTargetWord: self.targetWord)
        
    }
    
    func setupGameSceneBackground(){
        
        gameScene.background.contents = GameLevel.Level5.getBackgroundPath()

    }
    
    func setupOverlayNodes(){
        
        self.overlayNode = SCNNode()
        self.overlayNode.name = "OverlayNode"
        self.overlayNode.position = SCNVector3.init(0.0, 0.0, 0.0)
        self.gameScene.rootNode.addChildNode(self.overlayNode)
        
        self.backToMainMenuPlane = CloudGenerator.CreateMenuCloudNode(withMenuNodeType: .backMainMenuCloud)
        self.pauseGamePlane = CloudGenerator.CreateMenuCloudNode(withMenuNodeType: .pauseGameCloud)
        self.restartGamePlane = CloudGenerator.CreateMenuCloudNode(withMenuNodeType: .restartGameCloud)
        self.saveGamePlane = CloudGenerator.CreateMenuCloudNode(withMenuNodeType: .saveGameCloud)
        self.nextLevelPlane = CloudGenerator.CreateMenuCloudNode(withMenuNodeType: .nextLevelCloud)
        
        overlayNode.addChildNode(self.backToMainMenuPlane)
        overlayNode.addChildNode(self.pauseGamePlane)
        overlayNode.addChildNode(self.restartGamePlane)
        overlayNode.addChildNode(self.saveGamePlane)
        overlayNode.addChildNode(self.nextLevelPlane)
        
        let (cameraXPos,cameraYPos,cameraZPos) = (self.cameraNode.position.x,self.cameraNode.position.y,self.cameraNode.position.z)
        
    
        self.positionMenuBehindCamera()
        
        self.nextLevelPlane.position = SCNVector3(cameraXPos, cameraYPos, cameraZPos+20)
        self.pauseGamePlane.position = SCNVector3(cameraXPos+1, cameraYPos-2.5, cameraZPos-5)
        
        let introPanelCloud = CloudGenerator.GetTargetWordCloud(with: self.cameraNode.position, string1: "Level 1", string2: "Target Word:", string3: self.targetWord)
        
        overlayNode.addChildNode(introPanelCloud)
        
        introPanelCloud.rotation = SCNVector4(x: 1, y: 0, z: 0, w: 3.14159265)

        
    }
    
    func positionGameWinMenuInFrontOfCamera(){
        
        let (cameraXPos,cameraYPos,cameraZPos) = (self.cameraNode.position.x,self.cameraNode.position.y,self.cameraNode.position.z)

        self.backToMainMenuPlane.position = SCNVector3(cameraXPos, cameraYPos+1, cameraZPos-5)
        self.nextLevelPlane.position = SCNVector3(cameraXPos, cameraYPos, cameraZPos-5)

    }
    
    func positionGameLossMenuInFrontOfCamera(){
        let (cameraXPos,cameraYPos,cameraZPos) = (self.cameraNode.position.x,self.cameraNode.position.y,self.cameraNode.position.z)

        self.backToMainMenuPlane.position = SCNVector3(cameraXPos, cameraYPos+1, cameraZPos-5)
        self.restartGamePlane.position = SCNVector3(cameraXPos, cameraYPos, cameraZPos-5)

        
    }
    
    
    func positionMenuInFrontOfCamera(){
        let (cameraXPos,cameraYPos,cameraZPos) = (self.cameraNode.position.x,self.cameraNode.position.y,self.cameraNode.position.z)
        
        
        self.backToMainMenuPlane.position = SCNVector3(cameraXPos, cameraYPos+1, cameraZPos-5)
        self.restartGamePlane.position = SCNVector3(cameraXPos, cameraYPos, cameraZPos-5)
        self.saveGamePlane.position = SCNVector3(cameraXPos, cameraYPos-1, cameraZPos-5)
        

    }
    
    func positionMenuBehindCamera(){
        let (cameraXPos,cameraYPos,cameraZPos) = (self.cameraNode.position.x,self.cameraNode.position.y,self.cameraNode.position.z)
        
        
        self.backToMainMenuPlane.position = SCNVector3(cameraXPos, cameraYPos+1, cameraZPos+5)
        self.restartGamePlane.position = SCNVector3(cameraXPos, cameraYPos, cameraZPos+5)
        self.saveGamePlane.position = SCNVector3(cameraXPos, cameraYPos-1, cameraZPos+5)
        

        
    }
    
    
    func startPreamble(){
        //preambleScene.isPaused = true
        
        let transition = SKTransition.doorsOpenVertical(withDuration: 1.00)
        
        scnView.present(preambleScene, with: transition, incomingPointOfView: nil, completionHandler: {
            
            self.game.state = .tapToPlay
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
       
        gameStartNode = preambleScene.rootNode.childNode(withName: "StartGame", recursively: true)
        gameDifficultyNode = preambleScene.rootNode.childNode(withName: "DifficultyBox", recursively: true)
        gameTitleNode = preambleScene.rootNode.childNode(withName: "LetterBox", recursively: true)
        
       
        gameTitleNode.runAction(SCNAction.move(to: PreambleNodes.GameTitleNodeActivePos, duration: 1.00), completionHandler: {})
        gameStartNode.runAction(SCNAction.move(to: PreambleNodes.GameStartNodeActivePos, duration: 1.00), completionHandler: {})
        gameDifficultyNode.runAction(SCNAction.move(to: PreambleNodes.GameDifficultyNodeActivePos, duration: 1.00), completionHandler: {})
        
        
        currentScene = preambleScene
        currentScene.isPaused = false
        game.state = .tapToPlay
    }
    
    
    func setupGameScene(){
        gameScene = SCNScene()
        self.gameScene.isPaused = false


    }
    
    func setupWorldNode(){
        self.worldNode = SCNNode()
        self.worldNode.position = SCNVector3.init(0.0, 0.0, 0.0)
        self.worldNode.isPaused = true
        gameScene.rootNode.addChildNode(self.worldNode)
    }
    
    func setupLights(){
                // create and add a light to the scene
                let lightNode = SCNNode()
                lightNode.light = SCNLight()
                lightNode.light!.type = .omni
                lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
                worldNode.addChildNode(lightNode)
        
                // create and add an ambient light to the scene
                let ambientLightNode = SCNNode()
                ambientLightNode.light = SCNLight()
                ambientLightNode.light!.type = .ambient
                ambientLightNode.light!.color = UIColor.darkGray
                worldNode.addChildNode(ambientLightNode)
    }
    
    func setupCamera(){
        
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0.0, 5.0, 10.0)
        worldNode.addChildNode(cameraNode)
        
    }
    
    
    func setupHUD(){
        
        worldNode.addChildNode(hudManager.hudNode)
        hudManager.hudNode.position = SCNVector3(0.0, 10.0, 0.0)
        hudManager.setTargetWord(targetWord: self.targetWord)
    }
    
    
    func spawnLetterRandomSpawnPoint(){
        
        if(game.state != .playing){
            return
        }
        
        var spawnPoints: [SpawnPoint] = [
            .BehindCamera(self.cameraNode.position),
            .Top(self.cameraNode.position),
            .Bottom(self.cameraNode.position),
            .Left(self.cameraNode.position),
            .Right(self.cameraNode.position),

        ]
        
        
        if let cloudSpawnPoints = self.cloudSpawnPoints{
            spawnPoints.append(SpawnPoint.CloudSpawnPoints(cloudSpawnPoints))
        }
        
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
        
        worldNode.addChildNode(randomLetter)
        
       
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
        
        worldNode.addChildNode(cloudNode)
        
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
        
        destroyNode(node: node)
    }
    
    
    func destroyNode(node: SCNNode){
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
                    
                    if(node.name == CloudGenerator.MenuNodeType.pauseGameCloud.rawValue){
                        print("YOU TOUCHED THE PAUSE BUTTON")
                        
                        if(self.worldNode.isPaused){
                            self.positionMenuBehindCamera()
                            self.worldNode.isPaused = false
                        } else {
                            self.positionMenuInFrontOfCamera()
                            self.worldNode.isPaused = true
                        }
                        return
                    }
                    
                    
                    if(node.name == CloudGenerator.MenuNodeType.nextLevelCloud.rawValue){
                        return
                    }
                    
                    if(node.name == CloudGenerator.MenuNodeType.restartGameCloud.rawValue){
                        return
                    }
                    
                    if(node.name == CloudGenerator.MenuNodeType.backMainMenuCloud.rawValue){
                        return
                    }
                    
                    if(node.name == CloudGenerator.MenuNodeType.saveGameCloud.rawValue){
                        return
                    }
                    
                    if(node.name == "IntroPanel"){
                        destroyNode(node: node)
                        worldNode.isPaused = false
                        return
                    }
                    
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
        
        if(game.state != .playing){
            return
        }
        
        
        if(time > spawnTime){
            
            if(!worldNode.isPaused){
                spawnLetterRandomSpawnPoint()
            }
            spawnTime = time + Double(randomTimeDist.nextUniform())
            
            if(self.wordInProgress == self.targetWord){
                print("You've won the game!")
            }
            
            if(self.hudManager.lives <= 0){
                print("You've lost the game!")
            }
            
        }
        
        removeExcessNodes()
        
        hudManager.updateHUD()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
    }
}
