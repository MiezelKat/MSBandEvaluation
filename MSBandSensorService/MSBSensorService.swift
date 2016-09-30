//
//  MSBSensorService.swift
//  MSbandEvaluation
//
//  Created by Katrin Hansel on 07/04/2016.
//  Copyright © 2016 Katrin Hansel. All rights reserved.
//

import Foundation
import SensorEvaluationShared

public class MSBService : NSObject, MSBClientManagerDelegate{
    
    // MARK: Singleton and constructor
    
    /// singleton instance
    public class var instance : MSBService{
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : MSBService? = nil
        }
        dispatch_once(&Static.onceToken){
            Static.instance = MSBService()
        }
        
        return Static.instance!
    }
    
    private override init(){
        super.init()
    }
    
    // MARK: MSClient mebers
    
    /// MSBand Client
    var client: MSBClient?
    /// Singleton instance of the client manager
    private var clientManager = MSBClientManager.sharedManager()
    
    // MARK: Private Events
    
    private let msbEvent = Event<MSBEventData>()
    
    private let periphalEvent = Event<PeriphalChangedEventData>()
    
    //MARK: Connect
    
    public func connect(){
        clientManager.delegate = self
        if let band = clientManager.attachedClients().first as! MSBClient? {
            self.client = band
            clientManager.connectClient(client)
            periphalEvent.raise(PeriphalChangedEventData(status: PeriphalStatus.isConnecting, source: PeriphalSourceType.microsoftBand))
        } else {
            periphalEvent.raise(PeriphalChangedEventData(status: PeriphalStatus.failedConnecting, source: PeriphalSourceType.microsoftBand))
            return
        }
    }
    
    // MARK: Public functions for event subscription
    
    /**
    Subscibe new event handler to receive HR events
    
    - parameter hrEventHandler: hr event handler
    */
    public func subcribeToMSBEvents(msbEventHandler : MSBEventHandler){
        msbEvent.addHandler( {e in msbEventHandler.handleMSBEvent(e)} )
    }
    
    /**
     Subscibe new event handler to receive changes in connection status
     
     - parameter pEventHandler: periphal event handler
     */
    public func subcribeToPeriphalEvents(pEventHandler : PeriphalEventHandler){
        periphalEvent.addHandler( {e in pEventHandler.handlePeriphalEvent(e)} )
    }

    
    // MARK - MSBClientManagerDelegate
    public func clientManager(clientManager: MSBClientManager!, clientDidConnect client: MSBClient!) {
        periphalEvent.raise(PeriphalChangedEventData(status: PeriphalStatus.isConnected, source: PeriphalSourceType.microsoftBand));
        let consent : MSBUserConsent = self.client!.sensorManager.heartRateUserConsent()
        switch (consent)
        {
        case MSBUserConsent.Granted:
            // user has granted access
            self.startHeartRateUpdates()
        case MSBUserConsent.NotSpecified:
            // request user consent
            self.client!.sensorManager.requestHRUserConsentWithCompletion({
                (userConsent: Bool, error : NSError?) -> Void in
                
                if (userConsent)
                {
                    // user granted access
                    self.startHeartRateUpdates()
                }
                else
                {
                    // user declined access
                    print("no user consent")
                }
                
            })
        case MSBUserConsent.Declined:
            print("declined")
            
        }
    }
    
    public func clientManager(clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
        periphalEvent.raise(PeriphalChangedEventData(status: PeriphalStatus.isDisconnected, source: PeriphalSourceType.microsoftBand));
    }
  
    public func clientManager(clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: NSError!) {
        periphalEvent.raise(PeriphalChangedEventData(status: PeriphalStatus.failedConnecting, source: PeriphalSourceType.microsoftBand));
    }
    
    
    func startHeartRateUpdates() {
        if let client = self.client {
            // RR
            do{
                try client.sensorManager.startRRIntervalUpdatesToQueue(nil, withHandler: { (rrData: MSBSensorRRIntervalData!, error: NSError!) in
                    self.msbEvent.raise(MSBEventData1D(type: MSBEventType.rrChanged, newValue: rrData.interval))
                })
            } catch let error as NSError {
                print("startRRUpdatesToQueue failed: \(error.description)")
            }
            
            // HR
            do {
                try client.sensorManager.startHeartRateUpdatesToQueue(nil, withHandler: { (heartRateData: MSBSensorHeartRateData!, error: NSError!) in
                    self.msbEvent.raise(MSBEventData1D(type: MSBEventType.hrChanged, newValue: Double(heartRateData.heartRate)))
                })
            } catch let error as NSError {
                print("startHeartRateUpdatesToQueue failed: \(error.description)")
            }
            
            // GSR
            do{
                try client.sensorManager.startGSRUpdatesToQueue(nil, withHandler: { (gsrData: MSBSensorGSRData!, error: NSError!) in
                    self.msbEvent.raise(MSBEventData1D(type: MSBEventType.gsrChanged, newValue: Double(gsrData.resistance)))
                })
            } catch let error as NSError {
                print("startGSRUpdatesToQueue failed: \(error.description)")
            }
            
            // Accelerometer
            do{
                try client.sensorManager.startAccelerometerUpdatesToQueue(nil, withHandler: { (accelerometerData: MSBSensorAccelerometerData!, error: NSError!) in
                    self.msbEvent.raise(MSBEventDataMD(type: MSBEventType.accelerometerChanged, newValue: [Double(accelerometerData.x), Double(accelerometerData.y), Double(accelerometerData.z)]))
                })
            } catch let error as NSError {
                print("startAccelerometerUpdatesToQueue failed: \(error.description)")
            }
            
            // Gyroscope
            do{
                try client.sensorManager.startGyroscopeUpdatesToQueue(nil, withHandler: { (gyroscopeData: MSBSensorGyroscopeData!, error: NSError!) in
                    self.msbEvent.raise(MSBEventDataMD(type: MSBEventType.gyroscopeChanged, newValue: [Double(gyroscopeData.x), Double(gyroscopeData.y), Double(gyroscopeData.z)]))
                })
            } catch let error as NSError {
                print("startGyroscopeUpdatesToQueue failed: \(error.description)")
            }
            
            // altimeter
            do{
                try client.sensorManager.startAltimeterUpdatesToQueue(nil, withHandler: { (altimeterData: MSBSensorAltimeterData!, error: NSError!) in
                    self.msbEvent.raise(MSBEventData1D(type: MSBEventType.altimeterChanged, newValue: Double(altimeterData.rate)))
                })
            } catch let error as NSError {
                print("startAltimeterUpdatesToQueue failed: \(error.description)")
            }
            
            // ambient light
            do{
                try client.sensorManager.startAmbientLightUpdatesToQueue(nil, withHandler: { (lightData: MSBSensorAmbientLightData!, error: NSError!) in
                    self.msbEvent.raise(MSBEventData1D(type: MSBEventType.ambientLightChanged, newValue: Double(lightData.brightness)))
                })
            } catch let error as NSError {
                print("startAltimeterUpdatesToQueue failed: \(error.description)")
            }
            
            // ambient barometer
            do{
                try client.sensorManager.startBarometerUpdatesToQueue(nil, withHandler: { (barometerData: MSBSensorBarometerData!, error: NSError!) in
                    self.msbEvent.raise(MSBEventData1D(type: MSBEventType.ambientTemperatureChanged, newValue: Double(barometerData.temperature)))
                    self.msbEvent.raise(MSBEventData1D(type: MSBEventType.ambientPressureChanged, newValue: Double(barometerData.airPressure)))
                })
            } catch let error as NSError {
                print("startAltimeterUpdatesToQueue failed: \(error.description)")
            }
        } else {
            print("Client not connected, can not start heart rate updates")
        }
    }
    
    func stopHeartRateUpdates() {
        if let client = self.client {
            do {
                try client.sensorManager.stopHeartRateUpdatesErrorRef()
                try client.sensorManager.stopGSRUpdatesErrorRef()
                try client.sensorManager.stopRRIntervalUpdatesErrorRef()
            } catch let error as NSError {
                print("stopHeartRateUpdatesErrorRef failed: \(error.description)")
            }
        }
    }
}