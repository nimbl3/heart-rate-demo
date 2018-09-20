//
//  Processor.swift
//  Heart rate demo
//
//  Created by Pirush Prechathavanich on 9/19/18.
//  Copyright © 2018 nimbl3. All rights reserved.
//

import UIKit

final class Processor {
    
    private let windowSize = 9
    private let defaultBPM: UInt8 = 72 // todo: - ?
    private let calibrateDuration = 90
    
    private let filterOrder = 5
    private let filterLowerBand = 0.04 // 36
    private let filterUpperBand = 0.2 // 180
    
    private var currentCount = 0
    
    private var values: [Float] = []
    private var peaks: [Bool] = []
    
    private var bpmValues: [UInt8] = []
    private var bpmAverageValues: [UInt8] = []
    
    func addInput(_ value: Float) {
        currentCount += 1
        
        values += value
        peaks += false
        
        bpmValues += defaultBPM
        bpmAverageValues += defaultBPM
        
        guard currentCount == windowSize else { return }
        
        let size = windowSize + 1
        let x = values.suffix(size)
        let mean = x.reduce(0, +) / Float(size)
        
        let newX = x.map { $0 - mean }
        
        
    }
    
    // MARK: - private helper
    
}
