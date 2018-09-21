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

final class ViewController: UIViewController {
    
    private let statusLabel = UILabel()
    private let sessionButton = UIButton(type: .system)
    
    private let heartRateController = HeartRateController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
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
    
    // MARK: - action
    
    private var isStarted = false
    
    @objc private func start() {
        isStarted ? heartRateController.stop() : heartRateController.start()
        isStarted = !isStarted
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
