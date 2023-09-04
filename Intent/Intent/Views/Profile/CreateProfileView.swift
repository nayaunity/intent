//
//  CreateProfileView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/3/23.
//

import Foundation
import SwiftUI

struct CreateProfileView: View {
    @State private var name: String = ""
    @State private var selectedSex: String = ""
    @State private var selectedGenderIdentity: String = ""
    @State private var bio: String = ""
    @State private var profileImage: Image? = nil
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    let sexes = ["Male", "Female"]
    let genderIdentities = ["Man", "Woman", "Non-binary"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    
                    Picker("Sex", selection: $selectedSex) {
                        ForEach(sexes, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    Picker("Gender Identity", selection: $selectedGenderIdentity) {
                        ForEach(genderIdentities, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    TextEditor(text: $bio)
                        .frame(height: 150)
                        .cornerRadius(8.0)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                }
                
                Section(header: Text("Profile Picture")) {
                    if profileImage != nil {
                        profileImage?
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        self.showingImagePicker = true
                    }) {
                        Text("Select a profile picture")
                    }
                }
            }
            .navigationBarTitle("Create Profile", displayMode: .inline)
            .navigationBarItems(trailing: Button("Save", action: saveProfile))
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    func saveProfile() {
        // Implement the save logic here.
        // For instance, save the profile data to Firebase or another backend.
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
    }
}

struct CreateProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProfileView()
    }
}

// ImagePicker for selecting the profile image
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

//struct CreateProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateProfileView()
//    }
//}

