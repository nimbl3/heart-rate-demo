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

// swiftlint:disable force_unwrapping force_try

final class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let statusLabel = UILabel()
    private let sessionButton = UIButton(type: .system)
    
    private let session = AVCaptureSession()
    
    private let captureDevice: AVCaptureDevice
    private let captureInput: AVCaptureDeviceInput
    private let captureOutput = AVCaptureVideoDataOutput()
    
    init() {
        captureDevice = .default(for: .video)!
        captureInput = try! AVCaptureDeviceInput(device: captureDevice)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupSession()
    }
    
    // MARK: - private setup
    
    private func setupView() {
        view.addSubview(statusLabel)
        statusLabel.numberOfLines = 10
        statusLabel.textAlignment = .center
        statusLabel.textColor = .blueHorizon
        statusLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().offset(-32.0)
        }
        
        view.addSubview(sessionButton)
        sessionButton.backgroundColor = .royalBlue
        sessionButton.setTitle("start", for: .normal)
        sessionButton.setTitleColor(.white, for: .normal)
        sessionButton.snp.makeConstraints {
            $0.top.equalTo(statusLabel.snp.bottom).offset(40.0)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(160.0)
            $0.height.equalTo(80.0)
        }
    }

    private func setupSession() {
        session.sessionPreset = .cif352x288
        
        // todo: - setup frame rate
        
        session.addInput(captureInput)
        
        captureOutput.alwaysDiscardsLateVideoFrames = true
        captureOutput.videoSettings = [
            String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA
        ]
        
        let queue = DispatchQueue(label: "frame output")
        captureOutput.setSampleBufferDelegate(self, queue: queue)
        
        session.addOutput(captureOutput)
    }
    
    // MARK: - action
    
    @objc private func start() {
        do {
            try captureDevice.lockForConfiguration()
            try captureDevice.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            
            // todo: - flash?
            captureDevice.unlockForConfiguration()
            
            session.startRunning()
        } catch { print("### error", error) }
    }
    
    // MARK: - sample buffer delegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let image = image(from: sampleBuffer)?.cgImage else { return }
        let color = averageColor(of: image)
    }
    
    // MARK: - private helper
    
    private func image(from buffer: CMSampleBuffer) -> UIImage? {
        guard
            let data = AVCapturePhotoOutput
                .jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil)
        else { return nil }
        return UIImage(data: data)
    }
    
    private func averageColor(of image: CGImage) -> UIColor {
        let bytesPerRow = image.bytesPerRow
        let totalBytes = image.height * bytesPerRow
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        var intensities = [UInt8](repeating: 0, count: totalBytes)
        
        _ = CGContext(
            data: &intensities,
            width: image.width,
            height: image.height,
            bitsPerComponent: image.bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: 0
        )
        
        let sumOfIntensities = intensities.reduce(0, +)
        let averageIntensity = sumOfIntensities / UInt8(intensities.count)
        print("> average: \(averageIntensity)")
        return UIColor(white: CGFloat(averageIntensity), alpha: 1.0)
    }

}
