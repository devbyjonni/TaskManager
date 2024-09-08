//
//  Bool+Extensions.swift
//  TaskManager
//
//  Created by Jonni Akesson on 2024-09-08.
//

import Foundation

// Used for sorting completeded task (SortDescriptor).
extension Bool: Comparable {
    public static func <(lhs: Self, rhs: Self) -> Bool {
        // The only true inequality is false < true
        !lhs && rhs
    }
}
