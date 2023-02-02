//
//  ColorExt.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 2.2.23..
//

import SwiftUI

extension Color {
    
    static var systemBackgroundColor: Color {
        return Color(NSColor.windowBackgroundColor)
    }
    
    static var secondaryBackgroundColor: Color {
        return Color(NSColor.controlBackgroundColor)
    }
    
    static var rose_pastel: Color {
        return Color("RosePastel")
    }
    
    static var blue_pastel: Color {
        return Color("BluePastel")
    }
    
    static var green_pastel: Color {
        return Color("GreenPastel")
    }
    
    static var lightLinear1: Color {
        return Color("BG_Light_1")
    }
    static var lightLinear2: Color {
        return Color("BG_Light_2")
    }
    
    static var darkLinear1: Color {
        return Color("BG_Dark_1")
    }
    static var darkLinear2: Color {
        return Color("BG_dark_2")
    }
}

