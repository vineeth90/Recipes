//
//  SortRecipesUseCase.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import Foundation

/// Use case for sorting recipes
final class SortRecipesUseCase {

  /// Sort recipes by total time (prep + cooking) in ascending order
  func sortByTime(recipes: [Recipe]) -> [Recipe] {
    recipes.sorted { recipe1, recipe2 in
      recipe1.totalTimeInMinutes < recipe2.totalTimeInMinutes
    }
  }
}
