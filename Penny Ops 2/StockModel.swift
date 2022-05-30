//
//  StockModel.swift
//  Penny Ops 2
//
//  Created by Joe Satow on 3/14/20.
//  Copyright © 2020 Joe Satow. All rights reserved.
//

import UIKit

class StockModel: NSObject {
    //properties of a stock
    
    var name: String?
    var price: String?
    
    
    
    //empty constructor
    
    override init()
    {
        
    }
    
    //construct with @name and @price parameters
    
    init(name: String, price: String) {
        
        self.name = name
        self.price = price
        
        
    }
    
    
    //prints a stock's name and price
    
    override var description: String {
        return "Name: \(String(describing: name)), Address: \(String(describing: price))"
        
    }
    
}
