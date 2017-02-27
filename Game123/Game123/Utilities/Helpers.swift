//
//  Helpers.swift
//  Game123
//
//  Created by Serhii Syrotynin on 11/24/16.
//  Copyright © 2016 Serhii Syrotynin. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

struct PointData{
    var point = CGPoint(x: 0, y: 0)
    var initialized = false
}

struct TilePosition: Hashable{
    var column: Int, row: Int
    
    var hashValue: Int {
        return column.hashValue ^ row.hashValue
    }
    
    // satisfy Equatable requirement
    static func ==(lhs: TilePosition, rhs: TilePosition) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row
    }
}

enum MoveDirection {
    case none
    case right
    case left
    case up
    case down
    
    static func opposite(direction: MoveDirection) -> MoveDirection{
        switch direction {
        case .left:
            return .right
        case .right:
            return .left
        case .up:
            return .down
        case .down:
            return .up
        default:
            return .none
        }
    }
}

extension CGFloat {
    
    func inRange(_ first: CGFloat, _ second: CGFloat) -> Bool {
        var smaller = first
        var bigger = second
        
        if(smaller > bigger) {
            smaller = second
            bigger = first
        }
        
        return smaller <= self && self <= bigger
    }
    
    func reached(_ value: CGFloat, positive: Bool) -> Bool{
        if positive {
            return self >= value
        }
        else {
            return self <= value
        }
    }
}

extension SKTileMapNode {
    
    func centerOfTileFrom(_ point: CGPoint) -> CGPoint {
        let column = tileColumnIndex(fromPosition: point)
        let row = tileRowIndex(fromPosition: point)
        let center = centerOfTile(atColumn: column, row: row)
        
        return center
    }
    
    func edgeOfTileFrom(_ point: CGPoint) -> CGPoint {
        let column = tileColumnIndex(fromPosition: point)
        let row = tileRowIndex(fromPosition: point)
        let center = centerOfTile(atColumn: column, row: row)
        
        var edge = CGPoint()
        edge.x = point.x > center.x ? center.x + self.tileSize.width/2 : center.x - self.tileSize.width/2
        edge.y = point.y > center.y ? center.y + self.tileSize.height/2 : center.y - self.tileSize.height/2
        
        return edge
    }
    
    func isEdgeOfTile(_ point: CGPoint) -> Bool {
        let column = tileColumnIndex(fromPosition: point)
        let row = tileRowIndex(fromPosition: point)
        let center = centerOfTile(atColumn: column, row: row)
        
        if (point.x == center.x + tileSize.width/2) ||
            (point.x == center.x - tileSize.width/2) ||
            (point.y == center.y + tileSize.height/2) ||
            (point.y == center.y - tileSize.height/2) {
                return true
        }
        
        return false
    }
    
    //MARK: Map edges
    var leftTop: CGPoint {
        let x = (mapSize.width / 2) - tileSize.width
        let y = (mapSize.height / 2) - tileSize.height
        return CGPoint(x: -x, y: y)
    }
    
    var rightTop: CGPoint {
        let x = (mapSize.width / 2) - tileSize.width
        let y = (mapSize.height / 2) - tileSize.height
        return CGPoint(x: x, y: y)
    }
    
    var leftBottom: CGPoint {
        let x = (mapSize.width / 2) - tileSize.width
        let y = (mapSize.height / 2) - tileSize.height
        return CGPoint(x: -x, y: -y)
    }
    
    var rightBottom: CGPoint {
        let x = (mapSize.width / 2) - tileSize.width
        let y = (mapSize.height / 2) - tileSize.height
        return CGPoint(x: x, y: -y)
    }
}
