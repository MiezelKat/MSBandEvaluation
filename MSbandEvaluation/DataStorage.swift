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
    
    private var polarDataPoints : [PolarEventData] = [PolarEventData]()
    
    private var msbDataPoints : [MSBEventData] = [MSBEventData]()
    
    func reset(){
        polarDataPoints.removeAll()
        msbDataPoints.removeAll()
    }
    
    func appendPolar(data : PolarEventData){
        polarDataPoints.append(data)
    }
    
    func appendMSB(data : MSBEventData){
        msbDataPoints.append(data)
    }

    
    func writeToDisk(){
        let now = NSDate()
        //let polarRRFile = getDocumentsDirectory().stringByAppendingPathComponent("polarRR\(now.description).csv")
        //let polarHRFile = getDocumentsDirectory().stringByAppendingPathComponent("polarHR\(now.description).csv")
        
        // folder:
        let polarRRFile = getDocumentsDirectory().stringByAppendingPathComponent("\(now.description)/polarRR.csv")
        let polarHRFile = getDocumentsDirectory().stringByAppendingPathComponent("\(now.description)/polarHR.csv")
        
        //let msbRRFile = getDocumentsDirectory().stringByAppendingPathComponent("msbRR.csv")
        //let msbHRFile = getDocumentsDirectory().stringByAppendingPathComponent("msbHR.csv")
        //let msbGSRFile = getDocumentsDirectory().stringByAppendingPathComponent("msbGSR.csv")
        
        var polarRRData  = "Time,TimeLong,rr \n"
        var polarHRData  = "Time,TimeLong,hr \n"
        
        for dataP in polarDataPoints{
            if(dataP.type == PolarEventType.rrChanged){
                polarRRData.appendContentsOf("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.newValue!.description)\n")
            }else{
                polarHRData.appendContentsOf("\(dataP.timestamp.description),\(dataP.timestamp.timeIntervalSince1970),\(dataP.newValue!.description)\n")
            }
        }
        
        do{
            try polarRRData.writeToURL(NSURL(fileURLWithPath: polarRRFile), atomically: true, encoding: NSUTF8StringEncoding)
        }catch{
            print("error")
        }
        
        do{
            try polarHRData.writeToURL(NSURL(fileURLWithPath: polarHRFile), atomically: true, encoding: NSUTF8StringEncoding)
        }catch{
        print("error")
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