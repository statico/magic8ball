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
  @State private var selectedAnswer = " "
  @State private var isShowingAnswer = false
  @State private var hideAnswerTimer: Timer?
  @State private var isShaking = true

  let motionManager = CMMotionManager()
  let motionQueue = OperationQueue()

  var body: some View {
    ZStack {
      Image("8ball")
        .resizable()
        .scaledToFit()
        .scaledToFill()
        .rotationEffect(
          isShaking
            ? Angle.degrees(Double.random(in: -10...10))
            : Angle.degrees(0)
        )
        .offset(
          x: isShaking ? CGFloat.random(in: -20...20) : 0,
          y: isShaking ? CGFloat.random(in: -20...20) : 0
        )
      VStack {
        Spacer()
        Text(selectedAnswer)
          .opacity(isShowingAnswer ? 1.0 : 0.0)
      }
    }
    .onTapGesture {
      withAnimation(.interpolatingSpring(mass: 2, stiffness: 200, damping: 5, initialVelocity: 0)) {
        show()
      }

      // Revert back to 8-ball image after 3 seconds
      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
        withAnimation(.interpolatingSpring(mass: 2, stiffness: 200, damping: 5, initialVelocity: 0)) {
          isShowingAnswer = false
        }
      }

      if isShowingAnswer {
        hideAnswerTimer?.invalidate()
        withAnimation {
          isShowingAnswer = false
        }
      } else {
        show()
      }
    }
    .padding()
    .onAppear {
      initAudio()
      withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
        isShaking = true
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationDidBecomeActiveNotification)) { _ in
      motionManager.startAccelerometerUpdates(to: motionQueue) { data, _ in
        guard let data = data else { return }
        let magnitude = sqrt(pow(data.acceleration.x, 2) + pow(data.acceleration.y, 2) + pow(data.acceleration.z, 2))
        if magnitude > 2.0 {
          show()
        }
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationWillResignActiveNotification)) { _ in
      // Disable motion detection
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

  func show() {
    // Display the message
    let randomIndex = Int(arc4random_uniform(UInt32(answers.count)))
    selectedAnswer = answers[randomIndex]
    withAnimation {
      isShowingAnswer = true
    }

    // Play the sound
    audioSession.activate(options: []) { success, error in
      guard error == nil else {
        print("Error: \(error!.localizedDescription)")
        return
      }
      if success {
        audioPlayer.play()
      }
    }

    // Revert back to 8-ball image after 3 seconds
    hideAnswerTimer?.invalidate()
    hideAnswerTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
      withAnimation {
        isShowingAnswer = false
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
