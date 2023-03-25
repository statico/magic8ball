//
//  ContentView.swift
//  magic8ball Watch App
//
//  Created by Ian on 3/24/23.
//

import SwiftUI

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
      showRandomMessage()

      // Revert back to 8-ball image after 3 seconds
      hideAnswerTimer?.invalidate()
      hideAnswerTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
        withAnimation {
          isShowingAnswer = false
        }
      }
    }
    .padding()
  }

  func showRandomMessage() {
    let randomIndex = Int(arc4random_uniform(UInt32(answers.count)))
    selectedAnswer = answers[randomIndex]
    withAnimation {
      isShowingAnswer = true
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
