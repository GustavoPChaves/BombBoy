//
//  Player.swift
//  Bomb boy
//
//  Created by Gustavo Portela Chaves on 03/04/19.
//  Copyright © 2019 Gustavo Portela Chaves. All rights reserved.
//

import Foundation
import SceneKit

class Player: SCNNode{
    
    override init() {
        super.init()
        geometry = SCNSphere(radius: 0.5)
        var redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.red
        geometry?.materials = [redMaterial]
        
        setupPhysicBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPhysicBody(){
        let pb = SCNPhysicsBody(type: .dynamic, shape: nil)
        pb.mass = 100
        self.physicsBody = pb
    }
    
    func move(direction: SCNVector3){
        self.position += direction
    }
    
    func move(dx: Float, dy: Float) {
        var xSpeed: Float = dx > 0 ? 10 : -10
        var ySpeed: Float = dy > 0 ? 10 : -10
        
        if abs(dx) > abs(dy) || abs(dy) < 15  {
            ySpeed = 0
        }
        
        if abs(dy) > abs(dx) || abs(dx) < 15 {
            xSpeed = 0
        }
        
        self.physicsBody?.velocity = SCNVector3(xSpeed, 0, -ySpeed)
    }
    
    
    
}
