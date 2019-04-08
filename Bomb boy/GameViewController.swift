//
//  GameViewController.swift
//  Bomb boy
//
//  Created by Gustavo Portela Chaves on 03/04/19.
//  Copyright © 2019 Gustavo Portela Chaves. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit
class GameViewController: UIViewController {

    var scene: SCNScene!
    
    var player: Player!
    var joyStick: Joystick!
    var spriteView: SKView!
    var spriteScene: SKScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        scene = SCNScene()
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.name = "Camera"
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 15)
        cameraNode.eulerAngles.x = -30 * .pi / 180
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.name = "Directional Light"
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.name = "Ambiente Light"
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        //scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        
        
        

        
        createLevel(width: 31, height: 21)
        
        player = Player()
        player.position = SCNVector3(-0.5, 0, 0.5)
        scene.rootNode.addChildNode(player)
        addGestures()
        
        
        self.spriteScene = SKScene()
        self.spriteView = SKView(frame: view.frame)
        spriteView.backgroundColor = .clear
        spriteScene.backgroundColor = .clear
        spriteScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        spriteView.presentScene(spriteScene)
        view.addSubview(spriteView)
        
        joyStick = Joystick()
        joyStick.position = CGPoint(x: 0, y: 0)

        spriteScene.addChild(joyStick)
    }
    
    
    func addGestures(){
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)];
        self.view.addGestureRecognizer(tapRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.pan(_:)))
        self.view.addGestureRecognizer(panRecognizer)
        
//        let directions: [UISwipeGestureRecognizer.Direction] = [.up, .right, .down, .left]
//
//        for i in 0..<4{
//            let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe(_:)))
//            swipeRecognizer.direction = directions[i]
//
//            self.view.addGestureRecognizer(swipeRecognizer)
//        }
    }
    
    @objc func pan(_ sender: UIPanGestureRecognizer? = nil){
        print(sender?.translation(in: self.view))
        joyStick.move(touchPoint: sender!.translation(in: self.view))
    }
    @objc func tapped(_ sender: UITapGestureRecognizer? = nil){
        print("foi")
    }
    @objc func swipe(_ sender: UISwipeGestureRecognizer? = nil){
        
        switch sender?.direction {
        case UISwipeGestureRecognizer.Direction.up:
            player.move(direction: SCNVector3(0,0,1))
            print("up")
        case UISwipeGestureRecognizer.Direction.right:
            player.move(direction: SCNVector3(1,0,0))
            print("right")
        case UISwipeGestureRecognizer.Direction.down:
            player.move(direction: SCNVector3(0,0,-1))
            print("down")
        case UISwipeGestureRecognizer.Direction.left:
            player.move(direction: SCNVector3(-1,0,0))
            print("left")
        default:
            print("nunca")
        }
    }
    
    func createLevel(width: CGFloat, height: CGFloat){
        let levelNode = SCNNode()
        levelNode.name = "Floor"
        let positions = [(-width/2), (-height/2)]
        for row in 0..<Int(width) {
            for column in 0..<Int(height){
                let block = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
                let blockNode = SCNNode()
                blockNode.geometry = block
                blockNode.position = SCNVector3(positions[0] + CGFloat(row), -1, positions[1] + CGFloat(column))
                levelNode.addChildNode(blockNode)
            }
        }
        scene.rootNode.addChildNode(levelNode)
        createFences(node: scene.rootNode, width: width, height: height)
        createPins(node: scene.rootNode, width: width, height: height)
    }
    
    func createFences(node: SCNNode, width: CGFloat, height: CGFloat){
        let fencesNode = SCNNode()
        fencesNode.name = "Walls"
        let positions = [(-width/2), (-height/2)]
       
        for row in 0..<Int(height){
            if(row == 0 || row == Int(height - 1)){
                let numberOfFences = Int(width)
                for column in 0..<numberOfFences{
                    let fence = createFence()
                    fence.position = SCNVector3(positions[0] + CGFloat(column), 0, positions[1] + CGFloat(row))
                    fencesNode.addChildNode(fence)
                }
            }
            else{
                let fence = createFence()
                fence.position = SCNVector3(positions[0] + CGFloat(0), 0, positions[1] + CGFloat(row))
                let fence2 = createFence()
                fence2.position = SCNVector3(positions[0] + CGFloat(width-1), 0, positions[1] + CGFloat(row))
                fencesNode.addChildNode(fence)
                fencesNode.addChildNode(fence2)
            }
            
            
        }
        node.addChildNode(fencesNode)
    }
    func createPins(node: SCNNode, width: CGFloat, height: CGFloat){
        let fencesNode = SCNNode()
        fencesNode.name = "Pins"
        let positions = [(-width/2), (-height/2)]
        
        for row in 2..<Int(width-2) where row % 2 == 0{
            for column in 2..<Int(height-2) where column % 2 == 0 {
                let block = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
                let blockNode = SCNNode()
                blockNode.geometry = block
                blockNode.position = SCNVector3(positions[0] + CGFloat(row), 0, positions[1] + CGFloat(column))
                fencesNode.addChildNode(blockNode)
            }
        }
        node.addChildNode(fencesNode)
    }
    func createFence()->SCNNode{
        let block = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let blockNode = SCNNode()
        blockNode.geometry = block
        return blockNode
    }
    
    
    func collada2SCNNode(filepath:String) -> SCNNode {
        
        var node = SCNNode()
        let scene = SCNScene(named: filepath)
        var nodeArray = scene!.rootNode.childNodes
        
        for childNode in nodeArray {
            
            node.addChildNode(childNode as SCNNode)
            
        }
        
        return node
        
    }


    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?)  {
//        for item in presses {
//            if item.type == .select {
//                self.view.backgroundColor = UIColor.green
//            }
//        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
//        for item in presses {
//            if item.type == .select {
//                self.view.backgroundColor = UIColor.white
//            }
//        }
    }
    
    override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent?)  {
        // ignored
    }
    
    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?)  {
//        for item in presses {
//            if item.type == .select {
//                self.view.backgroundColor = UIColor.white
//            }
//        }
    }
}
