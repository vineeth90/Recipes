//
//  Ingredient.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import Foundation

struct Ingredient: Identifiable, Equatable {
  let id: UUID
  let text: String

  init(id: UUID = UUID(), text: String) {
    self.id = id
    self.text = text
  }
}

