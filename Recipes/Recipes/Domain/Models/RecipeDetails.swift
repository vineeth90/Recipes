//
//  RecipeDetails.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import Foundation

struct RecipeDetails: Equatable {
  let servesLabel: String
  let servesAmount: String
  let prepLabel: String
  let prepTime: String
  let prepNote: String?
  let cookingLabel: String
  let cookingTime: String
  let cookTimeAsMinutes: Int?
  let prepTimeAsMinutes: Int?
}
