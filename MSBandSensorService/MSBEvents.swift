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

public protocol MSBEventData{
    /// Type of event
    var type : MSBEventType{
        get
        set
    }
    /// Timestamp of new data
    var timestamp : NSDate{
        get
        set
    }
    
    func printData() -> String
}

/**
 *  HR Event Data containing new hr data and timestamp
 */
public struct MSBEventData1D : MSBEventData{
    /// Type of event
    public var type : MSBEventType
    /// Timestamp of new data
    public var timestamp : NSDate
    /// new hr or rr value
    public var newValue : Double?
    
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
    
    public func printData() -> String{
        if(newValue != nil){
            return "\(newValue!.description)"
        }else{
            return " "
        }
    }
}

/**
 *  HR Event Data containing new hr data and timestamp
 */
public struct MSBEventDataMD : MSBEventData{
    /// Type of event
    public var type : MSBEventType
    /// new hr or rr value
    public var newValue : [Double]?
    /// Timestamp of new data
    public var timestamp : NSDate
    
    /**
     Create new event data
     
     - parameter type:      hr or rr data
     - parameter newValue:  the changed hr or rr value
     - parameter timestamp: timestamp of data (default is current type)
     
     - returns: new data object
     */
    public init(type: MSBEventType, newValue: [Double]?, timestamp : NSDate = NSDate()){
        self.type = type
        self.newValue = newValue
        self.timestamp = timestamp
    }
    
    public func printData() -> String{
        var retVal = " "
        
        if(newValue == nil){
            return retVal
        }
        
        var first = true
        for v in newValue! {
            if(!first){
                retVal = "\(retVal),\(v.description)"
            }else{
                first = false
                retVal = "\(v.description)"
            }
        }
        
        return retVal
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
    case accelerometerChanged
    case skinTemperatureChanged
    case gyroscopeChanged
    case ambientTemperatureChanged
    case ambientPressureChanged
    case ambientLightChanged
    case altimeterChanged
}