//
//  MoveComponent.swift
//  Game123
//
//  Created by Serhii Syrotynin on 11/23/16.
//  Copyright © 2016 Serhii Syrotynin. All rights reserved.
//

import SpriteKit
import GameplayKit

let Pi = CGFloat(M_PI)
let DegreesToRadians = Pi / 180
let RadiansToDegrees = 180 / Pi

let moveSpeed = CGFloat(300)

class MoveComponent: GKComponent {

    let entityManager: EntityManager
    var playerVelocity = CGVector(dx: 0, dy: 0)
    
    var playerAngle: CGFloat = 0
    var previousAngle: CGFloat = 0
    
    init(entityManager: EntityManager){
        self.entityManager = entityManager
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard let spriteNode = entity?.component(ofType: SpriteComponent.self)?.node else {
            return
        }
        
        // 3
        let size = entityManager.scene.size
        let minX = -(size.width / 2)
        let minY = -(size.height / 2)
        
        var newX = spriteNode.position.x + playerVelocity.dx * CGFloat(seconds)
        var newY = spriteNode.position.y + playerVelocity.dy * CGFloat(seconds)
        
        // 4
        if newX < minX {
            newX = minX
        } else if newX > size.width + minX {
            newX = size.width + minX
        }
        
        if newY < minY {
            newY = minY
        } else if newY > size.height + minY {
            newY = size.height + minY
        }
        
        // 5
        if canMove(x: newX, y: newY){
            spriteNode.position = CGPoint(x: newX, y: newY)
        }
        
        let RotationThreshold: CGFloat = 40
        let RotationBlendFactor: CGFloat = 0.2
        
        let speed = sqrt(playerVelocity.dx * playerVelocity.dx + playerVelocity.dy * playerVelocity.dy)
        if speed > RotationThreshold {
            let angle = atan2(playerVelocity.dy, playerVelocity.dx)
            
            // did angle flip from +π to -π, or -π to +π?
            if angle - previousAngle > Pi {
                playerAngle += 2 * Pi
            } else if previousAngle - angle > Pi {
                playerAngle -= 2 * Pi
            }
            
            previousAngle = angle
            playerAngle = angle * RotationBlendFactor + playerAngle * (1 - RotationBlendFactor)
            
            spriteNode.zRotation = playerAngle - 90 * DegreesToRadians
        }

    }
    
    func move(direction: UISwipeGestureRecognizerDirection){
        
        if let spriteNode = entity?.component(ofType: SpriteComponent.self)?.node {
            let position = spriteNode.position
            let tileCenter = entityManager.map.centerOfTileFrom(position)
            spriteNode.position = tileCenter
        }
        
        playerVelocity = CGVector(dx: 0, dy: 0)
        
        switch direction {
        case UISwipeGestureRecognizerDirection.left:
            print("left")
            playerVelocity.dx = -moveSpeed
        case UISwipeGestureRecognizerDirection.right:
            print("right")
            playerVelocity.dx = moveSpeed
        case UISwipeGestureRecognizerDirection.up:
            print("up")
            playerVelocity.dy = moveSpeed
        case UISwipeGestureRecognizerDirection.down:
            print("down")
            playerVelocity.dy = -moveSpeed
            
        default:
            break
        }
    }
    
    func canMove(x: CGFloat, y: CGFloat) -> Bool{
        
        let position = CGPoint(x: x, y: y)
        let column = entityManager.map.tileColumnIndex(fromPosition: position)
        let row = entityManager.map.tileRowIndex(fromPosition: position)
        let tile = entityManager.map.tileDefinition(atColumn: column, row: row)
        
        let intersect = intersectCutLine(x: x, y: y)
        
        if (tile != nil) || (intersect == true){
            return false
        }
        else if tile == nil {
            if let tile = entityManager.map.tileSet.tileGroups.first(
                where: {$0.name == "green"}) {
                
                entityManager.map.setTileGroup(nil, forColumn: column, row: row)
            }
            else {
                print("Ooops")
            }
        }
        
        return true
    }
    
    //MARK: - Check if cut line interfere with the move point
    
    func intersectCutLine(x: CGFloat, y: CGFloat) -> Bool {
        
        var intersect = false
        
        guard let spriteNode = entity?.component(ofType: SpriteComponent.self)?.node else {
            return intersect
        }
        
        var currentPosition = spriteNode.position
        
        // get sprite position with tile's size offset
        // to create offset between cut lines
        let tileSize = entityManager.map.tileSize
        
        let playerOffsetX = tileSize.width + spriteNode.size.width / 2
        let playerOffsetY = tileSize.height + spriteNode.size.height / 2
        
        var stopX = x
        var stopY = y
        
        // define direction (positive/negative) and 
        // point where player model should stop before cut line
        var direction = MoveDirection.none
        
        if x > currentPosition.x {
            stopX = x + playerOffsetX
            direction = .right
        }
        else if x < currentPosition.x {
            stopX = x - playerOffsetX
            direction = .left
        }
        
        if y > currentPosition.y {
            stopY = y + playerOffsetY
            direction = .up
        }
        else if y < currentPosition.y {
            stopY = y - playerOffsetY
            direction = .down
        }
        
        if direction == .none {
            return false
        }
        
        // search for line that intersect with movement position
        if let hamster = entityManager.hamster,
            let cut = hamster.component(ofType: CutComponent.self),
            cut.routePoints.count > 3 {
            
            for i in 1..<cut.routePoints.count {
                let first = cut.routePoints[i-1].cgPointValue
                let second = cut.routePoints[i].cgPointValue
                
                if(first.x == second.x && y.inRange(first.y, second.y)
                    && stopX.reached(first.x, positive: direction == .right)
                    && sameDirectionX(offset: x, real: currentPosition.x)) {
                    intersect = true
                }
                else if(first.y == second.y && x.inRange(first.x, second.x)
                    && stopY.reached(first.y, positive: direction == .up)
                    && sameDirectionY(offset: y, real: currentPosition.y)) {
                    intersect = true
                }
            }
        }
        
        return intersect
    }
    
    func sameDirectionX(offset: CGFloat, real: CGFloat) -> Bool {
        if (offset > real) && playerVelocity.dx > 0 {
            return true
        }
        if (offset < real) && playerVelocity.dx < 0 {
            return true
        }
        
        return false
    }
    
    func sameDirectionY(offset: CGFloat, real: CGFloat) -> Bool {
        if (offset > real) && playerVelocity.dy > 0 {
            return true
        }
        if (offset < real) && playerVelocity.dy < 0 {
            return true
        }
        
        return false
    }
}
