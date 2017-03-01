//
//  HRVHelpers.swift
//  MSbandEvaluation
//
//  Created by Katrin Hansel on 02/06/2016.
//  Copyright © 2016 Katrin Hansel. All rights reserved.
//

import Foundation


class HRVHelper {
    
    /**
     Calculate Root Mean Square Successive Difference of RR intervals
     
     - parameter rrs: RR intervals
     
     - returns: the RMSSD
     */
    static func calculateRMSSD(_ rrs: [Double]) -> Double {
        var d = 0.0
        
        let count = rrs.count
        // sum of squared successive differences
        for i in 0 ... count - 1  {
            let interval0 = rrs[i]
            let interval1 = rrs[i + 1]
            let diff = interval1 - interval0
            d += (diff * diff)
        }
        // the root of the sum
        return sqrt(d / Double(count - 1))
    }
    
    /**
     Calculate average of RR intervals
     
     - parameter rrs: RR intervals
     
     - returns: average of rr intervals
     */
    static func calculateAVNN(_ rrs: [Double]) -> Double {
        var sum = 0.0
        for rr in rrs {
            sum += rr
        }
        
        let count = rrs.count
        return sum / Double(count);
    }
    
    /**
     Calculate standard deviation of averages
     
     - parameter intervals: rr intervalls
     
     - returns: Standard deviation of averages
     */
    static func calculateSDANN(_ rrs: [Double]) -> Double {
        let average = calculateAVNN(rrs)
        var d = 0.0
        
        for rr in rrs {
            let v = rr - average
            d += (v * v)
        }
        
        let count = rrs.count
        return sqrt(d / Double(count))
    }
    

    /**
     Calculates the Percentage of differences between RR over x ms
     
     - parameter rrs:         rr intervals
     - parameter thresholdMs: threshold in milliseconds (default 50)
     
     - returns: Percentage of differences between RR over x ms
     */
    static func calcPNNx(_ rrs: [Double], thresholdMs : Double = 50) -> Double {
        var overX: Int = 0
        
        let count = rrs.count
        for i in 0 ... count - 1 {
            let interval0 = rrs[i]
            let interval1 = rrs[i + 1]
            let diff = abs(interval1 - interval0)
            
            if diff > thresholdMs {
                overX += 1
            }
        }
        
        return Double(overX) / Double(count) * 100.0
    }
    
}
