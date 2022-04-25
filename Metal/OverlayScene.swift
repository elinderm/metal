//
//  OverlayScene.swift
//  Metal
//
//  Created by Emily R. Linderman on 4/24/22.
//

import Foundation
import SpriteKit

class OverlayScene: SKScene {
    var objLabel: SKLabelNode!
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = UIColor.clear
        
        self.objLabel = SKLabelNode(text: "")
        self.objLabel.fontName = "DINAternate-Bold"
        self.objLabel.fontColor = UIColor.white
        self.objLabel.fontSize = 24
        self.objLabel.position = CGPoint(x: size.width/2, y: size.height/7 + 4)
        
        self.addChild(self.objLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
