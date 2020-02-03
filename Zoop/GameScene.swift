//
//  GameScene.swift
//  Zoop
//
//  Created by M Rezaur Rahman on 2020-01-18.
//  Copyright © 2020 M Rezaur Rahman. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var lastUpdateTime: TimeInterval = 0
    let playableRect: CGRect
    var dt: TimeInterval = 0
    let fish = SKSpriteNode(imageNamed: "fish")
    let crab = SKSpriteNode(imageNamed: "crab")
    let fishMovePointPerSecond: CGFloat = 480.0
    var velocity = CGPoint.zero
    var lastTouchLocation: CGPoint?
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight)/2
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width/2, y: size.width/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.zPosition = -1
        addChild(background)
        
        fish.size = CGSize(width: 200, height: 200)
        fish.position = CGPoint(x: 1600, y: 600)
        fish.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(fish)
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnEnemy),SKAction.wait(forDuration: 2.0)])))
        

        crab.size = CGSize(width: 200, height: 200)
        crab.position = CGPoint(x: 1500, y: 500)
        addChild(crab)
        
        debugDrawPlayableArea()
    }
    
    
    
    
    func spawnEnemy() {
        let shark = SKSpriteNode(imageNamed: "shark")
        fish.size = CGSize(width: 200, height: 200)
        shark.position = CGPoint(
            x: size.width+shark.size.width/2,
            y: CGFloat.random(
                min: playableRect.minY + shark.size.height/2,
                max: playableRect.maxY + shark.size.height/2
            )
        )
        addChild(shark)
        let actionMove = SKAction.moveTo(x: -shark.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        shark.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint){
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
        print("amount to move \(amountToMove)")
        sprite.position = CGPoint(x: sprite.position.x +     amountToMove.x, y: sprite.position.y + amountToMove.y)
    }
    
    func BoundCheckFish() {
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxX)
        if(fish.position.x <= bottomLeft.x) {
            fish.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if fish.position.x >= topRight.x {
            fish.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if fish.position.y<=bottomLeft.y {
            fish.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if fish.position.y >= topRight.y {
            fish.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func moveFishToward(location: CGPoint) {
        let offset = CGPoint(x: location.x - fish.position.x, y: location.y-fish.position.y)
        let length = sqrt(Double(offset.x*offset.x+offset.y*offset.y))
        let direction = CGPoint(x: offset.x/CGFloat(length), y: offset.y/CGFloat(length))
        velocity = CGPoint(x: direction.x*fishMovePointPerSecond, y: direction.y*fishMovePointPerSecond)
    }
    
    func angle(between starting: CGPoint, ending: CGPoint) -> CGFloat {
        let center = CGPoint(x: ending.x - starting.x, y: ending.y - starting.y)
        let radians = atan2(center.y, center.x)
        let degrees = radians * 180 / .pi
        return degrees > 0 ? degrees : degrees + degrees
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime>0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt=0
        }
        lastUpdateTime = currentTime
//        print("\(dt*1000)")
//        moveSprite(sprite: fish, velocity: CGPoint(x: fishMovePointPerSecond, y: 0))
        if let lastTouchLocation = lastTouchLocation {
//            let diff = lastTouchLocation - fish.position
            let p1 = lastTouchLocation //[1]
            let p2 = fish.position
            //Assign the coord of p2 and p1...
            //End Assign...
            let xDist = (p2.x - p1.x); //[2]
            
            print("xDist start")
            print(fish.yScale)
            print("xDist end")
            if xDist > 0 {
                fish.yScale = -1.0
            }
            if xDist <= 0 {
                fish.yScale = 1
            }
            let yDist = (p2.y - p1.y); //[3]
            let distance = sqrt((xDist * xDist) + (yDist * yDist)) //[4]
//            if(diff.length() <= fishMovePointPerSecond*CGFloat(dt)) {
            if(distance <= fishMovePointPerSecond*CGFloat(dt)) {
                fish.position = lastTouchLocation
                velocity = CGPoint.zero
            } else {
                let center = CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
                let radians = atan2(center.y, center.x)
                fish.run(SKAction.rotate(toAngle: radians, duration: 0.001))
                
                moveSprite(sprite: fish, velocity: velocity)
            }
        }
        
        BoundCheckFish()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        lastTouchLocation = touchLocation
        moveFishToward(location: touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        lastTouchLocation = touchLocation
        moveFishToward(location: touchLocation)
    }
    
    func debugDrawPlayableArea(){
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
//        CGPathAddRect(path, NIL, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
}
