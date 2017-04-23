//
//  PeriphalEvents.swift
//  HRVCore
//
//  Created by Katrin Hansel on 21/12/2015.
//  Copyright © 2015 Katrin Hansel. All rights reserved.
//

import Foundation

/**
 *  Handler for Periphical Events
 */
public protocol PeriphalEventHandler{
    
    func handleEvent(withData data : PeriphalChangedEventData)
    
}

/**
 *  Periphical Changed Event Data
 */
public struct PeriphalChangedEventData{
    /// The new connection status
    public var status : PeriphalStatus
    
    public var source: PeriphalSourceType
    
    /**
     Constructor
     
     - parameter status: the new status
     
     - returns: new object
     */
    public init(status : PeriphalStatus, source: PeriphalSourceType){
        self.status = status
        self.source = source
    }
}

/**
 Periphal states of Polar HR Strap
 
 - discovering:    discovering strap
 - isConnecting:   strap is getting connected
 - isConnected:    strap was connected
 - isDisconnected: strap is disconnected
  - failedConnecting: strap is disconnected
 */
public enum PeriphalStatus : String{
    case discovering
    case isConnecting
    case isConnected
    case isDisconnected
    case failedConnecting
}

public enum PeriphalSourceType : String{
    case polarStrap
    case microsoftBand
}
