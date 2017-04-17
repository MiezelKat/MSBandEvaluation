//
//  ViewController.swift
//  MSbandEvaluation
//
//  Created by Katrin Hansel on 06/04/2016.
//  Copyright © 2016 Katrin Hansel. All rights reserved.
//

import UIKit
import PolarHRService
import MSBandSensorService
import SensorEvaluationShared
import AudioToolbox

class ViewController: UITableViewController, PeriphalEventHandler, MSBEventHandler, PolarEventHandler  {

    @IBOutlet var polarTableRows: [UIView]!
    
    @IBOutlet var msbTableRows: [UITableViewCell]!

    @IBOutlet var recordingTableRows: [UITableViewCell]!
    
    @IBOutlet weak var connectPolarBtn: UIButton!
    
    @IBOutlet var connectMSBandBtn: UIButton!
    
    @IBOutlet weak var startRecordingBtn: UIButton!
    
    @IBOutlet weak var stopRecordingBtn: UIButton!
    
    @IBOutlet weak var polarConnectionTextB: UILabel!
    
    @IBOutlet weak var msbConnectionTextB: UILabel!
    
    @IBOutlet weak var recordDataTextB: UILabel!
    
    @IBOutlet weak var polarEnableSwitch: UISwitch!
    
    @IBOutlet weak var msbEnableSwitch: UISwitch!
    
    @IBOutlet weak var polarHROutputTextB: UILabel!
    
    @IBOutlet weak var polarRROutputTextB: UILabel!
    
    
    @IBOutlet weak var msbHROutputTextB: UILabel!
    
    @IBOutlet weak var msbRROutputTextB: UILabel!
    
    @IBOutlet weak var msbGSROutputTextB: UILabel!
    
    
    @IBOutlet weak var recordingTimeTextB: UILabel!
    
    var _polarEnabled = true
    var polarEnabled : Bool{
        get{
            return _polarEnabled
        }
        set(newVal){
            if(!polarConnected && newVal != _polarEnabled){
                _polarEnabled = newVal
                
                if(_polarEnabled){
                    connectPolarBtn.isEnabled = true
                    polarTableRows.map({(e) -> Void in e.isHidden = false })
                }else{
                    connectPolarBtn.isEnabled = false
                    polarTableRows.map({(e) -> Void in e.isHidden = true })
                }
                
                checkRecordDataValid()
            }
        }
    }
    
    var _msbEnabled = true
    var msbEnabled : Bool{
        get{
            return _msbConnected
        }
        set(newVal){
            if(!msbConnected && newVal != _msbEnabled){
                _msbEnabled = newVal
                
                if(_msbEnabled){
                    connectMSBandBtn.isEnabled = true
                    msbTableRows.map({(e) -> Void in e.isHidden = false })
                }else{
                    connectMSBandBtn.isEnabled = false
                    msbTableRows.map({(e) -> Void in e.isHidden = true })
                }
                
                checkRecordDataValid()
            }
        }
    }

    
    var _polarConnected = false
    var polarConnected : Bool{
        get{
            return _polarConnected
        }
        set(newVal){
            if(newVal != _polarConnected){
                _polarConnected = newVal
//                if(_polarConnected){
//                    connectPolarBtn.titleLabel?.text = "Disconnect Polar Strap"
//                }else{
//                    connectPolarBtn.titleLabel?.text = "Connect Polar Strap"
//                }
                
                checkRecordDataValid()
            }
        }
    }
    
    var _msbConnected = false
    var msbConnected : Bool{
        get{
            return _msbConnected
        }
        set(newVal){
            if(newVal != _msbConnected){
                _msbConnected = newVal
//                if(_msbConnected){
//                    connectMSBandBtn.titleLabel?.text = "Disconnect MS Band"
//                }else{
//                    connectMSBandBtn.titleLabel?.text = "Connect MS Band"
//                }
                
                checkRecordDataValid()
            }
        }
    }
    
    fileprivate func checkRecordDataValid(){
        var recordingCheck = false
        
        if(!polarConnected && !msbConnected){
            recordingCheck = false
        }else{
            
            let polarCheck = polarEnabled == polarConnected
            let msbCheck = msbConnected == msbEnabled
            
            recordingCheck = polarCheck && msbCheck
        }
        
        if(recordingCheck){
            startRecordingBtn.isEnabled = true
            recordDataTextB.textColor = UIColor.red
        }else{
            startRecordingBtn.isEnabled = false
            recordDataTextB.textColor = UIColor.gray
        }
    }
    
    var _recordData = false
    var recordData : Bool{
        get{
            return _recordData
        }
        set(newVal){
            if(newVal != _recordData){
                _recordData = newVal
                if(_recordData){
//                    connectMSBandBtn.enabled = false
//                    connectPolarBtn.enabled = false
                    
                    startRecordingBtn.isEnabled = false
                    stopRecordingBtn.isEnabled = true
                    
                    recordingTableRows.map({(e) -> Void in e.isHidden = false })
                }else{
//                    connectMSBandBtn.enabled = true
//                    connectPolarBtn.enabled = true
                    
                    startRecordingBtn.isEnabled = true
                    stopRecordingBtn.isEnabled = false
                    
                    recordingTableRows.map({(e) -> Void in e.isHidden = true })
                }
            }
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        MSBService.instance.subscribe(msbEventHandler: self)
        MSBService.instance.subscribe(periphalEventHandler: self)
        
        PolarHRService.instance.subcribeToHREvents(self)
        PolarHRService.instance.subcribeToPeriphalEvents(self)
        
        startRecordingBtn.isEnabled = false
        
        recordDataTextB.textColor = UIColor.gray
        
        stopRecordingBtn.isEnabled = false
        
        recordingTableRows.map({(e) -> Void in e.isHidden = true })
        
        // Do any additional setup after loading the view, typically from a nib.
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ViewController.addTapped))
    }
    
    func addTapped(){
        let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
        
        self.navigationController!.pushViewController(secondViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func polarEnabledValueChanged(_ sender: AnyObject) {
        let enabled = (sender as! UISwitch).isOn
        polarEnabled = enabled
        
    }
    
    
    @IBAction func msbEnabledValueChanged(_ sender: AnyObject) {
        let enabled = (sender as! UISwitch).isOn
        msbEnabled = enabled
    }
    

    @IBAction func connectPolarBtnEvent(_ sender: AnyObject) {
        if(!polarConnected){
            polarEnableSwitch.isEnabled = false
            connectPolarBtn.isEnabled = false
            PolarHRService.instance.connect()
        }
    }

    @IBAction func connectMSBandBtnEvent(_ sender: AnyObject) {
        if(!msbConnected){
            msbEnableSwitch.isEnabled = false
            connectMSBandBtn.isEnabled = false
            MSBService.instance.connect()
        }
    }
    
    
    
    @IBAction func startRecordingBtnEvent(_ sender: AnyObject) {
        recordData = true
        if !timer.isValid {
            let aSelector : Selector = #selector(ViewController.updateTime)
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = Date.timeIntervalSinceReferenceDate
        }
    }
    
    @IBAction func stopRecodingBtnEvent(_ sender: AnyObject) {
        recordData = false
        DataStorage.sharedInstance.writeToDisk()
        DataStorage.sharedInstance.reset()
        timer.invalidate()
    }
    
    var startTime = TimeInterval()
    var timer = Timer()
    
    func updateTime() {
        
        let currentTime = Date.timeIntervalSinceReferenceDate
        
        //Find the difference between current time and start time.
        
        var elapsedTime: TimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= TimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        
        //let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        //let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        
        recordingTimeTextB.text = "\(strMinutes):\(strSeconds)" //:\(strFraction)"
        
    }

    @IBAction func placeMarkerBtnEvent(_ sender: AnyObject) {
        DataStorage.sharedInstance.appendMarkerTimestamp()
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    
    //MARK: PeriphalEventHandler
    
     public func handleEvent(withData data: PeriphalChangedEventData){
        
        if(data.source == PeriphalSourceType.polarStrap){
            
            switch data.status{
            case .discovering, .isConnecting:
                print("polar discovering")
                polarConnectionTextB.textColor = UIColor.orange
                polarConnected = false
            case .isConnected:
                print("polar connected")
                polarConnectionTextB.textColor = UIColor.green
                polarConnected = true
            case .failedConnecting, .isDisconnected:
                print("polar disconnected")
                polarConnectionTextB.textColor = UIColor.red
                polarConnected = false
            }
            
        }else if (data.source == PeriphalSourceType.microsoftBand){
            
            switch data.status{
            case .discovering, .isConnecting:
                print("msb discovering")
                msbConnectionTextB.textColor = UIColor.orange
                msbConnected = false
            case .isConnected:
                print("msb connected")
                msbConnectionTextB.textColor = UIColor.green
                msbConnected = true
            case .failedConnecting, .isDisconnected:
                print("msb disconnected")
                msbConnectionTextB.textColor = UIColor.red
                msbConnected = false
            }
            
        }
    }
    
    public func handleEvent(withData data: MSBEventData) {
        
        switch data.sensorDataType{
        case .hrChanged:
            msbHROutputTextB.text = data.printData()
        case .rrChanged:
            msbRROutputTextB.text = data.printData()
        case .gsrChanged:
            msbGSROutputTextB.text = data.printData()
        default:print("")
        }
        
        if(recordData){
            DataStorage.sharedInstance.append(data: data)
        }
        
    }
    
    public func handleEvent(withData data: PolarEventData) {
        switch data.sensorDataType{
        case .hrChanged:
            polarHROutputTextB.text = data.newValue?.description
        case .rrChanged:
            polarRROutputTextB.text = data.newValue?.description
        default:
            print("invalid polar data: \(data.sensorDataType)")
        }
        
        if(recordData){
            DataStorage.sharedInstance.append(data: data)
        }
    }
}

