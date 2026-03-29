//
//  PredictionView.swift
//  HelloML
//
//  Created by Brian Surface on 3/28/26.
//

import Foundation
import SwiftUI

struct PredictionView: View {
    let probs: [Dictionary<String, Double>.Element]
    
    var body: some View {
        List(probs, id: \.key){(key, value) in
            HStack{
                Text(key)
                Spacer()
                Text("Confidence: \(NSNumber(value: value), formatter: NumberFormatter.percentage)")
            }
        }
    }
}
