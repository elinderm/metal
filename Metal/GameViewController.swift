//
//  GameViewController.swift
//  Metal
//
//  Created by Emily R. Linderman on 4/19/22.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class GameViewController: UIViewController {
    var panStartZ: CGFloat?
    var draggingNode: SCNNode?
    var lastPanLocation: SCNVector3?
    var overlay : OverlayScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(panGest:)))
        view.addGestureRecognizer(panRecognizer)
        
        // create a new scene
        let scene = SCNScene(named: "MainScene.scn")!
        self.overlay = OverlayScene(size: self.view.bounds.size)
//        self.view.scene.overlaySKScene = overlay
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
//        let block0 = scene.rootNode.childNode(withName: "block0", recursively: true)
//        block0?.physicsBody?.collisionBitMask = 100
//        let t1 = scene.rootNode.childNode(withName: "central", recursively: true)
//        t1?.physicsBody?.collisionBitMask = 1
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        scnView.overlaySKScene = overlay
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            self.overlay.objLabel.text = result.node.name
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    @objc
    func handlePan(panGest: UIPanGestureRecognizer) {
        guard let view = view as? SCNView else {return}
        let location = panGest.location(in: self.view)
        switch panGest.state {
        case .began:
            guard let hitNodeResult = view.hitTest(location, options: nil).first else {return}
            lastPanLocation = hitNodeResult.worldCoordinates
            panStartZ = CGFloat(view.projectPoint(lastPanLocation!).z)
            draggingNode = hitNodeResult.node
        case .changed:
            let location = panGest.location(in: view)
            if (panStartZ == nil) {return}
            let worldTouchPosition = view.unprojectPoint(SCNVector3(location.x, location.y, panStartZ!))
            let movementVector = SCNVector3(
                worldTouchPosition.x - lastPanLocation!.x,
                worldTouchPosition.y - lastPanLocation!.y,
                worldTouchPosition.z - lastPanLocation!.z
            )
            let name = draggingNode?.name
            if (name == "base" || name == "backWall" || name == "leftWall" || name == "rightWall") {break}
            draggingNode?.localTranslate(by: movementVector)
            self.lastPanLocation = worldTouchPosition
        default:
            break
        }
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
