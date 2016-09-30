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

class DataStorage : NSObject{
    
    /// singleton instance
    class var sharedInstance : DataStorage{
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : DataStorage? = nil
        }
        dispatch_once(&Static.onceToken){
            Static.instance = DataStorage()
        }
        
        return Static.instance!
    }
    
    private override init(){
        super.init()
    }
    
    private var startTS : NSTimeInterval?
    
    private var polarDataPoints : [PolarEventData] = [PolarEventData]()
    
    private var msbDataPoints : [MSBEventData] = [MSBEventData]()
    
    private var markerTimestamps : [NSDate] = [NSDate]()
    
    func reset(){
        polarDataPoints.removeAll()
        msbDataPoints.removeAll()
        startTS = nil
    }
    
    func appendPolar(data : PolarEventData){
        if(startTS == nil)
        {
            startTS = data.timestamp.timeIntervalSince1970
        }
        polarDataPoints.append(data)
    }
    
    func appendMSB(data : MSBEventData){
        if(startTS == nil)
        {
            startTS = data.timestamp.timeIntervalSince1970
        }
        msbDataPoints.append(data)
    }

    func appendMarkerTimestamp(){
        markerTimestamps.append(NSDate())
    }
    
    func writeToDisk(){
        let now = NSDate()
        
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
        let dataPath = documentsPath.URLByAppendingPathComponent("record-\(now.description)")
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(dataPath.path!, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        
        let polarRRURL = dataPath.URLByAppendingPathComponent("polarRR.csv")
        let polarHRURL = dataPath.URLByAppendingPathComponent("polarHR.csv")
        
        // folder:
        //let polarRRFile = getDocumentsDirectory().stringByAppendingPathComponent("\(now.description)/polarRR.csv")
        //let polarHRFile = getDocumentsDirectory().stringByAppendingPathComponent("\(now.description)/polarHR.csv")
        
        let msbRRURL = dataPath.URLByAppendingPathComponent("msbRR.csv")
        let msbHRURL = dataPath.URLByAppendingPathComponent("msbHR.csv")
        let msbGSRURL = dataPath.URLByAppendingPathComponent("msbGSR.csv")
        let msbSkinTempURL = dataPath.URLByAppendingPathComponent("msbSkinTemp.csv")
        
        let msbAccelerometerURL = dataPath.URLByAppendingPathComponent("msbAccel.csv")
        let msbGyroscopeURL = dataPath.URLByAppendingPathComponent("msbGyro.csv")
        
        let msbAmbientTempURL = dataPath.URLByAppendingPathComponent("msbATemp.csv")
        let msbAmbientPressureURL = dataPath.URLByAppendingPathComponent("msbAPressure.csv")
        let msbAmbientLightURL = dataPath.URLByAppendingPathComponent("msbALight.csv")
        
        let msbAltimeterURL = dataPath.URLByAppendingPathComponent("msbAlti.csv")
        
        let markerURL = dataPath.URLByAppendingPathComponent("markers.csv")
        
        var polarRRData  = "d,dts,ts,rr\n"
        var polarHRData  = "d,dts,ts,hr\n"
        
        
        for dataP in polarDataPoints{
            if(dataP.type == PolarEventType.rrChanged){
                polarRRData.appendContentsOf("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.newValue!.description)\n")
            }else{
                polarHRData.appendContentsOf("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.newValue!.description)\n")
            }
        }
        
        do{
            try polarRRData.writeToURL(polarRRURL, atomically: true, encoding: NSUTF8StringEncoding)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try polarHRData.writeToURL(polarHRURL, atomically: true, encoding: NSUTF8StringEncoding)
        }catch let error as NSError{
            print(error.description)
        }
        
        var msbRRData  = "d,dts,ts,rr\n"
        var msbHRData  = "d,dts,ts,hr\n"
        var msbGSRData = "d,dts,ts,gsr\n"
        var msbSkinTempData = "d,ts,gsr\n"
        
        var msbAccelerometerData = "d,dts,ts,x,y,z\n"
        var msbGyroscopeData = "d,dts,ts,x,y,z\n"
        
        var msbAmbientTempData = "d,dts,ts,temp\n"
        var msbAmbientPressureData = "d,dts,ts,pressure\n"
        var msbAmbientLightData = "d,dts,ts,light\n"
        
        var msbAltimeterData = "d,dts,ts,altitude\n"
        
        
        for dataP in msbDataPoints{
            if(dataP.type == MSBEventType.rrChanged){
                msbRRData.appendContentsOf("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
            }else if(dataP.type == MSBEventType.hrChanged){
                msbHRData.appendContentsOf("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
            }else if(dataP.type == MSBEventType.gsrChanged){
                msbGSRData.appendContentsOf("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
            }else if(dataP.type == MSBEventType.skinTemperatureChanged){
                msbSkinTempData.appendContentsOf("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
            }else if(dataP.type == MSBEventType.accelerometerChanged){
                msbAccelerometerData.appendContentsOf("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
            }else if(dataP.type == MSBEventType.gyroscopeChanged){
                msbGyroscopeData.appendContentsOf("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
            }else if(dataP.type == MSBEventType.ambientTemperatureChanged){
                msbAmbientTempData.appendContentsOf("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
            }else if(dataP.type == MSBEventType.ambientLightChanged){
                msbAmbientLightData.appendContentsOf("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
            }else if(dataP.type == MSBEventType.ambientPressureChanged){
                msbAmbientPressureData.appendContentsOf("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
            }else if(dataP.type == MSBEventType.altimeterChanged){
                msbAltimeterData.appendContentsOf("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.timestamp.timeIntervalSince1970-startTS!),\(dataP.printData())\n")
            }
        }
        
        var markerData  = "d,dts,ts\n"
        
        for dataP in markerTimestamps{
            markerData.appendContentsOf("\(dataP.description),\(dataP.timeIntervalSince1970),\(dataP.timeIntervalSince1970-startTS!)\n")
        }
        
        do{
            try msbRRData.writeToURL(msbRRURL, atomically: true, encoding: NSUTF8StringEncoding)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbHRData.writeToURL(msbHRURL, atomically: true, encoding: NSUTF8StringEncoding)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbGSRData.writeToURL(msbGSRURL, atomically: true, encoding: NSUTF8StringEncoding)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try markerData.writeToURL(markerURL, atomically: true, encoding: NSUTF8StringEncoding)
        }catch let error as NSError{
            print(error.description)
        }

        do{
            try msbAltimeterData.writeToURL(msbAltimeterURL, atomically: true, encoding: NSUTF8StringEncoding)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbAmbientLightData.writeToURL(msbAmbientLightURL, atomically: true, encoding: NSUTF8StringEncoding)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbAmbientPressureData.writeToURL(msbAmbientPressureURL, atomically: true, encoding: NSUTF8StringEncoding)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbAmbientTempData.writeToURL(msbAmbientTempURL, atomically: true, encoding: NSUTF8StringEncoding)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbSkinTempData.writeToURL(msbSkinTempURL, atomically: true, encoding: NSUTF8StringEncoding)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbAccelerometerData.writeToURL(msbAccelerometerURL, atomically: true, encoding: NSUTF8StringEncoding)
        }catch let error as NSError{
            print(error.description)
        }
        
        do{
            try msbGyroscopeData.writeToURL(msbGyroscopeURL, atomically: true, encoding: NSUTF8StringEncoding)
        }catch let error as NSError{
            print(error.description)
        }
    }
    
    private func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getDataSamplesList() -> [String]{
        var directories : [NSString?]
        var directoryUrls : [NSURL]?
        
        var returnStrs = [String]()
        
        do {
            directoryUrls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(NSURL(fileURLWithPath: getDocumentsDirectory() as String), includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
            
            print(directoryUrls)

            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        if(directoryUrls != nil){
            //mp3Files = directoryUrls!.filter{x in (x.lastPathComponent?.containsString("polarRR"))!}.map{x in x.lastPathComponent! as NSString }
            
            let f = directoryUrls!.map{x in x.absoluteString as! NSString}
            
            let d = directoryUrls!.filter{x in (x.hasDirectoryPath)}.map{x in x.absoluteString as! NSString}
            
            directories = d
            
            print("MP3 FILES:\n" + directories.description)
            
            for s in directories{
                let split1 = s!.substringToIndex(s!.length - 1 - 4) as NSString
                let split2 = split1.substringFromIndex(7)
                
                returnStrs.append(split2)
                
            }
        }
        
        return returnStrs
    }
    
}