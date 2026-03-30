//
//  RecipeRootView.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import SwiftUI

struct RecipeRootView: View {
  let factory: ViewModelFactory

  var body: some View {
    RecipeRootContentView(factory: factory)
  }
}

private struct RecipeRootContentView: View {
  @StateObject private var viewModel: RecipeViewModel

  init(factory: ViewModelFactory) {
    _viewModel = StateObject(wrappedValue: factory.makeRecipeViewModel())
  }

  var body: some View {
    RecipeOrientationView(viewModel: viewModel)
  }
}
