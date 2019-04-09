//
//  Player.swift
//  Bomb boy
//
//  Created by Gustavo Portela Chaves on 03/04/19.
//  Copyright © 2019 Gustavo Portela Chaves. All rights reserved.
//

import Foundation
import SceneKit
import MultipeerConnectivity

class Player: SCNNode{
    
    var checkGround: SCNNode!
    var active = false {
        didSet{
            if active{
                setupCheck()
            }
        }
    }
    
    override init() {
        super.init()
        geometry = SCNSphere(radius: 0.3)
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.red
        geometry?.materials = [redMaterial]
        //self.addChildNode(bodyNode)
        self.name = "Player"
        //setupCheck()
        
        setupPhysicBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupCheck(){
        checkGround = SCNNode()
        checkGround.geometry = SCNBox(width: 0.2, height: 2, length: 0.2, chamferRadius: 0)
        checkGround.name = "Check"
        let blackMaterial = SCNMaterial()
        blackMaterial.diffuse.contents = UIColor.black
        checkGround.geometry?.materials = [blackMaterial]
        
        checkGround.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        checkGround.physicsBody?.isAffectedByGravity = false
        checkGround.physicsBody?.categoryBitMask = ColliderType.checkGround
        checkGround.physicsBody?.contactTestBitMask = ColliderType.ground
        checkGround.physicsBody?.collisionBitMask = ColliderType.none
        checkGround.physicsBody?.angularVelocityFactor = SCNVector3(0,0,0)
        self.addChildNode(checkGround)
    }
    func setupPhysicBody(){
    
        let pb = SCNPhysicsBody(type: .dynamic, shape: nil)
        pb.angularVelocityFactor = SCNVector3(0,0,0)
        pb.friction = 0
        pb.restitution = 0
        self.physicsBody = pb
        
    }
    
    func move(direction: SCNVector3){
        self.position += direction
    }
    
    func move(dx: Float, dy: Float) {
        let speed: Float = 10
        var xSpeed: Float = dx > 0 ? speed : -speed
        var ySpeed: Float = dy > 0 ? speed : -speed
        
        if abs(dx) > abs(dy) || abs(dy) < 15  {
            ySpeed = 0
        }

        if abs(dy) > abs(dx) || abs(dx) < 15 {
            xSpeed = 0
        }
    self.physicsBody?.velocity = SCNVector3(xSpeed, 0, -ySpeed)
      // self.physicsBody?.applyForce(SCNVector3(xSpeed, 0, -ySpeed), asImpulse: false)

    }
    
    
    
}
