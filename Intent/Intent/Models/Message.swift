////
////  Message.swift
////  Intent
////
////  Created by Nyaradzo Bere on 9/6/23.
////
//
//import Foundation
//import SwiftUI
//import Firebase
//
//// Model
//
//struct Message: Identifiable {
//    var id: String
//    var text: String
//    var senderId: String
//    var timestamp: Date
//    
//    init?(snapshot: QueryDocumentSnapshot) {
//        guard let text = snapshot["text"] as? String,
//              let senderId = snapshot["senderId"] as? String,
//              let timestamp = snapshot["timestamp"] as? Timestamp else {
//            return nil
//        }
//        self.id = snapshot.documentID
//        self.text = text
//        self.senderId = senderId
//        self.timestamp = timestamp.dateValue()
//    }
//}
