import SwiftUI
import NaturalLanguage

class PatientsViewModel: ObservableObject {
    @Published var patients: [Patient] = []
    @Published var isLoading: Bool = true // Track loading state
    private var patientService: PatientService

    // Initialize with default service (can be swapped with another service for testing)
    init(patientService: PatientService = MockPatientService()) {
        self.patientService = patientService
        // Fetch patients on initialization
        Task {
            await fetchPatients()
        }
    }

    // Fetch all patients from the service asynchronously
    @MainActor
    func fetchPatients() async {
        do {
            self.isLoading = true // Start loading
            let fetchedPatients = try await patientService.fetchPatients()
            
            // Update the state on the main thread
            self.patients = fetchedPatients
            self.isLoading = false // Stop loading once data is fetched
            
            print("Fetched patients from Patientviewmodel: \(self.patients)")
        } catch {
            // Handle any errors during the fetch operation
            print("Error fetching patients: \(error)")
            
            // Stop loading on main thread in case of error
            self.isLoading = false
        }
    }

    // Add a new patient to the list
    func addPatient(_ patient: Patient) async {
        do {
            // Add the new patient to the service
            try await patientService.addPatient(patient)
            
            // After adding, manually append to the patients array for immediate UI update
            self.patients.append(patient)

        } catch {
            print("Error adding new patient: \(error)")
        }
    }

    // Update an existing patient's information
    func updatePatient(_ patient: Patient) async {
        do {
            // Update the patient in the service
            try await patientService.updatePatient(patient)
            
            // Update the patient in the local patients array
            if let index = self.patients.firstIndex(where: { $0.id == patient.id }) {
                self.patients[index] = patient
            }

        } catch {
            print("Error updating patient: \(error)")
        }
    }

    // Group patients based on diagnosis and treatment notes
    func groupPatientsByDiagnosis() -> [String: [Patient]] {
        var groupedPatients: [String: [Patient]] = [:]

        for patient in patients {
            for diagnosis in patient.diagnoses {
                let keywords = extractKeywords(from: diagnosis.description + " " + diagnosis.treatmentNotes)
                let key = keywords.joined(separator: ", ")
                groupedPatients[key, default: []].append(patient)
            }
        }
        return groupedPatients
    }

    // Helper method to extract meaningful keywords from diagnosis and treatment notes
    private func extractKeywords(from text: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text.lowercased()
        
        var keywords: [String] = []
        
        // Enumerate over the words in the string and capture relevant ones (nouns, verbs)
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: [.omitPunctuation, .omitWhitespace]) { tag, tokenRange in
            if let tag = tag, (tag == .noun || tag == .verb) {
                let word = String(text[tokenRange])
                if word.count > 2 { // Avoid short words
                    keywords.append(word)
                }
            }
            return true
        }
        
        return Array(Set(keywords)).sorted()
    }
}
