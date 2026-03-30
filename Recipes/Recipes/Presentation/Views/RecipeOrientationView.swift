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
    contentView
    .task {
      await viewModel.loadRecipes()
    }
  }

  @ViewBuilder
  private var contentView: some View {
    switch viewModel.viewState {
    case .loading:
      loadingView
    case .recipes(let recipes):
      if isPortrait {
        RecipeDetailView(recipe: recipes.first)
      } else {
        RecipeGridView(recipes: recipes)
      }
    case .empty:
      emptyView
    case .error(let message):
      errorView(message: message)
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

  private var emptyView: some View {
    VStack(alignment: .center, spacing: 16) {
      Spacer()
      Text("No recipe available")
        .font(.headline)
        .foregroundColor(.secondary)
      Spacer()
    }
  }
}
