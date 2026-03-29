//
//  NumberFormatter+Extension.swift
//  HelloML
//
//  Created by Brian Surface on 3/28/26.
//

import Foundation

extension NumberFormatter {
    static var percentage: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 2
        
        return formatter
    }
}
