////
////  MessagingViewModel.swift
////  Intent
////
////  Created by Nyaradzo Bere on 9/6/23.
////
//
//import Foundation
//import Firebase
//import FirebaseFirestore
//
//class MessagingViewModel: ObservableObject {
//    @Published var messages: [Message] = []
//    
//    private var db = Firestore.firestore()
//    
//    func sendMessage(userId: String, recipientId: String, text: String) {
//        let docId = [userId, recipientId].sorted().joined(separator: "_")
//        let data: [String: Any] = [
//            "text": text,
//            "senderId": userId,
//            "timestamp": Timestamp(date: Date())
//        ]
//        db.collection("messages").document(docId).collection("conversations").addDocument(data: data)
//    }
//    
//    func fetchMessages(userId: String, recipientId: String) {
//        let docId = [userId, recipientId].sorted().joined(separator: "_")
//        db.collection("messages").document(docId).collection("conversations").order(by: "timestamp").addSnapshotListener { (snapshot, error) in
//            guard let documents = snapshot?.documents else {
//                print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            self.messages = documents.compactMap { Message(snapshot: $0) }
//        }
//    }
//}
