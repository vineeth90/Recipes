//
//  RecipeViewModel.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import Foundation
import Combine

@MainActor
final class RecipeViewModel: ObservableObject {

  // MARK: - Properties

  public enum ViewState: Equatable {
    case loading
    case loaded(recipes: [Recipe], selectedRecipe: Recipe)
    case empty
    case error(String)
  }

  @Published private(set) var viewState: ViewState = .loading

  private let getRecipeUseCase: GetRecipesUseCase
  private let sortRecipeUseCase: SortRecipesUseCase

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
    do {
      let fetchRecipes = try await getRecipeUseCase.getRecipes()
      let recipes = sortRecipeUseCase.sortByTime(recipes: fetchRecipes)
      if let selectedRecipe = recipes.first {
        viewState = .loaded(recipes: recipes, selectedRecipe: selectedRecipe)
      } else {
        viewState = .empty
      }
    } catch let error as RepositoryError {
      viewState = .error(error.localizedDescription)
    } catch {
      viewState = .error("An unexpected error occurred.")
    }

  }

}
