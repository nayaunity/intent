//
//  FilterView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/6/23.
//

import Foundation
import SwiftUI

struct FilterView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedGenders: Set<String>
    var onApplyFilters: (() -> Void)? = nil // Callback for applying filters
    
    private let genderOptions = ["Man", "Woman", "Non-binary"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Genders to Swipe On")
                .font(.headline)
            
            ForEach(genderOptions, id: \.self) { gender in
                Button(action: {
                    if selectedGenders.contains(gender) {
                        selectedGenders.remove(gender)
                    } else {
                        selectedGenders.insert(gender)
                    }
                }) {
                    Text(gender)
                        .padding()
                        .foregroundColor(selectedGenders.contains(gender) ? .white : .black)
                        .background(selectedGenders.contains(gender) ? Color(hex: "21258a") : Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            Button(action: {
                onApplyFilters?()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Apply")
                    .foregroundColor(Color(hex: "21258a"))
            }
            
            Spacer()
        }
        .padding()
    }
}
