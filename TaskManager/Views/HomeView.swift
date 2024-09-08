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
    @State private var weekCollection: [[Date.WeekDay]] = [] // [[prev week], [current week], [next week]].
    @State private var currentWeekIndex = 1
    @State private var createWeek = false
    @State private var createNewTask = false
    @State private var taskToEdit: Task?
    
    private let offset: CGFloat = 10
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeaderView()
            TasksView(currentDate: $currentDate, taskToEdit: $taskToEdit)
        }
        .overlay(alignment: .bottomTrailing, content: {
            Button(action: toggleCreateNewTask, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .frame(width: 50, height: 50)
                    .background(.blue.shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: .circle)
            })
            .padding(15)
        })
        .onAppear {
            initializeWeekSlider()
        }
        .sheet(isPresented: Binding<Bool>(
            get: { createNewTask || taskToEdit != nil }, // The sheet is presented if either is true
            set: { if !$0 { createNewTask = false; taskToEdit = nil } }  // Reset both when the sheet is dismissed
        )) {
            AddEditTaskView(taskToEdit: $taskToEdit)
                .presentationDetents([.height(300)])
                .interactiveDismissDisabled()
                .presentationCornerRadius(30)
        }
        .onChange(of: currentWeekIndex, initial: false) { oldValue, newValue in
            handleWeekChange(newIndex: newValue)
        }
    }
    
    private func initializeWeekSlider() {
        resetWeekCalendarToToday()
    }

    private func handleWeekChange(newIndex: Int) {
        if newIndex == 0 || newIndex == (weekCollection.count - 1) {
            triggerWeekCreation()
        }
    }

    private func triggerWeekCreation() {
        createWeek = true
    }

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
                    resetWeekCalendarToToday()
                }
                
                Spacer()
                
                // MARK: More Menu
                Menu {
                    Button("Add Mock Data", action: addMockData)
                    Button("Remove Mock Data", action: removeMockData)
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
                        .padding(.horizontal, offset)
                        .tag(index)
                }
            }
            .padding(.horizontal, -offset)
            .tabViewStyle(.page(indexDisplayMode: .never))
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
                            if day.date.isSameDate(as: currentDate) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.blue.shadow(.drop(color: .black.opacity(0.25), radius: 2, x: 0, y: 0)))
                            }
                            // MARK: WeekView Indicator
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
                        currentDate = day.date
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
                        if value.rounded() == offset && createWeek {
                            pagingWeek()  // Call function to load the next or previous week
                            createWeek = false  // Reset the flag after paging
                        }
                    }
            }
        }
    }
    
    //MARK: - Helpers
    private func pagingWeek() {
        // Ensure that the current week index is valid within the weekCollection's bounds
        if weekCollection.indices.contains(currentWeekIndex) {
            
            // If the current week is the first one (index 0), load the previous week
            if let firstDate = weekCollection[currentWeekIndex].first?.date, currentWeekIndex == 0 {
                // Insert the previous week at the start of the collection and remove the last week to keep the collection size consistent
                weekCollection.insert(firstDate.createPreviousWeek(), at: 0)
                weekCollection.removeLast()
                // Update the currentWeekIndex to point to the new current week
                currentWeekIndex = 1
            }
            
            // If the current week is the last one in the collection, load the next week
            if let lastDate = weekCollection[currentWeekIndex].last?.date, currentWeekIndex == (weekCollection.count - 1) {
                // Append the next week to the end of the collection and remove the first week to maintain the collection size
                weekCollection.append(lastDate.createNextWeek())
                weekCollection.removeFirst()
                // Update the currentWeekIndex to point to the new current week (second-to-last in the collection)
                currentWeekIndex = weekCollection.count - 2
            }
        }
    }

    private func resetWeekCalendarToToday() {
        currentDate = Date()
        currentWeekIndex = 1
        createWeek = false
        weekCollection = []
        
        let currentWeek = Date().fetchWeek()
        
        if let firstDate = currentWeek.first?.date {
            weekCollection.append(firstDate.createPreviousWeek())
        }
        
        weekCollection.append(currentWeek)
        
        if let lastDate = currentWeek.last?.date {
            weekCollection.append(lastDate.createNextWeek())
        }
    }
    
    private func addMockData() {
        Task.createMockData(modelContext: modelContext)
        resetWeekCalendarToToday()
    }
    
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
