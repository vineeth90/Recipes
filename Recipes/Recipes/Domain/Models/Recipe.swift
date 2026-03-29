//
//  Recipe.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import Foundation

struct Recipe: Identifiable, Equatable {
  let id: UUID
  let title: String
  let description: String
  let thumbnailURL: URL?
  let thumbnailAltText: String?
  let details: RecipeDetails?
  let ingredients: [Ingredient]

  init(
    id: UUID = UUID(),
    title: String,
    description: String,
    thumbnailURL: URL?,
    thumbnailAltText: String?,
    details: RecipeDetails?,
    ingredients: [Ingredient]
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.thumbnailURL = thumbnailURL
    self.thumbnailAltText = thumbnailAltText
    self.details = details
    self.ingredients = ingredients
  }

  // Total time in minutes prep + cooking
  var totalTimeInMinutes: Int {
    guard let details = details else { return 0 }
    return details.prepTimeAsMinutes + details.cookTimeAsMinutes
  }
}
