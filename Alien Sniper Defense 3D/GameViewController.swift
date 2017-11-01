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



struct SceneConfiguration{
    var numberOfSpawnPoints: Int
    var velocityLowerLimit: Int
    var velocityUpperLimit: Int
    var extraLetterTypes: [LetterBoxGenerator.LetterType]?
    //TODO: spawning times can be adjusted as well
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
    var randomTimeDist = GKRandomDistribution(lowestValue: 3, highestValue: 5)
    
    var totalNodesSpawned: Int = 0
    var canStartSpawning: Bool = false
    
    var targetWord: String!
    var tempWord: String!
    var wordInProgress: String!
    var wordsArray = [String]()
    
    /** Preamble Nodes **/
    
    var gameStartNode: SCNNode!
    var gameDifficultyNode: SCNNode!
    var gameTitleNode: SCNNode!
    
    var easyDifficultyNode: SCNNode!
    var mediumDifficultyNode: SCNNode!
    var hardDifficultyNode: SCNNode!
    
    var worldNode: SCNNode!
    var overlayNode: SCNNode!
    
    /**  Menu Options Nodes **/
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
        startPreamble()

    }
    
    
    func loadTargetWords(){
        
        let path = Bundle.main.path(forResource: "TargetWordsSimple", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: path!)
        let key = game.difficultyLevel.rawValue
        
        self.wordsArray = dictionary![key] as! Array<String>
    }
    
    func startGame(){
        
        preambleScene.isPaused = true
        loadGame(isRestart: false, gameLevel: 1)
    }
    
    func loadGame(isRestart: Bool = false, gameLevel: Int){
        
        let transition = SKTransition.doorsOpenVertical(withDuration: 1.00)
        
        
        if(!isRestart || (gameLevel != self.game.level)){
            self.setupGameScene()
            self.setupGameSceneBackground()
            self.game.level = gameLevel
        }
        
        self.totalNodesSpawned = 0
        hudManager.lives = 3
        canStartSpawning = false
        self.gameScene.isPaused = false

        
        scnView.present(gameScene, with: transition, incomingPointOfView: nil, completionHandler: {
            
            self.game.state = .playing
            
            if(!isRestart){
                self.setRandomTargetWord()
                self.setupWorldNode()
                self.setupCamera()
                self.setupHUD()
                self.createRandomClouds(number: 5)
                self.setupOverlayNodes()
            } else {
                self.resetOverlayNodePositions()
            }
            
            
            self.wordInProgress = ""
            self.hudManager.wordInProgress = ""
            self.tempWord = self.targetWord

          

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
        
        gameScene.background.contents = game.getRandomBackgroundPath()

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
        
       self.resetOverlayNodePositions()
        
    }
    
    
    func resetOverlayNodePositions(){
        let (cameraXPos,cameraYPos,cameraZPos) = (self.cameraNode.position.x,self.cameraNode.position.y,self.cameraNode.position.z)
        
        
        self.positionMainMenu(isInFrontOfCamera: false)
        positionGameLossMenu(hasLostGame: false)
        positionGameWinMenu(hasWonGame: false)
        
        self.pauseGamePlane.position = SCNVector3(cameraXPos+1, cameraYPos-2.5, cameraZPos-5)
        
        let introPanelCloud = CloudGenerator.GetTargetWordCloud(with: self.cameraNode.position, string1: "Level \(self.game.level)", string2: "Target Word:", string3: self.targetWord)
        
        overlayNode.addChildNode(introPanelCloud)
        
        introPanelCloud.rotation = SCNVector4(x: 1, y: 0, z: 0, w: 3.14159265)

    }
    
    func positionGameWinMenu(hasWonGame: Bool){
        
        let (cameraXPos,cameraYPos,cameraZPos) = (self.cameraNode.position.x,self.cameraNode.position.y,self.cameraNode.position.z)

        if(hasWonGame){
            self.backToMainMenuPlane.position = SCNVector3(cameraXPos, cameraYPos+1, cameraZPos-5)
            self.nextLevelPlane.position = SCNVector3(cameraXPos, cameraYPos, cameraZPos-5)
        } else {
            self.backToMainMenuPlane.position = SCNVector3(cameraXPos, cameraYPos+1, cameraZPos+5)
            self.nextLevelPlane.position = SCNVector3(cameraXPos, cameraYPos, cameraZPos+5)
        }
  

    }
    
    func positionGameLossMenu(hasLostGame: Bool){
        let (cameraXPos,cameraYPos,cameraZPos) = (self.cameraNode.position.x,self.cameraNode.position.y,self.cameraNode.position.z)

        if(hasLostGame){
            self.backToMainMenuPlane.position = SCNVector3(cameraXPos, cameraYPos+1, cameraZPos-5)
            self.restartGamePlane.position = SCNVector3(cameraXPos, cameraYPos, cameraZPos-5)
        } else {
            self.backToMainMenuPlane.position = SCNVector3(cameraXPos, cameraYPos+1, cameraZPos+5)
            self.restartGamePlane.position = SCNVector3(cameraXPos, cameraYPos, cameraZPos+5)
        }
      

        
    }
    
   
    
    func positionMainMenu(isInFrontOfCamera: Bool){
        let (cameraXPos,cameraYPos,cameraZPos) = (self.cameraNode.position.x,self.cameraNode.position.y,self.cameraNode.position.z)
        
        if(isInFrontOfCamera){
            self.backToMainMenuPlane.position = SCNVector3(cameraXPos, cameraYPos+1, cameraZPos-5)
            self.restartGamePlane.position = SCNVector3(cameraXPos, cameraYPos, cameraZPos-5)
            self.saveGamePlane.position = SCNVector3(cameraXPos, cameraYPos-1, cameraZPos-5)
        } else {
            self.backToMainMenuPlane.position = SCNVector3(cameraXPos, cameraYPos+1, cameraZPos+5)
            self.restartGamePlane.position = SCNVector3(cameraXPos, cameraYPos, cameraZPos+5)
            self.saveGamePlane.position = SCNVector3(cameraXPos, cameraYPos-1, cameraZPos+5)
            
        }
        

    }
    
   
    
    
    func startPreamble(){
        
        let transition = SKTransition.doorsOpenVertical(withDuration: 1.00)
        
        if(gameScene != nil){
            gameScene.isPaused = true
        }
        
        scnView.present(preambleScene, with: transition, incomingPointOfView: nil, completionHandler: {
            
            self.game.state = .tapToPlay
            self.positionPreambleMainMenu(inFrontOfCamera: true)
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
     
        easyDifficultyNode = preambleScene.rootNode.childNode(withName: "EasyBox", recursively: true)
        mediumDifficultyNode = preambleScene.rootNode.childNode(withName: "MediumBox", recursively: true)
        hardDifficultyNode = preambleScene.rootNode.childNode(withName: "HardBox", recursively: true)

    
        currentScene = preambleScene
        currentScene.isPaused = false
        game.state = .tapToPlay
    }
    
    func positionPreambleMainMenu(inFrontOfCamera: Bool){
        
        if(inFrontOfCamera){
            gameTitleNode.runAction(SCNAction.move(to: PreambleNodePositions.GameTitleNodeActivePos, duration: 1.00), completionHandler: {})
            gameStartNode.runAction(SCNAction.move(to: PreambleNodePositions.GameStartNodeActivePos, duration: 1.00), completionHandler: {})
            gameDifficultyNode.runAction(SCNAction.move(to: PreambleNodePositions.GameDifficultyNodeActivePos, duration: 1.00), completionHandler: {})
            
        } else {
            gameTitleNode.runAction(SCNAction.move(to: PreambleNodePositions.GameTitleNodeInactivePos, duration: 1.00), completionHandler: {})
            gameStartNode.runAction(SCNAction.move(to: PreambleNodePositions.GameStartNodeInactivePos, duration: 1.00), completionHandler: {})
            gameDifficultyNode.runAction(SCNAction.move(to: PreambleNodePositions.GameDifficultyNodeInactivePos, duration: 1.00), completionHandler: {})
        }
    }
    
    func positionPreambleDifficultyMenu(isInFrontOfCamera: Bool){
        
        if(isInFrontOfCamera){
            self.easyDifficultyNode.runAction(SCNAction.move(to: PreambleNodePositions.EasyDifficultyNodeActivePos, duration: 1.00), completionHandler: {})
            self.mediumDifficultyNode.runAction(SCNAction.move(to: PreambleNodePositions.MediumDifficultyNodeActivePos, duration: 1.00), completionHandler: {})
            self.hardDifficultyNode.runAction(SCNAction.move(to: PreambleNodePositions.HardDifficultyNodeActivePos, duration: 1.00), completionHandler: {})
        } else {
            self.easyDifficultyNode.runAction(SCNAction.move(to: PreambleNodePositions.EasyDifficultyNodeInactivePos, duration: 0.50), completionHandler: {})
            self.mediumDifficultyNode.runAction(SCNAction.move(to: PreambleNodePositions.MediumDifficultyNodeInactivePos, duration: 0.50), completionHandler: {})
            self.hardDifficultyNode.runAction(SCNAction.move(to: PreambleNodePositions.HardDifficultyNodeInactivePos, duration: 0.50), completionHandler: {})
            
        }
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
        hudManager.hudNode.position = SCNVector3(0.0, 9.5, 0.0)
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
        
        totalNodesSpawned += 1
        hudManager.setTotalNodesSpawned(totalNodes: self.totalNodesSpawned)
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
            print("Yes, you got the correct letter")
            self.wordInProgress = self.wordInProgress.appending(letter)
            
            self.tempWord.removeFirst()
            
            hudManager.setWordInProgress(wordInProgress: self.wordInProgress)
            totalNodesSpawned -= 1
            hudManager.setTotalNodesSpawned(totalNodes: self.totalNodesSpawned)
        } else {
            print("Wrong letter, you lost a life")
            hudManager.lives -= 1
        }
        
        destroyNode(node: node, completion: nil)
    }
    
    
    func destroyNode(node: SCNNode, completion: (() -> (Void))?){
        let explosion = createExplosionParticles()
        
        node.addParticleSystem(explosion)
        
        node.runAction(SCNAction.wait(duration: 0.50), completionHandler: {
            node.removeFromParentNode()
    
            if(completion != nil){
                completion!()
            }
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
                        
                        positionPreambleMainMenu(inFrontOfCamera: false)
                        positionPreambleDifficultyMenu(isInFrontOfCamera: true)
                    }
                    
                    if(node.name == "EasyBox"){
                        positionPreambleMainMenu(inFrontOfCamera: true)
                        positionPreambleDifficultyMenu(isInFrontOfCamera: false)
                        game.difficultyLevel = .Easy
                        loadTargetWords()
                    }
                    
                    if(node.name == "MediumBox"){
                        positionPreambleMainMenu(inFrontOfCamera: true)
                        positionPreambleDifficultyMenu(isInFrontOfCamera: false)
                        game.difficultyLevel = .Medium
                        loadTargetWords()
                        
                    }
                    
                    if(node.name == "HardBox"){
                        positionPreambleMainMenu(inFrontOfCamera: true)
                        positionPreambleDifficultyMenu(isInFrontOfCamera: false)
                        game.difficultyLevel = .Hard
                        loadTargetWords()
                        
                    }
                }
                
        
                if(game.state == .missionCompleted){
                    
                    if(node.name == CloudGenerator.MenuNodeType.backMainMenuCloud.rawValue){
                        print("Going back to main menu")
                        startPreamble()
                        positionGameWinMenu(hasWonGame: false)
                    }
                    
                    if(node.name == CloudGenerator.MenuNodeType.nextLevelCloud.rawValue){
                        print("Loading next level")
                        loadGame(isRestart: false, gameLevel: (self.game.level + 1))
                        positionGameWinMenu(hasWonGame: false)


                    }
                }
                
                if(game.state == .gameOver){
                    
                    if(node.name == CloudGenerator.MenuNodeType.restartGameCloud.rawValue){
                        print("Restarting current game scene")
                        loadGame(isRestart: true, gameLevel: self.game.level)
                        positionGameLossMenu(hasLostGame: false)


                    }
                    
                    if(node.name == CloudGenerator.MenuNodeType.backMainMenuCloud.rawValue){
                        print("Back to main menu")
                        startPreamble()
                        positionGameLossMenu(hasLostGame: false)
                    }
                    
                }
                
                if(game.state == .playing){
                    
                    if(node.name == CloudGenerator.MenuNodeType.pauseGameCloud.rawValue){
                        print("YOU TOUCHED THE PAUSE BUTTON")
                        
                        if(self.worldNode.isPaused){
                            self.positionMainMenu(isInFrontOfCamera: false)
                            self.worldNode.isPaused = false
                        } else {
                            self.positionMainMenu(isInFrontOfCamera: true)
                            self.worldNode.isPaused = true
                        }
                        return
                    }
                    
                    
                  
                    if(node.name == CloudGenerator.MenuNodeType.restartGameCloud.rawValue){
                        loadGame(isRestart: true, gameLevel: self.game.level)
                        return
                    }
                    
                    if(node.name == CloudGenerator.MenuNodeType.backMainMenuCloud.rawValue){
                        startPreamble()
                        return
                    }
                    
                    if(node.name == CloudGenerator.MenuNodeType.saveGameCloud.rawValue){
                        return
                    }
                    
                    if(node.name == "IntroPanel"){
                        destroyNode(node: node, completion: {
                            
                            self.canStartSpawning = true

                        })
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
            
            if(!worldNode.isPaused && canStartSpawning){
                spawnLetterRandomSpawnPoint()
            }
            spawnTime = time + Double(randomTimeDist.nextUniform())
         
            
        }
        
        
        if(self.tempWord.isEmpty || self.tempWord == ""){
            print("You've won the game!")
            game.state = .missionCompleted
            positionGameWinMenu(hasWonGame: true)
        }
        
        if(self.hudManager.lives <= 0 || self.totalNodesSpawned > game.getSpawnLimit()){
            print("You've lost the game!")
            game.state = .gameOver
            positionGameLossMenu(hasLostGame: true)
            
        }
        
        removeExcessNodes()
        
        hudManager.updateHUD()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
    }
}
