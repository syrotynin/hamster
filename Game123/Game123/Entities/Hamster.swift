//
//  Hamster.swift
//  Game123
//
//  Created by Serhii Syrotynin on 11/22/16.
//  Copyright © 2016 Serhii Syrotynin. All rights reserved.
//

import SpriteKit
import GameplayKit

class Hamster: GKEntity {
    
    convenience init(entityManager: EntityManager){
        self.init(imageName: "Spaceship", entityManager: entityManager)
    }
    
    init(imageName: String, entityManager: EntityManager) {
        super.init()
        
        let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: imageName))
        addComponent(spriteComponent)
        addComponent(MoveComponent(entityManager: entityManager))
        addComponent(CutComponent(entityManager: entityManager))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
