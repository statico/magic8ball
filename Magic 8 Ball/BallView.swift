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
    let rotation = SCNAction.rotateBy(x: CGFloat.random(in: -1...1), y: CGFloat.random(in: -1...1), z: CGFloat.random(in: -1...1), duration: 1.0)
    let translation = SCNAction.move(by: direction, duration: 1.0)
    let scale = SCNAction.scale(by: 1.5, duration: 0.5)
    let bounceScale = SCNAction.customAction(duration: 0.5) { node, elapsed in
      let progress = elapsed / CGFloat(0.5)
      let scale = SCNMatrix4Lerp(from: SCNMatrix4Identity, to: SCNMatrix4MakeScale(1.0, 1.0, 1.0), t: Float(progress))
      node.transform = scale
    }
    let bounceTranslation = SCNAction.customAction(duration: 0.5) { node, elapsed in
      let progress = elapsed / CGFloat(0.5)
      let position = SCNVector3Lerp(node.presentation.position, SCNVector3Zero, Float(progress))
      node.position = position
    }
    let bounceRotation = SCNAction.customAction(duration: 0.5) { node, elapsed in
      let progress = elapsed / CGFloat(0.5)
      let rotation = SCNVector4Lerp(SCNVector4(x: 0, y: 0, z: 0, w: 1), SCNVector4Zero, Float(progress))
      node.rotation = rotation
    }

    // Run the spin action for a short duration, then ease back to the original rotation
    ballNode?.runAction(SCNAction.sequence([
      SCNAction.group([rotation, translation, scale]),
      SCNAction.group([bounceScale, bounceTranslation, bounceRotation])
    ]))
  }

  func SCNMatrix4Lerp(from: SCNMatrix4, to: SCNMatrix4, t: Float) -> SCNMatrix4 {
    return SCNMatrix4(
      m11: from.m11 + (to.m11 - from.m11) * t,
      m12: from.m12 + (to.m12 - from.m12) * t,
      m13: from.m13 + (to.m13 - from.m13) * t,
      m14: from.m14 + (to.m14 - from.m14) * t,
      m21: from.m21 + (to.m21 - from.m21) * t,
      m22: from.m22 + (to.m22 - from.m22) * t,
      m23: from.m23 + (to.m23 - from.m23) * t,
      m24: from.m24 + (to.m24 - from.m24) * t,
      m31: from.m31 + (to.m31 - from.m31) * t,
      m32: from.m32 + (to.m32 - from.m32) * t,
      m33: from.m33 + (to.m33 - from.m33) * t,
      m34: from.m34 + (to.m34 - from.m34) * t,
      m41: from.m41 + (to.m41 - from.m41) * t,
      m42: from.m42 + (to.m42 - from.m42) * t,
      m43: from.m43 + (to.m43 - from.m43) * t,
      m44: from.m44 + (to.m44 - from.m44) * t
    )
  }

  func SCNVector3Lerp(_ a: SCNVector3, _ b: SCNVector3, _ t: Float) -> SCNVector3 {
    let x = a.x + (b.x - a.x) * t
    let y = a.y + (b.y - a.y) * t
    let z = a.z + (b.z - a.z) * t
    return SCNVector3(x, y, z)
  }

  func SCNVector4Lerp(_ a: SCNVector4, _ b: SCNVector4, _ t: Float) -> SCNVector4 {
    let x = a.x + (b.x - a.x) * t
    let y = a.y + (b.y - a.y) * t
    let z = a.z + (b.z - a.z) * t
    let w = a.w + (b.w - a.w) * t
    return SCNVector4(x, y, z, w)
  }
}
