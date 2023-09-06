//
//  MessagingView.swift
//  Intent
//
//  Created by Nyaradzo Bere on 9/5/23.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct MessagingView: View {
    var user: User
    
    @State private var messages: [Message] = []
    @State private var newMessage: String = ""
    
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
    }
    
    func sendMessage() {
        let trimmedMessage = newMessage.trimmingCharacters(in: .whitespaces)
        
        if !trimmedMessage.isEmpty {
            messages.append(Message(content: trimmedMessage, isCurrentUser: true)) // Assume current user is sending the message for this demo
            newMessage = ""
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

struct MessagingView_Previews: PreviewProvider {
    static var previews: some View {
        MessagingView(user: User(name: "John Doe"))
    }
}
