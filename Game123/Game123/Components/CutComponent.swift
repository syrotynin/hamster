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
                direction = MoveDirection.top
            }
            if(currentPosition.y < previousPosition.point.y){
                direction = MoveDirection.down
            }
            
            if direction != routeDirection{
                
                var point = previousPosition.point
                
                // place point on tile's edge
                point = self.entityManager.map.edgeOfTileFrom(point)
                
                // if it is the first point
                // add intersecting point as start (edge)
                if !lineIsDrawing{
                    point = edgePosition(direction: direction, position: previousPosition.point)
                }
                
                // add route point if player changes direction
                // if direction is opposite to current - don't need to set point
                if direction != routeDirection.opposite || lineIsDrawing == false{
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
        
        let delta = spriteNode.size.width/2
        //let delta : CGFloat = 2.0
        
        let upLeft = CGPoint(x: spriteNode.position.x - delta,
                             y: spriteNode.position.y + delta)
        let upRight = CGPoint(x: spriteNode.position.x + delta,
                              y: spriteNode.position.y + delta)
        let downLeft = CGPoint(x: spriteNode.position.x - delta,
                               y: spriteNode.position.y - delta)
        let downRight = CGPoint(x: spriteNode.position.x + delta,
                             y: spriteNode.position.y - delta)
        
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
        case .top:
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
            let invertedDirection = routeDirection.opposite
            
            let point = edgePosition(direction: invertedDirection, position: currentPosition())
            routePoints.append(NSValue(cgPoint: point))
            
            // cut selected area
            cutArea()
        }
        
        lineIsDrawing = false
    }
    
    
    //TODO: implement cut logic
    func cutArea(){
        
//        if routePoints.count < 2 {
//            return
//        }
        
//        if routePoints.count == 2 {
//            let p1 = routePoints[0].cgPointValue
//            let p2 = routePoints[1].cgPointValue
//            
//            let col1 = entityManager.map.tileColumnIndex(fromPosition: p1)
//            let row1 = entityManager.map.tileRowIndex(fromPosition: p1)
//            
//            if p1.x == p2.x {
//                if p1.x > 0 {
//                    for row in 0..<entityManager.map.numberOfRows {
//                        for col in col1..<entityManager.map.numberOfColumns {
//                            setGreenTile(column: col, row: row)
//                        }
//                    }
//                }
//                else {
//                    for row in 0..<entityManager.map.numberOfRows {
//                        for col in 0..<col1 {
//                            setGreenTile(column: col, row: row)
//                        }
//                    }
//                }
//            }
//            else if p1.y == p2.y {
//                if p1.y > 0 {
//                    for col in 0..<entityManager.map.numberOfColumns {
//                        for i in row1..<entityManager.map.numberOfRows {
//                            setGreenTile(column: col, row: i)
//                        }
//                    }
//                }
//                else {
//                    for col in 0..<entityManager.map.numberOfColumns {
//                        for i in 0..<row1 {
//                            setGreenTile(column: col, row: i)
//                        }
//                    }
//                }
//            }
//        }

        routePoints.removeAll()
    }
    
    func setGreenTile(column: Int, row: Int) {
        if let tile = entityManager.map.tileSet.tileGroups.first(
            where: {$0.name == "green"}) {
            
            entityManager.map.setTileGroup(tile, forColumn: column, row: row)
        }
        else {
            print("Ooops")
        }
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
