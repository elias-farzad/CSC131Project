//
//  Date+Ext.swift
//  Calender Trail
//
//  Created by Abdel Taeha on 3/13/24.
//
// This file is just for a lot of functions needed for the app

import Foundation

extension Date {
    
    func datesOfMonth() -> [Date] {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: self)
        let currentYear = calendar.component(.year, from: self)
        
        var startDateComponents = DateComponents()
        startDateComponents.year = currentYear
        startDateComponents.month = currentMonth
        startDateComponents.day = 1
        let startDate = calendar.date(from: startDateComponents)!
        
        var endDateComponents = DateComponents()
        endDateComponents.month = 1
        endDateComponents.day = -1
        let endDate = calendar.date(byAdding: endDateComponents, to: startDate)!
        
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    // Returns date as ex: August 2023
    func monthYearFormat() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        
        return formatter.string(from: self)
    }
    
    // Returns date as ex: 08/23/23
    func monthDayYearFormat() -> String {
            
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from:self)
        
    }
    
    // Returns date as ex: August 23, 2023
    func fullMonthDayYearFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, YYYY"
        return formatter.string (from: self)
    }
    
    // Returns date as ex: Monday, Tuesday Wednsay ... ecs
    func dayOfTheWeek() -> String{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string (from: self)
        
    }
    // returns time ex: 12:15 AM
    func timeFromDate() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from:self)
        
    }
    
    func bookingViewDateFormat() -> String{
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        
        let start = timeFormatter.string(from: self)
        
        let endDate = Calendar.current.date(byAdding: .minute, value: 30, to: self)!
        
        let end = timeFormatter.string(from: endDate)
        
        let day = self.dayOfTheWeek()
        let fullDateString = self.fullMonthDayYearFormat()
        
        return "\(start) - \(end), \(day), \(fullDateString)"
    }
}
