//
//  ConfirmationView.swift
//  Calender Trail
//
//  Created by Abdel Taeha on 3/15/24.
//
// Thispage is to let you know the date and time you selected and confirming it
import SwiftUI

struct ConfirmationView: View {
    var currentDate: Date
    var name : String
    var contactInfo: String
    var doctorName: String

    //UI layout
    var body: some View {
          VStack {
              Image("Kalid")
                  .resizable()
                  .scaledToFill()
                  .frame(width: 128, height: 128)
                  .cornerRadius(64)
              
              Text("Confirmed")
                  .font(.title)
                  .bold()
                  .padding()
              
              Text("Your appointment is now confirmed")
              
              Divider()
                  .padding()
              
              VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Circle()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.blue)
                        Text("Appintment for \(name) is set")
                    }
                    .padding()

                    HStack {
                        Circle()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.green)
                        Text("Preferred Contact Method is: \(contactInfo)")
                    }
                    .padding()
                              
                  HStack {
                      Circle()
                          .frame(width: 28, height: 28)
                          .foregroundColor(.red)
                      Text("You are scheduled with Dr. \(doctorName)")
                  }
                  .padding()
                  
                    HStack(alignment: .top) {
                        Image(systemName: "calendar")
                        Text(currentDate.bookingViewDateFormat())
                    }
                    .padding(.top, 5) 
                }
            Spacer()
            
            Button {
                
            } label: {
                Text("Done")
                    .bold()
                    .padding()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.blue)
                    )
            }
        }
            
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct ConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ConfirmationView(currentDate: Date(), name: "Sample Patient", contactInfo: "sample@email.com", doctorName: "User")
        }
    }
}