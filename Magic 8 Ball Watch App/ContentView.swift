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

struct ContentView: View {
  let answers = ["It is certain", "It is decidedly so", "Without a doubt", "Yes definitely", "You may rely on it", "As I see it, yes", "Most likely", "Outlook good", "Yes", "Signs point to yes", "Reply hazy, try again", "Ask again later", "Better not tell you now", "Cannot predict now", "Concentrate and ask again", "Don't count on it", "Outlook not so good", "My sources say no", "Very doubtful", "My reply is no"]

  @State private var selectedAnswer = " "
  @State private var isShowingAnswer = false
  @State private var hideAnswerTimer: Timer?

  let motionManager = CMMotionManager()
  let motionQueue = OperationQueue()

  var body: some View {
    VStack {
      Image("8ball")
        .resizable()
        .scaledToFit()
      Text(selectedAnswer)
        .opacity(isShowingAnswer ? 1.0 : 0.0)
    }
    .onTapGesture {
      if isShowingAnswer {
        hideAnswerTimer?.invalidate()
        withAnimation {
          isShowingAnswer = false
        }
      } else {
        showRandomMessage()
      }
    }
    .padding()
    .onAppear {
      willActivate()
    }
    .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationDidBecomeActiveNotification)) { _ in
      // Enable motion detection
      motionManager.startAccelerometerUpdates(to: motionQueue) { data, _ in
        guard let data = data else { return }
        let magnitude = sqrt(pow(data.acceleration.x, 2) + pow(data.acceleration.y, 2) + pow(data.acceleration.z, 2))
        selectedAnswer = "\(magnitude)"
//        if magnitude > 2.0 {
//          showRandomMessage()
//        }
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationWillResignActiveNotification)) { _ in
      // Disable motion detection
      motionManager.stopAccelerometerUpdates()
    }
  }

  func willActivate() {
    do {
      try audioSession.setCategory(AVAudioSession.Category.playback,
                                   mode: .default,
                                   policy: .default,
                                   options: [])
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

  func showRandomMessage() {
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
