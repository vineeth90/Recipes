//
//  RecipeResponse.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//

import Foundation

struct RecipeResponse: Codable {
  let recipes: [RecipeData]
}

struct RecipeData: Codable {
  let dynamicTitle: String?
  let dynamicDescription: String?
  let dynamicThumbnail: String?
  let dynamicThumbnailAlt: String?
  let recipeDetails: RecipeDetailsData?
  let ingredients: [IngredientData]?

  func toDomain() -> Recipe {
    let thumbnailURL = dynamicThumbnail.flatMap {
      URL(string: "https://coles.com.au\($0)")
    }

    return Recipe(
      title: dynamicTitle ?? "Untitled Recipe",
      description: dynamicDescription ?? "",
      thumbnailURL: thumbnailURL,
      thumbnailAltText: dynamicThumbnailAlt,
      details: recipeDetails?.toDomain(),
      ingredients: ingredients?.compactMap { $0.toDomain() } ?? []
    )
  }
}

struct RecipeDetailsData: Codable {
  let amountLabel: String?
  let amountNumber: Int?
  let prepLabel: String?
  let prepTime: String?
  let prepNote: String?
  let cookingLabel: String?
  let cookingTime: String?
  let cookTimeAsMinutes: Int?
  let prepTimeAsMinutes: Int?

  func toDomain() -> RecipeDetails? {
    // Default values are assigned to the fields in domain model, to handle the optional fields in the Data model. This can be avoided once there is a defined API contract.
    var servesAmount: String = "N/A"
    if let amountNumber {
      servesAmount = String(amountNumber)
    }
    return RecipeDetails(
      servesLabel: amountLabel ?? "Serves",
      servesAmount: servesAmount,
      prepLabel: prepLabel ?? "Prep",
      prepTime: prepTime ?? "N/A",
      prepNote: prepNote,
      cookingLabel: cookingLabel ?? "Cooking",
      cookingTime: cookingTime ?? "N/A",
      cookTimeAsMinutes: cookTimeAsMinutes ?? 0,
      prepTimeAsMinutes: prepTimeAsMinutes ?? 0
    )
  }
}

struct IngredientData: Codable {
  let ingredient: String?

  func toDomain() -> Ingredient? {
    guard let text = ingredient, !text.isEmpty else { return nil }
    return Ingredient(text: text)
  }
}

