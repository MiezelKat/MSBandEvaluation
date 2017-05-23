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
        markerTimestamps.removeAll()
        startTS = nil
        recordDir = nil
    }
    
    var batch = 0
    var lastSaved : Date
    var recordDir : String? = nil
    
    public func startRecording(inDirectory dir: String? = nil){
        startTS = Date().timeIntervalSince1970
        lastSaved = Date()
        recordDir = dir
    }
    
    public func stopRecording(){
        write(msbData: msbDataPoints, polarData: polarDataPoints, batchNo: batch)
        reset()
    }
    
    
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
        let nextTransmission = lastSaved.addingTimeInterval(60)
        
        if(nextTransmission.compare(Date()) == .orderedAscending){
            let msb = msbDataPoints
            let polar = polarDataPoints
            polarDataPoints.removeAll(keepingCapacity: true)
            msbDataPoints.removeAll(keepingCapacity: true)
            lastSaved = Date()
            write(msbData: msb, polarData: polar, batchNo: batch)
            
            batch = batch + 1
            
        }
    }
    
    
    public func appendMarkerTimestamp(){
        markerTimestamps.append(Date())
    }
    
    public func write(msbData: [SensorData], polarData : [SensorData], batchNo : Int){
        let now = Date()
        
        let documentsPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let dir = recordDir != nil ? recordDir! : "record-\(now.description)"
        let dataPath = documentsPath.appendingPathComponent(dir)
        let polarDirPath = dataPath.appendingPathComponent("polar")
        let msbDirPath = dataPath.appendingPathComponent("msb")
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(atPath: polarDirPath.path, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(atPath: msbDirPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        
        let polarRRURL = polarDirPath.appendingPathComponent("pRR_\(batchNo).csv")
        let polarHRURL = polarDirPath.appendingPathComponent("pHR_\(batchNo).csv")
        
        let msbRRURL = msbDirPath.appendingPathComponent("mRR_\(batchNo).csv")
        let msbHRURL = msbDirPath.appendingPathComponent("mHR_\(batchNo).csv")
        let msbGSRURL = msbDirPath.appendingPathComponent("mGSR_\(batchNo).csv")
        let msbSkinTempURL = msbDirPath.appendingPathComponent("mSkinTemp_\(batchNo).csv")
        
        let msbAccelerometerURL = msbDirPath.appendingPathComponent("mAccel_\(batchNo).csv")
        let msbGyroscopeURL = msbDirPath.appendingPathComponent("mGyro_\(batchNo).csv")
        
        let msbAmbientTempURL = msbDirPath.appendingPathComponent("mATemp_\(batchNo).csv")
        let msbAmbientPressureURL = msbDirPath.appendingPathComponent("mAPressure_\(batchNo).csv")
        let msbAmbientLightURL = msbDirPath.appendingPathComponent("mALight_\(batchNo).csv")
        
        let msbAltimeterURL = msbDirPath.appendingPathComponent("mAlti_\(batchNo).csv")
        
        let markerURL = dataPath.appendingPathComponent("markers_\(batchNo).csv")
        
        var polarRRData  = SensorDataHelper.csvHeader(forType: .rrChanged)
        var polarHRData  = SensorDataHelper.csvHeader(forType: .hrChanged)
        
        
        for dataP in polarData{
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

        
        for dataP in msbData{
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
    
       
}
