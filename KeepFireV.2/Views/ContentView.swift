//
//  ContentView.swift
//  KeepFireV2
//

import SwiftUI

struct ContentView: View {
    let container: DependencyContainer
    @State private var selectedTab = 0
    @State private var showAddFireSheet = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: container.makeHomeViewModel())
                .tabItem { Label("All Fire", systemImage: "flame.fill") }
                .tag(0)

            MyCollectionView(viewModel: container.makeMyCollectionViewModel(), container: container)
                .tabItem { Label("My Fire", systemImage: "flame.circle") }
                .tag(1)

            Color.clear
                .tabItem { Label("Add Fire", systemImage: "plus") }
                .tag(2)

            LetMeCookView(viewModel: container.makeLetMeCookViewModel(), container: container)
                .tabItem { Label("Let Me Cook", systemImage: "ellipsis.message") }
                .tag(3)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 2 {
                showAddFireSheet = true
                selectedTab = oldValue
            }
        }
        .sheet(isPresented: $showAddFireSheet) {
            AddFireView(viewModel: container.makeAddFireViewModel())
                .presentationDetents([.fraction(0.45), .medium])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    ContentView(container: DependencyContainer(inMemory: true))
}
