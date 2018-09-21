//
//  Processor.swift
//  Heart rate demo
//
//  Created by Pirush Prechathavanich on 9/19/18.
//  Copyright © 2018 nimbl3. All rights reserved.
//

import UIKit

final class Processor {
    
    private let algorithm = HeartRateKitAlgorithm()
    
    func addInput(_ value: Float) {
        algorithm.newFrameDetected(withValue: CGFloat(value))
        
        guard algorithm.shouldShowLatestResult else { return }
        print(algorithm.bpmLatestResult)
    }
    
}
