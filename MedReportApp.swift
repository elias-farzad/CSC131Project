//
//  MedicalApp.swift
//  MedicalRecords
//
//  Created by Boramy on 5/7/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

enum BloodGroup: String, CaseIterable {
    case aPositive = "A+"
    case aNegative = "A-"
    case bPositive = "B+"
    case bNegative = "B-"
    case abPositive = "AB+"
    case abNegative = "AB-"
    case oPositive = "O+"
    case oNegative = "O-"
}

enum RHFactor {
    case positive
    case negative
}

enum MaritalStatus {
    case single
    case married
    case divorced
    case widowed
}

enum AgeFormat {
    case years
    case months
    case days
}

// AppDelegate to handle Firebase initialization
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// Main entry point of your app
@main
struct MedicalApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
            }
        }
    }
}


struct HomeView: View {
    @State private var showAddPatient = false
    @State private var patientId = ""

    var body: some View {
        List {
            Section(header: Text("Patient Management")) {
                NavigationLink(destination: PatientsView()) {
                    HStack {
                        Image(systemName: "person.3")
                            .foregroundColor(.blue)
                        Text("Patients")
                    }
                }
                Button(action: {
                    showAddPatient = true
                }) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(.green)
                        Text("Add Patient")
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        
        .sheet(isPresented: $showAddPatient) {
            AddPatientView()
        }
        .background(
            NavigationLink(destination: HealthCategoriesView(patientId: patientId),
                           isActive: .constant(patientId != "")) {
                EmptyView()
            }
        )
        .onReceive(NotificationCenter.default.publisher(for: .newPatientAdded)) { notification in
            if let patientId = notification.object as? String {
                self.patientId = patientId
            }
        }
    }
}

struct AddPatientView: View {
    @StateObject private var viewModel = AddPatientViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("Patient ID")) {
                HStack {
                    Text("Patient ID")
                    Spacer()
                    Button(action: {
                        // Handle patient ID image selection
                    }) {
                        Image(systemName: "camera")
                    }
                }
            }
            
            Section(header: Text("Personal Information")) {
                TextField("First Name", text: $viewModel.firstName)
                TextField("Middle Name", text: $viewModel.middleName)
                TextField("Last Name", text: $viewModel.lastName)
                DatePicker("Date of Birth", selection: $viewModel.dateOfBirth, displayedComponents: .date)
                Picker("Blood Group", selection: $viewModel.bloodGroup) {
                    ForEach(BloodGroup.allCases, id: \.self) { bloodGroup in
                        Text(bloodGroup.rawValue)
                    }
                }
                Picker("RH Factor", selection: $viewModel.rhFactor) {
                    Text("Positive").tag(RHFactor.positive)
                    Text("Negative").tag(RHFactor.negative)
                }
                Picker("Marital Status", selection: $viewModel.maritalStatus) {
                    Text("Single").tag(MaritalStatus.single)
                    Text("Married").tag(MaritalStatus.married)
                    Text("Divorced").tag(MaritalStatus.divorced)
                    Text("Widowed").tag(MaritalStatus.widowed)
                }
                Picker("Age Format", selection: $viewModel.ageFormat) {
                    Text("Years").tag(AgeFormat.years)
                    Text("Months").tag(AgeFormat.months)
                    Text("Days").tag(AgeFormat.days)
                }
            }
            
            Section(header: Text("Contact Information")) {
                TextField("Phone Residence", text: $viewModel.phoneResidence)
                TextField("Mobile Phone", text: $viewModel.mobilePhone)
                TextField("Email Address", text: $viewModel.emailAddress)
            }
            
            Section(header: Text("Emergency Contact")) {
                TextField("Name", text: $viewModel.emergencyContactName)
                TextField("Phone Number", text: $viewModel.emergencyContactPhone)
                Toggle("Send SMS", isOn: $viewModel.sendEmergencySMS)
            }
            
            Section {
                Button("Save") {
                    viewModel.savePatientInformation() { success in
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Add Patient")
    }
}

class AddPatientViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var middleName: String = ""
    @Published var lastName: String = ""
    @Published var dateOfBirth: Date = Date()
    @Published var bloodGroup: BloodGroup = .aPositive
    @Published var rhFactor: RHFactor = .positive
    @Published var maritalStatus: MaritalStatus = .single
    @Published var ageFormat: AgeFormat = .years
    @Published var phoneResidence: String = ""
    @Published var mobilePhone: String = ""
    @Published var emailAddress: String = ""
    @Published var emergencyContactName: String = ""
    @Published var emergencyContactPhone: String = ""
    @Published var sendEmergencySMS: Bool = false
    @Published var patientId: String = ""
    
    private var db = Firestore.firestore()
    
    func savePatientInformation(completion: @escaping (Bool) -> Void) {
        let patientData: [String: Any] = [
            "firstName": firstName,
            "middleName": middleName,
            "lastName": lastName,
            "dateOfBirth": Timestamp(date: dateOfBirth),
            "bloodGroup": bloodGroup.rawValue,
            "rhFactor": rhFactor == .positive ? "Positive" : "Negative",
            "maritalStatus": String(describing: maritalStatus),
            "ageFormat": String(describing: ageFormat),
            "phoneResidence": phoneResidence,
            "mobilePhone": mobilePhone,
            "emailAddress": emailAddress,
            "emergencyContactName": emergencyContactName,
            "emergencyContactPhone": emergencyContactPhone,
            "sendEmergencySMS": sendEmergencySMS
        ]
        
        let patientRef = db.collection("patients").document()
                patientRef.setData(patientData) { error in
                    if let error = error {
                        print("Error adding patient: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Patient added successfully")
                        self.patientId = patientRef.documentID
                        NotificationCenter.default.post(name: .newPatientAdded, object: self.patientId)
                        completion(true)
                    }
                }
    }
}

extension Notification.Name {
    static let newPatientAdded = Notification.Name("NewPatientAdded")
}

struct HealthCategoriesView: View {
    let patientId: String
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Health Categories")) {
                    NavigationLink(destination: MedicalRecordsView(patientId: patientId)) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("Health")
                        }
                    }
                    NavigationLink(destination: PrescriptionsView(patientId: patientId)) {
                        HStack {
                            Image(systemName: "pills.fill")
                                .foregroundColor(.blue)
                            Text("Medication")
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Health Categories")
        }
    }
}

struct MedicalRecordsView: View {
    let patientId: String
    @StateObject private var viewModel: MedicalRecordsViewModel
    
    init(patientId: String) {
        self.patientId = patientId
        _viewModel = StateObject(wrappedValue: MedicalRecordsViewModel(patientId: patientId))
    }

    var body: some View {
        List {
            Section(header: Text("Current Illnesses")) {
                ForEach(viewModel.currentIllnesses, id: \.self) { illness in
                    Text(illness)
                }

                HStack {
                    TextField("New Illness", text: $viewModel.newIllness)
                    Button(action: {
                        if !viewModel.newIllness.isEmpty {
                            viewModel.currentIllnesses.append(viewModel.newIllness)
                            viewModel.newIllness = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }

            Section(header: Text("Previous Medical History")) {
                ForEach(viewModel.medicalHistory, id: \.self) { history in
                    Text(history)
                }

                HStack {
                    TextField("New Medical History", text: $viewModel.newMedicalHistory)
                    Button(action: {
                        if !viewModel.newMedicalHistory.isEmpty {
                            viewModel.medicalHistory.append(viewModel.newMedicalHistory)
                            viewModel.newMedicalHistory = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }

            Section(header: Text("Specific Allergies")) {
                ForEach(viewModel.allergies, id: \.self) { allergy in
                    Text(allergy)
                }

                HStack {
                    TextField("New Allergy", text: $viewModel.newAllergy)
                    Button(action: {
                        if !viewModel.newAllergy.isEmpty {
                            viewModel.allergies.append(viewModel.newAllergy)
                            viewModel.newAllergy = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Medical Records")
        .navigationBarItems(trailing: Button("Save", action: viewModel.saveMedicalRecords))
    }
}

class MedicalRecordsViewModel: ObservableObject {
    private let patientId: String
    @Published var currentIllnesses: [String] = []
    @Published var medicalHistory: [String] = []
    @Published var allergies: [String] = []
    @Published var newIllness: String = ""
    @Published var newMedicalHistory: String = ""
    @Published var newAllergy: String = ""
    
    private var db = Firestore.firestore()
    
    init(patientId: String) {
        self.patientId = patientId
        loadMedicalRecords()
    }
    
    func loadMedicalRecords() {
        db.collection("patients").document(patientId).collection("medicalRecords").document("records").getDocument { snapshot, error in
            if let error = error {
                print("Error retrieving medical records: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No medical records found")
                return
            }
            
            self.currentIllnesses = data["currentIllnesses"] as? [String] ?? []
            self.medicalHistory = data["medicalHistory"] as? [String] ?? []
            self.allergies = data["allergies"] as? [String] ?? []
        }
    }
    
    func saveMedicalRecords() {
        let medicalRecordsData: [String: Any] = [
            "currentIllnesses": currentIllnesses,
            "medicalHistory": medicalHistory,
            "allergies": allergies
        ]
        
        db.collection("patients").document(patientId).collection("medicalRecords").document("records").setData(medicalRecordsData) { error in
            if let error = error {
                print("Error saving medical records: \(error.localizedDescription)")
            } else {
                print("Medical records saved successfully")
                self.newIllness = ""
                self.newMedicalHistory = ""
                self.newAllergy = ""
            }
        }
    }
}

// Model for Prescription
struct Prescription: Identifiable, Codable {
    let id = UUID()
    var name: String
    var dosage: String
    var frequency: String
    var startDate: Date
    var endDate: Date

    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "dosage": dosage,
            "frequency": frequency,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate)
        ]
    }
}

struct PrescriptionsView: View {
    let patientId: String
    @StateObject private var viewModel: PrescriptionsViewModel
    
    init(patientId: String) {
        self.patientId = patientId
        _viewModel = StateObject(wrappedValue: PrescriptionsViewModel(patientId: patientId))
    }

    var body: some View {
        List {
            ForEach(viewModel.prescriptions) { prescription in
                VStack(alignment: .leading) {
                    Text(prescription.name)
                        .font(.headline)
                    Text("Dosage: \(prescription.dosage)")
                    Text("Frequency: \(prescription.frequency)")
                    Text("Start Date: \(formatDate(prescription.startDate))")
                    Text("End Date: \(formatDate(prescription.endDate))")
                }
            }

            Section(header: Text("New Prescription")) {
                TextField("Name", text: $viewModel.newPrescription.name)
                TextField("Dosage", text: $viewModel.newPrescription.dosage)
                TextField("Frequency", text: $viewModel.newPrescription.frequency)
                DatePicker("Start Date", selection: $viewModel.newPrescription.startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $viewModel.newPrescription.endDate, displayedComponents: .date)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Prescriptions")
        .navigationBarItems(trailing: Button("Save", action: viewModel.savePrescriptions))
    }

    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}

class PrescriptionsViewModel: ObservableObject {
    private let patientId: String
    @Published var prescriptions: [Prescription] = []
    @Published var newPrescription = Prescription(name: "", dosage: "", frequency: "", startDate: Date(), endDate: Date())
    
    private var db = Firestore.firestore()
    
    init(patientId: String) {
        self.patientId = patientId
        loadPrescriptions()
    }
    
    func loadPrescriptions() {
        db.collection("patients").document(patientId).collection("prescriptions").getDocuments { snapshot, error in
            if let error = error {
                print("Error retrieving prescriptions: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No prescriptions found")
                return
            }
            
            self.prescriptions = documents.compactMap { document in
                let data = document.data()
                guard let name = data["name"] as? String,
                      let dosage = data["dosage"] as? String,
                      let frequency = data["frequency"] as? String,
                      let startDate = (data["startDate"] as? Timestamp)?.dateValue(),
                      let endDate = (data["endDate"] as? Timestamp)?.dateValue() else {
                    return nil
                }
                return Prescription(name: name, dosage: dosage, frequency: frequency, startDate: startDate, endDate: endDate)
            }
        }
    }
    
    func savePrescriptions() {
        let prescriptionData: [String: Any] = [
            "name": newPrescription.name,
            "dosage": newPrescription.dosage,
            "frequency": newPrescription.frequency,
            "startDate": Timestamp(date: newPrescription.startDate),
            "endDate": Timestamp(date: newPrescription.endDate)
        ]
        
        db.collection("patients").document(patientId).collection("prescriptions").addDocument(data: prescriptionData) { error in
            if let error = error {
                print("Error saving prescription: \(error.localizedDescription)")
            } else {
                print("Prescription saved successfully")
                self.newPrescription = Prescription(name: "", dosage: "", frequency: "", startDate: Date(), endDate: Date())
            }
        }
    }
}

struct Patient: Identifiable, Codable {
    let id: String
    let firstName: String
    let middleName: String
    let lastName: String
    let dateOfBirth: Date
    let bloodGroup: String
    let rhFactor: String
    let maritalStatus: String
    let ageFormat: String
    let phoneResidence: String
    let mobilePhone: String
    let emailAddress: String
    let emergencyContactName: String
    let emergencyContactPhone: String
    let sendEmergencySMS: Bool
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.firstName = data["firstName"] as? String ?? ""
        self.middleName = data["middleName"] as? String ?? ""
        self.lastName = data["lastName"] as? String ?? ""
        self.dateOfBirth = (data["dateOfBirth"] as? Timestamp)?.dateValue() ?? Date()
        self.bloodGroup = data["bloodGroup"] as? String ?? ""
        self.rhFactor = data["rhFactor"] as? String ?? ""
        self.maritalStatus = data["maritalStatus"] as? String ?? ""
        self.ageFormat = data["ageFormat"] as? String ?? ""
        self.phoneResidence = data["phoneResidence"] as? String ?? ""
        self.mobilePhone = data["mobilePhone"] as? String ?? ""
        self.emailAddress = data["emailAddress"] as? String ?? ""
        self.emergencyContactName = data["emergencyContactName"] as? String ?? ""
        self.emergencyContactPhone = data["emergencyContactPhone"] as? String ?? ""
        self.sendEmergencySMS = data["sendEmergencySMS"] as? Bool ?? false
    }
}

struct PatientDetailsView: View {
    let patient: Patient
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // Personal Information
                VStack(alignment: .leading, spacing: 10) {
                    Text("Personal Information")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    InfoRow(label: "First Name", value: patient.firstName)
                    InfoRow(label: "Middle Name", value: patient.middleName)
                    InfoRow(label: "Last Name", value: patient.lastName)
                    InfoRow(label: "Date of Birth", value: formatDate(patient.dateOfBirth))
                    InfoRow(label: "Blood Group", value: patient.bloodGroup)
                    InfoRow(label: "RH Factor", value: patient.rhFactor)
                    InfoRow(label: "Marital Status", value: patient.maritalStatus)
                    InfoRow(label: "Age Format", value: patient.ageFormat)
                }
                
                // Contact Information
                VStack(alignment: .leading, spacing: 10) {
                    Text("Contact Information")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    InfoRow(label: "Phone Residence", value: patient.phoneResidence)
                    InfoRow(label: "Mobile Phone", value: patient.mobilePhone)
                    InfoRow(label: "Email Address", value: patient.emailAddress)
                }
                
                // Emergency Contact
                VStack(alignment: .leading, spacing: 10) {
                    Text("Emergency Contact")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    InfoRow(label: "Name", value: patient.emergencyContactName)
                    InfoRow(label: "Phone Number", value: patient.emergencyContactPhone)
                    InfoRow(label: "Send SMS", value: patient.sendEmergencySMS ? "Yes" : "No")
                }
                
                // Health Categories
                VStack(alignment: .leading, spacing: 10) {
                    Text("Health Categories")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    NavigationLink(destination: MedicalRecordsView(patientId: patient.id)) {
                        Text("Medical Records")
                    }
                    
                    NavigationLink(destination: PrescriptionsView(patientId: patient.id)) {
                        Text("Prescriptions")
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("\(patient.firstName) \(patient.lastName)")
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}

class PatientsViewModel: ObservableObject {
    @Published var patients: [Patient] = []
    
    private var db = Firestore.firestore()
    
    func fetchPatients() {
        db.collection("patients").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching patients: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No patients found")
                return
            }
            
            self.patients = documents.compactMap { document in
                let data = document.data()
                let id = document.documentID
                return Patient(id: id, data: data)
            }
        }
    }
}

struct PatientsView: View {
    @StateObject private var viewModel = PatientsViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.patients) { patient in
                NavigationLink(destination: PatientDetailsView(patient: patient)) {
                    VStack(alignment: .leading) {
                        Text("\(patient.firstName) \(patient.lastName)")
                            .font(.headline)
                        Text("DOB: \(formatDate(patient.dateOfBirth))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Patients")
        .onAppear {
            viewModel.fetchPatients()
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}

