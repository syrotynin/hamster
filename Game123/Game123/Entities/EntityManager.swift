//
//  EntityManager.swift
//  Game123
//
//  Created by Serhii Syrotynin on 11/22/16.
//  Copyright © 2016 Serhii Syrotynin. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class EntityManager {
    
    var hamster: Hamster? = nil
    
    // 1
    var entities = Set<GKEntity>()
    var toRemove = Set<GKEntity>()
    let scene: SKScene
    var map: SKTileMapNode
    
    lazy var componentSystems: [GKComponentSystem] = {
        let moveSystem = GKComponentSystem(componentClass: MoveComponent.self)
        let cutSystem = GKComponentSystem(componentClass: CutComponent.self)
        return [moveSystem, cutSystem]
    }()
    
    // 2
    init(scene: SKScene, map: SKTileMapNode) {
        self.scene = scene
        self.map = map
    }
    
    // 3
    func add(entity: GKEntity) {
        entities.insert(entity)
        
        if let hamster = entity as? Hamster{
            self.hamster = hamster
        }
        
        if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node{
            scene.addChild(spriteNode)
        }
        
        for componentSystem in componentSystems {
            componentSystem.addComponent(foundIn: entity)
        }
    }
    
    // 4
    func remove(entity: GKEntity) {
        if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
            spriteNode.removeFromParent()
        }
        
        entities.remove(entity)
    }
    
    func update(deltaTime: CFTimeInterval) {
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
        
        for curRemove in toRemove {
            for componentSystem in componentSystems {
                componentSystem.removeComponent(foundIn: curRemove)
            }
        }
        toRemove.removeAll()
    }
    
    func movePlayer(direction: UISwipeGestureRecognizerDirection){
        if let moveComponent = hamster?.component(ofType: MoveComponent.self) {
            moveComponent.move(direction: direction)
        }
    }
}
