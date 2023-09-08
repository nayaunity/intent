//
//  Color.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/7/23.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        // Remove any leading "#" or "0x" if present
        var cleanedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedHex.hasPrefix("#") {
            cleanedHex.removeFirst()
        } else if cleanedHex.hasPrefix("0x") {
            cleanedHex = String(cleanedHex.dropFirst(2))
        }
        
        // Check if the cleanedHex string has a valid length
        guard cleanedHex.count == 6 else {
            self.init(red: 0, green: 0, blue: 0)
            return
        }
        
        // Parse the Hex values (2 characters each) for red, green, and blue
        var rgb: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
