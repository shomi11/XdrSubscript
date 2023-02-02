//
//  ImageExt.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 2.2.23..
//

import SwiftUI


public extension UIImage {
    
    /// Resizes the image by keeping the aspect ratio
    func resize(height: CGFloat) -> UIImage {
        let scale = height / self.size.height
        let width = self.size.width * scale
        let newSize = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
