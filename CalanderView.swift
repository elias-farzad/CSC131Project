//
//  ContentView.swift
//  calander trail
//
//  Created by Abdel Taeha on 3/12/24.
//
//  CalanderView is for the clinic app, provides a calendar home page for selecting dates
import SwiftUI

struct CalanderView: View {
    @StateObject var manager = DataBaseManager()
    
    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    @State var selectedMonth = 0
    @State var selectedDate = Date()
   
    // UI for the calendar, including navigation and date selection.
    var body: some View {
        NavigationStack{
            VStack {
                
                //UI Features here
                Image("Kalid")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 128, height: 128)
                    .cornerRadius(64)
                
                Text("Sac State Approved")
                    .font(.title)
                    .bold()
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                
                VStack(spacing: 20) {
                    Text("Select a Day")
                        .font(.title2)
                        .bold()
                    
                    // Month selection
                    HStack {
                        
                        Spacer()
                        
                        Button{
                            withAnimation {
                                selectedMonth -= 1
                                
                            }
                        }label: {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 32)
                        }
                            
                        Spacer()
                        
                        Text(selectedDate.monthDayYearFormat())
                            .font(.title2)
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                selectedMonth += 1
                                
                            }
                        }label: {
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 32)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        ForEach(days, id:\.self) { day in
                            Text(day)
                                .font(.system(size: 12, weight: .medium))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // This part deals with selecting the day for an appointment and send you to the Day View
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 20 ) {
                        ForEach(fetchDates()) { value in
                            ZStack{
                                if value.day != -1 {
                                    let hasAppts = manager.days.contains(value.date.monthDayYearFormat())
                                    NavigationLink{
                                        DayView(currentDate: value.date)
                                            .environmentObject(manager)
                                    } label: {
                                        Text("\(value.day)")
                                            .foregroundColor(hasAppts ? .blue : .black)
                                            .fontWeight(hasAppts ? .bold : .none)
                                            .background {
                                                ZStack(alignment: .bottom) {
                                                    Circle()
                                                        .frame(width: 48,height: 48)
                                                        .foregroundColor(hasAppts ? .blue.opacity(0.1) : .clear)
                                                    
                                                    if value.date.monthDayYearFormat() == Date().monthDayYearFormat() {
                                                        Circle()
                                                            .frame(width: 8, height: 8)
                                                            .foregroundColor(hasAppts ? .blue : .gray)
                                                    }
                                                }
                                            }
                                    }
                                    .disabled(!hasAppts)
                                    
                                }else {
                                    Text("")
                                }
                            }
                            .frame(width:32, height:32)
                        }
                    }
                }
                .padding()
            }
            .frame(maxHeight: .infinity, alignment: .top )
            .onChange(of: selectedMonth) { _ in
                selectedDate = fetchSelectedMonth()
            }

        }
        }
      
    
    
    // sets up varaibles needed for app
    struct CalendarDate: Identifiable {
        let id = UUID()
        var day: Int
        var date: Date
    }
    
    // This grabs the correct day
    func fetchDates() -> [CalendarDate] {
        
        let calendar = Calendar.current
        let currentMonth = fetchSelectedMonth()
        
        var  dates = currentMonth.datesOfMonth().map({ CalendarDate(day: calendar.component(.day, from: $0), date: $0) })
        
        let firstDayOfWeek = calendar.component(.weekday, from: dates.first?.date ?? Date())
        
        for _ in 0..<firstDayOfWeek - 1{
            
            dates.insert(CalendarDate(day:-1, date: Date()), at: 0)
        }
        
        return dates
    }
    
        // This grabes the correct month
    func fetchSelectedMonth() -> Date{
        
        let calendar = Calendar.current
        
        let month = calendar.date(byAdding: .month, value: selectedMonth, to: Date())
        return month!
        
    }

    struct calendarDate:Identifiable{
        
        let id = UUID()
        var day: Int
        var date: Date
        
    }
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            CalanderView()
        }
    }
}
