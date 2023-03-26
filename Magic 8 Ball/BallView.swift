//
//  BallView.swift
//  Magic 8 Ball
//
//  Created by Ian on 3/26/23.
//

import Foundation
import SceneKit
import SwiftUI
import UIKit

struct BallView: UIViewRepresentable {
  let scene: SCNScene
  let childNodeName: String
  
  func makeUIView(context: Context) -> SCNView {
    print("ball makeUIView")
    let view = SCNView(frame: .zero)
    view.scene = scene
    view.autoenablesDefaultLighting = true
    view.backgroundColor = UIColor.clear
    view.sizeToFit()
    return view
  }
  
  func updateUIView(_ uiView: SCNView, context: Context) {}
  
  func spinBall() {
    print("spinBall")
    let ballNode = scene.rootNode.childNode(withName: childNodeName, recursively: true)
    
    // Get a random direction and apply a random spin
    let direction = SCNVector3(x: Float.random(in: -1...1), y: Float.random(in: -1...1), z: Float.random(in: -1...1))
    let spin = SCNAction.repeatForever(SCNAction.rotateBy(x: CGFloat.random(in: -1...1), y: CGFloat.random(in: -1...1), z: CGFloat.random(in: -1...1), duration: 0.5))
    
    // Apply a force to the ball node to move it in the random direction
    ballNode?.physicsBody?.applyForce(direction, asImpulse: true)
    
    // Run the spin action for a short duration, then ease back to the original rotation
    ballNode?.runAction(spin, forKey: "spin")
    ballNode?.runAction(SCNAction.sequence([
      SCNAction.wait(duration: 0.5),
      SCNAction.run { node in
        node.removeAction(forKey: "spin")
        node.runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 1.0))
      }
    ]))
  }
}
