//
//  AnnotationStack.swift
//  mobibook
//
//  Created by ABHISHEK SINGH on 19/05/20.
//  Copyright © 2020 Abhishek Singh. All rights reserved.
//

import Foundation
import PDFKit


struct InkPair {
    var ink : Ink?
    var path : UIBezierPath?
}

struct AnnotationStack {
    
    private var inkPair: [InkPair] = []
    
    init(pair: InkPair) {
        self.inkPair = [pair]
    }
    
    mutating func push(pair : InkPair){
        inkPair.append(pair)
    }
    
    mutating func pop() -> InkPair? {
        let pair = inkPair.popLast()
        print("popped: \(inkPair.count)")
        return pair
    }
    
    func peek()  -> InkPair? {
        guard let top = inkPair.last else{ return nil}
        return top
    }
    
    func totalElements() -> Int {
        return inkPair.count
    }
}
