
import Foundation
import SpriteKit

enum Restriction{
    case none
    case horizontal
    case vertical
}
enum PositionType{
    case fixed
    case free
}

class Joystick: SKNode {
    
    // MARK: - Properties
    
    var forceTouchAction: ((UITouch) -> Void)?
    var restriction = Restriction.none
    var positionType = PositionType.fixed
    var canFade = true
    let kThumbSpringBackDuration: Double =  0.3
    private let backdropNode, thumbNode: SKSpriteNode
    
    private(set)var isTracking: Bool = false {
        didSet {
            let color = isTracking ? SKColor.black : SKColor.white
            colorizeThumbNode(with: color)
        }
    }
    
    private(set) var velocity: CGPoint = .zero
    private(set) var angularVelocity: CGFloat = 0.0
    
    var anchorPoint: CGPoint {
        return .zero
    }
    
    let thumbSize = CGSize(width: 40, height: 40)
    let dpadSize = CGSize(width: 160, height: 160)
    
    private(set) var moveControllable: MoveControllable?
    private(set) var rotateControllable: RotateControllable?
    
    // MARK: - Initiailziers
    
    init(thumbNode: SKSpriteNode = SKSpriteNode(imageNamed: "joystick-fg"), backdropNode: SKSpriteNode = SKSpriteNode(imageNamed: "joystick-bg"), restriction: Restriction = .none, positionType: PositionType = .fixed) {
        
        self.thumbNode = thumbNode
        self.thumbNode.size = thumbSize
        self.thumbNode.zPosition = 10
        self.thumbNode.alpha = 0.9
        
        
        self.backdropNode = backdropNode
        self.backdropNode.zPosition = 5
        self.backdropNode.size = dpadSize
        self.backdropNode.alpha = 0.7
        
        super.init()
        
        self.addChild(self.backdropNode)
        self.addChild(self.thumbNode)
        
        
        thumbNode.alpha = 0.5
        backdropNode.alpha = 0.5
        
        self.restriction = restriction
        self.positionType = positionType
        self.isUserInteractionEnabled = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setters
    
    func attach(moveControllable: MoveControllable) {
        self.moveControllable = moveControllable
    }
    
    func attach(rotateControllable: RotateControllable) {
        self.rotateControllable = rotateControllable
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint: CGPoint = touch.location(in: self)
            
            
            
                
            
            if self.isTracking == false, self.thumbNode.frame.contains(touchPoint) {
                self.isTracking = true
                fade(alpha: 0.5)
            }
            if(positionType == .free){
                if self.isTracking == false, self.backdropNode.frame.contains(touchPoint) {
                    
                    self.isTracking = true
                    fade(alpha: 0.5)
                    touchesMoved(touches, with: event)
                }
                
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint: CGPoint = touch.location(in: self)
            
            let powx = pow((Double(touchPoint.x) - Double(self.thumbNode.position.x)), 2)
            let powy = pow((Double(touchPoint.y) - Double(self.thumbNode.position.y)), 2)
            let isInCircle = sqrt(powx + powy)
            
            if self.isTracking == true, isInCircle < Double(self.backdropNode.size.width) {
                
                if sqrtf(powf((Float(touchPoint.x) - Float(self.anchorPoint.x)), 2) + powf((Float(touchPoint.y) - Float(self.anchorPoint.y)), 2)) <= Float(self.thumbNode.size.width) {
                    let moveDifference: CGPoint = CGPoint(x: touchPoint.x - self.anchorPoint.x, y: touchPoint.y - self.anchorPoint.y)
                    self.thumbNode.position = CGPoint(x: self.anchorPoint.x + moveDifference.x, y: self.anchorPoint.y + moveDifference.y)
                    
                } else {
                    let vX: Double = Double(touchPoint.x) - Double(self.anchorPoint.x)
                    let vY: Double = Double(touchPoint.y) - Double(self.anchorPoint.y)
                    let magV: Double = sqrt(vX*vX + vY*vY)
                    let aX: Double = Double(self.anchorPoint.x) + vX / magV * Double(self.thumbNode.size.width)
                    let aY: Double = Double(self.anchorPoint.y) + vY / magV * Double(self.thumbNode.size.width)
                    self.thumbNode.position = CGPoint(x: CGFloat(aX), y: CGFloat(aY))
                   
                }
            }
            self.velocity = CGPoint(x: ((self.thumbNode.position.x - self.anchorPoint.x)), y: ((self.thumbNode.position.y - self.anchorPoint.y)))
            self.angularVelocity = -atan2(self.thumbNode.position.x - self.anchorPoint.x, self.thumbNode.position.y - self.anchorPoint.y)
            clampRestriction()
        }
        
        for touch in touches {
            if touch.force > 6.66 {
                forceTouchAction?(touch)
            }
        }
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveControllable?.stopMoving()
        fade(alpha: 0.1)
        self.resetVelocity()
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveControllable?.stopMoving()
        fade(alpha: 0.1)
        self.resetVelocity()
    }
    
    // MAKR: - Conformance to Updatable protocol
    
    func update(_ currentTime: TimeInterval) {
        
        if angularVelocity != 0 {
            rotateControllable?.rotate(for: angularVelocity)
        }
        if velocity.x != 0 || velocity.y != 0 {
            moveControllable?.move(for: velocity)
        }
        
    }
    func fade(alpha: CGFloat){
        if(!canFade) {
            return
        }
        thumbNode.alpha = alpha
        backdropNode.alpha = alpha
    }
    
    // MARK: - Methods
    
    private func resetVelocity() {
        self.isTracking = false
        self.velocity = .zero
        self.angularVelocity = .zero
        let easeOut: SKAction = SKAction.move(to: anchorPoint, duration: kThumbSpringBackDuration)
        easeOut.timingMode = SKActionTimingMode.easeOut
        self.thumbNode.run(easeOut)
    }
    
    private func colorizeThumbNode(with color: SKColor, blendFactor: CGFloat = 0.5, duration: TimeInterval = 0.2) {
        let action = SKAction.colorize(with: color, colorBlendFactor: blendFactor, duration: duration)
        thumbNode.run(action)
    }
    
    private func clampRestriction(){
        switch restriction {
            case .horizontal:
                thumbNode.position.y = CGFloat.clamp(thumbNode.position.y, lower: 0, upper: 0)
            case .vertical:
                thumbNode.position.x = CGFloat.clamp(thumbNode.position.x, lower: 0, upper: 0)
            case .none:
                return
        }
    }
    
}
