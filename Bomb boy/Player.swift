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
    var peerID: MCPeerID?
    
    override init() {
        super.init()
        geometry = SCNSphere(radius: 0.4)
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.red
        geometry?.materials = [redMaterial]
        
        setupPhysicBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPhysicBody(){
    
        let pb = SCNPhysicsBody(type: .dynamic, shape: nil)
        pb.friction = 0
        self.physicsBody = pb
    }
    
    func move(direction: SCNVector3){
        self.position += direction
    }
    
    func move(dx: Float, dy: Float) {
        let speed: Float = 10
        let xSpeed: Float = dx > 0 ? speed : -speed
        let ySpeed: Float = dy > 0 ? speed : -speed
        
//        if abs(dx) > abs(dy) || abs(dy) < 15  {
//            ySpeed = 0
//        }
//
//        if abs(dy) > abs(dx) || abs(dx) < 15 {
//            xSpeed = 0
//        }
        
       self.physicsBody?.applyForce(SCNVector3(xSpeed, 0, -ySpeed), asImpulse: false)
////
//        if xSpeed == 0 && ySpeed == 0 {
//          self.physicsBody?.velocity = SCNVector3.zero
//        }

        //self.physicsBody?.velocity = SCNVector3(xSpeed, 0, -ySpeed)
    }
    
    
    
}
