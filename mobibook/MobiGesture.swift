//
//  MobiGesture.swift
//  mobibook
//
//  Created by ABHISHEK SINGH on 07/05/20.
//  Copyright © 2020 Abhishek Singh. All rights reserved.
//

import UIKit
import PDFKit

class DrawingGestureRecognizer: UIGestureRecognizer {
   var drawingDelegate: DrawingGestureRecognizerDelegate?
    var toggleDraw: Bool = false
    
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event!)
    
    if toggleDraw == false{
        state = .failed
        return
    }
    
    if let touch = touches.first,touch.type == .direct,let numberOfTouches = event?.allTouches?.count,
    numberOfTouches == 1 {
      state = .began
      let location = touch.location(in: self.view)
      drawingDelegate?.gestureRecognizerBegan(location)
    } else {
      state = .failed
    }
    //print("touches - \(numberOfTouches)")
  }
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    state = .changed
    guard let location = touches.first?.location(in: self.view) else { return }
    drawingDelegate?.gestureRecognizerMoved(location)
  }
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    guard let location = touches.first?.location(in: self.view) else  {
      state = .ended
      return
    }
    drawingDelegate?.gestureRecognizerEnded(location)
    state = .ended
  }
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
    state = .failed
  }
}

protocol DrawingGestureRecognizerDelegate: class {
    func gestureRecognizerBegan(_ location: CGPoint)
    func gestureRecognizerMoved(_ location: CGPoint)
    func gestureRecognizerEnded(_ location: CGPoint)
}


