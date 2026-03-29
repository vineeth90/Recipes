//
//  RecipeViewModel.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import Foundation
import Combine

final class RecipeViewModel: ObservableObject {

  // MARK: - Properties

  @Published private(set) var recipes: [Recipe] = []
  @Published private(set) var isLoading = false
  @Published private(set) var errorMessage: String?

  private let getRecipeUseCase: GetRecipesUseCase
  private let sortRecipeUseCase: SortRecipesUseCase

  var firstRecipe: Recipe? {
    recipes.first
  }

  // MARK: - Initialization

  init(
    getRecipeUseCase: GetRecipesUseCase,
    sortRecipeUseCase: SortRecipesUseCase
  ) {
    self.getRecipeUseCase = getRecipeUseCase
    self.sortRecipeUseCase = sortRecipeUseCase
  }

  // MARK: - Methods

  func loadRecipes() async {
    isLoading = true
    errorMessage = nil

    do {
      let fetchRecipes = try await getRecipeUseCase.getRecipes()
      recipes = sortRecipeUseCase.sortByTime(recipes: fetchRecipes)
    } catch let error as RepositoryError {
      errorMessage = error.localizedDescription
    } catch {
      errorMessage = "An unexpected error occurred."
    }

    isLoading = false
  }

}
