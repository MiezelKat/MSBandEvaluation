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

let POLARH7_HRM_DEVICE_INFO_SERVICE_UUID = "0x180A"
let POLARH7_HRM_HEART_RATE_SERVICE_UUID = "0x180D"
let POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID = "2A37"
let POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID = "2A38"
let POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID = "2A29"

/// Service for obtaining heart rate and rr values of a Polar Loop Chest Strap
public class PolarHRService : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate
{
    
    // MARK: Initialisation
    
    /// singleton instance
    public class var instance : PolarHRService{
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : PolarHRService? = nil
        }
        dispatch_once(&Static.onceToken){
            Static.instance = PolarHRService()
        }
        
        return Static.instance!
    }

    /**
    Initialises a new instance
    
    - returns: new instance
    */
    private override init() {
        
        let cm = CBCentralManager(delegate: nil, queue: nil)
        self.centralManager = cm;
        
        super.init()
        
        cm.delegate = self
    }
    
    // MARK: Attributs
    
    /// For the discovery of devices
    private var centralManager : CBCentralManager
    /// Remote peripheral device
    private var polarH7HRMPeripheral : CBPeripheral?

    /// Flag if the device is connected
    private(set) public var isConnected = false
    
    /// Device Info
    private(set) public var deviceInfo : NSString?
    
    /// Position of Sensor
    private(set) public var bodyData: NSString?;
    
    /// Manufacturer
    private(set) public var manufacturer: NSString?;
    
    private var polarH7DeviceData: NSString?;


    // MARK: Calculated Attributes for HR and RR

    var _heartRate: Int16?

    /// the current Heart Rate
    private(set) public var heartRate: Int16?{
        set(val){
            if(_heartRate != val){
                _heartRate = val
                hrEvent.raise(PolarEventData(type: PolarEventType.hrChanged, newValue: _heartRate))
            }
        }
        get{
            return _heartRate
        }
    }
    
    var _rrInterval: Int16?
    
    /// the current Heart Rate
    private(set) public var rrInterval: Int16?{
        set(val){
            if(_rrInterval != val){
                _rrInterval = val
                hrEvent.raise(PolarEventData(type: PolarEventType.rrChanged, newValue: _rrInterval))
            }
        }
        get{
            return _rrInterval
        }
    }
    
    // MARK: Private Events

    private let hrEvent = Event<PolarEventData>()
    
    private let periphalEvent = Event<PeriphalChangedEventData>()
    

    // MARK: Connect to Polar Strap

    /**
    Start connection process
    */
    public func connect(){
        //let services = [CBUUID(string: POLARH7_HRM_HEART_RATE_SERVICE_UUID), CBUUID(string: POLARH7_HRM_DEVICE_INFO_SERVICE_UUID)]
        //centralManager.scanForPeripheralsWithServices(services, options: nil)
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }

    // MARK: Public functions for event subscription

    /**
     Subscibe new event handler to receive HR events
     
     - parameter hrEventHandler: hr event handler
     */
    public func subcribeToHREvents(hrEventHandler : PolarEventHandler){
        hrEvent.addHandler( {e in hrEventHandler.handlePolarEvent(e)} )
    }

    /**
     Subscibe new event handler to receive changes in connection status

     - parameter pEventHandler: periphal event handler
     */
    public func subcribeToPeriphalEvents(pEventHandler : PeriphalEventHandler){
        periphalEvent.addHandler( {e in pEventHandler.handlePeriphalEvent(e)} )
    }

    //MARK: CBCentralManagerDelegate

    /**
    CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.

    - parameter central:           central manager
    - parameter peripheral:        discovered device
    - parameter advertisementData: advertisement data
    - parameter RSSI:              RSSI
    */
    public func centralManager(central: CBCentralManager,
        didDiscoverPeripheral peripheral: CBPeripheral,
         advertisementData: [String : AnyObject],
         RSSI: NSNumber)
    {
        let localName = advertisementData[CBAdvertisementDataLocalNameKey];
        if (localName?.length > 0) {
            NSLog("Found the heart rate monitor: \(localName)");
            centralManager.stopScan();
            polarH7HRMPeripheral = peripheral;
            polarH7HRMPeripheral!.delegate = self;
            centralManager.connectPeripheral(polarH7HRMPeripheral!, options:nil);
            periphalEvent.raise(PeriphalChangedEventData(status: PeriphalStatus.isConnecting, source: PeriphalSourceType.polarStrap) )
        }
    }

    /**
    method called whenever you have successfully connected to the BLE peripheral

    - parameter central:    central manager
    - parameter peripheral: the dicovered device
    */
    public func centralManager(central: CBCentralManager,
        didConnectPeripheral peripheral: CBPeripheral)
    {
        peripheral.delegate = self;
        peripheral.discoverServices(nil);
        self.isConnected = peripheral.state == CBPeripheralState.Connected
        periphalEvent.raise(PeriphalChangedEventData(status: PeriphalStatus.isConnected, source: PeriphalSourceType.polarStrap) )
        NSLog("connected: \(self.isConnected)");
    }


    /**
    method called whenever the device state changes.

    - parameter central: central manager
    */
    public func centralManagerDidUpdateState(central: CBCentralManager)
    {
        // Determine the state of the peripheral
        if (central.state == CBCentralManagerState.PoweredOff) {
            NSLog("CoreBluetooth BLE hardware is powered off");
        }
        else if (central.state  == CBCentralManagerState.PoweredOn) {
            NSLog("CoreBluetooth BLE hardware is powered on and ready");
            let services = [CBUUID(string: POLARH7_HRM_HEART_RATE_SERVICE_UUID), CBUUID(string: POLARH7_HRM_DEVICE_INFO_SERVICE_UUID)]
            centralManager.scanForPeripheralsWithServices(services, options: nil)
        }
        else if (central.state  == CBCentralManagerState.Unauthorized) {
            NSLog("CoreBluetooth BLE state is unauthorized");
        }
        else if (central.state  == CBCentralManagerState.Unknown) {
            NSLog("CoreBluetooth BLE state is unknown");
        }
        else if (central.state  == CBCentralManagerState.Unsupported) {
            NSLog("CoreBluetooth BLE hardware is unsupported on this platform");
        }
    }

    //MARK: CBPeripheralDelegate

    /**
    CBPeripheralDelegate - Invoked when you discover the peripheral's available services.

    - parameter peripheral: peripheral with services
    - parameter error:      error
    */
    public func peripheral(peripheral: CBPeripheral,
        didDiscoverServices error: NSError?)
    {
        for service in peripheral.services! {
            NSLog("Discovered service: \(service.UUID)");
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }

    /**
    Invoked when you discover the characteristics of a specified service.

    - parameter peripheral: peripheral
    - parameter service:    service, which characteristics have been discovered
    - parameter error:      error
    */
    public func peripheral(peripheral: CBPeripheral,
         didDiscoverCharacteristicsForService service: CBService,
            error: NSError?)
    {
        if (service.UUID.isEqual(CBUUID(string: POLARH7_HRM_HEART_RATE_SERVICE_UUID)))  {  // 1
            for aChar in service.characteristics!
            {
                // Request heart rate notifications
                if (aChar.UUID.isEqual(CBUUID(string: POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID))) { // 2
                    self.polarH7HRMPeripheral!.setNotifyValue(true, forCharacteristic:aChar)
                    NSLog("Found heart rate measurement characteristic")
                }
                    // Request body sensor location
                else if (aChar.UUID.isEqual(CBUUID(string:POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID))) { // 3
                    self.polarH7HRMPeripheral!.readValueForCharacteristic(aChar)
                    NSLog("Found body sensor location characteristic")
                }
            }
        }
        // Retrieve Device Information Services for the Manufacturer Name
        if (service.UUID.isEqual(CBUUID(string: POLARH7_HRM_DEVICE_INFO_SERVICE_UUID)))  { // 4
            for aChar in service.characteristics!
            {
                if (aChar.UUID.isEqual(CBUUID(string:POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID))) {
                    self.polarH7HRMPeripheral!.readValueForCharacteristic(aChar)
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
    public func peripheral(peripheral: CBPeripheral,
         didUpdateValueForCharacteristic characteristic: CBCharacteristic,
         error: NSError?)    {
            // Updated value for heart rate measurement received
            if (characteristic.UUID.isEqual(CBUUID(string: POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID))) { // 1
                // Get the Heart Rate Monitor BPM
                getHeartBPMData(characteristic, error:error)
            }
            // Retrieve the characteristic value for manufacturer name received
            if (characteristic.UUID.isEqual(CBUUID(string: POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID))) {  // 2
                getManufacturerName(characteristic)
            }
                // Retrieve the characteristic value for the body sensor location received
            else if (characteristic.UUID.isEqual(CBUUID(string: POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID))) {  // 3
                getBodyLocation(characteristic)
            }

            // Add your constructed device information to your UITextView
            if(bodyData != nil && manufacturer != nil){
                self.deviceInfo = NSString(format: "%@\n%@\n%@\n", self.isConnected, self.bodyData!, self.manufacturer!)  // 4
            }
    }
    
    //MARK: Helpers
    
    /**
    Function to extract the HR data from a characteristic
    check: https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.heart_rate_measurement.xml
    - parameter characteristic: characteristic with HR data
    - parameter error:          error
    */
    private func getHeartBPMData(characteristic: CBCharacteristic, error: NSError?)
    {
        // Get the Heart Rate Monitor BPM
        let data = characteristic.value
        let reportData = UnsafePointer<UInt8>(data!.bytes)

        var bpm : UInt16 = 0
        var rr : UInt16 = 0
        
        var str = ""
        
        for i in 0 ... data!.length/2{
            str.appendContentsOf("\(reportData[i]) ")
        }
        
        var offsetBits = 1
        
        // check if hr data 8 bit or 16 bit
        if ((reportData[0] & 0x01) == 0) {          // 2
            // Retrieve the BPM value for the Heart Rate Monitor
            bpm = UInt16(reportData[offsetBits]);
            offsetBits += 1
        }
        else {
            bpm = UnsafePointer<UInt16>(reportData + offsetBits)[0]
            bpm = CFSwapInt16LittleToHost(bpm)
            offsetBits += 2
        }
        
        // check if energy expenditure data (16 bit)
        if((reportData[0] & 0x08) != 0){
            offsetBits += 2
        }
        
        // check if RR data present (16 bit)
        if ((reportData[0] & 0x16) != 0) {          // 2
            rr = UnsafePointer<UInt16>(reportData + offsetBits)[0]
            rr = CFSwapInt16LittleToHost(rr)
        }
        
        // Display the heart rate value to the UI if no error occurred
        if(error == nil) {   // 4
            self.heartRate = Int16(bpm)
            self.rrInterval = Int16(rr)
        }
    }
    
    /**
    Instance method to get the manufacturer name of the device
    
    - parameter characteristic: characteristic with manufacturer information
    */
    private func getManufacturerName(characteristic: CBCharacteristic)
    {
        let manufacturerName = NSString(data: characteristic.value!, encoding:NSUTF8StringEncoding)
        self.manufacturer = NSString(format:"Manufacturer: %@", manufacturerName!)
    }
    
    /**
    Instance method to get the body location of the device, executed every time
    
    - parameter characteristic: characteristics send by periphical delegate
    */
    func getBodyLocation(characteristic: CBCharacteristic )
    {
        // data as byte array
        let data = characteristic.value
        let bodyData = UnsafePointer<UInt8>(data!.bytes)

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