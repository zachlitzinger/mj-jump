//
//  RandomFunction.swift
//  FlappyGame1
//
//  Created by Zach Litzinger on 5/22/16.
//  Copyright © 2016 Zach Litzinger. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat{
    
    public static func random() -> CGFloat{
        
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(min min : CGFloat, max : CGFloat) -> CGFloat{
        
        return CGFloat.random() * (max - min) + min
        
    }
}
