//
//  RecipeDetailView.swift
//  Recipes
//
//  Created by Vineeth M on 30/3/2026.
//
import SwiftUI

struct RecipeDetailView: View {
  let recipe: Recipe?

  var body: some View {
    ScrollView {
      if let recipe {
        VStack(spacing: 24) {
          Text(recipe.title)
            .font(.largeTitle)
            .fontWeight(.heavy)
            .multilineTextAlignment(.center)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("recipeDetail.title")
            .padding(.horizontal, 40)
            .padding(.top, 20)
          Text(recipe.description)
            .font(.body)
            .multilineTextAlignment(.center)
            .accessibilityIdentifier("recipeDetail.description")
            .padding(.horizontal, 40)
          RecipeImageView(url: recipe.thumbnailURL)
            .clipped()
            .frame(height: 250)
            .accessibilityElement()
            .accessibilityAddTraits(.isImage)
            .accessibilityLabel(recipe.thumbnailAltText ?? "Recipe image")

          Divider()

          if let details = recipe.details {
            RecipeDetailsView(details: details)
            Divider()
          }

          IngredientsListView(ingredients: recipe.ingredients)
            .padding(.horizontal)
        }
      }
    }
    .accessibilityIdentifier("recipeDetail.container")
  }
}

private struct RecipeDetailsView: View {
  let details: RecipeDetails

  var body: some View {
    ViewThatFits {
      horizontalLayout
      verticalLayout
    }
  }

  private var horizontalLayout: some View {
    HStack(spacing: 0) {
      DetailItem(
        label: details.servesLabel,
        value: details.servesAmount,
        accessibilityLabel: "\(details.servesLabel) \(details.servesAmount) People"
      )
      .frame(maxWidth: .infinity)
      Divider()
        .frame(height: 40)
        .accessibilityHidden(true)

      DetailItem(
        label: details.prepLabel,
        value: details.prepTime,
        accessibilityLabel: "\(details.prepLabel) time: \(details.prepTime)"
      )
      .frame(maxWidth: .infinity)
      Divider()
        .frame(height: 40)
        .accessibilityHidden(true)

      DetailItem(
        label: details.cookingLabel,
        value: details.cookingTime,
        accessibilityLabel: "\(details.cookingLabel) time: \(details.cookingTime)"
      )
      .frame(maxWidth: .infinity)
    }
  }

  private var verticalLayout: some View {
    VStack(alignment: .center, spacing: 12) {
      DetailItem(
        label: details.servesLabel,
        value: details.servesAmount,
        accessibilityLabel: "\(details.servesLabel) \(details.servesAmount) People"
      )
      DetailItem(
        label: details.prepLabel,
        value: details.prepTime,
        accessibilityLabel: "\(details.prepLabel) time: \(details.prepTime)"
      )
      DetailItem(
        label: details.cookingLabel,
        value: details.cookingTime,
        accessibilityLabel: "\(details.cookingLabel) time: \(details.cookingTime)"
      )
    }
    .frame(maxWidth: .infinity)
  }
}

private struct DetailItem: View {
  let label: String
  let value: String
  let accessibilityLabel: String

  var body: some View {
    VStack(alignment: .center, spacing: 4) {
      Text(label)
        .font(.caption)
        .foregroundStyle(.secondary)
        .textCase(.uppercase)

      Text(value)
        .font(.headline)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(accessibilityLabel)
  }
}

private struct IngredientsListView: View {
  let ingredients: [Ingredient]

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Ingredients")
        .font(.title)
        .bold()
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("recipeDetail.ingredientsHeader")
      VStack(alignment: .leading, spacing: 12) {
        ForEach(ingredients) { ingredient in
          HStack(alignment: .top, spacing: 8) {
            Text("‣")
              .font(.callout)
              .accessibilityHidden(true)
            Text(ingredient.text)
              .font(.callout)
              .fixedSize(horizontal: false, vertical: true)
          }
        }
      }
    }
  }
}


#Preview {
  RecipeDetailView(
    recipe: Recipe(
      title: "Lemon Herb Pasta with polenta",
      description: "A quick weeknight pasta with lemon, herbs, and parmesan. Served with fluffy polenta and it is delicious.",
      thumbnailURL: URL(string: "https://example.com/recipe.jpg"),
      thumbnailAltText: "A bowl of lemon herb pasta",
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
        Ingredient(text: "4 cups (240g) 2cm-pieces day-old Coles Bakery Stone Baked by Laurent Pane Di Casa"),
        Ingredient(text: "1 lemon"),
        Ingredient(text: "2 tbsp parsley")
      ]
    )
  )
}
