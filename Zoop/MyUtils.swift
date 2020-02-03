//
//  MyUtils.swift
//  Zoop
//
//  Created by M Rezaur Rahman on 2020-01-29.
//  Copyright © 2020 M Rezaur Rahman. All rights reserved.
//

import Foundation
import CoreGraphics

func -  (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

//func -=  (inout left: CGPoint, right: CGPoint) { 
//    left = left - right
//}

extension CGFloat {
    static func random() -> CGFloat{
        return CGFloat(Float(arc4random())/Float(UInt32.max))
    }
    static func random(min: CGFloat, max: CGFloat)->CGFloat{
        assert(min<max)
        return CGFloat.random()*(max-min)+min
    }
}
