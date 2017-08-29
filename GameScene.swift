//
//  GameScene.swift
//  Run
//
//  Created by Sean Corcoran on 7/20/17.
//  Copyright © 2017 Sean Corcoran. All rights reserved.
//

import SpriteKit
import AVFoundation
import GameplayKit

var gameScore:Int = 0
var audioPlayer: AVAudioPlayer = AVAudioPlayer()
var clickSound = SKAction.playSoundFileNamed("clickSound", waitForCompletion: false)
var explosionSound = SKAction.playSoundFileNamed("explosionSound", waitForCompletion: false)
class GameScene: SKScene, SKPhysicsContactDelegate {
    let background1 = SKSpriteNode(imageNamed: "background")
    let background2 = SKSpriteNode(imageNamed: "background")
    let scoreLabel = SKLabelNode(fontNamed: "Gayatri")
    let startLabel = SKLabelNode(fontNamed: "Gayatri")
    let highScoreLabel = SKLabelNode(fontNamed: "Gayatri")
    let optionsLabel = SKLabelNode(fontNamed: "Gayatri")
    let player = SKSpriteNode(imageNamed: "ship")
    let bulletSound = SKAction.playSoundFileNamed("bullet sound", waitForCompletion: false)
    var levelNumber = 0
    let worldNode = SKNode()
    
    
    let menuBackground = SKSpriteNode(imageNamed: "background")
    let areYouSureLabel = SKLabelNode(fontNamed: "Gayatri")
    let musicToggleLabel = SKLabelNode(fontNamed: "Gayatri")
    let soundToggleLabel = SKLabelNode(fontNamed: "Gayatri")
    let mainMenuLabel = SKLabelNode(fontNamed: "Gayatri")
    let returnLabel = SKLabelNode(fontNamed: "Gayatri")
    

    
    enum gameState {
        case preGame
        case inGame
        case postGame
    }
    var currentGameState = gameState.preGame

    
    struct PhysicsCategories {
        static let none : UInt32 = 0
        static let player : UInt32 = 0b1 //1
       // static let bullet : UInt32 = 0b10 //2
        static let enemy : UInt32 = 0b100 //4 (3 = player and bullet)
    
    
        
    }
    
    


    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF )
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max-min) + min
    }
 
    
    let gameArea: CGRect
    
    override init(size: CGSize) {
        
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height/maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    

    override func didMove(to view: SKView) {
        
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        
        do {
        let audioPath = Bundle.main.path(forResource: "backgroundMusic", ofType: "mp3")
         audioPlayer = try AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
        }
        catch {
            //error
        }
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            //error
        }
        audioPlayer.play()
        
        addChild(worldNode)
        
        
        
        
        background1.size = self.size
        background1.anchorPoint = CGPoint(x:0.5, y: 0.0)
        background1.position = CGPoint(x: self.size.width / 2, y: 0)
        background1.zPosition = 0
        self.addChild(background1)
        background2.size = self.size
        background2.anchorPoint = CGPoint(x: 0.5, y: 0)
        background2.position = CGPoint(x: self.size.width/2, y: background1.size.height - 1)
        background2.zPosition = 0
        self.addChild(background2)
 
        
        player.setScale(0.25)
        player.name = "Player"
        player.position = CGPoint(x: self.size.width/2 , y: self.size.height * 0.13)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width * 0.6, height: player.size.height))
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.player
        player.physicsBody!.collisionBitMask = PhysicsCategories.none
        player.physicsBody!.contactTestBitMask = PhysicsCategories.enemy
        self.addChild(player)
        
        
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height * 0.9)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        
        optionsLabel.text = "Options"
        optionsLabel.fontSize = 85
        optionsLabel.fontColor = SKColor.white
        optionsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        optionsLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height * 0.05)
        optionsLabel.zPosition = 100
        self.addChild(optionsLabel)
        
        
        let startLabelGetBigger = SKAction.scale(to: 3, duration: 0.5)
        let startLabelGetSmaller = SKAction.scale(to: 2.5, duration: 0.5)
        let startLabelSizeSequence = SKAction.sequence([startLabelGetBigger, startLabelGetSmaller])
        let runStartLabelSequenceForever = SKAction.repeatForever(startLabelSizeSequence)
        startLabel.run(runStartLabelSequenceForever)
        startLabel.text = "Tap To Begin"
        startLabel.fontColor = SKColor.cyan
        startLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        startLabel.zPosition = 10
        self.addChild(startLabel)
        
        let defaults = UserDefaults()
        var highScore = defaults.integer(forKey: "savedHighScore")
        if gameScore > highScore {
            highScore = gameScore
            defaults.set(highScore, forKey: "savedHighScore")
        }
        highScoreLabel.text = "High Score: \(highScore)"
        highScoreLabel.fontSize = 70
        highScoreLabel.zPosition = 100
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        highScoreLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height * 0.9)
        self.addChild(highScoreLabel)

        
    
    }
    
    //CHANGE SCENE
    func changeScene() {
        
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let sceneTransition = SKTransition.fade(with: UIColor.red, duration: 0.73)
        self.view!.presentScene(sceneToMoveTo, transition: sceneTransition)
        
   
    
    }
    
    
    //UPDATE
   override  func update(_ currentTime: TimeInterval) {
    if currentGameState == gameState.inGame {
        if worldNode.isPaused == false{
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
    
    if gameScore == 500 || gameScore == 1000 || gameScore == 1500 || gameScore == 2000 || gameScore == 3000 {
        startNewLevel()
    }
    
    
        background1.position = CGPoint(x: background1.position.x, y: background1.position.y - 12)
        background2.position = CGPoint(x: background1.position.x, y: background2.position.y - 12)
        
        if background2.position.y < -background1.size.height  {
            background2.position = CGPoint(x: self.size.width / 2, y:background1.position.y + background2.size.height)
        }
        if background1.position.y < -background2.size.height  {
            background1.position = CGPoint(x: self.size.width / 2, y: background2.position.y + background1.size.height)
        }
    }
    }
    }
    //EXPLOSION
    func spawnExplosion(spawnPosition: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.setScale (0)
        explosion.position = spawnPosition
        explosion.zPosition = 3
        self.addChild(explosion)
        let scaleIn = SKAction.scale(to: 0.55, duration: 0.14)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }
    
   
    //CONTACT
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        /*if contact.bodyA == player.physicsBody && contact.bodyB == enemy.physicsBody {
            
        }
      */
        
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
            }
        else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        
        
        
    if body1.categoryBitMask == PhysicsCategories.player && body2.categoryBitMask == PhysicsCategories.enemy {
        
        
        
        if body1.node != nil {
            
            spawnExplosion(spawnPosition: body1.node!.position)
        }
        
        if body2.node != nil {
          
            spawnExplosion(spawnPosition: body2.node!.position)
        }
        body1.node?.removeFromParent()
        body2.node?.removeFromParent()
        
        
        self.removeAllActions()
        
        currentGameState = gameState.postGame
    
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
        
        }
    }
    
       
        
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
       // let randomXEnd = randomXStart
       let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        //POLY PATH
        let offsetX = CGFloat(enemy.size.width * (enemy.anchorPoint.x - 0.25))
        let offsetY = CGFloat(enemy.size.height * (enemy.anchorPoint.y - 0.25))
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x:122-offsetX, y:267-offsetY))
        path.addLine(to: CGPoint(x: 147 - offsetX, y: 262 - offsetY))
        path.addLine(to: CGPoint(x: 178 - offsetX, y: 251 - offsetY))
        path.addLine(to: CGPoint(x: 196 - offsetX, y: 240 - offsetY))
        path.addLine(to: CGPoint(x: 207 - offsetX, y: 200 - offsetY))
        path.addLine(to: CGPoint(x: 196 - offsetX, y: 160 - offsetY))
        path.addLine(to: CGPoint(x: 177 - offsetX, y: 150 - offsetY))
        path.addLine(to: CGPoint(x: 158 - offsetX, y: 143 - offsetY))
        path.addLine(to: CGPoint(x: 147 - offsetX, y: 139 - offsetY))
        path.addLine(to: CGPoint(x: 122 - offsetX, y: 134 - offsetY))
        path.addLine(to: CGPoint(x: 107 - offsetX, y: 134 - offsetY))
        path.addLine(to: CGPoint(x: 101 - offsetX, y: 148 - offsetY))
        path.addLine(to: CGPoint(x: 190 - offsetX, y: 183 - offsetY))
        path.addLine(to: CGPoint(x: 89 - offsetX, y: 217 - offsetY))
        path.addLine(to: CGPoint(x: 101 - offsetX, y: 252 - offsetY))
        path.addLine(to: CGPoint(x: 107 - offsetX, y: 266 - offsetY))
        path.closeSubpath()
        // END POLY PATH
        enemy.setScale (0.55)
        enemy.position = startPoint
        enemy.zPosition = (2)
        enemy.physicsBody = SKPhysicsBody(polygonFrom: path)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.none
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.player
        worldNode.addChild(enemy)
        
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 2.5)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        enemy.run(enemySequence)

        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amounttoRotate = atan2(dy, dx)
        enemy.zRotation = amounttoRotate
    
    
    }
    
    
    
    
    
    func startNewLevel() {
       
        levelNumber += 1
        if worldNode.action(forKey: "spawningEnemies") != nil {
            worldNode.removeAction(forKey: "spawningEnemies")
        }
        
        var timeSubtract = TimeInterval()
        
        switch levelNumber {
        case 1: timeSubtract = 1
        case 2: timeSubtract = 0.8
        case 3: timeSubtract = 0.65
        case 4: timeSubtract = 0.5
        case 5: timeSubtract = 0.3
        case 6: timeSubtract = 0.15
        default: timeSubtract = 0.5
            print("wtf")
        }
        let waitForSpawn = SKAction.wait(forDuration: timeSubtract)
        let spawn = SKAction.run(spawnEnemy)
        let spawnSequence = SKAction.sequence([waitForSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        worldNode.run(spawnForever, withKey: "spawningEnemies")

    }
    
    
    func startGame() {
    currentGameState = gameState.inGame
    
    let fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
    let removeStartLabelAction = SKAction.removeFromParent()
    let deleteStartLabelSequence = SKAction.sequence([fadeOutAction, removeStartLabelAction])
    startLabel.run(deleteStartLabelSequence)
    startNewLevel()
    
    }
 
    
    
    
    
        
     override func touchesMoved(_  touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches , with: event)
        if touches.count > 0 {
            let touch: UITouch = touches.first!
            var position: CGPoint = touch.location(in: self.view)
            position = self.convertPoint(fromView: position)
            if worldNode.isPaused == false {
            player.position = position
            }
            }
    }
    
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == gameState.preGame {
            startGame()
        }
    
        for touch:AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
           
        
            if optionsLabel.contains(pointOfTouch) {
                self.run(clickSound)
                worldNode.isPaused = true
                optionsLabel.text = nil
                
        
                
                areYouSureLabel.text = "Options"
                areYouSureLabel.color = SKColor.white
                areYouSureLabel.fontSize = 130
                areYouSureLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.75)
                areYouSureLabel.zPosition = 100
                self.addChild(areYouSureLabel)
                
                musicToggleLabel.text = "Music OFF"
                musicToggleLabel.fontSize = 85
                musicToggleLabel.fontColor = SKColor.cyan
                musicToggleLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.6)
                musicToggleLabel.zPosition = 100
                self.addChild(musicToggleLabel)
                
                soundToggleLabel.text = "Sound OFF"
                soundToggleLabel.fontSize = 85
                soundToggleLabel.fontColor = SKColor.cyan
                soundToggleLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.45)
                soundToggleLabel.zPosition = 100
                self.addChild(soundToggleLabel)
                
                mainMenuLabel.text = "Return To Main Menu"
                mainMenuLabel.fontColor = SKColor.cyan
                mainMenuLabel.fontSize = 85
                mainMenuLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.3)
                mainMenuLabel.zPosition  = 100
                self.addChild(mainMenuLabel)
                
                
                let returnLabelGetBigger = SKAction.scale(to: 3.5, duration: 0.5)
                let returnLabelGetSmaller = SKAction.scale(to: 3, duration: 0.5)
                let returnLabelSizeSequence = SKAction.sequence([returnLabelGetBigger, returnLabelGetSmaller])
                let runReturnLabelSequenceForever = SKAction.repeatForever(returnLabelSizeSequence)
                returnLabel.text = "Return To Game"
                returnLabel.fontColor = SKColor.cyan
                returnLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.15)
                returnLabel.zPosition = 100
                returnLabel.run(runReturnLabelSequenceForever)
                self.addChild(returnLabel)
            
            }
            
            if musicToggleLabel.contains(pointOfTouch) {
                self.run(clickSound)
            }
                    if musicToggleLabel.contains(pointOfTouch) && musicToggleLabel.text == "Music OFF"  {
                        audioPlayer.stop()
                        musicToggleLabel.text = "Music ON"
                    
                    }
                    else if musicToggleLabel.contains(pointOfTouch) && musicToggleLabel.text == "Music ON" {
                        audioPlayer.play()
                        musicToggleLabel.text = "Music OFF"
                    }
            
            if soundToggleLabel.contains(pointOfTouch) && soundToggleLabel.text == "Sound OFF" {
                clickSound = SKAction.playSoundFileNamed("nothingSound", waitForCompletion: false)
                explosionSound = SKAction.playSoundFileNamed("nothingSound", waitForCompletion: false)
                soundToggleLabel.text = "Sound ON"
            }
            else if soundToggleLabel.contains(pointOfTouch) && soundToggleLabel.text == "Sound ON" {
                clickSound = SKAction.playSoundFileNamed("clickSound", waitForCompletion: false)
                explosionSound = SKAction.playSoundFileNamed("explosionSound", waitForCompletion: false)
                soundToggleLabel.text = "Sound OFF"
            }
            
                    if mainMenuLabel.contains(pointOfTouch) {
                        self.run(clickSound)
                        let sceneToMoveTo = MainMenuScene(size: self.size)
                        sceneToMoveTo.scaleMode = self.scaleMode
                        let myTransition = SKTransition.doorsCloseVertical(withDuration: 0.6)
                        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
                        audioPlayer.stop()
                    }
                    
                    
                    if returnLabel.contains(pointOfTouch) {
                        self.run(clickSound)
                        mainMenuLabel.removeFromParent()
                        mainMenuLabel.text = nil
                        musicToggleLabel.removeFromParent()
                        musicToggleLabel.text = nil
                        soundToggleLabel.removeFromParent()
                        soundToggleLabel.text = nil
                        areYouSureLabel.removeFromParent()
                        areYouSureLabel.text = nil
                        returnLabel.removeFromParent()
                        returnLabel.text = nil
                        worldNode.isPaused = false
                        optionsLabel.text = "Options"
            
            }
                    
                    
                }
        
        }
            
        }

    


