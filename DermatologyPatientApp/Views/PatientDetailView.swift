import SwiftUI

struct PatientDetailView: View {
    @State var patient: Patient
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Patient Info Header
                patientInfoHeader
                
                // Diagnosis Details
                diagnosisSection
                
                // Image Gallery
                imageGallerySection
            }
            .padding()
        }
        .navigationTitle("Patient Details")
    }
    
    // Extracted Patient Info Header
    private var patientInfoHeader: some View {
        VStack(alignment: .leading) {
            Text(patient.name)
                .font(.title)
            Text("Age: \(patient.age)")
                .font(.subheadline)
            Text("Contact: \(patient.contactNumber)")
                .font(.subheadline)
        }
        .padding()
    }
    
    // Extracted Diagnosis Section
    private var diagnosisSection: some View {
        ForEach(patient.diagnoses) { diagnosis in
            VStack(alignment: .leading) {
                Text("Diagnosis")
                    .font(.headline)
                Text(diagnosis.description)
                
                Text("Treatment Notes")
                    .font(.headline)
                Text(diagnosis.treatmentNotes)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    // Extracted Image Gallery Section
    private var imageGallerySection: some View {
        VStack(alignment: .leading) {
            Text("Patient Images")
                .font(.headline)
            
            ScrollView(.horizontal) {
                HStack {
                    // Display existing images
                    ForEach(existingImageIndices, id: \.self) { index in
                        existingImageView(at: index)
                    }
                    
                    // Add Image Button
                    addImageButton
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImages: $selectedImages)
        }
    }
    
    // Helper to get existing image indices
    private var existingImageIndices: Range<Int> {
        guard let firstDiagnosis = patient.diagnoses.first else { return 0..<0 }
        return 0..<firstDiagnosis.imageData.count
    }
    
    // View for existing image
    private func existingImageView(at index: Int) -> some View {
        guard
            let firstDiagnosis = patient.diagnoses.first,
            let uiImage = UIImage(data: firstDiagnosis.imageData[index])
        else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(10)
        )
    }
    
    // Add Image Button
    private var addImageButton: some View {
        Button(action: { showImagePicker = true }) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
        }
    }
    
    // Method to add new images
    private func addNewImages(_ images: [UIImage]) {
        for image in images {
            if let data = image.jpegData(compressionQuality: 0.8) {
                // Ensure we have a diagnosis to add images to
                if patient.diagnoses.isEmpty {
                    patient.diagnoses.append(
                        Diagnosis(
                            id: UUID(),
                            date: Date(),
                            description: "No Description",
                            imageData: [],
                            treatmentNotes: ""
                        )
                    )
                }
                
                // Add image data to the first diagnosis
                patient.diagnoses[0].imageData.append(data)
            }
        }
    }
}
