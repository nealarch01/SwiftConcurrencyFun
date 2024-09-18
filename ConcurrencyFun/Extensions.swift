//
//  Extensions.swift
//  ConcurrencyFun
//
//  Created by Neal Archival on 9/17/24.
//

import Foundation

extension Int {
    func formatWithCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self)) ?? "NaN"
    }
}
