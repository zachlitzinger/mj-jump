//
//  GameScene.swift
//  FlappyGame1
//
//  Created by Zach Litzinger on 5/22/16.
//  Copyright (c) 2016 Zach Litzinger. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let Player : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
    
    
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Ground = SKSpriteNode()
    var Player = SKSpriteNode()
    
    var wallPair = SKNode()
    
    var moveAndRemove = SKAction()
    
    var gameStarted = Bool()
    
    var score = Int()
    let scoreLbl = SKLabelNode()
    
    var died = Bool()
    var restartBTN = SKSpriteNode()
    
    
    
    func restartScene(){
        
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
        
    }
    
    func createScene(){
        
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "Hoop")
            background.anchorPoint = CGPointZero
            background.position = CGPointMake(CGFloat(i) * self.frame.width, 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
            
            
        }
        
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLbl.text = "\(score)"
        scoreLbl.fontName = "Mexecellent"
        scoreLbl.fontSize = 60
        scoreLbl.zPosition = 5
        self.addChild(scoreLbl)
        
        
        Ground = SKSpriteNode(imageNamed: "Court")
        Ground.setScale(0.5)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOfSize: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.Player
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.dynamic = false
        
        Ground.zPosition = 3
        
        
        self.addChild(Ground)
        
        
        Player = SKSpriteNode(imageNamed: "MJ")
        Player.size = CGSize(width: 100, height: 110)
        Player.position = CGPoint(x: self.frame.width / 2 - Player.frame.width, y: self.frame.height / 2)
        
        Player.physicsBody = SKPhysicsBody(circleOfRadius: Player.frame.height / 2 - 5)
        Player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        Player.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall
        Player.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Score
        Player.physicsBody?.affectedByGravity = false
        Player.physicsBody?.dynamic = true
        
        Player.zPosition = 2
        
        
        self.addChild(Player)
        

        
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
      createScene()
    
        
    }
    
    func createBTN(){
        
        restartBTN = SKSpriteNode(imageNamed: "Crying")
        restartBTN.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBTN.zPosition = 6
        restartBTN.setScale(0)
        self.addChild(restartBTN)
        restartBTN.runAction(SKAction.scaleTo(1.5, duration: 0.7))
        
        
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Player{
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
            
        }
            
        
        else if firstBody.categoryBitMask == PhysicsCategory.Player && secondBody.categoryBitMask == PhysicsCategory.Score {
            
            score += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        }
        
        else if firstBody.categoryBitMask == PhysicsCategory.Player && secondBody.categoryBitMask == PhysicsCategory.Wall || firstBody.categoryBitMask == PhysicsCategory.Wall && secondBody.categoryBitMask == PhysicsCategory.Player {
            
            
            
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false{
                died = true
                createBTN()
            }
            
            
            
            
        }
        else if firstBody.categoryBitMask == PhysicsCategory.Player && secondBody.categoryBitMask == PhysicsCategory.Ground || firstBody.categoryBitMask == PhysicsCategory.Ground && secondBody.categoryBitMask == PhysicsCategory.Player {
            
            
            
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            if died == false{
                died = true
                createBTN()
            }
            
            
            
            
        }
        

        
        
        
        
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        if gameStarted == false{
            
            gameStarted = true
            
            Player.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.runBlock({
                () in
                
                self.createWalls()
                
            })
            
            let delay = SKAction.waitForDuration(3.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatActionForever(SpawnDelay)
            self.runAction(spawnDelayForever)
            
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveByX(-distance - 50, y: 0, duration: NSTimeInterval(0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Player.physicsBody?.velocity = CGVectorMake(0, 0)
            Player.physicsBody?.applyImpulse(CGVectorMake(0, 200))
            
        }
        else{
            
            if died == true{
                
            }
            else {
                Player.physicsBody?.velocity = CGVectorMake(0, 0)
                Player.physicsBody?.applyImpulse(CGVectorMake(0, 200))
            }
        }
        
        for touch in touches{
            let location = touch.locationInNode(self)
            
            if died == true{
                if restartBTN.containsPoint(location){
                    restartScene()
                }
                
                
            }
        }
        
        
        
        
        
        }
    
    func createWalls(){
        
        let scoreNode = SKSpriteNode(imageNamed: "Ball")
        
        scoreNode.size = CGSize(width: 75, height: 100)
        scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height/2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.dynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        
        
        
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 375)
        btmWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 375)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Player
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        topWall.physicsBody?.dynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOfSize: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCategory.Player
        btmWall.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        btmWall.physicsBody?.dynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
        
        let randomPosition = CGFloat.random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y + randomPosition
        wallPair.addChild(scoreNode)
        
        wallPair.runAction(moveAndRemove)
        
        
        self.addChild(wallPair)
        
        
        
        
        
        
        
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if gameStarted == true{
            if died == false{
                enumerateChildNodesWithName("background", usingBlock: ({
                    (node,error) in
                    
                    let bg = node as! SKSpriteNode
                    
                    bg.position = CGPoint(x: bg.position.x, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y)
                    }
                }))
            }
        }
    }
}
