//
//  TaskRowView.swift
//  TaskManager
//
//  Created by Jonni Akesson on 2024-09-08.
//

import SwiftUI

struct TaskRowView: View {
    @Environment(\.modelContext) private var context
    @Bindable var task: Task
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            timeIndicator
            taskContent
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
        .onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation {
                task.isCompleted.toggle()
            }
        }
    }
    
    private var timeIndicator: some View {
        Text(task.creationDate.localizedTime())
            .fontWeight(.semibold)
            .foregroundStyle(indicatorColor)
            .frame(minWidth: 70, alignment: .center)
            .padding(.horizontal)
    }
    
    private var taskContent: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 6)
                .fill(task.tintColor.opacity(0.1)) // Background with opacity
                .background(
                    Rectangle()
                        .fill(task.tintColor)
                        .frame(width: 6), alignment: .leading // Left color bar
                )
            
            taskDetails
                .padding()
        }
        .clipShape(.rect(topLeadingRadius: 6, bottomLeadingRadius: 6)) // Clip shape for the entire view
    }
    
    private var taskDetails: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                Text(task.taskTitle)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted, pattern: .solid)
                HStack(spacing: 5) {
                    Image(systemName: "clock")
                    Text("\(task.creationDate.localizedTime())")
                }
                .font(.caption)
            }
            Spacer()
            Image(systemName: "checkmark.square.fill")
                .foregroundStyle(task.isCompleted ? task.tintColor : Color(uiColor: .systemBackground))
                .font(.title2)
        }
    }
    
    private var indicatorColor: Color {
        if task.isCompleted {
            return .primary
        }
        return task.creationDate.isSameHour ? .blue : (task.creationDate.isPastHour ? .red : .primary)
    }
}

#Preview {
    let previewContainer = TaskController.previewContainer
    @State var currentDate = Date()
    @State var task: Task = Task(taskTitle: "Preview Task 1", creationDate: Date(), tint: "taskColor1")
    
    return TaskRowView(task: task)
        .modelContainer(previewContainer)
        .scaledToFit()
}
