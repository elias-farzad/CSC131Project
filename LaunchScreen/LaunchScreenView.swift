//
//  LaunchScreenView.swift
//  LaunchScreen
//
//  Created by Renay  on 5/14/24.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5

    var body: some View {

        //screen after launch screen is over
        if isActive {
            ContentView() //replace with dashboard file I think cuz I just used this as a placeholder to see what happens after the launch screen is over
        } else {
            VStack {
                VStack {
                    Image( "logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240, height: 240)
                        .font(.system(size: 80))
                        .foregroundColor(.cyan)
                    Text("Persistence Medical App")
                        .font(Font.custom("Futura", size: 30))
                        .foregroundColor(.black.opacity(0.80))
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }

            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    self.isActive = true
                }
            }
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
    }
}
