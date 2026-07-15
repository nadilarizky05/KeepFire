//
//  DreamViews.swift
//  KeepFireV.2
//
//  Created by Nadila Rizky Amelia on 14/07/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: @autoclosure @escaping () -> HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: [.blue.opacity(0.8), .blue.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("KeepFire")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(Array(viewModel.dreams.enumerated()), id: \.element.id) { index, dream in
                            HStack {
                                if index % 2 != 0 { Spacer() }
                                CloudView(text: dream.text) {
                                    viewModel.skip(dream)
                                } onKeep: {
                                    viewModel.keep(dream)
                                }
                                if index % 2 == 0 { Spacer() }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                }
            }
        }
    }
}

struct CloudView: View {
    let text: String
    var onSkip: () -> Void
    var onKeep: () -> Void
    @State private var isFloating = false

    var body: some View {
        VStack {
            Text(text)
                .font(.caption).bold().multilineTextAlignment(.center)
                .padding(.horizontal, 38)
                .padding(.top, 10)
                .frame(width: 220, height: 100)
                .background(
                    Image(systemName: "cloud.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                )

            HStack {
                Button("SKIP", action: onSkip).modifier(BtnModifier(color: .red))
                Button("KEEP", action: onKeep).modifier(BtnModifier(color: .green))
            }
            .offset(y: -15)
        }
        .offset(x: isFloating ? -10 : 10)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever()) { isFloating = true }
        }
    }
}

struct BtnModifier: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
            .font(.body).bold().padding(6)
            .background(color).foregroundColor(.white).cornerRadius(8)
    }
}

struct MyCollectionView: View {
    @StateObject private var viewModel: MyCollectionViewModel
    let container: DependencyContainer

    init(viewModel: @autoclosure @escaping () -> MyCollectionViewModel, container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.container = container
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.savedDreams.isEmpty {
                    ContentUnavailableView(
                        "Belum ada dream yang di-Keep",
                        systemImage: "flame",
                        description: Text("Keep dream favoritmu dari tab All Fire")
                    )
                } else {
                    List(viewModel.savedDreams) { dream in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.seal.fill").foregroundColor(.green).font(.headline)
                            Text(dream.text)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if let chat = viewModel.chat(for: dream) {
                                NavigationLink(destination: ChatDetailView(viewModel: container.makeChatDetailViewModel(chatID: chat.id))) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Reached Out")
                                    }
                                    .font(.caption).bold()
                                    .padding(.horizontal, 10).padding(.vertical, 6)
                                    .background(Color.green).foregroundColor(.white).cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Button {
                                    viewModel.reachOut(to: dream)
                                } label: {
                                    Text("Reach Out")
                                        .font(.caption).bold()
                                        .padding(.horizontal, 10).padding(.vertical, 6)
                                        .background(Color.blue).foregroundColor(.white).cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 10))
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) { viewModel.delete(dream) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("KeepFire")
        }
    }
}

struct AddFireView: View {
    @StateObject private var viewModel: AddFireViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: @autoclosure @escaping () -> AddFireViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("What's your fire? 🔥").font(.title2.bold())
                TextField("Type your dream here...", text: $viewModel.dreamText, axis: .vertical)
                    .lineLimit(4...8)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                Spacer()
            }
            .padding()
            .navigationTitle("Add Fire")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        viewModel.submit()
                        dismiss()
                    }
                    .bold()
                    .disabled(!viewModel.canSubmit)
                }
            }
        }
    }
}
