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

class ViewController: UITableViewController, PeriphalEventHandler, MSBEventHandler, PolarEventHandler  {

    
    
    @IBOutlet weak var connectPolarBtn: UIButton!
    
    @IBOutlet var connectMSBandBtn: UIButton!
    
    @IBOutlet weak var recordDataBtn: UIButton!
    
    @IBOutlet weak var polarConnectionTextB: UILabel!
    
    @IBOutlet weak var msbConnectionTextB: UILabel!
    
    @IBOutlet weak var recordDataTextB: UILabel!
    
    
    @IBOutlet weak var polarHROutputTextB: UILabel!
    
    @IBOutlet weak var polarRROutputTextB: UILabel!
    
    
    @IBOutlet weak var msbHROutputTextB: UILabel!
    
    @IBOutlet weak var msbRROutputTextB: UILabel!
    
    @IBOutlet weak var msbGSROutputTextB: UILabel!
    
    
    @IBOutlet weak var recordingTimeTextB: UILabel!
    
    
    var _polarConnected = false
    var polarConnected : Bool{
        get{
            return _polarConnected
        }
        set(newVal){
            if(newVal != _polarConnected){
                _polarConnected = newVal
                if(_polarConnected){
                    connectPolarBtn.titleLabel?.text = "Disconnect Polar Strap"
                }else{
                    connectPolarBtn.titleLabel?.text = "Connect Polar Strap"
                }
                
                if(_msbConnected && _polarConnected){
                    recordDataBtn.enabled = true
                }else{
                    recordDataBtn.enabled = false
                }
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
                if(_msbConnected){
                    connectMSBandBtn.titleLabel?.text = "Disconnect MS Band"
                }else{
                    connectMSBandBtn.titleLabel?.text = "Connect MS Band"
                }
                
                if(_msbConnected && _polarConnected){
                    recordDataBtn.enabled = true
                }else{
                    recordDataBtn.enabled = false
                }
            }
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
                    recordDataBtn.titleLabel?.text = "Stop Recording"
                    connectMSBandBtn.enabled = false
                    connectPolarBtn.enabled = false
                }else{
                    recordDataBtn.titleLabel?.text = "Start Recording"
                    connectMSBandBtn.enabled = true
                    connectPolarBtn.enabled = true
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
        
        recordDataBtn.enabled = false

        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ViewController.addTapped))
    }
    
    func addTapped(){
        let secondViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ShareViewController") as! ShareViewController
        
        self.navigationController!.pushViewController(secondViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func connectPolarBtnEvent(sender: AnyObject) {
        if(!polarConnected){
            PolarHRService.instance.connect()
        }else{
            
        }
    }

    @IBAction func connectMSBandBtnEvent(sender: AnyObject) {
        if(!msbConnected){
            MSBService.instance.connect()
        }else{
            
        }
    }
    
    @IBAction func recordDataBtnEvent(sender: AnyObject) {
        
        if(!recordData){
            recordData = true
        }
        else{
            recordData = false
            DataStorage.sharedInstance.writeToDisk()
            DataStorage.sharedInstance.reset()
        }
        
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

