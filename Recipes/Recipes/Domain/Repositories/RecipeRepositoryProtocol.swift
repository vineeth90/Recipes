//
//  RecipeRepositoryProtocol.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import Foundation

protocol RecipeRepositoryProtocol {

  func fetchRecipes() async throws -> [Recipe]
}

enum RepositoryError: Error, Equatable {
  case fileNotFound
  case decodingFailed(String)
  case invalidData
  case unknown
}
