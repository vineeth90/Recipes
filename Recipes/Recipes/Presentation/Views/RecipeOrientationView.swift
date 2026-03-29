//
//  RecipeOrientationView.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//

import SwiftUI

struct RecipeOrientationView: View {
  @Environment(\.verticalSizeClass) private var verticalSizeClass
  @ObservedObject var viewModel: RecipeViewModel

  private var isPortrait: Bool {
    verticalSizeClass == .regular
  }

  var body: some View {
    Group {
      if viewModel.isLoading {
        loadingView
      } else if let errorMessage = viewModel.errorMessage {
        errorView(message: errorMessage)
      } else if isPortrait {
        RecipeDetailView(recipe: viewModel.firstRecipe)
      } else {
        RecipeGridView(recipes: viewModel.recipes)
      }
    }
    .task {
      await viewModel.loadRecipes()
    }
  }

  private var loadingView: some View {
    VStack(spacing: 16) {
      ProgressView()
      Text("Loading recipes..")
        .font(.headline)
        .foregroundColor(.secondary)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Loading recipes")
  }

  private func errorView(message: String) -> some View {
    VStack(spacing: 16) {
      Text ("Error")
        .font(.headline)
      Text(message)
        .font(.body)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
  }
}
