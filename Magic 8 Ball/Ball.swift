//
//  Ball.swift
//  Magic 8 Ball
//
//  Created by Ian on 3/26/23.
//

import Foundation
import SceneKit
import UIKit
import SwiftUI

struct Ball: UIViewRepresentable {
  let scene: SCNScene

  func makeUIView(context: Context) -> SCNView {
    let sceneView = SCNView(frame: .zero)
    sceneView.scene = scene
    sceneView.allowsCameraControl = true
    sceneView.autoenablesDefaultLighting = true
    sceneView.backgroundColor = UIColor.black
    let ball = sceneView.scene?.rootNode.childNode(withName: "ball", recursively: true)
    ball?.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 3)))
    return sceneView
  }

  func updateUIView(_ uiView: SCNView, context: Context) {}
}

