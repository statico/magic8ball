//
//  ShakeGestureManager.swift
//  Magic 8 Ball
//
//  Created by Ian on 3/26/23.
//

import Combine
import Foundation
import SwiftUI

let messagePublisher = PassthroughSubject<Void, Never>()

class ShakeViewController: UIViewController {
  override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    print("motion began")
    guard motion == .motionShake else { return }
    messagePublisher.send()
  }
}

struct ShakeViewRepresentable: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> ShakeViewController { ShakeViewController() }
  func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {}
}
