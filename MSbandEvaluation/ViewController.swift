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
                    connectPolarBtn.enabled = true
                    polarTableRows.map({(e) -> Void in e.hidden = false })
                }else{
                    connectPolarBtn.enabled = false
                    polarTableRows.map({(e) -> Void in e.hidden = true })
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
                    connectMSBandBtn.enabled = true
                    msbTableRows.map({(e) -> Void in e.hidden = false })
                }else{
                    connectMSBandBtn.enabled = false
                    msbTableRows.map({(e) -> Void in e.hidden = true })
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
    
    private func checkRecordDataValid(){
        var recordingCheck = false
        
        if(!polarConnected && !msbConnected){
            recordingCheck = false
        }else{
            
            let polarCheck = polarEnabled == polarConnected
            let msbCheck = msbConnected == msbEnabled
            
            recordingCheck = polarCheck && msbCheck
        }
        
        if(recordingCheck){
            startRecordingBtn.enabled = true
            recordDataTextB.textColor = UIColor.redColor()
        }else{
            startRecordingBtn.enabled = false
            recordDataTextB.textColor = UIColor.grayColor()
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
                    
                    startRecordingBtn.enabled = false
                    stopRecordingBtn.enabled = true
                    
                    recordingTableRows.map({(e) -> Void in e.hidden = false })
                }else{
//                    connectMSBandBtn.enabled = true
//                    connectPolarBtn.enabled = true
                    
                    startRecordingBtn.enabled = true
                    stopRecordingBtn.enabled = false
                    
                    recordingTableRows.map({(e) -> Void in e.hidden = true })
                }
            }
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        MSBService.instance.subcribeToPeriphalEvents(self)
        MSBService.instance.subcribeToMSBEvents(self)
        
        PolarHRService.instance.subcribeToHREvents(self)
        PolarHRService.instance.subcribeToPeriphalEvents(self)
        
        startRecordingBtn.enabled = false
        
        recordDataTextB.textColor = UIColor.grayColor()
        
        stopRecordingBtn.enabled = false
        
        recordingTableRows.map({(e) -> Void in e.hidden = true })
        
        // Do any additional setup after loading the view, typically from a nib.
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ViewController.addTapped))
    }
    
    func addTapped(){
        let secondViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ShareViewController") as! ShareViewController
        
        self.navigationController!.pushViewController(secondViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func polarEnabledValueChanged(sender: AnyObject) {
        let enabled = (sender as! UISwitch).on
        polarEnabled = enabled
        
    }
    
    
    @IBAction func msbEnabledValueChanged(sender: AnyObject) {
        let enabled = (sender as! UISwitch).on
        msbEnabled = enabled
    }
    

    @IBAction func connectPolarBtnEvent(sender: AnyObject) {
        if(!polarConnected){
            polarEnableSwitch.enabled = false
            connectPolarBtn.enabled = false
            PolarHRService.instance.connect()
        }
    }

    @IBAction func connectMSBandBtnEvent(sender: AnyObject) {
        if(!msbConnected){
            msbEnableSwitch.enabled = false
            connectMSBandBtn.enabled = false
            MSBService.instance.connect()
        }
    }
    
    
    
    @IBAction func startRecordingBtnEvent(sender: AnyObject) {
        recordData = true
        if !timer.valid {
            let aSelector : Selector = "updateTime"
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
    }
    
    @IBAction func stopRecodingBtnEvent(sender: AnyObject) {
        recordData = false
        DataStorage.sharedInstance.writeToDisk()
        DataStorage.sharedInstance.reset()
        timer.invalidate()
    }
    
    var startTime = NSTimeInterval()
    var timer = NSTimer()
    
    func updateTime() {
        
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= NSTimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        
        //let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        //let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        
        recordingTimeTextB.text = "\(strMinutes):\(strSeconds)" //:\(strFraction)"
        
    }

    @IBAction func placeMarkerBtnEvent(sender: AnyObject) {
        DataStorage.sharedInstance.appendMarkerTimestamp()
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    
    //MARK: PeriphalEventHandler
    
    func handlePeriphalEvent(event : PeriphalChangedEventData){
        
        if(event.source == PeriphalSourceType.polarStrap){
            
            switch event.status{
            case .discovering, .isConnecting:
                print("polar discovering")
                polarConnectionTextB.textColor = UIColor.orangeColor()
                polarConnected = false
            case .isConnected:
                print("polar connected")
                polarConnectionTextB.textColor = UIColor.greenColor()
                polarConnected = true
            case .failedConnecting, .isDisconnected:
                print("polar disconnected")
                polarConnectionTextB.textColor = UIColor.redColor()
                polarConnected = false
            }
            
        }else if (event.source == PeriphalSourceType.microsoftBand){
            
            switch event.status{
            case .discovering, .isConnecting:
                print("msb discovering")
                msbConnectionTextB.textColor = UIColor.orangeColor()
                msbConnected = false
            case .isConnected:
                print("msb connected")
                msbConnectionTextB.textColor = UIColor.greenColor()
                msbConnected = true
            case .failedConnecting, .isDisconnected:
                print("msb disconnected")
                msbConnectionTextB.textColor = UIColor.redColor()
                msbConnected = false
            }
            
        }
    }
    
    func handleMSBEvent(event: MSBEventData) {
        
        switch event.type{
        case .hrChanged:
            msbHROutputTextB.text = event.newValue?.description
        case .rrChanged:
            msbRROutputTextB.text = event.newValue?.description
        case .gsrChanged:
            msbGSROutputTextB.text = event.newValue?.description
        }
        
        if(recordData){
            DataStorage.sharedInstance.appendMSB(event)
        }
        
    }
    
    func handlePolarEvent(event: PolarEventData) {
        switch event.type{
        case .hrChanged:
            polarHROutputTextB.text = event.newValue?.description
        case .rrChanged:
            polarRROutputTextB.text = event.newValue?.description
        }
        
        if(recordData){
            DataStorage.sharedInstance.appendPolar(event)
        }
    }
}

