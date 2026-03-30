//
//  RecipesApp.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//

import SwiftUI

@main
struct RecipesApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
          RecipeRootView(factory: container.viewModelFactory)
        }
    }
}
