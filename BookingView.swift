//
//  BookingView.swift
//  Calender Trail
//
//  Created by Abdel Taeha on 3/14/24.
//
//  This File is for when someone is choosing a booking

import SwiftUI

struct BookingView: View {
    
    // User input: name, contact, and notes
    @State private var name = ""
    @State private var contactInfo = ""
    @State private var notes = ""
    
    // Booking date
    var currentDate: Date
    
    // UI layout
    var body: some View {
        VStack (alignment: .leading) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "clock.circle")
                    Text("30 minutes")
                }
                HStack {
                    Image(systemName: "video.bubble.left")
                    Text("Meeting details provided upon confirmation")
                }
                HStack {
                    Image(systemName: "calendar.badge.plus")
                    Text(currentDate.fullMonthDayYearFormat())
                }
            }
            .padding()
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Please Enter Details here")
                    .font(.title)
                    .bold()
                
                Text("Name")
                TextField("", text: $name)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke()
                    )
                    
                Text("Contact Info")
                TextField("", text: $contactInfo)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke()
                    )
                    
                Text("Please enter details for meeting here")
                    ScrollView {
                        TextEditor(text: $notes)
                            .padding()
                            .frame(minHeight: 100)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke()
                            )
                    }
                
                Spacer()
                
                //Sends user to Confirmation page
                NavigationLink {
                    ConfirmationView(currentDate: currentDate)
                } label: {
                    Text("Confirm")
                        .bold()
                        .padding()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.green)
                        )
                }
                
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Calendar")
    }
}

struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BookingView(currentDate: Date())
        }
    }
}
