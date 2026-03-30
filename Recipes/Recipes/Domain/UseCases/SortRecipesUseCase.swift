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
      switch (recipe1.totalTimeInMinutes, recipe2.totalTimeInMinutes) {
      case let (time1?, time2?):
        return time1 < time2
      case (.some, .none):
        return true
      case (.none, .some):
        return false
      case (.none, .none):
        // If totalTimeInMinutes value is not present, sort by title
        return recipe1.title < recipe2.title
      }
    }
  }
}
