//
//  FontExt.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 23.1.23..
//

import Foundation
import SwiftUI

extension Font {
    static var body13: Font {
        return Font(UIFont.preferredFont(forTextStyle: .body, compatibleWith: .current).withSize(13))
    }
    
    static var body14: Font {
        return Font(UIFont.preferredFont(forTextStyle: .body, compatibleWith: .current).withSize(14))
    }
    
    static var body15: Font {
        return Font(UIFont.preferredFont(forTextStyle: .body, compatibleWith: .current).withSize(15))
    }
    
    static var body16: Font {
        return Font(UIFont.preferredFont(forTextStyle: .body, compatibleWith: .current).withSize(16))
    }
}
