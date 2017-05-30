//
//  MSBEvents.swift
//  MSbandEvaluation
//
//  Created by Katrin Hansel on 07/04/2016.
//  Copyright © 2016 Katrin Hansel. All rights reserved.
//

import Foundation
import SensorEvaluationShared

/**
 *  Interface for handling HR events
 */
public protocol MSBEventHandler{
    
    /**
     Handle a new MSB Event with the data
     
     - parameter event: event data
     */
    func handleEvent(withData data: MSBEventData)
    
}

public protocol MSBEventData : SensorData{
//    /// Type of event
//    var type : MSBEventType{
//        get
//    }
    /// Timestamp of new data
    var timestamp : Date{
        get
    }
    
    func printData() -> String
    
    func getOnePointPrint() -> String
}

/**
 *  HR Event Data containing new hr data and timestamp
 */
public struct MSBEventData1D : MSBEventData{
//    /// Type of event
//    public fileprivate(set) var type : MSBEventType
    
    /// Timestamp of new data
    public fileprivate(set) var timestamp : Date
    /// new hr or rr value
    public fileprivate(set) var newValue : Double?
    
    public var sensorSource : SensorSourceType{
        return SensorSourceType.msb
    }
    
    private var _sensorDataType : SensorDataType
    public var sensorDataType : SensorDataType{
        return _sensorDataType
    }
    
    
    public var csvString : String{
        get{
            return "\(timestamp),\(timestamp.timeIntervalSince1970),\(newValue!)\n"
        }
    }
    
    /**
     Create new event data
     
     - parameter type:      hr or rr data
     - parameter newValue:  the changed hr or rr value
     - parameter timestamp: timestamp of data (default is current type)
     
     - returns: new data object
     */
    public init(type: SensorDataType, newValue: Double?, timestamp : Date = Date()){
        self._sensorDataType = type
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
    
    public func getOnePointPrint() -> String{
        return printData()
    }
}

/**
 *  HR Event Data containing new hr data and timestamp
 */
public struct MSBEventDataMD : MSBEventData{

    /// new hr or rr value
    public fileprivate(set) var newValues : [Double]?
    /// Timestamp of new data
    public fileprivate(set) var timestamp : Date
    
    public var sensorSource : SensorSourceType{
        return SensorSourceType.msb
    }
    
    private var _sensorDataType : SensorDataType
    public var sensorDataType : SensorDataType{
        return _sensorDataType
    }
    
//    public static func csvHeader(forType type : SensorDataType) -> String{
//            switch type {
//            case .accelerometerChanged:
//                return "date,ts,x,y,z\n"
//            case .altimeterChanged:
//                return "date,ts,xAlti,yAlti,zAlti\n"
//            case .gyroscopeChanged:
//                return "date,ts,x,y,z\n"
//            default:
//                return "invalid"
//            }
//    }
//    
    public var csvString : String{
        get{
            return "\(timestamp),\(timestamp.timeIntervalSince1970),\(printData())\n"
        }
    }
    
    /**
     Create new event data
     
     - parameter type:      hr or rr data
     - parameter newValue:  the changed hr or rr value
     - parameter timestamp: timestamp of data (default is current type)
     
     - returns: new data object
     */
    public init(type: SensorDataType, newValues: [Double]?, timestamp : Date = Date()){
        self._sensorDataType = type
        self.newValues = newValues
        self.timestamp = timestamp
    }
    
    public func printData() -> String{
        var retVal = ""
        
        if(newValues == nil){
            return retVal
        }
        
        var first = true
        for v in newValues! {
            if(!first){
                retVal = "\(retVal),\(v.description)"
            }else{
                first = false
                retVal = "\(v.description)"
            }
        }
        
        return retVal
    }
    
    public func getOnePointPrint() -> String{
        var retVal = ""
        
        if(newValues == nil){
            return retVal
        }
        
        return newValues!.last!.description
        
    }
}

///**
// MSB Event Types
// 
// - hrChanged: heart rate data available
// - rrChanged: rr data available
// - gsrChanged: GSR data available
// */
//public enum MSBEventType{
//    case hrChanged
//    case rrChanged
//    case gsrChanged
//    case accelerometerChanged
//    case skinTemperatureChanged
//    case gyroscopeChanged
//    case ambientTemperatureChanged
//    case ambientPressureChanged
//    case ambientLightChanged
//    case altimeterChanged
//}
