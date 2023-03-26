//
//  Ball.swift
//  Magic 8 Ball
//
//  Created by Ian on 3/26/23.
//

import Foundation
import SceneKit
import SwiftUI
import UIKit

struct Ball: UIViewRepresentable {
  let scene: SCNScene
  private var ballNode: SCNNode?
  
  func makeUIView(context: Context) -> SCNView {
    print("ball makeUIView")
    let sceneView = SCNView(frame: .zero)
    sceneView.scene = scene
    sceneView.allowsCameraControl = true
    sceneView.autoenablesDefaultLighting = true
    sceneView.backgroundColor = UIColor.black
    
//    ballNode = sceneView.scene?.rootNode.childNode(withName: "abstract_ball", recursively: true)
    ballNode = sceneView.scene?.rootNode.childNodes[0]
    ballNode?.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 3)))
    if ballNode == nil {
      print("error: ballNode not found")
    }
    
    return sceneView
  }
  
  func updateUIView(_ uiView: SCNView, context: Context) {}
  
  func spinBall() {
    print("spinBall")
    guard let ballNode = ballNode else { return }
    print("ballNode OK")
    
    // Get a random direction and apply a random spin
    let direction = SCNVector3(x: Float.random(in: -1...1), y: Float.random(in: -1...1), z: Float.random(in: -1...1))
    let spin = SCNAction.repeatForever(SCNAction.rotateBy(x: CGFloat.random(in: -1...1), y: CGFloat.random(in: -1...1), z: CGFloat.random(in: -1...1), duration: 0.5))
    
    // Apply a force to the ball node to move it in the random direction
    ballNode.physicsBody?.applyForce(direction, asImpulse: true)
    
    // Run the spin action for a short duration, then ease back to the original rotation
    ballNode.runAction(spin, forKey: "spin")
    ballNode.runAction(SCNAction.sequence([
      SCNAction.wait(duration: 0.5),
      SCNAction.run { node in
        node.removeAction(forKey: "spin")
        node.runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 1.0))
      }
    ]))
  }
}
