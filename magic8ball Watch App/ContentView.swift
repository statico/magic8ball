//
//  ContentView.swift
//  magic8ball Watch App
//
//  Created by Ian on 3/24/23.
//

import AVFoundation
import SwiftUI

var player = AVAudioPlayer()
let audioSession = AVAudioSession.sharedInstance()

struct ContentView: View {
  let answers = ["It is certain", "It is decidedly so", "Without a doubt", "Yes definitely", "You may rely on it", "As I see it, yes", "Most likely", "Outlook good", "Yes", "Signs point to yes", "Reply hazy, try again", "Ask again later", "Better not tell you now", "Cannot predict now", "Concentrate and ask again", "Don't count on it", "Outlook not so good", "My sources say no", "Very doubtful", "My reply is no"]

  @State private var selectedAnswer = " "
  @State private var isShowingAnswer = false
  @State private var hideAnswerTimer: Timer?

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

    print("here")
    if let soundPath = Bundle.main.path(forResource: "shake", ofType: "wav") {
      let soundURL = URL(fileURLWithPath: soundPath)
      print("soundURL = \(soundURL)")
      do {
        player = try AVAudioPlayer(contentsOf: soundURL)
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
        player.play()
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
