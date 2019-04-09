//
//  PhysicsDetection.swift
//  Sprite
//
//  Created by Gustavo Portela Chaves on 22/02/19.
//  Copyright © 2019 Gustavo Portela Chaves. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

struct ColliderType {
    static let none = 0// collide with all
     static let all = 1000 // collide with all
     static let player = 1 // 000000001 = 1
     static let ground = 2 // 000000010 = 2 // 000000100 = 4
     static let checkGround = 3
     static let gravity = 4
     static let wall = 5
     static let platform = 6
}

class PhysicsDetection: NSObject, SCNPhysicsContactDelegate {
    //var player: CharacterNode?
    
    var nodeToRemove = [SCNNode()]
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("bodyA:", contact.nodeA.name ?? "nil", "bodyB: ", contact.nodeB.name ?? "nil")



        if contact.nodeA.name == "Check" || contact.nodeB.name == "Check"{

            var node = SCNNode()
            if contact.nodeA.name == "Floor"{
                node = contact.nodeA
            } else if contact.nodeB.name == "Floor"{
                node = contact.nodeB
            }
            nodeToRemove.append(node)
            node.geometry?.materials.first?.diffuse.contents = UIColor.gray
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
                if let block = self.nodeToRemove.first{
                    self.nodeToRemove.remove(at: 0)
                    block.removeFromParentNode()
                    
                }
            }
        }
    }
    
//    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
//        if contact.nodeA.name == "Check" || contact.nodeB.name == "Check"{
//            print("collision between check")
//            var node = SCNNode()
//            if contact.nodeA.name == "Floor"{
//                node = contact.nodeA
//            } else if contact.nodeB.name == "Floor"{
//                node = contact.nodeB
//            }
//            node.removeFromParentNode()
//
//        }
//    }
   
    
}
