//
//  ViewModelFactory.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import Foundation
import SwiftUI

final class ViewModelFactory {

  // MARK: - Properties

  private let recipeRepository: RecipeRepositoryProtocol

  // MARK: - Initialization

  init(recipeRepository: RecipeRepositoryProtocol = LocalRecipeRepository()) {
    self.recipeRepository = recipeRepository
  }

  // MARK: - Methods

  func makeRecipeViewModel() -> RecipeViewModel {
    RecipeViewModel(
      getRecipeUseCase: GetRecipesUseCase(repository: recipeRepository),
      sortRecipeUseCase: SortRecipesUseCase()
    )
  }

}

// MARK: - Environment Key

private struct ViewModelFactoryKey: EnvironmentKey {
  static let defaultValue: ViewModelFactory = ViewModelFactory()
}

extension EnvironmentValues {
  var viewModelFactory: ViewModelFactory {
    get { self[ViewModelFactoryKey.self] }
    set { self[ViewModelFactoryKey.self] = newValue }
  }
}
