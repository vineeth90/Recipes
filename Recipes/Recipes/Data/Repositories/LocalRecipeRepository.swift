//
//  LocalRecipeRepository.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import Foundation

final class LocalRecipeRepository: RecipeRepositoryProtocol {
  private let fileName: String
  private let bundle: Bundle

  init(fileName: String = "recipesSample", bundle: Bundle = .main) {
    self.fileName = fileName
    self.bundle = bundle
  }

  func fetchRecipes() async throws -> [Recipe] {
    guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
      throw RepositoryError.fileNotFound
    }

    do {
      let data = try Data(contentsOf: url)
      let recipeList = try JSONDecoder().decode(RecipeResponse.self, from: data)

      return recipeList.recipes.map { $0.toDomain() }
    } catch let decodingError as DecodingError {
      throw RepositoryError.decodingFailed(decodingError.localizedDescription)
    } catch {
      throw RepositoryError.unknown
    }
  }
}
