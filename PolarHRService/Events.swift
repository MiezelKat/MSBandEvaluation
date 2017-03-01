//
//  HRVEvents.swift
//  HRVCore
//
//  Created by Katrin Hansel on 21/12/2015.
//  Copyright © 2015 Katrin Hansel. All rights reserved.
//

import Foundation

/// Class for generic events
open class Event<T> {
    
    public typealias EventHandler = (T) -> ()
    
    fileprivate var eventHandlers = [EventHandler]()
    
    public init(){}
        
    /// Add an eventhandler
    ///
    /// - Parameter handler: method pointer to handler
    open func add(handler: @escaping EventHandler) {
        eventHandlers.append(handler)
    }
    

    /// raise new event with data
    ///
    /// - Parameter data: event data
    open func raise(withData data: T) {
        for handler in eventHandlers {
            handler(data)
        }
    }
}
