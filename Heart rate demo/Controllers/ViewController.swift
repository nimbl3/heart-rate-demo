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
        sessionButton.addTarget(self, action: #selector(start), for: .touchUpInside)
        sessionButton.layer.cornerRadius = 8.0
        sessionButton.backgroundColor = .blueGrey
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
        
        captureOutput.alwaysDiscardsLateVideoFrames = false
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
            
            captureDevice.exposureMode = .locked
            
            //todo: - frame rate?
            
//            var frameRate: AVFrameRateRange!
//            if let format = captureDevice.formats.first(where: {
//                $0.videoSupportedFrameRateRanges.contains {
//                    frameRate = $0
//                    return $0.maxFrameRate == 240.0
//                }
//            }) {
//                captureDevice.activeFormat = format
//                captureDevice.activeVideoMinFrameDuration = frameRate.minFrameDuration
//                captureDevice.activeVideoMaxFrameDuration = frameRate.maxFrameDuration
//            }
            
            captureDevice.unlockForConfiguration()
            
            session.startRunning()
        } catch { print("### error", error) }
    }
    
    // MARK: - sample buffer delegate
    
    private let context = CIContext()
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard
            let image = image(from: sampleBuffer)?.cgImage
        else { return }
        
        let value = averageValue(of: image)
        print("> value:", value)
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
    
    private func image(from buffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(buffer) else { return nil }
        
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        let context = CGContext(
            data: baseAddress,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        )
        let quartzImage = context?.makeImage()
        CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
        
        return UIImage(cgImage: quartzImage!)
    }
    
    private func averageValue(of image: CGImage) -> Float {
        guard
            let data = image.dataProvider?.data,
            let pixelData = CFDataGetBytePtr(data)
        else { print("🤬"); return 0 }
        
        let height = image.height
        let width = image.width
        let bytesPerRow = UInt(image.bytesPerRow)
        let stride = image.bitsPerPixel / 8
        
        var red: UInt = 0
        var green: UInt = 0
        var blue: UInt = 0
        
        // todo: - for-in loop is required as using forEach will cause a performance
        //         tradeoff for debug mode even though it results the same with release
        //         configuration.
        
        for row in 0...height {
            var rowPointer = pixelData.advanced(by: Int(bytesPerRow) * row)
            
            for _ in 0...width {
                let buffer = UnsafeBufferPointer(start: rowPointer, count: 3)
                
                red += UInt(buffer[2])
                green += UInt(buffer[1])
                blue += UInt(buffer[0])
                
                rowPointer = rowPointer.advanced(by: stride)
            }
        }
        
        let averageSum = Float(red + green + blue) / 3.0
        return averageSum / Float(width) / Float(height)
    }
    
    private func averageValue(of pixelBuffer: CVPixelBuffer) -> Float {
        
        return 0.0
    }

}

extension Array {
    
    static func += (elements: inout [Element], element: Element) {
        elements.append(element)
    }
    
}
