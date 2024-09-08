//
//  Task.swift
//  TaskManager
//
//  Created by Jonni Akesson on 2024-09-08.
//

import SwiftUI
import SwiftData

@Model
class Task: Identifiable {
    var id: UUID
    var taskTitle: String
    var creationDate: Date
    var isCompleted: Bool
    var tint: String
    
    init(id: UUID = .init(), taskTitle: String, creationDate: Date = .init(), isCompleted: Bool = false, tint: String) {
        self.id = id
        self.taskTitle = taskTitle
        self.creationDate = creationDate
        self.isCompleted = isCompleted
        self.tint = tint
    }
    
    var tintColor: Color {
        switch tint {
        case "taskColor1": return .taskColor1
        case "taskColor2": return .taskColor2
        case "taskColor3": return .taskColor3
        case "taskColor4": return .taskColor4
        case "taskColor5": return .taskColor5
        case "taskColor6": return .taskColor6
        default:
            return .taskColor1
        }
    }
}

extension Task {
    static func createMockData(modelContext: ModelContext) {
        deleteAllTasks(modelContext: modelContext)
        
        do {
            for i in 1...6 {
                let task = Task(taskTitle: "Task \(i)", creationDate: .updateHour(i), tint: "taskColor\(i)")
                modelContext.insert(task)
            }
            
            try modelContext.save()
            print("Successfully created new mock data tasks")
        } catch {
            print("Failed to create mock data: \(error.localizedDescription)")
        }
    }
    
    static func deleteAllTasks(modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Task>()
        
        do {
            let tasks = try modelContext.fetch(fetchDescriptor)
            
            for task in tasks {
                modelContext.delete(task)
            }
            
            try modelContext.save()
            print("Successfully deleted all tasks")
        } catch {
            print("Failed to delete all tasks: \(error.localizedDescription)")
        }
    }
    
    static func deleteTask(modelContext: ModelContext, task: Task) {
        do {
            modelContext.delete(task)
            
            try modelContext.save()
            print("Successfully deleted all tasks")
        } catch {
            print("Failed to delete all tasks: \(error.localizedDescription)")
        }
    }
}
