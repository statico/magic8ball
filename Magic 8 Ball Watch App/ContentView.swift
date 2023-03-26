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
  @State private var hasShaken = false

  let motionManager = CMMotionManager()
  let motionQueue = OperationQueue()

  var body: some View {
    ZStack {
      Image("8ball")
        .resizable()
        .scaledToFit()
        .scaledToFill()
        .rotationEffect(Angle.degrees(hasShaken ? Double.random(in: -20...20) : 0))
        .offset(
          x: hasShaken ? CGFloat.random(in: -20...20) : 0,
          y: hasShaken ? CGFloat.random(in: -20...20) : 0
        )
        .scaleEffect(1.0 + (hasShaken ? CGFloat.random(in: -0.1...0.1) : 0))
        .animation(.interpolatingSpring(mass: 1, stiffness: 200, damping: 5, initialVelocity: 0), value: message)
      VStack {
        Spacer()
        Text(message)
          .opacity(1.0)
          .animation(.linear(duration: 1.0), value: message)
      }
    }
    .onAppear {
      initAudio()
    }
    .padding()
    .onTapGesture {
      shake()
    }
    .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationDidBecomeActiveNotification)) { _ in
      motionManager.startAccelerometerUpdates(to: motionQueue) { data, _ in
        guard let data = data else { return }
        let magnitude = sqrt(pow(data.acceleration.x, 2) + pow(data.acceleration.y, 2) + pow(data.acceleration.z, 2))
        if magnitude > 2.0 {
          shake()
        }
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationWillResignActiveNotification)) { _ in
      motionManager.stopAccelerometerUpdates()
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
      } catch {
        print("Error playing sound: \(error.localizedDescription)")
      }
    } else {
      print("Error: sound file not found")
    }
  }

  func shake() {
    hasShaken = true
    
    let index = Int(arc4random_uniform(UInt32(answers.count)))
    message = answers[index]

    audioSession.activate(options: []) { success, error in
      guard error == nil else {
        print("Error: \(error!.localizedDescription)")
        return
      }
      if success {
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
