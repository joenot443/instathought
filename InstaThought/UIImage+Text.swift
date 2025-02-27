//
//  UIImage+Text.swift
//  InstaThought
//
//  Created by Joe Crozier on 9/11/24.
//

import Foundation

import UIKit

extension UIImage {
    func averageBrightness() -> CGFloat {
        guard let cgImage = self.cgImage else { return 1.0 } // If no CGImage, assume white (bright)

        let width = 1
        let height = 1
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixelData = [UInt8](repeating: 0, count: 4)
        let context = CGContext(data: &pixelData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width * 4,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Get the RGB values
        let red = CGFloat(pixelData[0]) / 255.0
        let green = CGFloat(pixelData[1]) / 255.0
        let blue = CGFloat(pixelData[2]) / 255.0

        // Calculate brightness using the formula for luminance
        let brightness = (0.299 * red + 0.587 * green + 0.114 * blue)

        return brightness
    }

    var shouldUseWhiteText: Bool {
        // Use white text if the image is dark
        return averageBrightness() < 0.5
    }
}
