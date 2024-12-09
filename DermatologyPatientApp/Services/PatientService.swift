import Foundation

// PatientService Protocol remains the same
protocol PatientService {
    func fetchPatients() async throws -> [Patient]
    func addPatient(_ patient: Patient) async throws
    func updatePatient(_ patient: Patient) async throws
}

class RealPatientService: PatientService {
    
    private let baseUrl: URL
    
    // Initialize with the base URL (API endpoint)
    init(baseUrl: URL) {
        self.baseUrl = baseUrl
    }
    
    // Fetch all patients from the backend
    func fetchPatients() async throws -> [Patient] {
        let url = baseUrl.appendingPathComponent("/patients")
        
        // Create URLRequest for GET request to fetch patients
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Perform network request using URLSession
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check the response status code
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Decode the JSON data into an array of Patient objects
        let decoder = JSONDecoder()
        let patients = try decoder.decode([Patient].self, from: data)
        
        return patients
    }
    
    // Add a new patient
    func addPatient(_ patient: Patient) async throws {
        let url = baseUrl.appendingPathComponent("/patients")
        
        // Create URLRequest for POST request to add a patient
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Encode the patient data into JSON
        let encoder = JSONEncoder()
        let patientData = try encoder.encode(patient)
        
        request.httpBody = patientData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Perform the network request using URLSession
        let (_, response) = try await URLSession.shared.data(for: request)
        
        // Check the response status code
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
    }
    
    // Update an existing patient
    func updatePatient(_ patient: Patient) async throws {
        let url = baseUrl.appendingPathComponent("/patients/\(patient.id.uuidString)")
        
        // Create URLRequest for PUT request to update a patient
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // Encode the patient data into JSON
        let encoder = JSONEncoder()
        let patientData = try encoder.encode(patient)
        
        request.httpBody = patientData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Perform the network request using URLSession
        let (_, response) = try await URLSession.shared.data(for: request)
        
        // Check the response status code
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}


class MockPatientService: PatientService {
    // In-memory storage of patients (mock database)
    private var patients: [Patient] = [
        Patient(id: UUID(), name: "John Doe", age: 30, contactNumber: "123-456-7890", diagnoses: [
            Diagnosis(id: UUID(), date: Date(), description: "Flu", imageData: [], treatmentNotes: "Rest and hydration")
        ]),
        Patient(id: UUID(), name: "Jane Smith", age: 25, contactNumber: "987-654-3210", diagnoses: [
            Diagnosis(id: UUID(), date: Date(), description: "Cold", imageData: [], treatmentNotes: "Take it easy")
        ])
    ]
    
    // Fetch all patients
    func fetchPatients() async throws -> [Patient] {
        return patients
    }
    
    // Add a new patient
    func addPatient(_ patient: Patient) async throws {
        patients.append(patient)
    }
    
    // Update an existing patient
    func updatePatient(_ patient: Patient) async throws {
        if let index = patients.firstIndex(where: { $0.id == patient.id }) {
            patients[index] = patient
        }
    }
}
