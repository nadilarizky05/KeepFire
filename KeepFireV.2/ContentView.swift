//
//  ContentView.swift
//  KeepFireV.2
//
//  Created by Nadila Rizky Amelia on 11/03/26.
//

import SwiftUI
import Observation

struct Dream: Identifiable, Equatable {
    let id = UUID()
    var text: String
}

@Observable
class DreamStore {
    var savedDreams: [Dream] = []
}

struct ContentView: View {
    @State private var store = DreamStore()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Dream Sky", systemImage: "cloud.sun.fill") }
                .environment(store)
            
            MyCollectionView()
                .tabItem { Label("My Fire", systemImage: "flame.fill") }
                .environment(store)
            
            InputView()
                .tabItem { Label("New", systemImage: "plus") }
                .environment(store)
        }
    }
}

struct HomeView: View {
    @Environment(DreamStore.self) var store
    @State var dreams = [
        // --- Apple & Career ---
        "Become a World Class iOS Developer",
        "Win the Swift Student Challenge",
        "Get an internship at Apple Singapore",
        "Work as a Software Engineer at Apple Park",
        "Publish an app that gets Featured on the App Store",
        "Meet Tim Cook in person at WWDC",
        "Present my app at the Academy's Graduation Day",
        "Become a Tech Lead in a global startup",
        "Master SwiftUI and Combine frameworks",
        "Get a job at a FAANG company",
        "Build a startup that reaches Unicorn status",
        "Collaborate with international developers",
        "Contribute to an open-source Swift project",
        "Learn Machine Learning with CoreML",
        "Create a viral AR experience using RealityKit",

        // --- Education & Scholarship ---
        "Get an LOA from Harvard University",
        "Pursue a Master's degree in Australia",
        "Win a Fulbright Scholarship",
        "Study Human-Computer Interaction at Stanford",
        "Get into MIT for Computer Science",
        "Pass the IELTS with a band score of 8.0",
        "Attend a tech conference in Europe",
        "Become a mentor for junior developers",
        "Write a research paper on AI ethics",
        "Get a scholarship for Oxford University",

        // --- Personal & Lifestyle ---
        "Buy a MacBook Pro M3 Max for my mom",
        "Renovate my mother's kitchen",
        "Travel around the world while working remotely",
        "Build a dream house in Bali",
        "Speak fluently in English for professional presentations",
        "Have 10,000 active users on my app",
        "Finish a marathon while at the Academy",
        "Start a YouTube channel about coding",
        "Create a non-profit tech community for kids",
        "Achieve financial freedom before 30",
        "Write a book about my journey in tech",
        "Be a speaker at a TEDx event",
        "Learn to play the piano in my spare time",
        "Build a smart home system for my family",
        "Donate a portion of my first salary to charity",

        // --- Specific Academy Vibes ---
        "Create a pixel-perfect UI design",
        "Build an app that solves a real-world problem in Indonesia",
        "Pass the Academy technical challenge with flying colors",
        "Make a game that people play every day",
        "Design an accessible app for people with disabilities",
        "Master the art of Storytelling in presentations",
        "Get a 'Keep' on every dream cloud I make",
        "Integrate Apple Watch features into my app",
        "Create a seamless iPadOS experience",
        "Develop a VisionOS app for the future"
    ].map { Dream(text: $0) }
    
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(gradient: Gradient(colors: [
                .blue.opacity(0.8),
                .blue.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("KeepFire")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    .background(Color.clear)
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(dreams) { item in
                            let isLeft = (dreams.firstIndex(of: item) ?? 0) % 2 == 0
                            
                            HStack {
                                if !isLeft { Spacer() }
                                
                                CloudView(text: item.text) {
                                    removeDream(item)
                                } onKeep: {
                                    store.savedDreams.append(item)
                                    removeDream(item)
                                }
                            
                                if isLeft { Spacer() }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                }
            }
        }
    }
    
    func removeDream(_ dream: Dream) {
        dreams.removeAll { $0.id == dream.id }
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

struct MyCollectionView: View {
    @Environment(DreamStore.self) var store
    
    var body: some View {
        NavigationStack {
            Text("KeepFire")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .padding(.top, 10)
                .padding(.bottom, 20)
                .background(Color.clear)
            List(store.savedDreams) { dream in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .font(.headline)
                    
                    Text(dream.text)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 10))
            }
            .listStyle(.plain)
        }
    }
}

struct InputView: View {
    var body: some View {
        Text("tes")
    }
}

struct BtnModifier: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
            .font(.body)
            .bold()
            .padding(6)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

#Preview {
    ContentView()
}
