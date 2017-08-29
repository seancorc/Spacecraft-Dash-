//
//  MainMenuScene.swift
//  Run
//
//  Created by Sean Corcoran on 8/5/17.
//  Copyright © 2017 Sean Corcoran. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class MainMenuScene: SKScene {
    let background = SKSpriteNode(imageNamed: "background")
    let titleLabel = SKLabelNode(fontNamed: "Gayatri")
    let titleLabel2 = SKLabelNode(fontNamed: "Gayatri")
    let startGameLabel = SKLabelNode(fontNamed: "Gayatri")
    var menuAudioPlayer: AVAudioPlayer = AVAudioPlayer()
    let musicOffLabel = SKLabelNode(fontNamed: "Gayatri")
    let soundEffectsOffLabel = SKLabelNode(fontNamed: "Gayatri")
    
    override func didMove(to view: SKView) {
        
        
        do {
            let audioPath = Bundle.main.path(forResource: "menuMusic", ofType: "mp3")
            menuAudioPlayer = try AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
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
       menuAudioPlayer.play()
        
        
        musicOffLabel.text = "Music OFF"
        musicOffLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        musicOffLabel.fontColor = SKColor.cyan
        musicOffLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height * 0.9)
        musicOffLabel.zPosition = 1
        musicOffLabel.fontSize = 80
        self.addChild(musicOffLabel)
        
        soundEffectsOffLabel.text = "Sound OFF"
        soundEffectsOffLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        soundEffectsOffLabel.fontColor = SKColor.cyan
        soundEffectsOffLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height * 0.9)
        soundEffectsOffLabel.zPosition = 1
        soundEffectsOffLabel.fontSize = 80
        self.addChild(soundEffectsOffLabel)
        
        background.size = self.size
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = 0
        self.addChild(background)
        
        titleLabel.text = "SPACECRAFT"
        titleLabel.fontColor = SKColor.white
        titleLabel.zPosition = 1
        titleLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.65)
        titleLabel.fontSize  = 180
        self.addChild(titleLabel)
        
        titleLabel2.text = "DASH"
        titleLabel2.fontColor = SKColor.white
        titleLabel2.zPosition = 1
        titleLabel2.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.55)
        titleLabel2.fontSize  = 180
        self.addChild(titleLabel2)

        
        
        let startLabelGetBigger = SKAction.scale(to: 5, duration: 0.5)
        let startLabelGetSmaller = SKAction.scale(to: 4.5, duration: 0.5)
        let startLabelSizeSequence = SKAction.sequence([startLabelGetBigger, startLabelGetSmaller])
        let runStartLabelSequenceForever = SKAction.repeatForever(startLabelSizeSequence)
        startGameLabel.run(runStartLabelSequenceForever)
        
        startGameLabel.text = "Start Game"
        startGameLabel.fontColor = SKColor.cyan
        startGameLabel.zPosition = 1
        startGameLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.3)
        
        self.addChild(startGameLabel)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            
            if musicOffLabel.contains(pointOfTouch) && musicOffLabel.text == "Music OFF" {
                menuAudioPlayer.stop()
                musicOffLabel.text = "Music ON"
                musicOffLabel.run(clickSound)
            }
            
           else if musicOffLabel.contains(pointOfTouch) && musicOffLabel.text == "Music ON" {
                musicOffLabel.text = "Music OFF"
                menuAudioPlayer.play()
                musicOffLabel.run(clickSound)
            }
            
            if soundEffectsOffLabel.contains(pointOfTouch) && soundEffectsOffLabel.text == "Sound OFF" {
                clickSound = SKAction.playSoundFileNamed("nothingSound", waitForCompletion: false)
                explosionSound = SKAction.playSoundFileNamed("nothingSound", waitForCompletion: false)
                soundEffectsOffLabel.text = "Sound ON"
            }
            else if soundEffectsOffLabel.contains(pointOfTouch) && soundEffectsOffLabel.text == "Sound ON" {
                clickSound = SKAction.playSoundFileNamed("clickSound", waitForCompletion: false)
                explosionSound = SKAction.playSoundFileNamed("explosionSound", waitForCompletion: false)
                soundEffectsOffLabel.text = "Sound OFF"
            }
            
            if startGameLabel.contains(pointOfTouch) {
                startGameLabel.run(clickSound)
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
               let myTransition = SKTransition.fade(with: SKColor.cyan, duration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
                
                }
            
            
            
        }
        
        
    }
    
    
    
    
}
