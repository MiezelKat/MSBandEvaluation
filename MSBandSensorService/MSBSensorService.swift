//
//  MSBSensorService.swift
//  MSbandEvaluation
//
//  Created by Katrin Hansel on 07/04/2016.
//  Copyright © 2016 Katrin Hansel. All rights reserved.
//

import Foundation
import SensorEvaluationShared

public  class MSBService : NSObject, MSBClientManagerDelegate{

    public static let instance : MSBService = MSBService()
    
    private override init(){
        super.init()
    }
    
    // MARK: MSClient mebers
    
    /// MSBand Client
    var client: MSBClient?
    /// Singleton instance of the client manager
    fileprivate var clientManager = MSBClientManager.shared()
    
    // MARK: Private Events
    
    fileprivate let msbEvent = Event<MSBEventData>()
    
    fileprivate let periphalEvent = Event<PeriphalChangedEventData>()
    
    //MARK: Connect
    
    open func connect(){
        clientManager?.delegate = self
        if let band = clientManager?.attachedClients().first as! MSBClient? {
            self.client = band
            clientManager?.connect(client)
            periphalEvent.raise(withData: PeriphalChangedEventData(status: PeriphalStatus.isConnecting, source: PeriphalSourceType.microsoftBand))
        } else {
            periphalEvent.raise(withData: PeriphalChangedEventData(status: PeriphalStatus.failedConnecting, source: PeriphalSourceType.microsoftBand))
            return
        }
    }
    
    // MARK: Public functions for event subscription
    
    /**
    Subscibe new event handler to receive HR events
    
    - parameter hrEventHandler: hr event handler
    */
    open func subscribe(msbEventHandler handler : MSBEventHandler){
        msbEvent.add(handler: {e in handler.handleEvent(withData: e)} )
    }
    
    /**
     Subscibe new event handler to receive changes in connection status
     
     - parameter pEventHandler: periphal event handler
     */
    open func subscribe(periphalEventHandler handler: PeriphalEventHandler){
        periphalEvent.add(handler: {e in handler.handleEvent(withData:e)} )
    }

    
    // MARK - MSBClientManagerDelegate
    
    public func clientManager(_ clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: Error!) {
        periphalEvent.raise(withData: PeriphalChangedEventData(status: PeriphalStatus.failedConnecting, source: PeriphalSourceType.microsoftBand));
    }
    
    open func clientManager(_ clientManager: MSBClientManager!, clientDidConnect client: MSBClient!) {
        periphalEvent.raise(withData: PeriphalChangedEventData(status: PeriphalStatus.isConnected, source: PeriphalSourceType.microsoftBand));
        let consent : MSBUserConsent = self.client!.sensorManager.heartRateUserConsent()
        switch (consent)
        {
        case MSBUserConsent.granted:
            // user has granted access
            self.startHeartRateUpdates()
        case MSBUserConsent.notSpecified:
            // request user consent
            self.client!.sensorManager.requestHRUserConsent(completion: {
                (userConsent: Bool, error : Error?) -> Void in
                
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
        case MSBUserConsent.declined:
            print("declined")
            
        }
    }
    
    open func clientManager(_ clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
        periphalEvent.raise(withData: PeriphalChangedEventData(status: PeriphalStatus.isDisconnected, source: PeriphalSourceType.microsoftBand));
    }
  
    
    
    func startHeartRateUpdates() {
        if let client = self.client {
            // RR
            do{
                try client.sensorManager.startRRIntervalUpdates(to: nil, withHandler: { (rrData: MSBSensorRRIntervalData?, error: Error?) in
                    let eventData : MSBEventData = MSBEventData1D(type: MSBEventType.rrChanged, newValue: rrData!.interval)
                    self.msbEvent.raise(withData: eventData)
                })
            } catch let error as NSError {
                print("startRRUpdatesToQueue failed: \(error.description)")
            }
            
            // HR
            do {
                try client.sensorManager.startHeartRateUpdates(to: nil, withHandler: { (heartRateData: MSBSensorHeartRateData?, error: Error?) in
                    self.msbEvent.raise(withData: MSBEventData1D(type: MSBEventType.hrChanged, newValue: Double(heartRateData!.heartRate)))
                })
            } catch let error as NSError {
                print("startHeartRateUpdatesToQueue failed: \(error.description)")
            }
            
            // GSR
            do{
                try client.sensorManager.startGSRUpdates(to: nil, withHandler: { (gsrData: MSBSensorGSRData?, error: Error?) in
                    self.msbEvent.raise(withData: MSBEventData1D(type: MSBEventType.gsrChanged, newValue: Double(gsrData!.resistance)))
                })
            } catch let error as NSError {
                print("startGSRUpdatesToQueue failed: \(error.description)")
            }
            
            // Accelerometer
            do{
                try client.sensorManager.startAccelerometerUpdates(to: nil, withHandler: { (accelerometerData: MSBSensorAccelerometerData?, error: Error?) in
                    self.msbEvent.raise(withData: MSBEventDataMD(type: MSBEventType.accelerometerChanged, newValues: [Double(accelerometerData!.x), Double(accelerometerData!.y), Double(accelerometerData!.z)]))
                })
            } catch let error as NSError {
                print("startAccelerometerUpdatesToQueue failed: \(error.description)")
            }
            
            // Skin Temp 
            do{
                try client.sensorManager.startSkinTempUpdates(to: nil, withHandler: { (skinTempData: MSBSensorSkinTemperatureData?, error: Error?) in
                    self.msbEvent.raise(withData: MSBEventDataMD(type: MSBEventType.skinTemperatureChanged, newValues: [Double(skinTempData!.temperature)]))
                })
            } catch let error as NSError {
                print("startAccelerometerUpdatesToQueue failed: \(error.description)")
            }
            
            
            // Gyroscope
            do{
                try client.sensorManager.startGyroscopeUpdates(to: nil, withHandler: { (gyroscopeData: MSBSensorGyroscopeData?, error: Error?) in
                    self.msbEvent.raise(withData: MSBEventDataMD(type: MSBEventType.gyroscopeChanged, newValues: [Double(gyroscopeData!.x), Double(gyroscopeData!.y), Double(gyroscopeData!.z)]))
                })
            } catch let error as NSError {
                print("startGyroscopeUpdatesToQueue failed: \(error.description)")
            }
            
            // altimeter
            do{
                try client.sensorManager.startAltimeterUpdates(to: nil, withHandler: { (altimeterData: MSBSensorAltimeterData?, error: Error?) in
                    self.msbEvent.raise(withData: MSBEventData1D(type: MSBEventType.altimeterChanged, newValue: Double(altimeterData!.rate)))
                })
            } catch let error as NSError {
                print("startAltimeterUpdatesToQueue failed: \(error.description)")
            }
            
            // ambient light
            do{
                try client.sensorManager.startAmbientLightUpdates(to: nil, withHandler: { (lightData: MSBSensorAmbientLightData?, error: Error?) in
                    self.msbEvent.raise(withData: MSBEventData1D(type: MSBEventType.ambientLightChanged, newValue: Double(lightData!.brightness)))
                })
            } catch let error as NSError {
                print("startAltimeterUpdatesToQueue failed: \(error.description)")
            }
            
            // ambient barometer
            do{
                try client.sensorManager.startBarometerUpdates(to: nil, withHandler: { (barometerData: MSBSensorBarometerData?, error: Error?) in
                    self.msbEvent.raise(withData: MSBEventData1D(type: MSBEventType.ambientTemperatureChanged, newValue: Double(barometerData!.temperature)))
                    self.msbEvent.raise(withData: MSBEventData1D(type: MSBEventType.ambientPressureChanged, newValue: Double(barometerData!.airPressure)))
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
