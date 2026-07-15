//
//  KeepFireV_2App.swift
//  KeepFireV.2
//
//  Created by Nadila Rizky Amelia on 11/03/26.
//

import SwiftUI

@main
struct KeepFireV_2App: App {
    private let container = DependencyContainer()
     
        var body: some Scene {
            WindowGroup {
                ContentView(container: container)
            }
        }
}
