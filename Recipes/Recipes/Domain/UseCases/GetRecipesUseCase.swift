//
//  GetRecipesUseCase.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import Foundation

/// Use case for fetching recipes from the repository
final class GetRecipesUseCase {
  private let repository: RecipeRepositoryProtocol

  init(repository: RecipeRepositoryProtocol) {
    self.repository = repository
  }

  /// Executes the use case to fetch all recipes
  func getRecipes() async throws -> [Recipe] {
    try await repository.fetchRecipes()
  }
}
