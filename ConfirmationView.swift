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
    
    //UI layout
    var body: some View {
        VStack{
            
            Image ("Kalid" )
                .resizable()
                .scaledToFill()
                .frame(width: 128, height: 128)
                .cornerRadius (64)
            
            Text("Confirmed")
                .font(.title)
                .bold()
                .padding()
            
            Text("You Are Scheduleda at PLACEHOLDER")
            
            Divider()
                .padding()
            
            VStack(alignment: .leading, spacing: 35) {
                HStack{
                    
                    Circle()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.blue)
                    
                    Text("Name of Patient")
                    
                }
                
                HStack (alignment: .top) {
        
                    Image (systemName: "calendar")
                    
                    Text (currentDate.bookingViewDateFormat())
                }
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
            ConfirmationView(currentDate: Date())
        }
    }
}
