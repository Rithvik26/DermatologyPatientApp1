//
//  AddPatientView.swift
//  DermatologyPatientApp
//
//  Created by Rithvik Golthi on 12/9/24.
//
import SwiftUI

import PhotosUI

struct AddPatientView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var patientStore: PatientStore
    
    @State private var name = ""
    @State private var age = ""
    @State private var contactNumber = ""
    @State private var diagnosisDescription = ""
    @State private var treatmentNotes = ""
    @State private var selectedImages: [UIImage] = []
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Patient Information")) {
                    TextField("Name", text: $name)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Contact Number", text: $contactNumber)
                }
                
                Section(header: Text("Diagnosis Details")) {
                    TextField("Diagnosis Description", text: $diagnosisDescription)
                    TextField("Treatment Notes", text: $treatmentNotes)
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Label("Select Images", systemImage: "photo.on.rectangle")
                    }
                    
                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(selectedImages, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .frame(height: 110)
                    }
                }
                
                Button("Add Patient") {
                    Task {
                        let newPatient = Patient(
                            id: UUID(),
                            name: name,
                            age: Int(age) ?? 0,
                            contactNumber: contactNumber,
                            diagnoses: [
                                Diagnosis(
                                    id: UUID(),
                                    date: Date(),
                                    description: diagnosisDescription,
                                    imageData: selectedImages.map { $0.jpegData(compressionQuality: 0.8) ?? Data() },
                                    treatmentNotes: treatmentNotes
                                )
                            ]
                        )
                        await patientStore.addPatient(newPatient)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(name.isEmpty || age.isEmpty)
            }
            .navigationTitle("Add New Patient")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImages: $selectedImages)
            }
        }
    }
}
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0 // Allow multiple selections
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                        if let image = object as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.selectedImages.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}
