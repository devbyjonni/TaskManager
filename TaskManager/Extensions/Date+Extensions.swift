//
//  Date+Extensions.swift
//  TaskManager
//
//  Created by Jonni Akesson on 2024-09-08.
//

import Foundation

extension Date {
    var isToday: Bool {
        Calendar.autoupdatingCurrent.isDateInToday(self)
    }
    
    var isSameHour: Bool {
        Calendar.autoupdatingCurrent.compare(self, to: .init(), toGranularity: .hour) == .orderedSame
    }
    
    var isPastHour: Bool {
        Calendar.autoupdatingCurrent.compare(self, to: .init(), toGranularity: .hour) == .orderedAscending
    }
    
    func isSameDate(as date: Date) -> Bool {
        Calendar.autoupdatingCurrent.isDate(self, inSameDayAs: date)
    }
    
    // Function to fetch the dates of a week starting from the given date.
    func fetchWeek(_ date: Date = .init()) -> [WeekDay] {
        let userCalendar = Calendar.autoupdatingCurrent
        let startOfDate = userCalendar.startOfDay(for: date)
        let weekForDate = userCalendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        
        guard let startOfWeek = weekForDate?.start else {
            return []
        }
        
        var week: [WeekDay] = []
        
        // Iterate over the next 7 days (0 to 6) to get each day of the week starting from `startOfWeek`.
        (0...6).forEach { index in
            if let weekDay = userCalendar.date(byAdding: .day, value: index, to: startOfWeek) {
                week.append(.init(date: weekDay))
            }
        }
        
        return week
    }
    
    // Create next week dates, based on the last current week's date
    func createNextWeek() -> [WeekDay] {
        let calendar = Calendar.autoupdatingCurrent
        let startOfLastDate = calendar.startOfDay(for: self)
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: startOfLastDate) else {
            return []
        }
        
        return fetchWeek(nextDate)
    }
    
    // Create previous week dates, based on the first current week's date
    func createPreviousWeek() -> [WeekDay] {
        let calendar = Calendar.autoupdatingCurrent
        let startOfFirstDate = calendar.startOfDay(for: self)
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: startOfFirstDate) else {
            return []
        }
        
        return fetchWeek(previousDate)
    }
    
    struct WeekDay: Identifiable {
        var id = UUID()
        var date: Date
    }
}

extension Date {
    func localizedTime() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Locale.preferredLanguageCode)
        formatter.timeStyle = .short // Uses the appropriate time format for the locale
        return formatter.string(from: self)
    }
    
    func localizedDate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Locale.preferredLanguageCode)
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension Locale {
    static var preferredLanguageCode: String {
        // Fallback to en_US if no preferred language is found
        let defaultLocale = Locale(identifier: "en_US")
        let preferredLanguage = Locale.preferredLanguages.first ?? defaultLocale.identifier
        // Use the new API for iOS 16+
        let locale = Locale(identifier: preferredLanguage)
        
        if #available(iOS 16.0, *) {
            return locale.language.languageCode?.identifier ?? "en" // Fallback to "en"
        } else {
            return locale.languageCode ?? "en" // Fallback for older iOS versions
        }
    }
    
    static var preferredLanguageCodes: [String] {
        // Return all preferred language codes using the new API for iOS 16+
        if #available(iOS 16.0, *) {
            return Locale.preferredLanguages.compactMap {
                Locale(identifier: $0).language.languageCode?.identifier
            }
        } else {
            return Locale.preferredLanguages.compactMap {
                Locale(identifier: $0).languageCode
            }
        }
    }
}

extension Date {
    static func updateHour(_ value: Int) -> Date {
        let calendar = Calendar.autoupdatingCurrent
        return calendar.date(byAdding: .hour, value: value, to: .init()) ?? .init()
    }
}
