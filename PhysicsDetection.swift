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
    static let deathArea = 7
}

class PhysicsDetection: NSObject, SCNPhysicsContactDelegate {
    //var player: CharacterNode?
    var gameVC: GameViewController?
    var nodeToRemove = [SCNNode()]
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        //print("bodyA:", contact.nodeA.name ?? "nil", "bodyB: ", contact.nodeB.name ?? "nil")
        
        if contact.nodeA.name == "Check" || contact.nodeB.name == "Check" {

            var node = SCNNode()
            if contact.nodeA.name == "Floor"{
                node = contact.nodeA
            } else if contact.nodeB.name == "Floor"{
                node = contact.nodeB
            }
            nodeToRemove.append(node)
            node.geometry?.materials.first?.diffuse.contents = "grassCrack.png"

            let waitAction = SCNAction.wait(duration: 3)
            gameVC?.scene.rootNode.runAction(waitAction) {
                if let block = self.nodeToRemove.first{
                    self.nodeToRemove.remove(at: 0)
                    block.removeFromParentNode()
                    
                }
            }

        }
        
        if (contact.nodeA.name == "DeathArea" || contact.nodeB.name == "DeathArea") &&
            (contact.nodeA.name == "Player" || contact.nodeB.name == "Player") {
            print("CAIU")
            var playerNode = Player()
            if contact.nodeA.name == "Player" {
                playerNode = contact.nodeA as! Player
            } else {
                playerNode = contact.nodeB as! Player
            }
            
            playerNode.canControl = false
            playerNode.playerLost = true
            gameVC?.checkForWinner()
        }
        
    }
    
    
    
}
