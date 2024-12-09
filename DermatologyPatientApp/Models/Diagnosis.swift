//
//  Diagnosis.swift
//  DermatologyPatientApp
//
//  Created by Rithvik Golthi on 12/9/24.
//
import Foundation

struct Diagnosis: Identifiable, Codable {
    let id: UUID
    var date: Date
    var description: String
    var imageData: [Data]  // Changed to store image data locally
    var treatmentNotes: String
}
