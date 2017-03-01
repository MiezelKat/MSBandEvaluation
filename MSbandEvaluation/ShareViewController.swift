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

open class ShareViewController : UIViewController, UIPickerViewDelegate, MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var filePicker: UIPickerView!
    
    var fileStrings : [String] = [String]()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        //fileStrings = DataStorage.sharedInstance.getDataSamplesList()
        
        //filePicker.delegate = self
    }
    
    @IBAction func sendEmail(_ sender: UIButton) {
        //Check to see the device can send email.
        if( MFMailComposeViewController.canSendMail() ) {
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("Have you heard a swift?")
            mailComposer.setMessageBody("This is what they sound like.", isHTML: false)
            
            if let filePath = Bundle.main.path(forResource: "swifts", ofType: "wav") {
                
                if let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                    mailComposer.addAttachmentData(fileData, mimeType: "audio/wav", fileName: "swifts")
                }
            }
            self.present(mailComposer, animated: true, completion: nil)
        }
    }
    
    //func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError) {
    //    self.dismissViewControllerAnimated(true, completion: nil)
    //}
    
    open func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func shareBtnPressed(_ sender: AnyObject) {
        
    }

    open func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }

    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fileStrings.count
    }

    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fileStrings[row]
    }

    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //fileStrings.text = pickOption[row]
    }
    
}
