//
//  ChatViews.swift
//  KeepFireV.2
//
//  Created by Nadila Rizky Amelia on 14/07/26.
//

import SwiftUI

struct LetMeCookView: View {
    @StateObject private var viewModel: LetMeCookViewModel
    let container: DependencyContainer

    init(viewModel: @autoclosure @escaping () -> LetMeCookViewModel, container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.container = container
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.chats.isEmpty {
                    ContentUnavailableView(
                        "Belum ada chat",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Tekan \"Reach Out\" di tab My Fire untuk mulai ngobrol")
                    )
                } else {
                    List(viewModel.chats) { chat in
                        NavigationLink(destination: ChatDetailView(viewModel: container.makeChatDetailViewModel(chatID: chat.id))) {
                            HStack(spacing: 12) {
                                Text(chat.avatarEmoji)
                                    .font(.system(size: 30))
                                    .frame(width: 50, height: 50)
                                    .background(Color.blue.opacity(0.15))
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(chat.contactName).font(.headline)
                                    Text(chat.messages.last?.text ?? "Draft: \(chat.draftText)")
                                        .font(.subheadline)
                                        .foregroundColor(chat.messages.isEmpty ? .orange : .secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                                Text(chat.messages.isEmpty ? "Draft" : "Now")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) { viewModel.delete(chat) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Let Me Cook")
        }
    }
}

struct ChatDetailView: View {
    @StateObject private var viewModel: ChatDetailViewModel

    init(viewModel: @autoclosure @escaping () -> ChatDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let chat = viewModel.chat {
                        Text("About: \(chat.dreamText)")
                            .font(.caption).foregroundColor(.secondary).padding(.bottom, 4)

                        if chat.messages.isEmpty {
                            Text("Belum ada pesan terkirim. Edit template di bawah lalu tekan kirim ✈️")
                                .font(.caption).foregroundColor(.secondary).padding(.vertical, 20)
                        }

                        ForEach(chat.messages) { message in
                            HStack {
                                if message.isMe { Spacer(minLength: 40) }
                                Text(message.text)
                                    .padding(10)
                                    .background(message.isMe ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(message.isMe ? .white : .primary)
                                    .cornerRadius(14)
                                if !message.isMe { Spacer(minLength: 40) }
                            }
                        }
                    }
                }
                .padding()
            }

            Divider()

            HStack(alignment: .bottom, spacing: 10) {
                TextField("Type a message...", text: $viewModel.draftText, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(18)

                Button {
                    viewModel.send()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                }
                .disabled(!viewModel.canSend)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .navigationTitle(viewModel.chat?.contactName ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}
