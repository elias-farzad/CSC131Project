//
//  DataBaseManager.swift
//  Calender Trail
//
//  Created by Abdel Taeha on 3/20/24.
//
//This deals with the DataBase and connected the files to the data base

import Foundation
import Supabase

// created all variables needed for the database and tranfering them over
struct Hours: Codable {
    let id: Int
    let createdAt: String
    let day: Int
    let start: Int
    let end: Int
    
    enum CodingKeys: String, CodingKey{
        case id, day, start, end
        case createdAt = "created_at"
    }
}

struct Appointment: Codable {
    let id: Int
    let createdAt: String
    let name: String
    let email: String
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, date
        case createdAt = "created_at"
    }
}

// The actual data base
class DataBaseManager: ObservableObject {
    
    @Published var avaliableDates = [Date]()
    @Published var days: Set<String> = []
    
    //static let shared = DataBaseManager()
    
    private let client = SupabaseClient(supabaseURL: URL(string: "https://bjdkxtrviksxjatvtcvi.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJqZGt4dHJ2aWtzeGphdHZ0Y3ZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTA5NzM4MjMsImV4cCI6MjAyNjU0OTgyM30.O6Y3Vwd_RjD5uTtFwPHAXKCfCP92E9P6jAc-ij9Q2eQ")
    
    init() {
        Task {
            do {
                let dates = try await self.fetchAvaliableAppointments()
                await MainActor.run {
                    avaliableDates = dates
                    days = Set(avaliableDates.map({$0.monthDayYearFormat()}))
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    // Grabes avaliabe appointments times in that day
    func fetchHours() async throws -> [Hours] {
        let response: [Hours] = try await client.database.from("hours").select().execute().value
        
        
        return response
        }
    
    // Grabes avaliabe appointmens in that day
    func fetchAvaliableAppointments() async throws -> [Date] {
        
        let appts: [Appointment] = try await client.database.from("appointments").select().execute().value
        
        return try await generateAppointmentTimes(from: appts)
    }
    
    // Puts them all together and checks to make sure they are all open
    func generateAppointmentTimes(from appts: [Appointment]) async throws -> [Date] {
        
        let takenAppts: Set<Date> = Set(appts.map({$0.date}))
        let hours = try await fetchHours()
       
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: Date()) - 2
        
        var timeSlots = [Date]()
        for weekOffset in 0...4 {
            let daysOffset = weekOffset * 7
            
            for hour in hours {
                
                if hour.start != 0 && hour.end != 0 {
                    var currentDate = calendar.date(from: DateComponents (year: calendar.component(.year, from: Date()), month: calendar.component (.month, from: Date()),day: calendar.component(.day, from: Date()) + daysOffset + (hour.day - currentWeekday), hour: hour.start))!
                    
                    while let nextDate = calendar.date(byAdding: .minute, value: 30, to: currentDate), calendar.component(.hour, from: nextDate) <= hour.end {
                        if !takenAppts.contains(currentDate) && currentDate > Date() && calendar.component(.hour, from: currentDate) != hour.end {
                            timeSlots.append(currentDate)
                        }
                        currentDate = nextDate
                    }
                    
                }
            }
            
        }
        
        return timeSlots
    }

}
