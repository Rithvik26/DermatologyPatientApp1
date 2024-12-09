import SwiftUI
@MainActor
class PatientStore: ObservableObject {
    @Published var patients: [Patient] = []
    private var patientService: PatientService
    
    init(patientService: PatientService = MockPatientService()) {
        self.patientService = patientService
        Task {
            await fetchPatients()
        }
    }
    
    func fetchPatients() async {
        do {
            let fetchedPatients = try await patientService.fetchPatients()
                       // Ensure that the update to the patients array is done on the main thread
                       DispatchQueue.main.async {
                           self.patients = fetchedPatients
                       }
                       print("Fetched patients: \(self.patients)")
        } catch {
            print("Error fetching patients: \(error)")
        }
    }
    
    func addPatient(_ patient: Patient) async {
        do {
            try await patientService.addPatient(patient)
            await fetchPatients()
        } catch {
            print("Error adding patient: \(error)")
        }
    }
}
struct PatientListView: View {
    @StateObject private var patientStore = PatientStore()
    @State private var showAddPatientView = false

    var body: some View {
        NavigationView {
            VStack {
                if patientStore.patients.isEmpty {
                    VStack {
                        Text("No Patients")
                            .foregroundColor(.gray)
                        Button(action: { showAddPatientView = true }) {
                            Label("Add First Patient", systemImage: "plus")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    List(patientStore.patients) { patient in
                        NavigationLink(destination: PatientDetailView(patient: patient)) {
                            VStack(alignment: .leading) {
                                Text(patient.name)
                                    .font(.headline)
                                Text("Age: \(patient.age)")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Patients")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showAddPatientView = true }) {
                        Label("Add Patient", systemImage: "plus")
                    }
                    NavigationLink(destination: PatientAnalyticsView()) {
                        Label("Group Analytics", systemImage: "chart.bar")
                    }
                }
            }
            .sheet(isPresented: $showAddPatientView) {
                AddPatientView(patientStore: patientStore)
                    .onDisappear {
                        Task {
                            await patientStore.fetchPatients()
                        }
                    }
            }
        }
    }
}
