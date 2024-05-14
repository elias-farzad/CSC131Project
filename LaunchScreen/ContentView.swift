//
//  ContentView.swift
//  LaunchScreen
//
//  Created by Renay  on 5/14/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.cyan
                .ignoresSafeArea()
            Text("ContentView") //demonstrate
                .foregroundColor(.white)
                .font(.system(size: 34))
        }
    }
}

