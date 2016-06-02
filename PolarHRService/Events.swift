//
//  HRVEvents.swift
//  HRVCore
//
//  Created by Katrin Hansel on 21/12/2015.
//  Copyright © 2015 Katrin Hansel. All rights reserved.
//

import Foundation

/// Class for generic events
public class Event<T> {
    
    public typealias EventHandler = T -> ()
    
    private var eventHandlers = [EventHandler]()
    
    public init(){}
    
    /**
      Add an eventhandler
     
     - parameter handler: method pointer to handler
     */
    public func addHandler(handler: EventHandler) {
        eventHandlers.append(handler)
    }
    
    /**
     raise new event with data
     
     - parameter data: event data
     */
    public func raise(data: T) {
        for handler in eventHandlers {
            handler(data)
        }
    }
}