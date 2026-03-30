import XCTest
@testable import Recipes

final class UseCaseTests: XCTestCase {

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

private extension UseCaseTests {
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
