//
//  GameScene.swift
//  Project26
//
//  Created by Daniel Haugstvedt on 07/03/16.
//  Copyright (c) 2016 Daniel Haugstvedt. All rights reserved.
//

import SpriteKit

enum CollisionTypes: UInt32 {
    case Player = 1
    case Wall = 2
    case Star = 4
    case Vortex = 8
    case Finish = 16
}

class GameScene: SKScene {
    
    var player: SKSpriteNode!
    var lastTouchPostition: CGPoint?
    
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = -1
        background.blendMode = .Replace
        addChild(background)
        loadLevel()
        
        creatPlayer()
        
        physicsWorld.gravity = CGVector.zero
    }
  
    //MARK: - Touches
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            lastTouchPostition = nil
            return
        }
        lastTouchPostition = touch.locationInNode(self)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            lastTouchPostition = nil
            return
        }
        lastTouchPostition = touch.locationInNode(self)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        lastTouchPostition = nil
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        lastTouchPostition = nil
    }
    
    
    //MARK: - Game cycle
  
    override func update(currentTime: CFTimeInterval) {
        if let currentTouch = lastTouchPostition {
            let diff = currentTouch - player.position
            physicsWorld.gravity = CGVector(point: diff/100)
        }
    }
    
    
    //MARK: - Helper funcions for setting up level
    func creatPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.categoryBitMask = CollisionTypes.Player.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.Wall.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.Vortex.rawValue | CollisionTypes.Star.rawValue | CollisionTypes.Finish.rawValue
        
        addChild(player)
    }
    
    func loadLevel() {
        if let levelPath = NSBundle.mainBundle().pathForResource("level1", ofType: "txt"){
            if let levelString = try? String(contentsOfFile: levelPath){
                let lines = levelString.componentsSeparatedByString("\n")
                
                for (row, line) in lines.reverse().enumerate() {
                    for (column, letter) in line.characters.enumerate() {
                        let position = CGPoint(x: 64*column + 32, y: 64*row + 32)
                        switch letter {
                        case "x":
                           loadLevelNodeOfType(CollisionTypes.Wall, position: position)
                        case "v":
                            loadLevelNodeOfType(CollisionTypes.Vortex, position: position)
                        case "s":
                            loadLevelNodeOfType(CollisionTypes.Star, position: position)
                        case "f":
                            loadLevelNodeOfType(CollisionTypes.Finish, position: position)
                        default:
                            break
                            
                        }
                    }
                }
            }
        }
    }
    
    func loadLevelNodeOfType(nodeType: CollisionTypes, position: CGPoint) {
        var node:SKSpriteNode
        
        switch nodeType {
        case .Wall:
            node = SKSpriteNode(imageNamed: "block")
            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
        case .Vortex:
            node = SKSpriteNode(imageNamed: "vortex")
            node.name = "vortex"
            node.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(M_PI), duration: 1)))
            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
        case .Star:
            node = SKSpriteNode(imageNamed: "star")
            node.name = "star"
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width/2)
        case .Finish:
            node = SKSpriteNode(imageNamed: "finish")
            node.name = "finish"
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width/2)
        case .Player:
            print("did you send in a player node as part of the map?")
            return
        }
        
        node.position = position
        node.physicsBody?.dynamic = false
        
        switch nodeType {
        case .Wall:
            node.physicsBody?.categoryBitMask = CollisionTypes.Wall.rawValue
        case .Vortex:
            node.physicsBody?.categoryBitMask = CollisionTypes.Vortex.rawValue
            node.physicsBody?.collisionBitMask = 0
            node.physicsBody?.contactTestBitMask = CollisionTypes.Player.rawValue
        case .Star:
            node.physicsBody?.categoryBitMask = CollisionTypes.Star.rawValue
            node.physicsBody?.contactTestBitMask = CollisionTypes.Player.rawValue
            node.physicsBody?.collisionBitMask = 0
        case .Finish:
            node.physicsBody?.categoryBitMask = CollisionTypes.Finish.rawValue
            node.physicsBody?.contactTestBitMask = CollisionTypes.Player.rawValue
            node.physicsBody?.collisionBitMask = 0
        default:
            return
        }
        addChild(node)
    }
}
