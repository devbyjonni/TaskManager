//
//  HomeView.swift
//  TaskManager
//
//  Created by Jonni Akesson on 2024-09-08.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentDate = Date()
    @State private var weekCollection: [[Date.WeekDay]] = [] // Collection of weeks: [previous, current, next]
    @State private var currentWeekIndex = 1 // Start at the second week (current)
    @State private var createWeek = false // Flag to trigger the creation of a new week when needed
    @State private var createNewTask = false // Controls whether the "create new task" sheet is shown
    @State private var taskToEdit: Task? // Task being edited (or nil if none)

    // The 'offset' is used for padding and to detect when the user has swiped far enough to trigger paging.
    // The app initially loads the previous, current, and next weeks into 'weekCollection'.
    // When the user swipes far enough (detected by the offset), we load a new week.
    // If the user swipes to the previous week (index 0), we insert the previous week at the start of the array and remove the last one.
    // If the user swipes to the next week (index 2), we append the next week to the end and remove the first one.
    // This ensures that 'weekCollection' always contains three weeks and the current week stays in the middle.
    private let paddingOffset: CGFloat = 15 // Padding offset used for layout and swipe detection

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeaderView() // Header view showing date and more menu
            TasksView(currentDate: $currentDate, taskToEdit: $taskToEdit) // Task view with current date and task to edit
        }
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: toggleCreateNewTask, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .frame(width: 50, height: 50)
                    .background(.blue.shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: .circle)
            })
        })
        .padding(paddingOffset)  // Correct padding using the offset variable
        .onAppear {
            initializeWeekSlider() // Initialize the week slider when the view appears
        }
        .sheet(isPresented: Binding<Bool>(
            get: { createNewTask || taskToEdit != nil }, // Show sheet if creating a new task or editing one
            set: { if !$0 { createNewTask = false; taskToEdit = nil } } // Reset when the sheet is dismissed
        )) {
            AddEditTaskView(taskToEdit: $taskToEdit) // Sheet for adding or editing tasks
                .presentationDetents([.height(300)])
                .interactiveDismissDisabled() // Prevent dismissing interactively
                .presentationCornerRadius(30)
        }
        .onChange(of: currentWeekIndex, initial: false) { oldValue, newValue in
            handleWeekChange(newIndex: newValue) // Handle week change when the user swipes to a different week
        }
    }
    
    // Initialize the week slider to today's date
    private func initializeWeekSlider() {
        resetWeekCalendarToToday()
    }

    // Handle week changes when the index changes
    private func handleWeekChange(newIndex: Int) {
        // If the user reaches the first or last week, trigger week creation
        if newIndex == 0 || newIndex == (weekCollection.count - 1) {
            triggerWeekCreation()
        }
    }

    // Set flag to trigger week creation
    private func triggerWeekCreation() {
        createWeek = true
    }

    // Toggle the state for creating a new task
    private func toggleCreateNewTask() {
        createNewTask.toggle()
    }

    // MARK: HeaderView
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: Current Date
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(currentDate.localizedDate(format: "eeee d").capitalized)
                        .font(.largeTitle)
                        .bold()
                    Text(currentDate.localizedDate(format: "MMMM YYY").capitalized)
                        .foregroundStyle(.gray)
                }
                .onTapGesture {
                    resetWeekCalendarToToday() // Reset to today when the date is tapped
                }
                
                Spacer()
                
                // MARK: More Menu (for adding or removing mock data)
                Menu {
                    Button("Add Mock Data", action: addMockData) // Adds mock data to the task list
                    Button("Remove Mock Data", action: removeMockData) // Removes all mock data
                } label: {
                    Label("", systemImage: "ellipsis")
                        .font(.system(size: 20, weight: .medium))
                        .padding([.leading, .top, .bottom])
                        .offset(y: -2)
                }
            }
            .padding([.leading, .trailing])
            
            // MARK: Week TabView
            TabView(selection: $currentWeekIndex) {
                ForEach(weekCollection.indices, id: \.self) { index in
                    let week = weekCollection[index]
                    WeekView(week)
                        .padding(.horizontal, paddingOffset)
                        .tag(index) // Use index as the tag for the TabView selection
                }
            }
            .padding(.horizontal, -paddingOffset) // Negative offset for consistent padding
            .tabViewStyle(.page(indexDisplayMode: .never)) // TabView without the page index indicator
            .frame(height: 90)
        }
    }
    
    // MARK: WeekView
    @ViewBuilder
    func WeekView(_ week: [Date.WeekDay]) -> some View {
        HStack(spacing: 0) {
            ForEach(week) { day in
                VStack(spacing: 5) {
                    Text(day.date.localizedDate(format: "EEE").capitalized)
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text(day.date.localizedDate(format: "d"))
                        .foregroundStyle(day.date.isSameDate(as: currentDate) ? .white : .primary)
                        .frame(width: 35, height: 35)
                        .background(content: {
                            // Highlight the current day
                            if day.date.isSameDate(as: currentDate) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.blue.shadow(.drop(color: .black.opacity(0.25), radius: 2, x: 0, y: 0)))
                            }
                            // MARK: WeekView Indicator for today's date
                            if day.date.isToday {
                                Circle()
                                    .fill(.gray)
                                    .frame(width: 5, height: 5)
                                    .verticalAlignment(.bottom)
                                    .offset(y: 10)
                            }
                        })
                }
                .horizontalAlignment(.center)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation(.snappy) {
                        currentDate = day.date // Update current date when a day is tapped
                    }
                }
            }
        }
        .background {
            // MARK: - Handle Week Paging
            GeometryReader { geometry in
                let minX = geometry.frame(in: .global).minX
                
                Color.clear
                    .preference(key: OffsetKey.self, value: minX)
                    .onPreferenceChange(OffsetKey.self) { value in
                        // When the scroll offset reaches the defined 'offset' value,
                        // and the flag 'createWeek' is true, generate the next or previous week.
                        if value.rounded() == paddingOffset && createWeek {
                            createWeek = false
                            pagingWeek()  // Load next or previous week based on currentWeekIndex
                        }
                    }
            }
        }
    }
    
    //MARK: - Helpers
    private func pagingWeek() {
        // Ensure the current week index is valid within the weekCollection bounds
        if weekCollection.indices.contains(currentWeekIndex) {
            
            // If the current week is the first one (index 0), load the previous week
            if let firstDate = weekCollection.first?.first?.date, currentWeekIndex == 0 {
                // Insert the previous week at the start and remove the last to maintain the array size
                weekCollection.insert(firstDate.createPreviousWeek(), at: 0)
                weekCollection.removeLast()
                currentWeekIndex = 1 // Update index to point to the current week
            }
            
            // If the current week is the last one (index 2), load the next week
            if let lastDate = weekCollection.last?.last?.date, currentWeekIndex == 2 {
                // Append the next week and remove the first to maintain the array size
                weekCollection.append(lastDate.createNextWeek())
                weekCollection.removeFirst()
                currentWeekIndex = 1 // Update index to point to the current week
            }
        }
    }

    // Reset the week calendar to the current date
    private func resetWeekCalendarToToday() {
        currentDate = Date()
        currentWeekIndex = 1
        createWeek = false
        weekCollection = []
        
        let currentWeek = Date().fetchWeek()
        
        // Create an initial week collection with the previous, current, and next weeks
        if let firstDate = currentWeek.first?.date {
            weekCollection.append(firstDate.createPreviousWeek()) // Add previous week
        }
        
        weekCollection.append(currentWeek) // Add current week
        
        if let lastDate = currentWeek.last?.date {
            weekCollection.append(lastDate.createNextWeek()) // Add next week
        }
    }
    
    // Add mock data for testing
    private func addMockData() {
        Task.createMockData(modelContext: modelContext)
        resetWeekCalendarToToday()
    }
    
    // Remove all mock data
    private func removeMockData() {
        Task.deleteAllTasks(modelContext: modelContext)
        resetWeekCalendarToToday()
    }
}

#Preview {
    let previewContainer = TaskController.previewContainer
    
    @State var currentDate = Date()
    @State var taskToEdit: Task?
    
    return HomeView()
        .modelContainer(previewContainer)
}
