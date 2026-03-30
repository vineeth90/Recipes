//
//  RecipeRootView.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import SwiftUI

struct RecipeRootView: View {
  @Environment(\.viewModelFactory) private var factory

  var body: some View {
    RecipeOrientationView(viewModel: factory.makeRecipeViewModel())
  }
}
