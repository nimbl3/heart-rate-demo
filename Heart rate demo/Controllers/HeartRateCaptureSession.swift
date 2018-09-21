//
//  HeartRateCaptureSession.swift
//  Heart rate demo
//
//  Created by Pirush Prechathavanich on 9/21/18.
//  Copyright © 2018 nimbl3. All rights reserved.
//

import UIKit
import AVFoundation

// swiftlint:disable force_try force_unwrapping

protocol HeartRateCaptureSessionDelegate: AnyObject {
    
    func heartRateCaptureSession(_ session: HeartRateCaptureSession, didOutput value: Float)
    
}

final class HeartRateCaptureSession: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let session = AVCaptureSession()
    
    private let captureDevice: AVCaptureDevice
    private let captureInput: AVCaptureDeviceInput
    private let captureOutput = AVCaptureVideoDataOutput()
    
    weak var delegate: HeartRateCaptureSessionDelegate?
    
    override init() {
        captureDevice = .default(for: .video)!
        captureInput = try! AVCaptureDeviceInput(device: captureDevice)
        super.init()
        setupSession()
    }
    
    func startCapturing() throws {
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
    }
    
    func stopCapturing() {
        session.stopRunning()
    }
    
    // MARK: - private setup
    
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
    
    // MARK: - sample buffer delegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let image = image(from: sampleBuffer)?.cgImage else { return }
        delegate?.heartRateCaptureSession(self, didOutput: averageValue(of: image))
    }
    
    // MARK: - private helper
    
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

}
