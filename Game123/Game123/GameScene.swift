//
//  GameScene.swift
//  Game123
//
//  Created by Serhii Syrotynin on 11/22/16.
//  Copyright © 2016 Serhii Syrotynin. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entityManager: EntityManager!
    
    var map: SKTileMapNode!
    
    // Update time
    var lastUpdateTimeInterval: TimeInterval = 0
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let deltaTime = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        entityManager.update(deltaTime: deltaTime)
    }
    
    override func didMove(to view: SKView) {
        print("scene size: \(size)")
        
        guard let map = childNode(withName: "Tile Map Node")
            as? SKTileMapNode else {
                fatalError("Background node not loaded")
        }
        self.map = map
        
        let directions: [UISwipeGestureRecognizerDirection] = [.right, .left, .up, .down]
        for direction in directions {
            let gestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(GameScene.handleSwipe(recognizer:)))
            gestureRecognizer.direction = direction
            view.addGestureRecognizer(gestureRecognizer)
        }
        
        entityManager = EntityManager(scene: self, map: self.map)
        
        let hamster = Hamster(entityManager: entityManager)
        if let spriteNode = hamster.component(ofType: SpriteComponent.self)?.node {
            spriteNode.position = entityManager.map.leftTop
            spriteNode.size = CGSize(width: 100, height: 100)
        }
        entityManager.add(entity: hamster)
    }
    
    func handleSwipe(recognizer: UISwipeGestureRecognizer){
        entityManager.movePlayer(direction: recognizer.direction)
    }

}
