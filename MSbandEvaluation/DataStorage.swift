//
//  DataStorage.swift
//  MSbandEvaluation
//
//  Created by Katrin Hansel on 09/04/2016.
//  Copyright © 2016 Katrin Hansel. All rights reserved.
//

import Foundation
import PolarHRService
import MSBandSensorService

//class DataStorage : NSObject{
//    
//    static let sharedInstance : DataStorage = DataStorage()
//    
//    fileprivate override init(){
//        super.init()
//    }
//    
//    fileprivate var startTS : TimeInterval?
//    
//    fileprivate var polarDataPoints : [PolarEventData] = [PolarEventData]()
//    
//    fileprivate var msbDataPoints : [MSBEventData] = [MSBEventData]()
//    
//    fileprivate var markerTimestamps : [Date] = [Date]()
//    
//    func reset(){
//        polarDataPoints.removeAll()
//        msbDataPoints.removeAll()
//        startTS = nil
//    }
//    
//    func append(polarData data : PolarEventData){
//        if(startTS == nil)
//        {
//            startTS = data.timestamp.timeIntervalSince1970
//        }
//        polarDataPoints.append(data)
//    }
//    
//    func append(msbData data : MSBEventData){
//        if(startTS == nil)
//        {
//            startTS = data.timestamp.timeIntervalSince1970
//        }
//        msbDataPoints.append(data)
//    }
//
//    func appendMarkerTimestamp(){
//        markerTimestamps.append(Date())
//    }
//    
//    func writeToDisk(){
//        let now = Date()
//        
//        let documentsPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
//        let dataPath = documentsPath.appendingPathComponent("record-\(now.description)")
//        do {
//            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
//        } catch let error as NSError {
//            NSLog("Unable to create directory \(error.debugDescription)")
//        }
//        
//        let polarRRURL = dataPath.appendingPathComponent("polarRR.csv")
//        let polarHRURL = dataPath.appendingPathComponent("polarHR.csv")
//        
//        // folder:
//        //let polarRRFile = getDocumentsDirectory().stringByAppendingPathComponent("\(now.description)/polarRR.csv")
//        //let polarHRFile = getDocumentsDirectory().stringByAppendingPathComponent("\(now.description)/polarHR.csv")
//        
//        let msbRRURL = dataPath.appendingPathComponent("msbRR.csv")
//        let msbHRURL = dataPath.appendingPathComponent("msbHR.csv")
//        let msbGSRURL = dataPath.appendingPathComponent("msbGSR.csv")
//        let msbSkinTempURL = dataPath.appendingPathComponent("msbSkinTemp.csv")
//        
//        let msbAccelerometerURL = dataPath.appendingPathComponent("msbAccel.csv")
//        let msbGyroscopeURL = dataPath.appendingPathComponent("msbGyro.csv")
//        
//        let msbAmbientTempURL = dataPath.appendingPathComponent("msbATemp.csv")
//        let msbAmbientPressureURL = dataPath.appendingPathComponent("msbAPressure.csv")
//        let msbAmbientLightURL = dataPath.appendingPathComponent("msbALight.csv")
//        
//        let msbAltimeterURL = dataPath.appendingPathComponent("msbAlti.csv")
//        
//        let markerURL = dataPath.appendingPathComponent("markers.csv")
//        
//        var polarRRData  = "d,dts,ts,rr\n"
//        var polarHRData  = "d,dts,ts,hr\n"
//        
//        
//        for dataP in polarDataPoints{
//            if(dataP.type == PolarEventType.rrChanged){
//                polarRRData.append("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.newValue!.description)\n")
//            }else{
//                polarHRData.append("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.newValue!.description)\n")
//            }
//        }
//        
//        do{
//            try polarRRData.write(to: polarRRURL, atomically: true, encoding: String.Encoding.utf8)
//        }catch let error as NSError{
//            print(error.description)
//        }
//        
//        do{
//            try polarHRData.write(to: polarHRURL, atomically: true, encoding: String.Encoding.utf8)
//        }catch let error as NSError{
//            print(error.description)
//        }
//        
//        var msbRRData  = "d,dts,ts,rr\n"
//        var msbHRData  = "d,dts,ts,hr\n"
//        var msbGSRData = "d,dts,ts,gsr\n"
//        var msbSkinTempData = "d,ts,temp\n"
//        
//        var msbAccelerometerData = "d,dts,ts,x,y,z\n"
//        var msbGyroscopeData = "d,dts,ts,x,y,z\n"
//        
//        var msbAmbientTempData = "d,dts,ts,temp\n"
//        var msbAmbientPressureData = "d,dts,ts,pressure\n"
//        var msbAmbientLightData = "d,dts,ts,light\n"
//        
//        var msbAltimeterData = "d,dts,ts,altitude\n"
//        
//        
//        for dataP in msbDataPoints{
//            if(dataP.type == MSBEventType.rrChanged){
//                msbRRData.append("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
//            }else if(dataP.type == MSBEventType.hrChanged){
//                msbHRData.append("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
//            }else if(dataP.type == MSBEventType.gsrChanged){
//                msbGSRData.append("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
//            }else if(dataP.type == MSBEventType.skinTemperatureChanged){
//                msbSkinTempData.append("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
//            }else if(dataP.type == MSBEventType.accelerometerChanged){
//                msbAccelerometerData.append("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
//            }else if(dataP.type == MSBEventType.gyroscopeChanged){
//                msbGyroscopeData.append("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
//            }else if(dataP.type == MSBEventType.ambientTemperatureChanged){
//                msbAmbientTempData.append("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
//            }else if(dataP.type == MSBEventType.ambientLightChanged){
//                msbAmbientLightData.append("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
//            }else if(dataP.type == MSBEventType.ambientPressureChanged){
//                msbAmbientPressureData.append("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
//            }else if(dataP.type == MSBEventType.altimeterChanged){
//                msbAltimeterData.append("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
//            }
//        }
//        
//        var markerData  = "d,dts,ts\n"
//        
//        for dataP in markerTimestamps{
//            markerData.append("\(dataP.description),\(dataP.timeIntervalSince1970),\(dataP.timeIntervalSince1970-startTS!)\n")
//        }
//        
//        do{
//            try msbRRData.write(to: msbRRURL, atomically: true, encoding: String.Encoding.utf8)
//        }catch let error as NSError{
//            print(error.description)
//        }
//        
//        do{
//            try msbHRData.write(to: msbHRURL, atomically: true, encoding: String.Encoding.utf8)
//        }catch let error as NSError{
//            print(error.description)
//        }
//        
//        do{
//            try msbGSRData.write(to: msbGSRURL, atomically: true, encoding: String.Encoding.utf8)
//        }catch let error as NSError{
//            print(error.description)
//        }
//        
//        do{
//            try markerData.write(to: markerURL, atomically: true, encoding: String.Encoding.utf8)
//        }catch let error as NSError{
//            print(error.description)
//        }
//
//        do{
//            try msbAltimeterData.write(to: msbAltimeterURL, atomically: true, encoding: String.Encoding.utf8)
//        }catch let error as NSError{
//            print(error.description)
//        }
//        
//        do{
//            try msbAmbientLightData.write(to: msbAmbientLightURL, atomically: true, encoding: String.Encoding.utf8)
//        }catch let error as NSError{
//            print(error.description)
//        }
//        
//        do{
//            try msbAmbientPressureData.write(to: msbAmbientPressureURL, atomically: true, encoding: String.Encoding.utf8)
//        }catch let error as NSError{
//            print(error.description)
//        }
//        
//        do{
//            try msbAmbientTempData.write(to: msbAmbientTempURL, atomically: true, encoding: String.Encoding.utf8)
//        }catch let error as NSError{
//            print(error.description)
//        }
//        
//        do{
//            try msbSkinTempData.write(to: msbSkinTempURL, atomically: true, encoding: String.Encoding.utf8)
//        }catch let error as NSError{
//            print(error.description)
//        }
//        
//        do{
//            try msbAccelerometerData.write(to: msbAccelerometerURL, atomically: true, encoding: String.Encoding.utf8)
//        }catch let error as NSError{
//            print(error.description)
//        }
//        
//        do{
//            try msbGyroscopeData.write(to: msbGyroscopeURL, atomically: true, encoding: String.Encoding.utf8)
//        }catch let error as NSError{
//            print(error.description)
//        }
//    }
//    
//    fileprivate func getDocumentsDirectory() -> NSString {
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let documentsDirectory = paths[0]
//        return documentsDirectory as NSString
//    }
//    
//    func getDataSamplesList() -> [String]{
//        var directories : [NSString?]
//        var directoryUrls : [URL]?
//        
//        var returnStrs = [String]()
//        
//        do {
//            directoryUrls = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: getDocumentsDirectory() as String), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
//            
//            print(directoryUrls)
//
//            
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
//        if(directoryUrls != nil){
//            //mp3Files = directoryUrls!.filter{x in (x.lastPathComponent?.containsString("polarRR"))!}.map{x in x.lastPathComponent! as NSString }
//            
//            let f = directoryUrls!.map{x in x.absoluteString as NSString}
//            
//            let d = directoryUrls!.filter{x in (x.hasDirectoryPath)}.map{x in x.absoluteString as NSString}
//            
//            directories = d
//            
//            print("MP3 FILES:\n" + directories.description)
//            
//            for s in directories{
//                let split1 = s!.substring(to: s!.length - 1 - 4) as NSString
//                let split2 = split1.substring(from: 7)
//                
//                returnStrs.append(split2)
//                
//            }
//        }
//        
//        return returnStrs
//    }
//    
//}
