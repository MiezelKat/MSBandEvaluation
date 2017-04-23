//
//  HRVService.swift
//  HRVCore
//
//  Created by Katrin Hansel on 20/12/2015.
//  Copyright © 2015 Katrin Hansel. All rights reserved.
//

import Foundation
import CoreBluetooth
import QuartzCore
import SensorEvaluationShared

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let POLARH7_HRM_DEVICE_INFO_SERVICE_UUID = "0x180A"
let POLARH7_HRM_HEART_RATE_SERVICE_UUID = "0x180D"
let POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID = "2A37"
let POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID = "2A38"
let POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID = "2A29"

/// Service for obtaining heart rate and rr values of a Polar Loop Chest Strap
open class PolarHRService : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate
{
    
    // MARK: Initialisation
    
    /// singleton instance
    public static let instance : PolarHRService = PolarHRService()
    
    /**
    Initialises a new instance
    
    - returns: new instance
    */
    fileprivate override init() {
        
        let cm = CBCentralManager(delegate: nil, queue: nil)
        self.centralManager = cm;
        
        super.init()
        
        cm.delegate = self
    }
    
    // MARK: Attributs
    
    /// For the discovery of devices
    fileprivate var centralManager : CBCentralManager
    /// Remote peripheral device
    fileprivate var polarH7HRMPeripheral : CBPeripheral?

    /// Flag if the device is connected
    fileprivate(set) open var isConnected = false
    
    /// Device Info
    fileprivate(set) open var deviceInfo : NSString?
    
    /// Position of Sensor
    fileprivate(set) open var bodyData: NSString?;
    
    /// Manufacturer
    fileprivate(set) open var manufacturer: NSString?;
    
    fileprivate var polarH7DeviceData: NSString?;

    fileprivate var isConnecting = false
    

    // MARK: Calculated Attributes for HR and RR

    var _heartRate: Int16?

    /// the current Heart Rate
    fileprivate(set) open var heartRate: Int16?{
        set(val){
            if(_heartRate != val){
                _heartRate = val
                hrEvent.raise(withData: PolarEventData(type: SensorDataType.hrChanged, newValue: _heartRate))
            }
        }
        get{
            return _heartRate
        }
    }
    
    var _rrInterval: Int16?
    
    /// the current Heart Rate
    fileprivate(set) open var rrInterval: Int16?{
        set(val){
            if(_rrInterval != val){
                _rrInterval = val
                hrEvent.raise(withData: PolarEventData(type: SensorDataType.rrChanged, newValue: _rrInterval))
            }
        }
        get{
            return _rrInterval
        }
    }
    
    // MARK: Private Events

    fileprivate let hrEvent = Event<PolarEventData>()
    
    fileprivate let periphalEvent = Event<PeriphalChangedEventData>()
    

    // MARK: Connect to Polar Strap

    /**
    Start connection process
    */
    open func connect(){
        //let services = [CBUUID(string: POLARH7_HRM_HEART_RATE_SERVICE_UUID), CBUUID(string: POLARH7_HRM_DEVICE_INFO_SERVICE_UUID)]
        //centralManager.scanForPeripheralsWithServices(services, options: nil)
        isConnecting = true
        
        let serviceUUIDs:[AnyObject] = [CBUUID(string: "180D")]
        let lastPeripherals = centralManager.retrieveConnectedPeripherals(withServices: serviceUUIDs as! [CBUUID])
        
        if lastPeripherals.count > 0{
            let device = lastPeripherals.last! as CBPeripheral;
            polarH7HRMPeripheral = device
            centralManager.connect(polarH7HRMPeripheral!, options: nil)
        }
        else {
            centralManager.scanForPeripherals(withServices: serviceUUIDs as! [CBUUID], options: nil)
        }
    }

    // MARK: Public functions for event subscription

    /**
     Subscibe new event handler to receive HR events
     
     - parameter hrEventHandler: hr event handler
     */
    open func subcribeToHREvents(_ hrEventHandler : PolarEventHandler){
        hrEvent.add(handler:  {e in hrEventHandler.handleEvent(withData: e)} )
    }

    /**
     Subscibe new event handler to receive changes in connection status

     - parameter pEventHandler: periphal event handler
     */
    open func subcribeToPeriphalEvents(_ pEventHandler : PeriphalEventHandler){
        periphalEvent.add(handler:  {e in pEventHandler.handleEvent(withData: e)} )
    }

    //MARK: CBCentralManagerDelegate

    /**
    CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.

    - parameter central:           central manager
    - parameter peripheral:        discovered device
    - parameter advertisementData: advertisement data
    - parameter RSSI:              RSSI
    */
    open func centralManager(_ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
         advertisementData: [String : Any],
         rssi RSSI: NSNumber)
    {
        if(isConnecting){
            let localName = advertisementData[CBAdvertisementDataLocalNameKey];
            if ((localName as AnyObject).length > 0) {
                NSLog("Found the heart rate monitor: \(localName)");
                centralManager.stopScan();
                polarH7HRMPeripheral = peripheral;
                polarH7HRMPeripheral!.delegate = self;
                centralManager.connect(polarH7HRMPeripheral!, options:nil);
                periphalEvent.raise(withData: PeriphalChangedEventData(status: PeriphalStatus.isConnecting, source: PeriphalSourceType.polarStrap) )
            }
        }
    }

    /**
    method called whenever you have successfully connected to the BLE peripheral

    - parameter central:    central manager
    - parameter peripheral: the dicovered device
    */
    open func centralManager(_ central: CBCentralManager,
        didConnect peripheral: CBPeripheral)
    {
        peripheral.delegate = self;
        peripheral.discoverServices(nil);
        self.isConnected = peripheral.state == CBPeripheralState.connected
        periphalEvent.raise(withData: PeriphalChangedEventData(status: PeriphalStatus.isConnected, source: PeriphalSourceType.polarStrap) )
        NSLog("connected: \(self.isConnected)");
    }


    /**
    method called whenever the device state changes.

    - parameter central: central manager
    */
    open func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        if (central.state  == CBManagerState.poweredOn) {
            NSLog("CoreBluetooth BLE hardware is powered on and ready");
            let services = [CBUUID(string: POLARH7_HRM_HEART_RATE_SERVICE_UUID), CBUUID(string: POLARH7_HRM_DEVICE_INFO_SERVICE_UUID)]
            centralManager.scanForPeripherals(withServices: services, options: nil)
        }else{
            
            periphalEvent.raise(withData: PeriphalChangedEventData(status: PeriphalStatus.isDisconnected, source: PeriphalSourceType.polarStrap) )
            
            // Determine the state of the peripheral
            if (central.state == CBManagerState.poweredOff) {
                NSLog("CoreBluetooth BLE hardware is powered off");
            }
            else if (central.state  == CBManagerState.unauthorized) {
                NSLog("CoreBluetooth BLE state is unauthorized");
            }
            else if (central.state  == CBManagerState.unknown) {
                NSLog("CoreBluetooth BLE state is unknown");
            }
            else if (central.state  == CBManagerState.unsupported) {
                NSLog("CoreBluetooth BLE hardware is unsupported on this platform");
            }
        }
    }

    //MARK: CBPeripheralDelegate

    /**
    CBPeripheralDelegate - Invoked when you discover the peripheral's available services.

    - parameter peripheral: peripheral with services
    - parameter error:      error
    */
    open func peripheral(_ peripheral: CBPeripheral,
        didDiscoverServices error: Error?)
    {
        for service in peripheral.services! {
            NSLog("Discovered service: \(service.uuid)");
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    /**
    Invoked when you discover the characteristics of a specified service.

    - parameter peripheral: peripheral
    - parameter service:    service, which characteristics have been discovered
    - parameter error:      error
    */
    open func peripheral(_ peripheral: CBPeripheral,
         didDiscoverCharacteristicsFor service: CBService,
            error: Error?)
    {
        if (service.uuid.isEqual(CBUUID(string: POLARH7_HRM_HEART_RATE_SERVICE_UUID)))  {  // 1
            for aChar in service.characteristics!
            {
                // Request heart rate notifications
                if (aChar.uuid.isEqual(CBUUID(string: POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID))) { // 2
                    self.polarH7HRMPeripheral!.setNotifyValue(true, for:aChar)
                    NSLog("Found heart rate measurement characteristic")
                }
                    // Request body sensor location
                else if (aChar.uuid.isEqual(CBUUID(string:POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID))) { // 3
                    self.polarH7HRMPeripheral!.readValue(for: aChar)
                    NSLog("Found body sensor location characteristic")
                }
            }
        }
        // Retrieve Device Information Services for the Manufacturer Name
        if (service.uuid.isEqual(CBUUID(string: POLARH7_HRM_DEVICE_INFO_SERVICE_UUID)))  { // 4
            for aChar in service.characteristics!
            {
                if (aChar.uuid.isEqual(CBUUID(string:POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID))) {
                    self.polarH7HRMPeripheral!.readValue(for: aChar)
                    NSLog("Found a device manufacturer name characteristic")
                }
            }
        }
    }

    /**
    Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.

    - parameter peripheral:     peripheral
    - parameter characteristic: characteristics, which are updated
    - parameter error:          error
    */
    open func peripheral(_ peripheral: CBPeripheral,
         didUpdateValueFor characteristic: CBCharacteristic,
         error: Error?)    {
            // Updated value for heart rate measurement received
            if (characteristic.uuid.isEqual(CBUUID(string: POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID))) { // 1
                // Get the Heart Rate Monitor BPM
                getHeartBPMData(characteristic, error:error as NSError?)
            }
            // Retrieve the characteristic value for manufacturer name received
            if (characteristic.uuid.isEqual(CBUUID(string: POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID))) {  // 2
                getManufacturerName(characteristic)
            }
                // Retrieve the characteristic value for the body sensor location received
            else if (characteristic.uuid.isEqual(CBUUID(string: POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID))) {  // 3
                getBodyLocation(characteristic)
            }

            // Add your constructed device information to your UITextView
            if(bodyData != nil && manufacturer != nil){
                self.deviceInfo = NSString(format: "%@\n%@\n%@\n", self.isConnected as CVarArg, self.bodyData!, self.manufacturer!)  // 4
            }
    }
    
    //MARK: Helpers
    
    /**
    Function to extract the HR data from a characteristic
    check: https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.heart_rate_measurement.xml
    - parameter characteristic: characteristic with HR data
    - parameter error:          error
    */
    fileprivate func getHeartBPMData(_ characteristic: CBCharacteristic, error: NSError?)
    {
        // Get the Heart Rate Monitor BPM
        let data = characteristic.value
        let reportData = (data! as NSData).bytes.bindMemory(to: UInt8.self, capacity: data!.count)

        var bpm : UInt16 = 0
        var rr : UInt16 = 0
        
        var str = ""
        
        for i in 0 ... data!.count/2{
            str.append("\(reportData[i]) ")
        }
        print(str)
        
        var offsetBits = 1
        
        // heart rate
        
        // check if hr data 8 bit or 16 bit
        if ((reportData[0] & 0x01) == 0) {          // 2
            // Retrieve the BPM value for the Heart Rate Monitor
            bpm = UInt16(reportData[offsetBits]);
            offsetBits += 1
            print("8 bit")
        }
        else {
            // todo: test
            bpm = UInt16(reportData.advanced(by: offsetBits)[0])
                //UnsafePointer<UInt16>(reportData + offsetBits)[0]
            bpm = CFSwapInt16LittleToHost(bpm)
            offsetBits += 2
            print("16 bit")
        }
        
        // rr intervall
        
        // check if energy expenditure data (16 bit)
        if((reportData[0] & 0x08) != 0){
            offsetBits += 2
        }
        
        // check if RR data present (16 bit)
        if ((reportData[0] & 0x16) != 0) {          // 2
            
            rr = UInt16(reportData[offsetBits+1]) << 8
            rr =  rr | UInt16(reportData[offsetBits])
            
            
            //rr = UInt16(reportData.advanced(by: offsetBits)[0])
                //UnsafePointer<UInt16>(reportData + offsetBits)[0]
            rr = CFSwapInt16LittleToHost(rr)
        }else{
            print("no rr")
        }
        
        // Display the heart rate value to the UI if no error occurred
        if(error == nil) {   // 4
            self.heartRate = Int16(bpm)
            
            var rrNum = Double(rr)
            
            
            self.rrInterval = Int16(rrNum * (1000.0/1024.0))
        }
    }
    
    /**
    Instance method to get the manufacturer name of the device
    
    - parameter characteristic: characteristic with manufacturer information
    */
    fileprivate func getManufacturerName(_ characteristic: CBCharacteristic)
    {
        let manufacturerName = NSString(data: characteristic.value!, encoding:String.Encoding.utf8.rawValue)
        self.manufacturer = NSString(format:"Manufacturer: %@", manufacturerName!)
    }
    
    /**
    Instance method to get the body location of the device, executed every time
    
    - parameter characteristic: characteristics send by periphical delegate
    */
    func getBodyLocation(_ characteristic: CBCharacteristic )
    {
        // data as byte array
        let data = characteristic.value
        let bodyData = (data! as NSData).bytes.bindMemory(to: UInt8.self, capacity: data!.count)

        // has information about body location
        if (bodyData != nil) {
            let bodyLocation = bodyData[0]
            self.bodyData = NSString(format: "Body Location: %@", bodyLocation == 1 ? "Chest" : "Undefined")
        }
        // no information about body location
        else {
            self.bodyData = "Body Location: N/A"
        }
    }
    
}
