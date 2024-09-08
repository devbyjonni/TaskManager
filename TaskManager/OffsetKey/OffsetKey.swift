//
//  OffsetKey.swift
//  TaskManager
//
//  Created by Jonni Akesson on 2024-09-08.
//

import SwiftUI

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
