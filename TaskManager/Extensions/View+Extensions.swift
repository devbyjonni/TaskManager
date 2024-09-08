//
//  View+Extensions.swift
//  TaskManager
//
//  Created by Jonni Akesson on 2024-09-08.
//

import SwiftUI

extension View {
    @ViewBuilder
    func horizontalAlignment(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func verticalAlignment(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
}
