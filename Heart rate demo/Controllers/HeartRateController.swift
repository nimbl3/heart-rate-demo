//
//  HeartRateController.swift
//  Heart rate demo
//
//  Created by Pirush Prechathavanich on 9/21/18.
//  Copyright © 2018 nimbl3. All rights reserved.
//

import UIKit
import AVFoundation

final class HeartRateController: HeartRateCaptureSessionDelegate {
    
    private let processor = Processor()
    private let session = HeartRateCaptureSession()
    
    init() {
        session.delegate = self
    }
    
    func start() {
        try? session.startCapturing()
    }
    
    func stop() {
        session.stopCapturing()
    }
    
    // MARK: - heart rate capture session delegate
    
    func heartRateCaptureSession(_ session: HeartRateCaptureSession, didOutput value: Float) {
        processor.addInput(value)
    }
}
