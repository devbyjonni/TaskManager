//
//  TaskController.swift
//  TaskManager
//
//  Created by Jonni Akesson on 2024-09-08.
//

import Foundation
import SwiftData

@MainActor
class TaskController {
    static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Task.self, configurations: config)
            
            // Insert some sample data for preview
            for i in 1...6 {
                let task = Task(taskTitle: "Preview Task \(i)", creationDate: Date(), tint: "taskColor\(i)")
                container.mainContext.insert(task)
            }
            
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
}
