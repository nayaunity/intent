//
//  FeedbackView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/3/23.
//

import Foundation
import SwiftUI

struct FeedbackView: View {
    @State private var feedback: String = ""

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            TextField("Feedback", text: $feedback)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .autocapitalization(.none)
            
            Button("Submit", action: submitFeedback)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding(.horizontal, 40)
    }

    func submitFeedback() {
        // Handle feedback submission
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
