//
//  RecipeGridView.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import SwiftUI

struct RecipeGridView: View {
  let recipes: [Recipe]

  private let columns = [
    GridItem(.flexible(), spacing: 16),
    GridItem(.flexible(), spacing: 16)
  ]
  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 16) {
        ForEach(recipes) { recipe in
          RecipeCardView(recipe: recipe)
        }
      }
      .padding()
    }
    .background(Color(.systemGroupedBackground))
  }
}

private struct RecipeCardView: View {
  let recipe: Recipe

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      RecipeImageView(url: recipe.thumbnailURL)
        .frame(height: 140)
        .clipped()

      VStack(alignment: .leading, spacing: 8) {
        Text("RECIPE")
          .font(.caption)
          .fontWeight(.semibold)
          .foregroundColor(.red)
        Text(recipe.title)
          .font(.subheadline)
          .fontWeight(.semibold)
          .lineLimit(2)
          .fixedSize(horizontal: false, vertical: true)
          .frame(minHeight: 36, alignment: .top)
      }
      .padding(12)
    }
    .frame(maxWidth: .infinity)
    .background(Color(.systemBackground))
    .cornerRadius(8)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Recipe: \(recipe.title)")
  }
}

#Preview {
  RecipeGridView(
    recipes: [
      Recipe(
        title: "Lemon Pasta",
        description: "Bright pasta with lemon and parmesan.",
        thumbnailURL: URL(string: "https://example.com/lemon-pasta.jpg"),
        thumbnailAltText: "A bowl of lemon pasta",
        details: RecipeDetails(
          servesLabel: "Serves",
          servesAmount: "4",
          prepLabel: "Prep",
          prepTime: "10 mins",
          prepNote: nil,
          cookingLabel: "Cook",
          cookingTime: "15 mins",
          cookTimeAsMinutes: 15,
          prepTimeAsMinutes: 10
        ),
        ingredients: [
          Ingredient(text: "300g pasta"),
          Ingredient(text: "1 lemon")
        ]
      ),
      Recipe(
        title: "Tomato Soup",
        description: "A simple tomato soup for weeknights.",
        thumbnailURL: nil,
        thumbnailAltText: nil,
        details: RecipeDetails(
          servesLabel: "Serves",
          servesAmount: "2",
          prepLabel: "Prep",
          prepTime: "15 mins",
          prepNote: nil,
          cookingLabel: "Cook",
          cookingTime: "25 mins",
          cookTimeAsMinutes: 25,
          prepTimeAsMinutes: 15
        ),
        ingredients: [
          Ingredient(text: "400g tomatoes"),
          Ingredient(text: "1 onion")
        ]
      )
    ]
  )
}
