import Foundation
import XCTest
@testable import Recipes

final class RecipesTests: XCTestCase {

    func testLocalRecipeRepositoryFetchRecipesReturnsMappedDomainModels() async throws {
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

        let recipes = try await repository.fetchRecipes()

        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes.first?.title, "Lemon Pasta")
        XCTAssertEqual(recipes.first?.description, "Fresh and bright")
        XCTAssertEqual(
            recipes.first?.thumbnailURL,
            URL(string: "https://coles.com.au/content/dam/coles/inspire-create/thumbnails/lemon-pasta.jpg")
        )
        XCTAssertEqual(recipes.first?.thumbnailAltText, "Bowl of lemon pasta")
        XCTAssertEqual(recipes.first?.details?.servesAmount, 4)
        XCTAssertEqual(recipes.first?.details?.prepNote, "plus resting")
        XCTAssertEqual(recipes.first?.totalTimeInMinutes, 25)
        XCTAssertEqual(recipes.first?.ingredients.map(\.text), ["200g pasta", "1 lemon"])
    }

    func testLocalRecipeRepositoryFetchRecipesThrowsFileNotFoundWhenResourceDoesNotExist() async {
        do {
            let bundle = try makeBundle(named: "MissingRecipes", files: [:])
            let repository = LocalRecipeRepository(fileName: "missing", bundle: bundle)

            _ = try await repository.fetchRecipes()
            XCTFail("Expected fileNotFound error")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, .fileNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLocalRecipeRepositoryFetchRecipesThrowsDecodingFailedForMalformedJSON() async {
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

        do {
            let bundle = try makeBundle(named: "MalformedRecipes", files: [
                "recipes.json": .file(malformedJSON)
            ])
            let repository = LocalRecipeRepository(fileName: "recipes", bundle: bundle)

            _ = try await repository.fetchRecipes()
            XCTFail("Expected decodingFailed error")
        } catch let error as RepositoryError {
            guard case .decodingFailed(let message) = error else {
                return XCTFail("Expected decodingFailed error, got \(error)")
            }

            XCTAssertFalse(message.isEmpty)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLocalRecipeRepositoryFetchRecipesThrowsUnknownForUnreadableResource() async {
        do {
            let bundle = try makeBundle(named: "UnreadableRecipes", files: [
                "recipes.json": .directory
            ])
            let repository = LocalRecipeRepository(fileName: "recipes", bundle: bundle)

            _ = try await repository.fetchRecipes()
            XCTFail("Expected unknown error")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, .unknown)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testGetRecipesUseCaseReturnsRepositoryRecipes() async throws {
        let expectedRecipes = [
            makeRecipe(title: "Soup", prepMinutes: 5, cookMinutes: 20),
            makeRecipe(title: "Pasta", prepMinutes: 10, cookMinutes: 15)
        ]
        let repository = MockRecipeRepository(result: .success(expectedRecipes))
        let useCase = GetRecipesUseCase(repository: repository)

        let recipes = try await useCase.getRecipes()

        XCTAssertEqual(recipes, expectedRecipes)
        XCTAssertEqual(repository.fetchRecipesCallCount, 1)
    }

    func testGetRecipesUseCasePropagatesRepositoryErrors() async {
        let repository = MockRecipeRepository(result: .failure(RepositoryError.fileNotFound))
        let useCase = GetRecipesUseCase(repository: repository)

        do {
            _ = try await useCase.getRecipes()
            XCTFail("Expected fileNotFound error")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, .fileNotFound)
            XCTAssertEqual(repository.fetchRecipesCallCount, 1)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testSortRecipesUseCaseSortsRecipesByAscendingTotalTime() {
        let useCase = SortRecipesUseCase()
        let slowRecipe = makeRecipe(title: "Slow", prepMinutes: 15, cookMinutes: 30)
        let mediumRecipe = makeRecipe(title: "Medium", prepMinutes: 10, cookMinutes: 15)
        let fastRecipe = makeRecipe(title: "Fast", prepMinutes: 5, cookMinutes: 10)

        let sortedRecipes = useCase.sortByTime(recipes: [mediumRecipe, slowRecipe, fastRecipe])

        XCTAssertEqual(sortedRecipes.map(\.title), ["Fast", "Medium", "Slow"])
    }

    func testSortRecipesUseCaseTreatsRecipesWithoutDetailsAsZeroMinutes() {
        let useCase = SortRecipesUseCase()
        let noDetailsRecipe = makeRecipe(title: "No Details", details: nil)
        let timedRecipe = makeRecipe(title: "Timed", prepMinutes: 5, cookMinutes: 10)

        let sortedRecipes = useCase.sortByTime(recipes: [timedRecipe, noDetailsRecipe])

        XCTAssertEqual(sortedRecipes.map(\.title), ["No Details", "Timed"])
    }
}

private extension RecipesTests {
    enum BundleFile {
        case file(String)
        case directory
    }

    func makeRecipe(
        title: String,
        prepMinutes: Int = 0,
        cookMinutes: Int = 0,
        details: RecipeDetails? = RecipeDetails(
            servesLabel: "Serves",
            servesAmount: 2,
            prepLabel: "Prep",
            prepTime: "0 mins",
            prepNote: nil,
            cookingLabel: "Cook",
            cookingTime: "0 mins",
            cookTimeAsMinutes: 0,
            prepTimeAsMinutes: 0
        )
    ) -> Recipe {
        let resolvedDetails = details.map {
            RecipeDetails(
                servesLabel: $0.servesLabel,
                servesAmount: $0.servesAmount,
                prepLabel: $0.prepLabel,
                prepTime: "\(prepMinutes) mins",
                prepNote: $0.prepNote,
                cookingLabel: $0.cookingLabel,
                cookingTime: "\(cookMinutes) mins",
                cookTimeAsMinutes: cookMinutes,
                prepTimeAsMinutes: prepMinutes
            )
        }

        return Recipe(
            title: title,
            description: "\(title) description",
            thumbnailURL: nil,
            thumbnailAltText: nil,
            details: resolvedDetails,
            ingredients: []
        )
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
            throw NSError(domain: "RecipesTests", code: 1)
        }

        addTeardownBlock {
            try? FileManager.default.removeItem(at: rootURL)
        }

        return bundle
    }
}

private final class MockRecipeRepository: RecipeRepositoryProtocol {
    private let result: Result<[Recipe], Error>
    private(set) var fetchRecipesCallCount = 0

    init(result: Result<[Recipe], Error>) {
        self.result = result
    }

    func fetchRecipes() async throws -> [Recipe] {
        fetchRecipesCallCount += 1
        return try result.get()
    }
}
