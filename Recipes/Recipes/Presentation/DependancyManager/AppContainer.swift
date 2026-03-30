//
//  AppContainer.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//

import Foundation

final class AppContainer {
  let viewModelFactory: ViewModelFactory

  init() {
    let recipeRepository = LocalRecipeRepository()
    viewModelFactory = ViewModelFactory(recipeRepository: recipeRepository)
  }
}
