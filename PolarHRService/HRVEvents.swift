//
//  HRVEvents.swift
//  HRVCore
//
//  Created by Katrin Hansel on 21/12/2015.
//  Copyright © 2015 Katrin Hansel. All rights reserved.
//

import Foundation

/**
 *  Interface for handling HR events
 */
public protocol PolarEventHandler{
    
    /**
     Handle a new HR Event with the data
     
     - parameter event: event data
     */
    func handlePolarEvent(event : PolarEventData)
    
}

/**
 *  HR Event Data containing new hr data and timestamp
 */
public struct PolarEventData{
    /// Type of event
    public var type : PolarEventType
    /// new hr or rr value
    public var newValue : Int16?
    /// Timestamp of new data
    public var timestamp : NSDate
    
    /**
     Create new event data
     
     - parameter type:      hr or rr data
     - parameter newValue:  the changed hr or rr value
     - parameter timestamp: timestamp of data (default is current type)
     
     - returns: new data object
     */
    public init(type: PolarEventType, newValue: Int16?, timestamp : NSDate = NSDate()){
        self.type = type
        self.newValue = newValue
        self.timestamp = timestamp
    }
}

/**
 HR Event Types
 
 - hrChanged: heart rate data available
 - rrChanged: rr data available
 */
public enum PolarEventType{
    case hrChanged
    case rrChanged
}