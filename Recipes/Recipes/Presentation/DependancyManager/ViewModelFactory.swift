//
//  ViewModelFactory.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import Foundation

final class ViewModelFactory {

  // MARK: - Properties

  private let recipeRepository: RecipeRepositoryProtocol

  // MARK: - Initialization

  init(recipeRepository: RecipeRepositoryProtocol) {
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

