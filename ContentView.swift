//
//  ContentView.swift
//  PS1
//
//  Created by Rikash Anand on 3/22/24.
//



import SwiftUI
import CoreData

struct User {
    var username: String
    var role: UserRole
}

enum UserRole {
    case doctor
    case patient
}

struct Appointment: Identifiable {
    var id = UUID()
    var date: String
    var details: String
}

struct Task: Identifiable {
    var id = UUID()
    var description: String
    var isCompleted: Bool
}


struct Day: Identifiable {
    var id: UUID = UUID()
    var number: Int
    var hasAppointment: Bool
}

struct Month {
    var days: [Day]
}

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: AppViewModel
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    // Generate days for a static month as placeholders
                    ForEach(1...30, id: \.self) { day in
                        Text("\(day)")
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle().stroke(Color.gray, lineWidth: 1)
                            )
                    }
                }
                .padding()
            }
            List {
                Section(header: Text("Appointments This Month")) {
                    ForEach(viewModel.appointments) { appointment in
                        VStack(alignment: .leading) {
                            Text(appointment.date)
                                .font(.headline)
                            Text(appointment.details)
                        }
                    }
                }
            }
        }
        .navigationTitle("Calendar")
    }
}


func generateSampleMonth() -> Month {
    var days = [Day]()
    let totalDays = 30 // Example for a month with 30 days
    let appointmentDays = Set([3, 10, 15, 20, 28]) // Days with appointments

    for i in 1...totalDays {
        let day = Day(number: i, hasAppointment: appointmentDays.contains(i))
        days.append(day)
    }

    return Month(days: days)
}


class AppViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var appointments: [Appointment] = [
        Appointment(date: "2024-05-10", details: "Consultation with John Doe"),
        Appointment(date: "2024-05-15", details: "Dental Checkup for Jane Smith"),
        Appointment(date: "2024-05-20", details: "Annual Physical Exam for Emily R."),
        Appointment(date: "2024-05-28", details: "Follow-up with Kyle M.")
    ]
    @Published var tasks: [Task] = [
    
    ]
    @Published var patientInfo: [PatientInfo] = []

    @Published var errorMessage: String?
    @Published var showAlert: Bool = false
    

    func login(username: String, password: String) {
        let normalizedUsername = username.lowercased()
        
        if normalizedUsername == "doctor" && password == "password" {
            currentUser = User(username: username, role: .doctor)
            // Sample appointments for doctors
            appointments = [Appointment(date: "2024-05-10", details: "Consultation with John Doe"),
                            Appointment(date: "2024-05-10", details: "Consultation with John Doe"),
                            Appointment(date: "2024-05-15", details: "Dental Checkup for Jane Smith"),
                            Appointment(date: "2024-05-20", details: "Annual Physical Exam for Emily R."),
                            Appointment(date: "2024-05-28", details: "Follow-up with Kyle M.")
            ]
            // Sample tasks for doctors
            tasks = [
                Task(description: "Review lab results for patient John Doe", isCompleted: false),
                Task(description: "Prepare lecture on cardiology", isCompleted: false),
                Task(description: "Complete annual training on patient data security", isCompleted: true)
            ]
            patientInfo = [
               PatientInfo(label: "Height", value: "5'9\""),
               PatientInfo(label: "Weight", value: "160 lbs"),
               PatientInfo(label: "Blood Type", value: "O+"),
               PatientInfo(label: "Allergies", value: "None"),
               PatientInfo(label: "Medications", value: "Ibuprofen as needed")
           ]
        //code for patient
        } else if normalizedUsername == "patient" && password == "password" {
            currentUser = User(username: username, role: .patient)
            // Sample appointments for patients
            appointments = [Appointment(date: "2024-05-10", details: "Annual Checkup")]
            // Sample tasks for patients
            tasks = [
                Task(description: "Complete new patient registration forms", isCompleted: false),
                Task(description: "Schedule follow-up appointment", isCompleted: false),
                Task(description: "Track daily medication for one week", isCompleted: false)
                ]
        // Sample info for patient
            patientInfo = [
               PatientInfo(label: "Height", value: "5'9\""),
               PatientInfo(label: "Weight", value: "160 lbs"),
               PatientInfo(label: "Blood Type", value: "O+"),
               PatientInfo(label: "Allergies", value: "None"),
               PatientInfo(label: "Medications", value: "Ibuprofen as needed")
           ]
        } else {
            errorMessage = "Invalid username or password. Please try again."
            currentUser = nil
            showAlert = true
        }
    }

}

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        NavigationView {
            Form {
                TextField("Username", text: $username)
                
                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                Button("Login") {
                    viewModel.login(username: username, password: password)
                }
            }
            .navigationTitle("Login")
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")) {
                    viewModel.errorMessage = nil
                    viewModel.showAlert = false
                })
            }
        }
    }
}


struct DashboardView: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        if let _ = viewModel.currentUser {
            mainTabView()
        } else {
            LoginView(viewModel: viewModel)
        }
    }
    
    @ViewBuilder
    private func mainTabView() -> some View {
        TabView {
            mainContentView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
            
            CalendarView(viewModel: viewModel)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            ContactUsView()
                .tabItem {
                    Label("Contact Us", systemImage: "phone.circle")
                }
            
            PatientInfoView(patientInfo: viewModel.patientInfo)
                .tabItem {
                    Label("Patient Info", systemImage: "person.fill")
                }
        }
    }
    
    
    @ViewBuilder
    private func mainContentView() -> some View {
        if let user = viewModel.currentUser {
            switch user.role {
            case .doctor:
                DoctorView(appointments: viewModel.appointments, tasks: viewModel.tasks)
            case .patient:
                PatientView(appointments: viewModel.appointments)
            }
        } else {
            LoginView(viewModel: viewModel)
        }
    }
}

struct DoctorView: View {
    var appointments: [Appointment]
    var tasks: [Task]

    var body: some View {
        List {
            Section(header: Text("Appointments")) {
                ForEach(appointments, id: \.date) { appointment in
                    Text(appointment.details)
                }
            }
            Section(header: Text("Tasks")) {
                ForEach(tasks, id: \.description) { task in
                    Text(task.description)
                }
            }
        }
    }
}

struct PatientView: View {
    var appointments: [Appointment]

    var body: some View {
        List {
            Section(header: Text("Appointments")) {
                ForEach(appointments, id: \.date) { appointment in
                    Text(appointment.details)
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject var viewModel = AppViewModel()

    var body: some View {
        DashboardView(viewModel: viewModel)
    }
}

struct ContactUsView: View {
    var body: some View {
        List {
            Section(header: Text("Contact Information")) {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                    Text("+1 234-567-8900")
                }
                HStack {
                    Image(systemName: "map.fill")
                        .foregroundColor(.blue)
                    Text("1234 Health St, Wellness City, HC 56789")
                }
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.orange)
                    Text("contact@healthclinic.com")
                }
            }
        }
        .navigationTitle("Contact Us")
    }
}


struct PatientInfo: Identifiable {
    var id = UUID()
    var label: String
    var value: String
}

struct PatientInfoView: View {
    var patientInfo: [PatientInfo]

    var body: some View {
        List(patientInfo) { info in
            HStack {
                Text(info.label + ":")
                    .bold()
                Spacer()
                Text(info.value)
            }
        }
        .navigationTitle("Patient Info")
    }
}



