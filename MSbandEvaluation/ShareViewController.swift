//
//  ShareViewController.swift
//  MSbandEvaluation
//
//  Created by Katrin Hansel on 20/04/2016.
//  Copyright © 2016 Katrin Hansel. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

public class ShareViewController : UIViewController, UIPickerViewDelegate, MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var filePicker: UIPickerView!
    
    var fileStrings : [String] = [String]()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //fileStrings = DataStorage.sharedInstance.getDataSamplesList()
        
        //filePicker.delegate = self
    }
    
    @IBAction func sendEmail(sender: UIButton) {
        //Check to see the device can send email.
        if( MFMailComposeViewController.canSendMail() ) {
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("Have you heard a swift?")
            mailComposer.setMessageBody("This is what they sound like.", isHTML: false)
            
            if let filePath = NSBundle.mainBundle().pathForResource("swifts", ofType: "wav") {
                
                if let fileData = NSData(contentsOfFile: filePath) {
                    mailComposer.addAttachmentData(fileData, mimeType: "audio/wav", fileName: "swifts")
                }
            }
            self.presentViewController(mailComposer, animated: true, completion: nil)
        }
    }
    
    //func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError) {
    //    self.dismissViewControllerAnimated(true, completion: nil)
    //}
    
    public func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func shareBtnPressed(sender: AnyObject) {
        
    }

    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fileStrings.count
    }

    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fileStrings[row]
    }

    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //fileStrings.text = pickOption[row]
    }
    
}