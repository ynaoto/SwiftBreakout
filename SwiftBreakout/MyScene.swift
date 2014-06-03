//
//  MyScene.swift
//  SwiftBreakout
//
//  Created by Naoto Yoshioka on 2014/06/03.
//  Copyright (c) 2014年 Naoto Yoshioka. All rights reserved.
//

import UIKit
import SpriteKit


protocol MySceneDelegate {
    func dead()
    func clear()
}

class MyScene: SKScene, SKPhysicsContactDelegate {
    var _padX: CGFloat!
    var padX: CGFloat {
    set(x) {
        _padX = x
        if _pad != nil {
            _pad.position = CGPointMake(x, _pad.position.y)
        }
    }
    get {
        return _padX
    }
    }
    var mySceneDelegate: MySceneDelegate?
    func reset() {
        _blocks = NSMutableSet()
        let y = size.height - 50
        addLineOfBlocksWithColor(UIColor.redColor(), at:y-0)
        addLineOfBlocksWithColor(UIColor.orangeColor(), at:y-12)
        addLineOfBlocksWithColor(UIColor.yellowColor(), at:y-24)
        addLineOfBlocksWithColor(UIColor.greenColor(), at:y-36)
        addLineOfBlocksWithColor(UIColor.blueColor(), at:y-48)
    }
    func respawn(completion block: (() -> Void)!) {
        _ball.runAction(SKAction.moveTo(CGPointMake(_pad.position.x, 20), duration:0), completion:block)
    }
    func fire() {
        _ball.physicsBody.applyImpulse(CGVectorMake(0.5 - Float(arc4random() % 2), 0.5))
    }

    let wallMask    : UInt32 = 1 << 0
    let ballMask    : UInt32 = 1 << 1
    let blockMask   : UInt32 = 1 << 2
    let padMask     : UInt32 = 1 << 3
    let deadZoneMask: UInt32 = 1 << 4

    var _blocks: NSMutableSet!
    var _ball, _pad, _deadZone: SKSpriteNode!
    var _blockSound, _padSound, _deadSound: SKAction!

    func didBeginContact(contact: SKPhysicsContact!) {
        var ballBody, againstBody: SKPhysicsBody
        
        if (contact.bodyA.categoryBitMask & ballMask) != 0 {
            ballBody = contact.bodyA
            againstBody = contact.bodyB
        } else if (contact.bodyB.categoryBitMask & ballMask) != 0 {
            ballBody = contact.bodyB
            againstBody = contact.bodyA
        } else {
            NSLog("something odd...")
            abort()
        }
        
        if (againstBody.categoryBitMask & blockMask) != 0 {
            runAction(_blockSound)
            _blocks.removeObject(againstBody.node)
            againstBody.node.removeFromParent()
            let v = ballBody.velocity
            let n = hypotf(v.dx, v.dy)
            let av = CGVectorMake(0.1 * v.dx / n, 0.1 * v.dy / n)
            ballBody.applyImpulse(av)

            if _blocks.count < 1 {
                _ball.physicsBody.velocity = CGVectorMake(0, 0)
                mySceneDelegate?.clear()
            }
        } else if (againstBody.categoryBitMask & padMask) != 0 {
            runAction(_padSound)
        } else if (againstBody.categoryBitMask & deadZoneMask) != 0 {
            runAction(_deadSound)
            _ball.physicsBody.velocity = CGVectorMake(0, 0)
            
            let smokePath = NSBundle.mainBundle().pathForResource("Smoke", ofType:"sks")
            let smoke = NSKeyedUnarchiver.unarchiveObjectWithFile(smokePath) as SKEmitterNode
            smoke.position = _ball.position
            self.addChild(smoke)
            
            mySceneDelegate?.dead()
        }
    }
    
    func addLineOfBlocksWithColor(color: UIColor, at y:CGFloat) {
        let n = 10
        let a = 0.9 as Float
        let blockSize = CGSizeMake(a * self.size.width / Float(n), 10)
        
        for i in 0...n-1 {
            let sprite = SKSpriteNode(color: color, size: blockSize)
            sprite.position = CGPointMake((Float(i) + 0.5) * size.width / Float(n), y)
            sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
            sprite.physicsBody.categoryBitMask = blockMask
            sprite.physicsBody.dynamic = false
            addChild(sprite)
            _blocks.addObject(sprite)
        }
    }
    
    init(size aSize: CGSize) {
        super.init(size: aSize)

        physicsBody = SKPhysicsBody(edgeLoopFromRect:frame)
        physicsBody.categoryBitMask = wallMask
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        _deadZone = SKSpriteNode(color:UIColor.redColor(), size:CGSizeMake(size.width, 10))
        _deadZone.position = CGPointMake(size.width / 2, _deadZone.size.height / 2)
        _deadZone.physicsBody = SKPhysicsBody(rectangleOfSize:_deadZone.size)
        _deadZone.physicsBody.categoryBitMask = deadZoneMask
        _deadZone.physicsBody.dynamic = false
        addChild(_deadZone)
            
        _ball = SKSpriteNode(color:UIColor.whiteColor(), size:CGSizeMake(10, 10))
        _ball.position = CGPointMake(size.width / 2, 20)
//        _ball.physicsBody = SKPhysicsBody(rectangleOfSize:_ball.size)
        _ball.physicsBody = SKPhysicsBody(circleOfRadius:_ball.size.width / 2)
        _ball.physicsBody.categoryBitMask = ballMask
        _ball.physicsBody.friction = 0.0 // 摩擦無し
        _ball.physicsBody.restitution = 1.0 // 完全弾性
        _ball.physicsBody.linearDamping = 0.0 // 空気抵抗無し
//        ball.physicsBody.allowsRotation = false
        _ball.physicsBody.contactTestBitMask = blockMask|padMask|deadZoneMask
        addChild(_ball)
        
        padX = size.width / 2
        _pad = SKSpriteNode(color:UIColor.lightGrayColor(), size:CGSizeMake(50, 10))
        _pad.position = CGPointMake(padX, 10)
        _pad.physicsBody = SKPhysicsBody(rectangleOfSize:_pad.size)
        _pad.physicsBody.categoryBitMask = padMask
        _pad.physicsBody.dynamic = false
        addChild(_pad)
        
        _blockSound = SKAction.playSoundFileNamed("Pop.caf", waitForCompletion:false)
        _padSound = SKAction.playSoundFileNamed("Ping.caf", waitForCompletion:false)
        _deadSound = SKAction.playSoundFileNamed("Basso.caf", waitForCompletion:false)
    }
}
