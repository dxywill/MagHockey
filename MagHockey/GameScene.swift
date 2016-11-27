//
//  GameScene.swift
//  MagHockey
//
//  Created by Xinyi Ding on 11/26/16.
//  Copyright © 2016 Xinyi. All rights reserved.
//

import UIKit
import SpriteKit


class GameScene: SKScene {
    let model = SharedData.sharedInstance
    let player = SKSpriteNode(imageNamed: "hockey")
    var coordinateX = 0.0
    var coordinateY = 0.0
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        addChild(player)
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(updateLocation),
                SKAction.wait(forDuration: 0.2)
                ])
        ))
    }
    
    func updateLocation() {
        
        let location = model.getCoordinates()
        coordinateX = location.x * ( Double(size.width / 8.0)) + 30.0
        coordinateY = location.y * (Double(size.height / 10.0)) + 30.0
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: coordinateX, y: coordinateY), duration:0.2)
        
        player.run(actionMove)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Capture the touch event.
        
        if let touch = touches.first {
            
            // Get the position that was touched.
            let touchPosition = touch.location(in: self)
            
            // Define actions for the ship to take.
            let moveAction = SKAction.move(to: touchPosition, duration: 0.5)
            
            // Tell the ship to execute actions.
            player.run(moveAction)
        }
    }
    
    
}
