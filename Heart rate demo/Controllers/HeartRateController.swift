//
//  HeartRateController.swift
//  Heart rate demo
//
//  Created by Pirush Prechathavanich on 9/21/18.
//  Copyright © 2018 nimbl3. All rights reserved.
//

import UIKit
import AVFoundation

extension HeartRateController {
    
    enum State {
        
        case idle
        case calibrating
        case measuring(bpm: Float)
        case finished(bpm: Float)
        case failed(HeartRateError)
        
    }
    
}

enum HeartRateError: LocalizedError {
    
    case unableToDetermine
    case unableToDetectFinger
    
    var errorDescription: String? {
        switch self {
        case .unableToDetermine:        return "Unable to determine"
        case .unableToDetectFinger:     return "Unable to detect finger"
        }
    }
    
}

protocol HeartRateControllerDelegate: AnyObject {
    
    /// Triggered once when measurement is completed with a final result
    func heartRateController(_ controller: HeartRateController, didFinishWithResult bpm: Float)
    
    /// Triggered simutenously after the processor is calibrated
    func heartRateController(_ controller: HeartRateController, didMeasureBPM bpm: Float)
    
    /// Triggered once measurement has been aborted with an error
    func heartRateController(_ controller: HeartRateController, didAbortWithError error: Error)
    
    /// The value is ready to be displayed
    func heartRateControllerDidFinishCalibration(_ controller: HeartRateController)
    
}

final class HeartRateController: HeartRateCaptureSessionDelegate {
    
    private let processor = HeartRateProcessor()
    private let session = HeartRateCaptureSession()
    
    private let track = HeartRateTrack()
    
    private let timeToDetermine: TimeInterval = 20.0
    private let timeBeforeAborting: TimeInterval = 10.0
    
    private(set) var state: State = .idle {
        didSet { handleState(state, previous: oldValue) }
    }
    
    weak var delegate: HeartRateControllerDelegate?
    
    init() {
        session.delegate = self
    }
    
    func start() {
        try? session.startCapturing()
        track.reset()
        state = .idle
    }
    
    func stop() {
        session.stopCapturing()
        state = .idle
    }
    
    // MARK: - heart rate capture session delegate
    
    func heartRateCaptureSession(_ session: HeartRateCaptureSession, didOutput value: Float) {
        processor.addInput(value)
        
        guard processor.isCalibrated else { return }
        
        if processor.isDetermined {
            state = .finished(bpm: value)
        } else {
            state = .measuring(bpm: value)
        }
    }
    
    func heartRateCaptureSession(_ session: HeartRateCaptureSession,
                                 unableToProcess error: HeartRateError) {
        guard abs(track.timeIntervalSinceTrackStarted) > timeBeforeAborting else { return }
        
        state = .failed(error)
    }
    
    // MARK: - private helper
    
    private func handleState(_ currentState: State, previous previousState: State) {
        switch (previousState, currentState) {
        case (.idle, .calibrating):
            break // did start
        case (.calibrating, .measuring(let bpm)):
            delegateOnMainThread {
                $0.heartRateControllerDidFinishCalibration($1)
                $0.heartRateController($1, didMeasureBPM: bpm)
            }
        case (.measuring, .measuring(let bpm)):
            delegateOnMainThread { $0.heartRateController($1, didMeasureBPM: bpm) }
        case (_, .failed(let error)):
            delegateOnMainThread { $0.heartRateController($1, didAbortWithError: error) }
        default:
            break
        }
    }
    
    private func delegateOnMainThread(action: @escaping (HeartRateControllerDelegate, HeartRateController) -> Void) {
        guard let delegate = delegate else { return }
        DispatchQueue.main.async { action(delegate, self) }
    }
    
}

private final class HeartRateTrack {
    
    var startDate: Date
    var bpmValues: [Float] = []
    
    init(startDate: Date = Date()) {
        self.startDate = startDate
    }
    
    func reset() {
        startDate = Date()
        bpmValues = []
    }
    
    var timeIntervalSinceTrackStarted: TimeInterval {
        return startDate.timeIntervalSinceNow
    }
    
}
