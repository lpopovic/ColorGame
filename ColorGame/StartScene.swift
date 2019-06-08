//
//  StartScene.swift
//  ACGame
//
//  Created by Brian Advent on 30.05.17.
//  Copyright © 2017 Brian Advent. All rights reserved.
//

import SpriteKit

class StartScene: SKScene {
    
    var playButton:SKSpriteNode?
    var gameScene:SKScene!
    var backgroundMusic: SKAudioNode!
    
    override func didMove(to view: SKView) {
        playButton = self.childNode(withName: "startButton") as? SKSpriteNode
        
        
        if let musicURL = Bundle.main.url(forResource: "MenuHighscoreMusic", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == playButton {

                
            }
        }
    }
}
