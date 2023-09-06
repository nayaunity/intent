//
//  MessagingView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/5/23.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore

struct MessagingView: View {
    var user: User
    var senderID: String
    
    @State private var messages: [Message] = []
    @State private var newMessage: String = ""
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: ProfileView(user: user)) {
                VStack(spacing: 8) {
                    WebImage(url: URL(string: user.profilePictureUrl))
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 95, height: 95)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    
                    Text(user.name)
                        .font(.headline)
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle()) // This ensures the area doesn't get highlighted on tap
            Divider()
            
            // Messages
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(messages) { message in
                        if message.isCurrentUser {
                            CurrentUserMessageView(message: message.content)
                        } else {
                            OtherUserMessageView(message: message.content)
                        }
                    }
                }
                .padding()
            }
            // Input Field
            Divider()
            HStack {
                TextField("Type a message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: sendMessage) {
                    Text("Send")
                }
                .padding(.trailing)
                .disabled(newMessage.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.vertical)
        }
        .onAppear(perform: loadMessages)
    }
    
    
    func sendMessage() {
        let trimmedMessage = newMessage.trimmingCharacters(in: .whitespaces)

        if !trimmedMessage.isEmpty {
            // Create a new document in the "messages" collection
            let messageData: [String: Any] = [
                "senderID": senderID, // Use the sender's ID obtained from the parameter
                "receiverID": user.id, // the receiver's ID
                "content": trimmedMessage,
                "timestamp": Timestamp(date: Date())
            ]

            db.collection("messages").addDocument(data: messageData) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                } else {
                    // Message sent successfully, you can update your UI or handle acknowledgments here
                    messages.append(Message(content: trimmedMessage, isCurrentUser: true))
                    newMessage = ""
                }
            }
        }
    }

    
    // Load messages from Firestore (implement this)
    func loadMessages() {
        db.collection("messages")
            .whereField("senderID", in: [senderID, user.id]) // Corrected sender and receiver IDs
            .whereField("receiverID", in: [senderID, user.id]) // Corrected sender and receiver IDs
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("No messages available")
                    return
                }

                messages = documents.compactMap { document in
                    let data = document.data()
                    let senderID = data["senderID"] as? String ?? ""
                    let content = data["content"] as? String ?? ""
                    let isCurrentUser = senderID == self.senderID // Use self.senderID to avoid shadowing
                    return Message(content: content, isCurrentUser: isCurrentUser)
                }
            }
    }
}

struct CurrentUserMessageView: View {
    var message: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(message)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
        .padding(.horizontal)
    }
}

struct OtherUserMessageView: View {
    var message: String
    
    var body: some View {
        HStack {
            Text(message)
                .padding()
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct Message: Identifiable {
    var id = UUID()
    var content: String
    var isCurrentUser: Bool
}

//struct MessagingView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessagingView(user: User(name: "John Doe"))
//    }
//}
