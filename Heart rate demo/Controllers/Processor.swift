//
//  HeartRateProcessor.swift
//  Heart rate demo
//
//  Created by Pirush Prechathavanich on 9/19/18.
//  Copyright © 2018 nimbl3. All rights reserved.
//

import UIKit

final class HeartRateProcessor {
    
    private var algorithm = HeartRateKitAlgorithm()
    
    // MARK: - getter
    
    var isDetermined: Bool {
        return algorithm.isFinalResultDetermined
    }
    
    var isCalibrated: Bool {
        return algorithm.shouldShowLatestResult
    }
    
    var latestBPM: Float {
        return Float(algorithm.bpmLatestResult)
    }
    
    // MARK: - helper
    
    func addInput(_ value: Float) {
        algorithm.newFrameDetected(withValue: CGFloat(value))
        
        guard algorithm.shouldShowLatestResult else { return }
        print(algorithm.bpmLatestResult)
    }
    
    func reset() {
        algorithm = HeartRateKitAlgorithm()
    }
}
