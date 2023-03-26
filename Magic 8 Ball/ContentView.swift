//
//  ContentView.swift
//  Magic 8 Ball Watch App
//
//  Created by Ian on 3/24/23.
//

import AVFoundation
import CoreMotion
import SceneKit
import SwiftUI
import UIKit

var audioPlayer = AVAudioPlayer()
let audioSession = AVAudioSession.sharedInstance()

let answers = ["It is certain", "It is decidedly so", "Without a doubt", "Yes definitely", "You may rely on it", "As I see it, yes", "Most likely", "Outlook good", "Yes", "Signs point to yes", "Reply hazy, try again", "Ask again later", "Better not tell you now", "Cannot predict now", "Concentrate and ask again", "Don't count on it", "Outlook not so good", "My sources say no", "Very doubtful", "My reply is no"]

struct ContentView: View {
  @State private var message = ""
  @State private var hasShaken = false
  @State private var timer: Timer?
  @State private var animationAngle = Angle.degrees(0.0)
  @State private var animationXOffset = 0.0
  @State private var animationYOffset = 0.0
  @State private var animationScale = 1.0
  @State private var lastShakeTime = Date.distantPast

  let motionManager = CMMotionManager()
  let motionQueue = OperationQueue()

  var body: some View {
    ZStack {
      ShakeViewRepresentable().allowsHitTesting(false)
      SceneKitView(scene: SCNScene(named: "abstract_ball.dae")!)
      VStack {
        Spacer()
        Text(message)
          .opacity(1.0)
          .animation(.linear(duration: 1.0), value: message)
          .foregroundColor(Color.white)
      }
    }
    .background(Color.black)
    .onAppear {
      print("onAppear")
      initAudio()
    }
    .gesture(TapGesture().onEnded {
      print("got tap gesture")
      shake()
    })
    .onReceive(messagePublisher) { _ in
      print("got shake gesture")
      let currentTime = Date()
      let timeSinceLastShake = currentTime.timeIntervalSince(lastShakeTime)
      if timeSinceLastShake >= 1.0 {
        lastShakeTime = currentTime
        DispatchQueue.main.async {
          shake()
        }
      }
    }
  }

  func initAudio() {
    print("init audio")
    do {
      try audioSession.setCategory(AVAudioSession.Category.playback, mode: .default, policy: .default, options: [])
    } catch {
      print("Unable to set up the audio session: \(error.localizedDescription)")
    }

    if let soundPath = Bundle.main.path(forResource: "shake", ofType: "wav") {
      let soundURL = URL(fileURLWithPath: soundPath)
      do {
        audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        audioPlayer.enableRate = true
      } catch {
        print("error playing sound: \(error.localizedDescription)")
      }
    } else {
      print("error: sound file not found")
    }
  }

  func shake() {
    print("shake()")
    hasShaken = true
    message = ""
    animationAngle = Angle.degrees(hasShaken ? Double.random(in: -20...20) : 0)
    animationXOffset = hasShaken ? CGFloat.random(in: -20...20) : 0
    animationYOffset = hasShaken ? CGFloat.random(in: -20...20) : 0
    animationScale = 1.0 + (hasShaken ? CGFloat.random(in: -0.1...0.1) : 0)

    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
      let index = Int(arc4random_uniform(UInt32(answers.count)))
      message = answers[index]
      print("timer message=\(message)")
    }

    do {
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("Error activating audio session: \(error.localizedDescription)")
    }
    if audioPlayer.isPlaying {
      audioPlayer.stop()
    }
    audioPlayer.currentTime = 0
    audioPlayer.volume = 0.5
    audioPlayer.rate = Float.random(in: 0.8...1.3)
    audioPlayer.play()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

struct SceneKitView: UIViewRepresentable {
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

