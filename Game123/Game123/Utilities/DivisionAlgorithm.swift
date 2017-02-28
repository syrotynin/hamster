//
//  CutAlgorithm.swift
//  Game123
//
//  Created by Serhii Syrotynin on 2/28/17.
//  Copyright © 2017 Serhii Syrotynin. All rights reserved.
//

import Foundation
import SpriteKit

struct CutAlgorithm {
    
    let map: SKTileMapNode
    var route: [NSValue]
    
    init(map: SKTileMapNode, route: [NSValue]) {
        self.map = map
        self.route = route
        addMissingPoints()
    }
    
    // add edge points if needed
    // to 'close' the polygon area (from line to polygon)
    private mutating func addMissingPoints() {
        
        if route.count < 2 {
            return
        }
        
        // at first we need to get first and last points
        // to understand if we need to add extra points
        guard let first = route.first?.cgPointValue,
            let last = route.last?.cgPointValue else {
            return
        }
        
        let firstSide = pointSide(first)
        let lastSide = pointSide(last)
        
        if firstSide == lastSide {
            // no extra points needed
            return
        }
        else if firstSide == lastSide.opposite {
            // two edge points needed
            if firstSide == .right || firstSide == .left {
                let midPoint = (first.y + last.y) / 2.0
                
                if midPoint > 0 {
                    route.append(NSValue(cgPoint: map.leftTop))
                    route.append(NSValue(cgPoint: map.rightTop))
                }
                else {
                    route.append(NSValue(cgPoint: map.leftBottom))
                    route.append(NSValue(cgPoint: map.rightBottom))
                }
            }
            else if firstSide == .top || firstSide == .down {
                let midPoint = (first.x + last.x) / 2.0
                
                if midPoint > 0 {
                    route.append(NSValue(cgPoint: map.rightTop))
                    route.append(NSValue(cgPoint: map.rightBottom))
                }
                else {
                    route.append(NSValue(cgPoint: map.leftTop))
                    route.append(NSValue(cgPoint: map.leftBottom))
                }
            }
        }
        else {
            // one edge point needed
            
            if expectedSides(firstSide, lastSide, expectedFirst: .top, expectedSecond: .left) {
                route.append(NSValue(cgPoint: map.leftTop))
            }
            if expectedSides(firstSide, lastSide, expectedFirst: .top, expectedSecond: .right) {
                route.append(NSValue(cgPoint: map.rightTop))
            }
            if expectedSides(firstSide, lastSide, expectedFirst: .down, expectedSecond: .left) {
                route.append(NSValue(cgPoint: map.leftBottom))
            }
            if expectedSides(firstSide, lastSide, expectedFirst: .down, expectedSecond: .right) {
                route.append(NSValue(cgPoint: map.rightBottom))
            }
        }
    }
    
    // check if sides meet our expectations
    
    func expectedSides(_ first: MoveDirection, _ second: MoveDirection,
                       expectedFirst: MoveDirection, expectedSecond: MoveDirection) -> Bool {
        
        if (first == expectedFirst && second == expectedSecond) ||
            (first == expectedSecond && second == expectedFirst){
            return true
        }
        
        return false
    }
    
    // get side of map where point located
    func pointSide(_ point: CGPoint) -> MoveDirection {
        
        if point.x > map.rightTop.x {
            return .right
        }
        if point.x < map.leftTop.x {
            return .left
        }
        if point.y > map.leftTop.y {
            return .top
        }
        if point.y < map.leftBottom.y {
            return .down
        }
        
        return .none
    }
    
    // get rectangles from polygon area
    func dividePolygon() -> [CGRect] {
        
        return [CGRect]()
    }
}
