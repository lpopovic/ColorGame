//
//  GameScene.swift
//  ColorGame
//
//  Created by MacBook Air on 6/8/19.
//  Copyright © 2019 Riitech. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: Game Properties
    // MARK:-
    
    // MARK: Collision Categories
    let playerCategory:UInt32 = 0x1 << 0
    let enemyCategory:UInt32 = 0x1 << 1
    let targetCategory:UInt32 = 0x1 << 2
    let powerUpCategory:UInt32 = 0x1 << 3
    
    // MARK: Nodes
    var player:SKSpriteNode?
    var target:SKSpriteNode?
    
    
    // MARK: HUD
    var pause:SKSpriteNode?
    var timeLabel:SKLabelNode?
    var scoreLabel:SKLabelNode?
    
    var currentScore:Int = 0 {
        didSet {
            self.scoreLabel?.text = "SCORE: \(self.currentScore)"
            GameHandler.sharedInstance.score = self.currentScore
        }
    }
    var remainingTime:TimeInterval = 0 {
        didSet {
            self.timeLabel?.text = "TIME: \(Int(self.remainingTime))"
        }
    }
    
    
    
    // MARK: Arrays
    var tracksArray:[SKSpriteNode]? = [SKSpriteNode]()
    let trackVelocities = [180, 200, 250]
    var directionArray = [Bool]()
    var velocityArray = [Int]()
    
    // MARK: Sound
    
    let moveSound = SKAction.playSoundFileNamed("move.wav", waitForCompletion: false)
    var backgroundNoise:SKAudioNode!
    
    
    // MARK: Rest
    var currentTrack = 0
    var movingToTrack = false
    
    
    
    
    
    // MARK: - Entry Point
    
    override func didMove(to view: SKView) {
        setupTracks()
        
        createHUD()
        launchGameTimer()
        
        createPlayer()
        createTarget()
        
        self.physicsWorld.contactDelegate = self
        
        if let musicURL = Bundle.main.url(forResource: "background", withExtension: "wav") {
            backgroundNoise = SKAudioNode(url: musicURL)
            addChild(backgroundNoise)
        }
        
        
        if let numberOfTracks = tracksArray?.count {
            for _ in 0 ... numberOfTracks {
                let randomNumberForVelocity = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
                velocityArray.append(trackVelocities[randomNumberForVelocity])
                directionArray.append(GKRandomSource.sharedRandom().nextBool())
            }
        }
        
        
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.spwanEnemies()
            }, SKAction.wait(forDuration: 2)])))
        
    }
    
    // MARK: - Touch Control
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.previousLocation(in: self)
            let node = self.nodes(at: location).first
            
            if node?.name == "right" {
                if currentTrack < 8 {
                   moveToNextTrack()
                }
            } else if node?.name == "up" {
                moveVertically(up: true)
            } else if node?.name == "down" {
                moveVertically(up: false)
            } else if node?.name == "pause", let scene = self.scene {
                if scene.isPaused {
                    scene.isPaused = false
                }else {
                    scene.isPaused = true
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !movingToTrack {
            player?.removeAllActions()
        }
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        player?.removeAllActions()
    }
    
    
    // MARK: - Contact Delegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        var playerBody:SKPhysicsBody
        var otherBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            playerBody = contact.bodyA
            otherBody = contact.bodyB
        }else{
            playerBody = contact.bodyB
            otherBody = contact.bodyA
        }
        
        if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == enemyCategory {
            self.run(SKAction.playSoundFileNamed("fail.wav", waitForCompletion: true))
            movePlayerToStart()
            
        } else if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == targetCategory {
            nextLevel(playerPhysicsBody: playerBody)
        } else if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == powerUpCategory {
            self.run(SKAction.playSoundFileNamed("powerUp.wav", waitForCompletion: true))
            otherBody.node?.removeFromParent()
            remainingTime += 5
        }
        
        
    }
    
    
    // MARK: - Update
    
    override func update(_ currentTime: TimeInterval) {
        if let player = self.player {
            if player.position.y > self.size.height || player.position.y < 0 {
                movePlayerToStart()
            }
        }
        
        if remainingTime <= 5 {
            timeLabel?.fontColor = UIColor.red
        }
        
        if remainingTime == 0 {
            gameOver()
        }
    }
}
