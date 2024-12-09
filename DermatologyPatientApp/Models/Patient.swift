//
//  Patient.swift
//  DermatologyPatientApp
//
//  Created by Rithvik Golthi on 12/9/24.
//

import Foundation


// 1. Update Patient Model to support multiple local images
struct Patient: Identifiable, Codable {
    let id: UUID
    var name: String
    var age: Int
    var contactNumber: String
    var diagnoses: [Diagnosis]
}
