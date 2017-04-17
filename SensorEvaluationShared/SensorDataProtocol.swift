//
//  SensorDataProtocol.swift
//  MSbandEvaluation
//
//  Created by Katrin Hansel on 16/04/2017.
//  Copyright © 2017 Katrin Hansel. All rights reserved.
//

import Foundation

public protocol SensorData{
    
    var sensorSource : SensorSourceType{
        get
    }
    
    var sensorDataType : SensorDataType{
        get
    }
    
    var csvString : String{
        get
    }
    
    var timestamp : Date{
        get
    }
    
}

public class SensorDataHelper{
    
    public static func csvHeader(forType type : SensorDataType) -> String{
        switch type {
        case .accelerometerChanged:
            return "date,ts,x,y,z\n"
        case .altimeterChanged:
            return "date,ts,xAlti,yAlti,zAlti\n"
        case .gyroscopeChanged:
            return "date,ts,x,y,z\n"
        case .hrChanged :
            return "date,ts,hr\n"
        case .rrChanged:
            return "date,ts,rr\n"
        case .ambientLightChanged:
            return "date,ts,aLight\n"
        case .ambientPressureChanged:
            return "date,ts,aPressure\n"
        case .ambientTemperatureChanged:
            return "date,ts,aTemp\n"
        case .gsrChanged:
            return "date,ts,gsr\n"
        case .skinTemperatureChanged:
            return "date,ts,skinTemp\n"
        default:
            return "invalid"
        }
    }

}

/**
 HR Event Types
 
 - hrChanged: heart rate data available
 - rrChanged: rr data available
 */
public enum SensorDataType{
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

public enum SensorSourceType{
    case polar
    case msb
}
