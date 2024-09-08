//
//  TasksView.swift
//  TaskManager
//
//  Created by Jonni Akesson on 2024-09-08.
//

import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var currentDate: Date
    @Query private var tasks: [Task]
    @Binding private var taskToEdit: Task?
    
    init(currentDate: Binding<Date>, taskToEdit: Binding<Task?>) {
        self._currentDate = currentDate
        let calendar = Calendar.autoupdatingCurrent
        let startDate = calendar.startOfDay(for: currentDate.wrappedValue)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        let predicate = #Predicate<Task> {
            return $0.creationDate >= startDate && $0.creationDate < endDate
        }
        
        let sortCompletion = SortDescriptor(\Task.isCompleted, order: .forward)
        let sortDate = SortDescriptor(\Task.creationDate, order: .forward)
        let sortDescriptors = [sortCompletion, sortDate]
        
        self._tasks = Query(filter: predicate, sort: sortDescriptors, animation: .snappy)
        self._taskToEdit = taskToEdit
    }
    
    var body: some View {
        List {
            ForEach(tasks) { task in
                TaskRowView(task: task)
                    .swipeActions {
                        editButton(for: task)
                        deleteButton(for: task)
                    }
            }
        }
        .listRowSpacing(20)
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .top, content: { // In iOS 15, SwiftUI can indirectly set content inset using .safeAreaInset modifier.
            Color.clear.frame(height: 20)
        })
        .safeAreaInset(edge: .bottom, content: {
            Color.clear.frame(height: 70)
        })
        .overlay(emptyStateOverlay)
    }
    
    // MARK: - Overlay for Empty State
    @ViewBuilder
    private var emptyStateOverlay: some View {
        if tasks.isEmpty {
            Text("No Tasks Found")
                .font(.callout)
                .foregroundStyle(.gray)
                .frame(width: 150)
        }
    }
    
    // MARK: - Delete Button
    private func deleteButton(for task: Task) -> some View {
        Button {
            Task.deleteTask(modelContext: modelContext, task: task)
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
    }
    
    // MARK: - Edit Button
    private func editButton(for task: Task) -> some View {
        Button {
            taskToEdit = task
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.blue)
    }
}

#Preview {
    let previewContainer = TaskController.previewContainer
    @State var currentDate = Date()
    @State var taskToEdit: Task? = Task(taskTitle: "Preview Task", creationDate: Date(), tint: "taskColor1")
    
    return TasksView(currentDate: $currentDate, taskToEdit: $taskToEdit)
        .modelContainer(previewContainer)
}
