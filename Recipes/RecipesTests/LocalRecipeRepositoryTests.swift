import Foundation
import XCTest
@testable import Recipes

@MainActor
final class LocalRecipeRepositoryTests: XCTestCase {

    func testFetchRecipesReturnsMappedDomainModels() async throws {
        // Given
        let json = """
        {
          "recipes": [
            {
              "dynamicTitle": "Lemon Pasta",
              "dynamicDescription": "Fresh and bright",
              "dynamicThumbnail": "/content/dam/coles/inspire-create/thumbnails/lemon-pasta.jpg",
              "dynamicThumbnailAlt": "Bowl of lemon pasta",
              "recipeDetails": {
                "amountLabel": "Serves",
                "amountNumber": 4,
                "prepLabel": "Prep",
                "prepTime": "10 mins",
                "prepNote": "plus resting",
                "cookingLabel": "Cook",
                "cookingTime": "15 mins",
                "cookTimeAsMinutes": 15,
                "prepTimeAsMinutes": 10
              },
              "ingredients": [
                { "ingredient": "200g pasta" },
                { "ingredient": "1 lemon" }
              ]
            }
          ]
        }
        """
        let bundle = try makeBundle(named: "ValidRecipes", files: [
            "recipes.json": .file(json)
        ])
        let repository = LocalRecipeRepository(fileName: "recipes", bundle: bundle)

        // When
        let recipes = try await repository.fetchRecipes()

        // Then
        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes.first?.title, "Lemon Pasta")
        XCTAssertEqual(recipes.first?.description, "Fresh and bright")
        XCTAssertEqual(
            recipes.first?.thumbnailURL,
            URL(string: "https://coles.com.au/content/dam/coles/inspire-create/thumbnails/lemon-pasta.jpg")
        )
        XCTAssertEqual(recipes.first?.thumbnailAltText, "Bowl of lemon pasta")
        XCTAssertEqual(recipes.first?.details?.servesAmount, "4")
        XCTAssertEqual(recipes.first?.details?.prepNote, "plus resting")
        XCTAssertEqual(recipes.first?.totalTimeInMinutes, 25)
        XCTAssertEqual(recipes.first?.ingredients.map(\.text), ["200g pasta", "1 lemon"])
    }

    func testFetchRecipesThrowsFileNotFoundWhenResourceDoesNotExist() async {
        // Given
        let bundle: Bundle
        let repository: LocalRecipeRepository

        do {
            bundle = try makeBundle(named: "MissingRecipes", files: [:])
            repository = LocalRecipeRepository(fileName: "missing", bundle: bundle)
        } catch {
            return XCTFail("Failed to create test bundle: \(error)")
        }

        // When
        do {
            _ = try await repository.fetchRecipes()
            XCTFail("Expected fileNotFound error")
        } catch let error as RepositoryError {
            // Then
            XCTAssertEqual(error, .fileNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchRecipesThrowsDecodingFailedForMalformedJSON() async {
        // Given
        let malformedJSON = """
        {
          "recipes": [
            {
              "dynamicTitle": "Broken Recipe",
              "recipeDetails": "invalid"
            }
          ]
        }
        """
        let bundle: Bundle
        let repository: LocalRecipeRepository

        do {
            bundle = try makeBundle(named: "MalformedRecipes", files: [
                "recipes.json": .file(malformedJSON)
            ])
            repository = LocalRecipeRepository(fileName: "recipes", bundle: bundle)
        } catch {
            return XCTFail("Failed to create test bundle: \(error)")
        }

        // When
        do {
            _ = try await repository.fetchRecipes()
            XCTFail("Expected decodingFailed error")
        } catch let error as RepositoryError {
            // Then
            guard case .decodingFailed(let message) = error else {
                return XCTFail("Expected decodingFailed error, got \(error)")
            }

            XCTAssertFalse(message.isEmpty)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchRecipesThrowsUnknownForUnreadableResource() async {
        // Given
        let bundle: Bundle
        let repository: LocalRecipeRepository

        do {
            bundle = try makeBundle(named: "UnreadableRecipes", files: [
                "recipes.json": .directory
            ])
            repository = LocalRecipeRepository(fileName: "recipes", bundle: bundle)
        } catch {
            return XCTFail("Failed to create test bundle: \(error)")
        }

        // When
        do {
            _ = try await repository.fetchRecipes()
            XCTFail("Expected unknown error")
        } catch let error as RepositoryError {
            // Then
            XCTAssertEqual(error, .unknown)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private extension LocalRecipeRepositoryTests {
    enum BundleFile {
        case file(String)
        case directory
    }

    func makeBundle(named name: String, files: [String: BundleFile]) throws -> Bundle {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        let bundleURL = rootURL.appendingPathComponent("\(name).bundle", isDirectory: true)

        try FileManager.default.createDirectory(at: bundleURL, withIntermediateDirectories: true)

        for (fileName, file) in files {
            let fileURL = bundleURL.appendingPathComponent(fileName)

            switch file {
            case .file(let content):
                try content.write(to: fileURL, atomically: true, encoding: .utf8)
            case .directory:
                try FileManager.default.createDirectory(
                    at: fileURL,
                    withIntermediateDirectories: true
                )
            }
        }

        guard let bundle = Bundle(url: bundleURL) else {
            throw NSError(domain: "LocalRecipeRepositoryTests", code: 1)
        }

        addTeardownBlock {
            try? FileManager.default.removeItem(at: rootURL)
        }

        return bundle
    }
}
