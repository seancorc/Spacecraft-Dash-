//
//  GameOverScene.swift
//  Run
//
//  Created by Sean Corcoran on 7/29/17.
//  Copyright © 2017 Sean Corcoran. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    let gameOverLabel = SKLabelNode(fontNamed: "Gayatri")
    let background = SKSpriteNode(imageNamed: "background")
    let player = SKSpriteNode(imageNamed: "ship")
    let scoreLabel = SKLabelNode(fontNamed: "Gayatri")
    let restartLabel = SKLabelNode(fontNamed: "Gayatri")

override func didMove(to View: SKView) {
    let highScoreLabel = SKLabelNode(fontNamed: "Gayatri")
    
    background.size = self.size
    background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
    background.zPosition = 0
    self.addChild(background)
    
    player.setScale(0.25)
    player.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.13)
    player.zPosition = 1
    self.addChild(player)
    
    gameOverLabel.text = "GAME OVER"
    gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.75)
    gameOverLabel.fontSize = 200
    gameOverLabel.fontColor = SKColor.red
    gameOverLabel.zPosition = 1
    self.addChild(gameOverLabel)
    
    scoreLabel.text = "Score: \(gameScore)"
    scoreLabel.fontSize = 85
    scoreLabel.zPosition = 2
    scoreLabel.fontColor = SKColor.white
    scoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.63)
    self.addChild(scoreLabel)
    
    let defaults = UserDefaults()
    var highScore = defaults.integer(forKey: "savedHighScore")
    
    if gameScore > highScore {
        highScore = gameScore
        defaults.set(highScore, forKey: "savedHighScore")
    }
    highScoreLabel.text = "High Score: \(highScore)"
    highScoreLabel.fontSize = 85
    highScoreLabel.zPosition = 2
    highScoreLabel.fontColor = SKColor.white
    highScoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.5)
    self.addChild(highScoreLabel)
        
        
    let restartLabelGetBigger = SKAction.scale(to: 3.5, duration: 0.5)
    let restartLabelGetSmaller = SKAction.scale(to: 3, duration: 0.5)
    let restartLabelSizeSequence = SKAction.sequence([restartLabelGetBigger, restartLabelGetSmaller])
    let runRestartLabelSequenceForever = SKAction.repeatForever(restartLabelSizeSequence)
    restartLabel.text = "Restart"
    restartLabel.run(runRestartLabelSequenceForever)
    restartLabel.zPosition = 1
    restartLabel.fontColor = SKColor.cyan
    restartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.3)
    self.addChild(restartLabel)
    
    
    }
    
    

 override  func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    for touch: AnyObject in touches {
        let pointOfTouch = touch.location(in: self)
        if restartLabel.contains(pointOfTouch) {
           restartLabel.run(clickSound)
            let SceneToMoveTo = GameScene(size: self.size)
            SceneToMoveTo.scaleMode = self.scaleMode
            let myTransition = SKTransition.fade(with: SKColor.black, duration: 0.3)
            self.view!.presentScene(SceneToMoveTo, transition: myTransition)
            
        }
    
    }
    }



}
