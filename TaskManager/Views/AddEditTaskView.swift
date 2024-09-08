//
//  AddEditTaskView.swift
//  TaskManager
//
//  Created by Jonni Akesson on 2024-09-08.
//

import SwiftUI

struct AddEditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var taskToEdit: Task?
    @State private var taskTitle = ""
    @State private var taskDate: Date = .init()
    @State private var taskColor: String = "taskColor1"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // MARK: Dismiss Button
            Button(action: { dismiss() }, label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .tint(.primary)
            })
            .horizontalAlignment(.trailing)
            .padding(.trailing)
            
            // MARK: Task Title Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                TextField("Go for a walk", text: $taskTitle)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(.gray.shadow(.drop(color: .black.opacity(0.2), radius: 2)).opacity(0.1), in: .rect(cornerRadius: 10))
            }
            .padding(.top, 5)
            
            
            // MARK: Date Picker and Color Picker
            HStack(spacing: 12) {
                taskDatePicker
                taskColorPicker
            }
            
            Spacer(minLength: 0)
            
            // MARK: Save/Create Button
            Button(action: saveTask, label: {
                Text(taskToEdit != nil ? "Save Task" : "Create Task")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .horizontalAlignment(.center)
                    .padding(.vertical, 12)
                    .background(Color(taskColor), in: .rect(cornerRadius: 10))
            })
            .disabled(taskTitle.isEmpty)
            .opacity(taskTitle.isEmpty ? 0.5 : 1)
        }
        .padding(15)
        .onAppear(perform: loadTaskData)
    }
    
    // MARK: - Task Date Picker View
    private var taskDatePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date")
                .font(.caption)
                .foregroundStyle(.gray)
            
            DatePicker("", selection: $taskDate)
                .datePickerStyle(.compact)
                .scaleEffect(0.9, anchor: .leading)
        }
        .padding(.trailing, -15)
    }
    
    // MARK: - Task Color Picker View
    private var taskColorPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color")
                .font(.caption)
                .foregroundStyle(.gray)
            
            let colors: [String] = (1...6).compactMap { index -> String in
                return "taskColor\(index)"
            }
            
            HStack(spacing: 0) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(Color(color))
                        .frame(width: 20, height: 20)
                        .background(content: {
                            Circle()
                                .stroke(lineWidth: 2.0)
                                .opacity(taskColor == color ? 1 : 0)
                        })
                        .horizontalAlignment(.center)
                        .contentShape(.rect)
                        .onTapGesture {
                            withAnimation(.snappy) {
                                taskColor = color
                            }
                        }
                }
            }
        }
    }
    
    // MARK: - Load Existing Task Data
    private func loadTaskData() {
        if let taskToEdit = taskToEdit {
            taskTitle = taskToEdit.taskTitle
            taskDate = taskToEdit.creationDate
            taskColor = taskToEdit.tint
        }
    }
    
    // MARK: - Save or Create Task
    private func saveTask() {
        if let taskToEdit {
            taskToEdit.taskTitle = taskTitle
            taskToEdit.creationDate = taskDate
            taskToEdit.tint = taskColor
        } else {
            let newTask = Task(taskTitle: taskTitle, creationDate: taskDate, tint: taskColor)
            modelContext.insert(newTask)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save task: \(error.localizedDescription)")
        }
    }
}

#Preview {
    let previewContainer = TaskController.previewContainer
    @State var taskToEdit: Task? = Task(taskTitle: "Preview Task 1", tint: "taskColor1")
    
    return AddEditTaskView(taskToEdit: $taskToEdit)
        .modelContainer(previewContainer)
        .scaledToFit()
}
