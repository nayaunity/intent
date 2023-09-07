////
////  RatingAlertView.swift
////  Intent
////
////  Created by Nyaradzo Bere on 9/7/23.
////
//
//import Foundation
//import SwiftUI
//
//struct RatingAlertView: View {
//    var title: String
//    var message: String
//    var dismissButtonTitle: String
//
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
//
//            VStack(spacing: 20) {
//                Text(title)
//                    .font(.title)
//                    .bold()
//                    .foregroundColor(.white)
//
//                Text(message)
//                    .font(.body)
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 20)
//
//                Button(action: {
//                    // Handle the dismiss action here
//                }) {
//                    Text(dismissButtonTitle)
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                }
//            }
//            .padding(20)
//            .background(Color.gray)
//            .cornerRadius(20)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//    }
//}
