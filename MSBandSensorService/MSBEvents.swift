//
//  MSBEvents.swift
//  MSbandEvaluation
//
//  Created by Katrin Hansel on 07/04/2016.
//  Copyright © 2016 Katrin Hansel. All rights reserved.
//

import Foundation

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
public protocol MSBEventHandler{
    
    /**
     Handle a new MSB Event with the data
     
     - parameter event: event data
     */
    func handleMSBEvent(event : MSBEventData)
    
}

/**
 *  HR Event Data containing new hr data and timestamp
 */
public struct MSBEventData{
    /// Type of event
    public var type : MSBEventType
    /// new hr or rr value
    public var newValue : Double?
    /// Timestamp of new data
    public var timestamp : NSDate
    
    /**
     Create new event data
     
     - parameter type:      hr or rr data
     - parameter newValue:  the changed hr or rr value
     - parameter timestamp: timestamp of data (default is current type)
     
     - returns: new data object
     */
    public init(type: MSBEventType, newValue: Double?, timestamp : NSDate = NSDate()){
        self.type = type
        self.newValue = newValue
        self.timestamp = timestamp
    }
}

/**
 MSB Event Types
 
 - hrChanged: heart rate data available
 - rrChanged: rr data available
 - gsrChanged: GSR data available
 */
public enum MSBEventType{
    case hrChanged
    case rrChanged
    case gsrChanged
}