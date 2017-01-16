//
//  SmallUISwitch.swift
//  TestProject
//
//  Created by Sudhansu Singh on 8/1/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
class SmallUISwitch: AnimatedSwitch{
    
    override func awakeFromNib() {
        self.transform = CGAffineTransformMakeScale(0.75, 0.75)
    }
}