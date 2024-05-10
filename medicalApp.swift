//
//  medicalApp.swift
//  medical
//
//  Created by Renay  on 4/25/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

// AppDelegate to handle Firebase initialization
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// Main entry point of your app
@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ProfileSettingsView()
            }
        }
    }
}

// ViewModel to handle data logic
class ProfileSettingsViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var sex: String = "Male"
    @Published var birthday: Date = Date()
    @Published var profileImage: UIImage?
    @Published var isImagePickerShowing = false
    private var db = Firestore.firestore()
    private var storage = Storage.storage()

    // Function to load user data
    func loadUserData() {
        // Implementation to load user data including profile image from Firestore
    }

    // Function to save user data
    func saveUserData() {
        let userId = "user_id"  // This should be dynamically assigned based on authenticated user.
        db.collection("users").document(userId).setData([
            "Name": name,
            "Email Address": email,
            "Sex": sex,
            "Birthday": Timestamp(date: birthday)
        ]) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
                self.uploadProfileImage(userId: userId)
            }
        }
    }

    // Upload Profile Image
    func uploadProfileImage(userId: String) {
        guard let imageData = profileImage?.jpegData(compressionQuality: 0.5) else { return }
        let storageRef = storage.reference().child("profile_images/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error)")
                return
            }
            print("Profile image successfully uploaded.")
        }
    }

    // Function to trigger image picker
    func showImagePicker() {
        isImagePickerShowing = true
    }
}

// View for Profile Settings
struct ProfileSettingsView: View {
    @StateObject private var viewModel = ProfileSettingsViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false // Persistent storage for theme preference

    var body: some View {
        NavigationView {
            VStack {
                profileImageSection
                formSection
            }
            .navigationTitle("Profile Settings")
            .sheet(isPresented: $viewModel.isImagePickerShowing) {
                ImagePicker(image: $viewModel.profileImage, isShown: $viewModel.isImagePickerShowing)
            }
            .onAppear {
                viewModel.loadUserData()
            }
        }
        .environment(\.colorScheme, isDarkMode ? .dark : .light) // Apply theme based on the toggle
    }

    var profileImageSection: some View {
        VStack {
            if let profileImage = viewModel.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 4))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 4))
            }
            Button("Change Profile Picture") {
                viewModel.showImagePicker()
            }
            .padding(.bottom, 20) // Adjust padding as needed
        }
    }

    var formSection: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Name", text: $viewModel.name)
                TextField("Email", text: $viewModel.email)
                Picker("Sex", selection: $viewModel.sex) {
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                    Text("Other").tag("Other")
                }
                DatePicker("Birthday", selection: $viewModel.birthday, displayedComponents: .date)
            }
            Section {
                Toggle(isOn: $isDarkMode) {
                    Text("Dark Mode")
                }
                .onChange(of: isDarkMode) { value in
                    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = value ? .dark : .light
                }
            }
            Button("Save Changes", action: viewModel.saveUserData)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
    
    // ImagePicker component to handle image picking
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        @Binding var isShown: Bool
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        }
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(image: $image, isShown: $isShown)
        }
        
        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            @Binding var image: UIImage?
            @Binding var isShown: Bool
            
            init(image: Binding<UIImage?>, isShown: Binding<Bool>) {
                _image = image
                _isShown = isShown
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                image = uiImage
                isShown = false
            }
            
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                isShown = false
            }
        }
    }
    

