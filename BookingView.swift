//
//  BookingView.swift
//  Calender Trail
//
//  Created by Abdel Taeha on 3/14/24.
//
//  This File is for when someone is choosing a booking

import SwiftUI
import Foundation

struct BookingView: View {
    @State private var name = ""
    @State private var contactInfo = ""
    @State private var notes = ""
    @State private var doctorName = ""  // Updated for clarity

    var currentDate: Date

    var body: some View {
        NavigationStack {
            ScrollView {  // Wraps the entire content in a ScrollView
                VStack(alignment: .leading) {
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
                        TextField("Enter your name", text: $name)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke())

                        Text("Doctor")
                        TextField("Doctor's name", text: $doctorName)  // Updated for clarity
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke())

                        Text("Email")
                        TextField("Enter your email", text: $contactInfo)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke())

                        Text("Please Enter the Meeting Details Here")
                        ScrollView {  // Another ScrollView for long text input
                            TextEditor(text: $notes)
                                .padding()
                                .frame(minHeight: 100)
                                .background(RoundedRectangle(cornerRadius: 10).stroke())
                        }

                        Spacer()

                        // Sends user to Confirmation page
                        NavigationLink {
                            ConfirmationView(currentDate: currentDate, name: name, contactInfo: contactInfo, doctorName: doctorName)
                        } label: {
                            Text("Confirm")
                                .bold()
                                .padding()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.green))
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .navigationTitle("Calendar")
            }
        }
    }
}

struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BookingView(currentDate: Date())
        }
    }
}