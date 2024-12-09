import SwiftUI

struct PatientAnalyticsView: View {
    @StateObject private var viewModel = PatientsViewModel()

    var body: some View {
        ScrollView {
            VStack {
                Text("Patient Diagnosis Analytics")
                    .font(.title)
                    .padding()

                // Check if the patients array is populated before grouping
                if viewModel.isLoading {
                    Text("Loading patients...")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // Fetch the grouped data from the view model
                    let groupedPatients = viewModel.groupPatientsByDiagnosis()
                    //Text("Grouped Patients: \(groupedPatients)") // Debug output

                    if groupedPatients.isEmpty {
                        Text("No data available")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(Array(groupedPatients.keys.sorted()), id: \.self) { keywordGroup in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Keywords: \(keywordGroup)")
                                    .font(.headline)
                                Text("Total Patients: \(groupedPatients[keywordGroup]?.count ?? 0)")
                                    .font(.subheadline)

                                Divider()

                                ForEach(groupedPatients[keywordGroup] ?? []) { patient in
                                    VStack(alignment: .leading) {
                                        Text("• Name: \(patient.name)")
                                        Text("  Age: \(patient.age)")
                                            .foregroundColor(.secondary)
                                        Text("  Contact: \(patient.contactNumber)")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.bottom, 5)
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            // Ensure patients are fetched when the view appears
            Task {
                await viewModel.fetchPatients()
            }
        }
    }
}
