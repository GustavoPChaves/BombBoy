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
import MultipeerConnectivity

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    var playerColors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow]
    var startPoints: [SCNVector3] = [SCNVector3(-14.5, 0, -9.5),SCNVector3(13.5, 0, 8.5), SCNVector3(13.5, 0, -9.5), SCNVector3(-14.5, 0, 8.5)]
    var scene: SCNScene!
    var physicsDelegate: PhysicsDetection!
    var player: Player!
    var joyStick: Joystick!
    var spriteView: SKView!
    var spriteScene: SKScene!
    var levelNode: SCNNode!
    //Multipeer attributes
    var peerID: MCPeerID!
    var allPlayers: [MCPeerID: Player] = [:]
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    var startingGame = true
    var pauseNode = SKSpriteNode(color: .white, size: CGSize.zero)
    var pauseTitleLabel = SKLabelNode(text: "Wating for players...")
    var pauseSubTitleLabel = SKLabelNode(text: "Press A to start")
    var pauseTimer = 2

    var numberOfPlayer = 0
    var paused = false
    var imagePaused = UIImageView.init(image: UIImage(named: "play.png"))
    var numberPlayConnected = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        
        startHosting()
    }
    
    func setupScene() {
        physicsDelegate = PhysicsDetection()
        // create a new scene
        scene = SCNScene()
        
        imagePaused.frame.origin.x = 553
        imagePaused.frame.origin.y = 197
        imagePaused.image = nil
        view.addSubview(imagePaused)
        
        print(numberOfPlayer)
        scene.physicsWorld.gravity = SCNVector3(0, -20, 0)
        scene.background.contents = UIImage(named: "lauchScreem.png")
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.name = "Camera"
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 18, z: 12)
        cameraNode.eulerAngles.x = -60 * .pi / 180
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
        createDeathArea()
        
        self.spriteScene = SKScene()
        self.spriteView = SKView(frame: view.frame)
        spriteView.backgroundColor = .clear
        spriteScene.backgroundColor = .clear
        spriteScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        spriteScene.scaleMode = .resizeFill
        spriteView.presentScene(spriteScene)
        view.addSubview(spriteView)
        
        
        physicsDelegate.gameVC = self
        scene.physicsWorld.contactDelegate = physicsDelegate
        scene.physicsWorld.gravity = SCNVector3(0,-50,0)

        setupPauseLabel()
        scene.isPaused = true
        
        if numberPlayConnected >= numberOfPlayer{
            scene.isPaused = false
            self.pauseNode.removeFromParent()
        }
    }

    
    func setupPauseLabel(){
        pauseNode.size = CGSize(width: self.view.frame.width, height: 250)
        pauseNode.color = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.8)
        pauseNode.position = CGPoint.zero

        pauseTitleLabel.text = "Waiting for players..."
        pauseSubTitleLabel.text = ""

        pauseTitleLabel.position = CGPoint.zero
        pauseTitleLabel.fontSize = 60
        pauseTitleLabel.fontColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        pauseTitleLabel.fontName = "HelveticaNeue-Bold"
        pauseTitleLabel.zPosition = 10
        pauseTitleLabel.removeFromParent()
        pauseNode.addChild(pauseTitleLabel)

        pauseSubTitleLabel.position = CGPoint(x: 0, y: -80)
        pauseSubTitleLabel.fontSize = 40
        pauseSubTitleLabel.fontColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        pauseSubTitleLabel.fontName = "HelveticaNeue"
        pauseSubTitleLabel.zPosition = 10
        pauseSubTitleLabel.removeFromParent()
        pauseNode.addChild(pauseSubTitleLabel)

        pauseNode.removeFromParent()
        spriteScene.addChild(pauseNode)

    }
    
    func createLevel(width: CGFloat, height: CGFloat){
        levelNode = SCNNode()
        levelNode.name = "Floors"
        let positions = [(-width/2), (-height/2)]
        for row in 0..<Int(width) {
            for column in 0..<Int(height){
                let block = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
                let blockNode = SCNNode()
                blockNode.name = "Floor"
                blockNode.geometry = block
                blockNode.position = SCNVector3(positions[0] + CGFloat(row), -1, positions[1] + CGFloat(column))
                blockNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
                blockNode.physicsBody?.isAffectedByGravity = false
                blockNode.physicsBody?.categoryBitMask = ColliderType.ground
                blockNode.geometry?.firstMaterial?.diffuse.contents = "grass.png"
                levelNode.addChildNode(blockNode)
            }
        }
        
        scene.rootNode.addChildNode(levelNode)
        createFences(node: scene.rootNode, width: width, height: height)
        //createPins(node: scene.rootNode, width: width, height: height)
        
        
        
    }
    
    func createDeathArea(){
        let deathAreaNode = SCNNode()
        deathAreaNode.name = "DeathArea"
        let deathAreaBlock = SCNPlane(width: 50, height: 50)
        
        deathAreaNode.eulerAngles.x = -90 * .pi / 180
        deathAreaNode.geometry = deathAreaBlock
        deathAreaNode.position = SCNVector3(0, -0.6, 0)
        deathAreaNode.geometry?.materials.first?.diffuse.contents = UIColor.clear
        deathAreaNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        deathAreaNode.physicsBody?.isAffectedByGravity = false
        deathAreaNode.physicsBody?.categoryBitMask = ColliderType.deathArea
        deathAreaNode.physicsBody?.collisionBitMask = ColliderType.none
        scene.rootNode.addChildNode(deathAreaNode)
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
                    fence.geometry?.firstMaterial?.diffuse.contents = "wall.png"
                    fencesNode.addChildNode(fence)
                }
            }
            else{
                let fence = createFence()
                fence.position = SCNVector3(positions[0] + CGFloat(0), 0, positions[1] + CGFloat(row))
                let fence2 = createFence()
                fence2.position = SCNVector3(positions[0] + CGFloat(width-1), 0, positions[1] + CGFloat(row))
                
                fence.geometry?.firstMaterial?.diffuse.contents = "wall.png"
                fence2.geometry?.firstMaterial?.diffuse.contents = "wall.png"
                fencesNode.addChildNode(fence)
                fencesNode.addChildNode(fence2)
            }
            
            
        }
        //setup physics body
        let pb = SCNPhysicsBody(type: .static, shape: nil)
        pb.continuousCollisionDetectionThreshold = 10
        fencesNode.physicsBody = pb
        fencesNode.physicsBody?.categoryBitMask = ColliderType.wall
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
                blockNode.name = "Pin"
                blockNode.geometry = block
                blockNode.position = SCNVector3(positions[0] + CGFloat(row), 0, positions[1] + CGFloat(column))
                fencesNode.addChildNode(blockNode)
            }
        }
        
        //setup physics body
        let pb = SCNPhysicsBody(type: .static, shape: nil)
        pb.continuousCollisionDetectionThreshold = 100
        fencesNode.physicsBody = pb
        fencesNode.physicsBody?.categoryBitMask = ColliderType.wall
        node.addChildNode(fencesNode)
    }
    
    func createFence()->SCNNode{
        let block = SCNBox(width: 1, height: 2, length: 1, chamferRadius: 0)
        let blockNode = SCNNode()
        blockNode.name = "Wall"
        blockNode.geometry = block
        return blockNode
    }
    
    
    func checkForWinner() {
        print("checking for winner...")
        var countWinner = 0
        var winner: Player?
        
        allPlayers.forEach { (id, player) in
            if !player.playerLost {
                countWinner += 1
                winner = player
            }
        }
        
        if let winPlayer = winner, countWinner == 1, allPlayers.count > 1 {

            self.pauseTitleLabel.text = "WINNER: \(winPlayer.peerID?.displayName ?? "")"
            self.pauseSubTitleLabel.text =  ""
            
            self.pauseNode.removeFromParent()
            self.spriteScene.addChild(self.pauseNode)
            
            scene.rootNode.runAction(SCNAction.wait(duration: 2)) {
                self.pauseSubTitleLabel.text =  "Press B to restart game"
                self.scene.isPaused = true
            }
        }else if countWinner == 0 {
            self.pauseTitleLabel.text = "DRAW"
            self.pauseSubTitleLabel.text =  ""
            
            self.pauseNode.removeFromParent()
            self.spriteScene.addChild(self.pauseNode)
            
            scene.rootNode.runAction(SCNAction.wait(duration: 2)) {
                self.pauseSubTitleLabel.text =  "Press B to restart game"
                self.scene.isPaused = true
            }
        }
    }
    
    
    func setupPlayers() {
        
        for i in allPlayers.enumerated() {
            
            let player = Player()
            let peerID = i.element.key
            
            allPlayers[peerID] = player
            player.active = false
            player.canControl = true
            player.position = startPoints[i.offset]
            player.geometry?.materials.first?.diffuse.contents = playerColors[i.offset]
            player.peerID = peerID
            scene.rootNode.removeFromParentNode()
            scene.rootNode.addChildNode(player)
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        

    }
}


//Multipeer methods
extension GameViewController: MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    func startHosting(){
        
        //start host to search for controllers
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-kb", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            
            let player = Player()
            player.geometry?.materials.first?.diffuse.contents = playerColors[allPlayers.count]
            player.position = startPoints[allPlayers.count]
            scene.rootNode.addChildNode(player)
            allPlayers[peerID] = player
            player.peerID = peerID
            print("Connected: \(peerID.displayName)")
            numberPlayConnected += 1
            
            if numberPlayConnected == numberOfPlayer{
                scene.isPaused = false
                self.pauseNode.removeFromParent()
            }
            
        case .connecting:
            print("Connecting: \(peerID.displayName)")
            
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
            allPlayers[peerID]?.removeFromParentNode()
            allPlayers.removeValue(forKey: peerID)
            
        default:
            fatalError("Error: entered in default case")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = Message.unarchive(data) {
            DispatchQueue.main.async {
                
                switch message {
                case .move(let dx, let dy):
                    
                    DispatchQueue.main.async {
                        if let p = self.allPlayers[peerID] {
                            if !p.active {
                                p.active = true
                            }
                            p.move(dx: dx, dy: dy)
                        }
                    }

                case .pressA:
                    if self.paused == false{
                        self.imagePaused.image = UIImage(named: "pause.png")
                        self.scene.isPaused = true
                        self.paused = true
                    }else{
                        self.imagePaused.image = nil
                        self.scene.isPaused = false
                        self.paused = false
                    }
                    
                case .pressB:
                    print("pressed B")
                    if self.scene.isPaused {
                        self.setupScene()
                        self.setupPlayers()
                    }
//                case .pressA:
//                    DispatchQueue.main.async {
//
//                        if self.scene.isPaused {
//                            self.unpause()
//
//                        }else{
//
//                            self.scene.isPaused = true
//                            self.pauseTitleLabel.text = "GAME PAUSED"
//                            self.pauseSubTitleLabel.text = "Press A to continue. Press B to Restart Game"
//
//                            self.pauseNode.removeFromParent()
//                            self.spriteScene.addChild(self.pauseNode)
//
//                        }
//                    }
                }
            }
        }
    }
    
    func unpause() {
        print("unpause \(self.pauseTimer)")
        self.pauseTitleLabel.text = "3"
        self.pauseSubTitleLabel.text = ""
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            print("unpause timer \(self.pauseTimer)")
            self.pauseTitleLabel.text = "\(self.pauseTimer)"
            
            if self.pauseTimer == 0 {
                self.pauseTitleLabel.text = "GO!"
            }
            
            if self.pauseTimer <= -1 {
                
                print("completion unpause")
                self.scene.isPaused = false
                self.pauseNode.removeFromParent()
                timer.invalidate()
                self.pauseTimer = 3
            }
            
            self.pauseTimer -= 1
        }
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    

}

