//
//  CutComponent.swift
//  Game123
//
//  Created by Serhii Syrotynin on 11/24/16.
//  Copyright © 2016 Serhii Syrotynin. All rights reserved.
//

import SpriteKit
import GameplayKit

class CutComponent: GKComponent {
    
    let entityManager: EntityManager
    
    var previousPosition = PointData()
    
    var lineIsDrawing = false
    var lineStart: CGPoint = CGPoint(x: 0, y: 0)
    var lineEnd: CGPoint = CGPoint(x: 0, y: 0)
    
    var routePoints = [NSValue]()
    var routeDirection = MoveDirection.none
    
    let cutLine = SKShapeNode()
    
    init(entityManager: EntityManager){
        self.entityManager = entityManager
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Update methods
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        if !previousPosition.initialized{
            previousPosition.point = currentPosition()
            previousPosition.initialized = true
        }
        
        if entityIntersectsWithTile(){
            finishDrawing()
        }
        else{
            updateRoutePoints()
            drawPath()
        }
        
        previousPosition.point = currentPosition()
    }
    
    func updateRoutePoints(){
        
        let currentPosition = self.currentPosition()
        
        if __CGPointEqualToPoint(currentPosition, previousPosition.point){
            print("position didn't change")
            return
        }
        else{
            
            var direction = MoveDirection.none
            if(currentPosition.x > previousPosition.point.x){
                direction = MoveDirection.right
            }
            if(currentPosition.x < previousPosition.point.x){
                direction = MoveDirection.left
            }
            if(currentPosition.y > previousPosition.point.y){
                direction = MoveDirection.up
            }
            if(currentPosition.y < previousPosition.point.y){
                direction = MoveDirection.down
            }
            
            if direction != routeDirection{
                
                var point = previousPosition.point
                
                // place point at center of the tile
                point = self.entityManager.map.centerOfTileFrom(point)
                
                // if it is the first point
                // add intersecting point as start (edge)
                if !lineIsDrawing{
                    point = edgePosition(direction: direction, position: point)
                }
                
                // add route point if player changes direction
                // if direction is opposite to current - don't need to set point
                if direction != MoveDirection.opposite(direction: routeDirection) || lineIsDrawing == false{
                    routePoints.append(NSValue(cgPoint: point))
                }
                
                routeDirection = direction
            }
        }
    }
    
    // MARK: Helpers
    
    func entityIntersectsWithTile() -> Bool{
        guard let spriteNode = entity?.component(ofType: SpriteComponent.self)?.node else {
            return false
        }
        
        let upLeft = CGPoint(x: spriteNode.position.x - spriteNode.size.width/2,
                             y: spriteNode.position.y + spriteNode.size.height/2)
        let upRight = CGPoint(x: spriteNode.position.x + spriteNode.size.width/2,
                              y: spriteNode.position.y + spriteNode.size.height/2)
        let downLeft = CGPoint(x: spriteNode.position.x - spriteNode.size.width/2,
                               y: spriteNode.position.y - spriteNode.size.height/2)
        let downRight = CGPoint(x: spriteNode.position.x + spriteNode.size.width/2,
                             y: spriteNode.position.y - spriteNode.size.height/2)
        
        if onTile(position: upLeft) || onTile(position: upRight) ||
            onTile(position: downLeft) || onTile(position: downRight){
            return true
        }
        
        return false
    }
    
    func onTile(position: CGPoint) -> Bool{
        let column = entityManager.map.tileColumnIndex(fromPosition: position)
        let row = entityManager.map.tileRowIndex(fromPosition: position)
        let tile = entityManager.map.tileDefinition(atColumn: column, row: row)
        
        if tile != nil{
            return true
        }
        else{
            return false
        }
    }
    
    func currentPosition() -> CGPoint{
        guard let spriteNode = entity?.component(ofType: SpriteComponent.self)?.node else {
            fatalError("no current position")
        }
        return spriteNode.position
    }
    
    func edgePosition(direction: MoveDirection, position: CGPoint) -> CGPoint{
        
        var point = position
        
        guard let spriteNode = entity?.component(ofType: SpriteComponent.self)?.node else {
            return point
        }
        
        switch direction {
        case .right:
            point.x -= spriteNode.size.width/2
        case .left:
            point.x += spriteNode.size.width/2
        case .up:
            point.y -= spriteNode.size.height/2
        case .down:
            point.y += spriteNode.size.height/2
            
        default:
            break
        }
        
        return point
    }
    
    //TODO: implement player interaction with cut line
    
    func intersectsWithCutLine(position: CGPoint) -> Bool{
        return false
    }
    
    // MARK: Drawing
    
    func drawPath(){
        if(!lineIsDrawing){
            lineIsDrawing = true
            entityManager.scene.addChild(cutLine)
        }
        
        updateCutLine()
    }
    
    func finishDrawing(){
        if(lineIsDrawing){
            
            cutLine.removeFromParent()
            
            // add intersecting edge point (last).
            // intersection with borders
            
            // invert route direction to get edge point
            let invertedDirection = MoveDirection.opposite(direction: routeDirection)
            
            let point = edgePosition(direction: invertedDirection, position: currentPosition())
            routePoints.append(NSValue(cgPoint: point))
            
            // cut selected area
            cutArea()
        }
        
        lineIsDrawing = false
    }
    
    
    //TODO: implement cut logic
    func cutArea(){
        
        for point in routePoints {
            let position = point.cgPointValue
        }
        
        routePoints.removeAll()
    }
    
    func updateCutLine(){
        let path = CGMutablePath()
        
        var first = true
        
        for point in routePoints {
            let position = point.cgPointValue
            // draw line to next position
            if !first{
                path.addLine(to: position)
            }
            first = false
            
            path.move(to: position)
        }
        
        let position = currentPosition()
        path.addLine(to: position)
        path.move(to: position)
        
        cutLine.path = path
        cutLine.strokeColor = SKColor.red
        cutLine.lineWidth = 6
    }
}
