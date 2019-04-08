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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func move(direction: SCNVector3){
        self.position += direction
    }
    
    
    
}
