//
//  SpriteComponent.swift
//  Game123
//
//  Created by Serhii Syrotynin on 11/22/16.
//  Copyright © 2016 Serhii Syrotynin. All rights reserved.
//

import SpriteKit
import GameplayKit

class SpriteComponent: GKComponent {
    
    let node: SKSpriteNode
    
    init(texture: SKTexture) {
        node = SKSpriteNode(texture: texture, color: SKColor.white, size: texture.size())
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
