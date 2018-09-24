//
//  ViewController.swift
//  Heart rate demo
//
//  Created by Pirush Prechathavanich on 3/19/18.
//  Copyright © 2018 nimbl3. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

final class ViewController: UIViewController, HeartRateControllerDelegate {
    
    private let bpmLabel = UILabel()
    private let statusLabel = UILabel()
    private let sessionButton = UIButton(type: .system)
    
    private let heartRateController = HeartRateController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        heartRateController.delegate = self
    }
    
    // MARK: - heart rate controller
    
    func heartRateController(_ controller: HeartRateController, didFinishWithResult bpm: Float) {
        statusLabel.text = "FINAL RESULT: \(bpm)"
        heartRateController.stop()
    }
    
    func heartRateController(_ controller: HeartRateController, didAbortWithError error: Error) {
        statusLabel.text = error.localizedDescription
    }
    
    func heartRateController(_ controller: HeartRateController, didMeasureBPM bpm: Float) {
        bpmLabel.text = "LATEST BPM: \(bpm)"
    }
    
    func heartRateControllerDidFinishCalibration(_ controller: HeartRateController) {
        statusLabel.text = "Calibration done!"
    }
    
    // MARK: - private setup
    
    private func setupView() {
        view.addSubview(bpmLabel)
        bpmLabel.textAlignment = .center
        bpmLabel.textColor = .blueGrey
        bpmLabel.snp.makeConstraints { $0.centerX.equalToSuperview() }
        
        view.addSubview(statusLabel)
        statusLabel.numberOfLines = 10
        statusLabel.textAlignment = .center
        statusLabel.textColor = .blueHorizon
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(bpmLabel.snp.bottom).offset(40.0)
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().offset(-32.0)
        }
        
        view.addSubview(sessionButton)
        sessionButton.addTarget(self, action: #selector(start), for: .touchUpInside)
        sessionButton.layer.cornerRadius = 8.0
        sessionButton.backgroundColor = .blueGrey
        sessionButton.setTitle("Start", for: .normal)
        sessionButton.setTitleColor(.white, for: .normal)
        sessionButton.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(80.0)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(140.0)
            $0.height.equalTo(60.0)
        }
    }
    
    // MARK: - action
    
    private var isStarted = false {
        didSet { sessionButton.setTitle(isStarted ? "Stop" : "Start", for: .normal) }
    }
    
    @objc private func start() {
        isStarted ? heartRateController.stop() : heartRateController.start()
        isStarted = !isStarted
        statusLabel.text = "Calibrating..."
    }
    
    // MARK: - private helper
    
    private func image2(from buffer: CMSampleBuffer) -> CIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(buffer) else { return nil }
        let cameraImage = CIImage(cvPixelBuffer: imageBuffer)
        let extent = cameraImage.extent
        let inputExtent = CIVector(x: extent.origin.x,
                                   y: extent.origin.y,
                                   z: extent.size.width,
                                   w: extent.size.height)
        
        return cameraImage.applyingFilter("CIAreaAverage", parameters: [
            kCIInputExtentKey: inputExtent,
            kCIInputImageKey: cameraImage
        ])
    }

}

extension Array {
    
    static func += (elements: inout [Element], element: Element) {
        elements.append(element)
    }
    
}
