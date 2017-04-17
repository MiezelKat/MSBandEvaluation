//
//  DataStorage.swift
//  MSbandEvaluation
//
//  Created by Katrin Hansel on 14/04/2017.
//  Copyright © 2017 Katrin Hansel. All rights reserved.
//

import Foundation
import Foundation
//import PolarHRService
//import MSBandSensorService

public class DataStorage : NSObject{
    
    public static let sharedInstance : DataStorage = DataStorage()
    
    fileprivate override init(){
        lastSaved = Date()
        super.init()
    }
    
    fileprivate var startTS : TimeInterval?
    
    fileprivate var polarDataPoints : [SensorData] = [SensorData]()
    
    fileprivate var msbDataPoints : [SensorData] = [SensorData]()
    
    fileprivate var markerTimestamps : [Date] = [Date]()
    
    public func reset(){
        polarDataPoints.removeAll()
        msbDataPoints.removeAll()
        startTS = nil
    }
    
    var batch = 0
    
    var lastSaved : Date
    
    public func append(data data : SensorData){
        if(startTS == nil)
        {
            startTS = data.timestamp.timeIntervalSince1970
        }
        if(data.sensorSource == .polar){
            polarDataPoints.append(data)
        }else{
            msbDataPoints.append(data)
        }
        
        
        checkSaving()
    }
    
    func checkSaving(){
        let nextTransmission = lastSaved.addingTimeInterval(60*5)
        

        if(nextTransmission.compare(Date()) == .orderedAscending){
            writeToDisk(batchNo: 0)
            polarDataPoints.removeAll()
            msbDataPoints.removeAll()
        }
    }
    
    
    public func appendMarkerTimestamp(){
        markerTimestamps.append(Date())
    }
    
    public func writeToDisk(batchNo : Int){
        let now = Date()
        
        let documentsPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let dataPath = documentsPath.appendingPathComponent("record-\(now.description)")
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        
        let polarRRURL = dataPath.appendingPathComponent("polarRR_\(batchNo).csv")
        let polarHRURL = dataPath.appendingPathComponent("polarHR_\(batchNo).csv")
        
        let msbRRURL = dataPath.appendingPathComponent("msbRR_\(batchNo).csv")
        let msbHRURL = dataPath.appendingPathComponent("msbHR_\(batchNo).csv")
        let msbGSRURL = dataPath.appendingPathComponent("msbGSR_\(batchNo).csv")
        let msbSkinTempURL = dataPath.appendingPathComponent("msbSkinTemp_\(batchNo).csv")
        
        let msbAccelerometerURL = dataPath.appendingPathComponent("msbAccel_\(batchNo).csv")
        let msbGyroscopeURL = dataPath.appendingPathComponent("msbGyro_\(batchNo).csv")
        
        let msbAmbientTempURL = dataPath.appendingPathComponent("msbATemp_\(batchNo).csv")
        let msbAmbientPressureURL = dataPath.appendingPathComponent("msbAPressure_\(batchNo).csv")
        let msbAmbientLightURL = dataPath.appendingPathComponent("msbALight_\(batchNo).csv")
        
        let msbAltimeterURL = dataPath.appendingPathComponent("msbAlti_\(batchNo).csv")
        
        let markerURL = dataPath.appendingPathComponent("markers_\(batchNo).csv")
        
        var polarRRData  = SensorDataHelper.csvHeader(forType: .rrChanged)
        var polarHRData  = SensorDataHelper.csvHeader(forType: .hrChanged)
        
        
        for dataP in polarDataPoints{
            if(dataP.sensorDataType == .rrChanged){
                polarRRData.append(dataP.csvString)
                
                //polarRRData.append("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.newValue!.description)\n")
            }else{
                polarHRData.append(dataP.csvString)
                
                //polarHRData.append("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.newValue!.description)\n")
            }
        }
        
        do{
            try polarRRData.write(to: polarRRURL, atomically: true, encoding: String.Encoding.utf8)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try polarHRData.write(to: polarHRURL, atomically: true, encoding: String.Encoding.utf8)
        }catch let error as NSError{
            print(error.description)
        }
        
        var msbRRData  = SensorDataHelper.csvHeader(forType: .rrChanged)
        var msbHRData  = SensorDataHelper.csvHeader(forType: .hrChanged)
        var msbGSRData = SensorDataHelper.csvHeader(forType: .gsrChanged)
        var msbSkinTempData = SensorDataHelper.csvHeader(forType: .skinTemperatureChanged)
        
        var msbAccelerometerData = SensorDataHelper.csvHeader(forType: .accelerometerChanged)
        var msbGyroscopeData = SensorDataHelper.csvHeader(forType: .gyroscopeChanged)
        
        var msbAmbientTempData = SensorDataHelper.csvHeader(forType: .ambientTemperatureChanged)
        var msbAmbientPressureData = SensorDataHelper.csvHeader(forType: .ambientPressureChanged)
        var msbAmbientLightData = SensorDataHelper.csvHeader(forType: .ambientLightChanged)
        
        var msbAltimeterData = SensorDataHelper.csvHeader(forType: .altimeterChanged)
        
        
        for dataP in msbDataPoints{
            if(dataP.sensorDataType == .rrChanged){
                msbRRData.append(dataP.csvString)
            }else if(dataP.sensorDataType == .hrChanged){
                msbHRData.append(dataP.csvString)
            }else if(dataP.sensorDataType == .gsrChanged){
                msbGSRData.append(dataP.csvString)
            }else if(dataP.sensorDataType == .skinTemperatureChanged){
                msbSkinTempData.append(dataP.csvString)
            }else if(dataP.sensorDataType == .accelerometerChanged){
                msbAccelerometerData.append(dataP.csvString)
            }else if(dataP.sensorDataType == .gyroscopeChanged){
                msbGyroscopeData.append(dataP.csvString)
            }else if(dataP.sensorDataType == .ambientTemperatureChanged){
                msbAmbientTempData.append(dataP.csvString)
            }else if(dataP.sensorDataType == .ambientLightChanged){
                msbAmbientLightData.append(dataP.csvString)
            }else if(dataP.sensorDataType == .ambientPressureChanged){
                msbAmbientPressureData.append(dataP.csvString)
            }else if(dataP.sensorDataType == .altimeterChanged){
                msbAltimeterData.append(dataP.csvString)
            }
        }
        
        var markerData  = "d,dts,ts\n"
        
        for dataP in markerTimestamps{
            markerData.append("\(dataP.description),\(dataP.timeIntervalSince1970),\(dataP.timeIntervalSince1970-startTS!)\n")
        }
        
        do{
            try msbRRData.write(to: msbRRURL, atomically: true, encoding: String.Encoding.utf8)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbHRData.write(to: msbHRURL, atomically: true, encoding: String.Encoding.utf8)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbGSRData.write(to: msbGSRURL, atomically: true, encoding: String.Encoding.utf8)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try markerData.write(to: markerURL, atomically: true, encoding: String.Encoding.utf8)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbAltimeterData.write(to: msbAltimeterURL, atomically: true, encoding: String.Encoding.utf8)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbAmbientLightData.write(to: msbAmbientLightURL, atomically: true, encoding: String.Encoding.utf8)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbAmbientPressureData.write(to: msbAmbientPressureURL, atomically: true, encoding: String.Encoding.utf8)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbAmbientTempData.write(to: msbAmbientTempURL, atomically: true, encoding: String.Encoding.utf8)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbSkinTempData.write(to: msbSkinTempURL, atomically: true, encoding: String.Encoding.utf8)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbAccelerometerData.write(to: msbAccelerometerURL, atomically: true, encoding: String.Encoding.utf8)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbGyroscopeData.write(to: msbGyroscopeURL, atomically: true, encoding: String.Encoding.utf8)
        }catch let error as NSError{
            print(error.description)
        }
    }
    
    fileprivate func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
    
    public func getDataSamplesList() -> [String]{
        var directories : [NSString?]
        var directoryUrls : [URL]?
        
        var returnStrs = [String]()
        
        do {
            directoryUrls = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: getDocumentsDirectory() as String), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
            
            print(directoryUrls)
            
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        if(directoryUrls != nil){
            //mp3Files = directoryUrls!.filter{x in (x.lastPathComponent?.containsString("polarRR"))!}.map{x in x.lastPathComponent! as NSString }
            
            let f = directoryUrls!.map{x in x.absoluteString as NSString}
            
            let d = directoryUrls!.filter{x in (x.hasDirectoryPath)}.map{x in x.absoluteString as NSString}
            
            directories = d
            
            print("MP3 FILES:\n" + directories.description)
            
            for s in directories{
                let split1 = s!.substring(to: s!.length - 1 - 4) as NSString
                let split2 = split1.substring(from: 7)
                
                returnStrs.append(split2)
                
            }
        }
        
        return returnStrs
    }
    
}
