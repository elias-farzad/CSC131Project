//
//  DayView.swift
//  Calender Trail
//
//  Created by Abdel Taeha on 3/13/24.
//
// This page is for you to select a time after selecting a day of the month

import SwiftUI

struct DayView: View {
    @EnvironmentObject var manager: DataBaseManager
    @State var dates = [Date]()
    @State var selectedDate: Date?
    
    var currentDate : Date
    var body: some View {
        ScrollView {
            
            //UI Layout
            VStack {
                Text(currentDate.fullMonthDayYearFormat())
                
                Divider()
                    .padding(.vertical)
                
                Text("Select a time")
                    .font(.largeTitle)
                    .bold()
                
                Text("Duration: 30 Minutes")
                
                ForEach(dates, id: \.self) { date in
                    HStack{
                        Button {
                            withAnimation{
                                selectedDate = date
                            }
                            
                        } label: {
                            Text(date.timeFromDate())
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(selectedDate == date ? .white : .blue)
                                .background(
                                    ZStack{
                                        if selectedDate == date{
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Gradient(colors: [.red, .purple]))
                                        } else {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke()
                                        }
                                    }
                                )
                        }
                        
                        if selectedDate == date {
                            
                            // This ends you to the booking view
                            NavigationLink {
                                BookingView(currentDate: date)
                            } label: {
                                Text("Next")
                                    .bold()
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.blue)
                                        )
                            }
                            
                        }
                        
                    }
                }
            }
        }
        .onAppear{
            
            self.dates = manager.avaliableDates.filter({ $0.fullMonthDayYearFormat() == currentDate.fullMonthDayYearFormat()})
            
        }
        .navigationTitle(currentDate.dayOfTheWeek())
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            DayView(currentDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())! )
        }
    }
}
