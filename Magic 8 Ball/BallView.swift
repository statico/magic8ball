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
    ballNode?.removeAllActions()

    // Get a random direction and apply a random spin
    let direction = SCNVector3(x: Float.random(in: -1...1), y: Float.random(in: -1...1), z: Float.random(in: -1...1))
    let spin = SCNAction.rotate(by: 4.0 * CGFloat.pi, around: direction, duration: 2.0)
    spin.timingMode = .easeOut

    // Apply a force to the ball node to move it in the random direction
    ballNode?.physicsBody?.applyForce(direction, asImpulse: true)

    // Run the spin action for a short duration
    ballNode?.runAction(spin, forKey: "spin")
  }
}
