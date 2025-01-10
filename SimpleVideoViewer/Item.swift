//
//  Item.swift
//  SimpleVideoViewer
//
//  Created by aleksey.kazakov on 10.01.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
