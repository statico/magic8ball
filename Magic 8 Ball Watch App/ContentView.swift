//
//  ContentView.swift
//  Magic 8 Ball Watch App
//
//  Created by Ian on 3/24/23.
//

import AVFoundation
import CoreMotion
import SwiftUI

var audioPlayer = AVAudioPlayer()
let audioSession = AVAudioSession.sharedInstance()

let answers = ["It is certain", "It is decidedly so", "Without a doubt", "Yes definitely", "You may rely on it", "As I see it, yes", "Most likely", "Outlook good", "Yes", "Signs point to yes", "Reply hazy, try again", "Ask again later", "Better not tell you now", "Cannot predict now", "Concentrate and ask again", "Don't count on it", "Outlook not so good", "My sources say no", "Very doubtful", "My reply is no"]

struct ContentView: View {
  @State private var message = ""
  @State private var isActive = false
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
      Image("8ball")
        .resizable()
        .scaledToFit()
        .scaledToFill()
        .rotationEffect(animationAngle)
        .offset(x: animationXOffset, y: animationYOffset)
        .scaleEffect(animationScale)
        .animation(.interpolatingSpring(mass: 1, stiffness: 200, damping: 5, initialVelocity: 0), value: timer)
      VStack {
        Spacer()
        Text(message)
          .opacity(1.0)
          .animation(.linear(duration: 1.0), value: message)
      }
    }
    .padding()
    .onAppear {
      initAudio()
    }
    .onTapGesture {
      guard isActive else { return }
      shake()
    }
    .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationDidBecomeActiveNotification)) { _ in
      print("did become active")
      isActive = true
      motionManager.startAccelerometerUpdates(to: motionQueue) { data, _ in
        guard isActive else { return }
        guard let data = data else { return }
        let magnitude = sqrt(pow(data.acceleration.x, 2) + pow(data.acceleration.y, 2) + pow(data.acceleration.z, 2))
        if magnitude > 2.0 {
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
    }
    .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationWillResignActiveNotification)) { _ in
      print("will resign")
      isActive = false
      message = ""
      motionManager.stopAccelerometerUpdates()
      timer?.fire()
      timer?.invalidate()
    }
  }

  func initAudio() {
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

    audioSession.activate(options: []) { success, error in
      guard error == nil else {
        print("error: \(error!.localizedDescription)")
        return
      }
      if success {
        audioPlayer.volume = 0.5
        audioPlayer.rate = Float.random(in: 0.8...1.3)
        audioPlayer.play()
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
