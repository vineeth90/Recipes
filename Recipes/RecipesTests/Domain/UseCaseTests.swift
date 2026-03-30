import XCTest
@testable import Recipes

final class UseCaseTests: XCTestCase {

  var sortUseCase: SortRecipesUseCase!

  override func setUp() {
    super.setUp()
    sortUseCase = SortRecipesUseCase()
  }

  override func tearDown() {
    sortUseCase = nil
    super.tearDown()
  }

  @MainActor
  func testGetRecipesUseCaseReturnsRepositoryRecipes() async throws {
    // Given
    let expectedRecipes = [
      makeRecipe(title: "Soup", prepMinutes: 5, cookMinutes: 20),
      makeRecipe(title: "Pasta", prepMinutes: 10, cookMinutes: 15)
    ]
    let repository = MockRecipeRepository(result: .success(expectedRecipes))
    let useCase = GetRecipesUseCase(repository: repository)

    // When
    let recipes = try await useCase.getRecipes()

    // Then
    XCTAssertEqual(recipes, expectedRecipes)
    XCTAssertEqual(repository.fetchRecipesCallCount, 1)
  }

  @MainActor
  func testGetRecipesUseCaseReturnsEmptyArrayWhenRepositoryHasNoRecipes() async throws {
    // Given
    let repository = MockRecipeRepository(result: .success([]))
    let useCase = GetRecipesUseCase(repository: repository)

    // When
    let recipes = try await useCase.getRecipes()

    // Then
    XCTAssertTrue(recipes.isEmpty)
    XCTAssertEqual(repository.fetchRecipesCallCount, 1)
  }

  @MainActor
  func testGetRecipesUseCasePropagatesRepositoryErrors() async {
    // Given
    let repository = MockRecipeRepository(result: .failure(RepositoryError.fileNotFound))
    let useCase = GetRecipesUseCase(repository: repository)
    // When
    do {
      _ = try await useCase.getRecipes()
      XCTFail("Expected fileNotFound error")
    } catch let error as RepositoryError {
      // Then
      XCTAssertEqual(error, .fileNotFound)
      XCTAssertEqual(repository.fetchRecipesCallCount, 1)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testSortRecipesUseCaseSortsRecipes() {
    // Given
    let slowRecipe = makeRecipe(title: "Slow", prepMinutes: 15, cookMinutes: 30)
    let mediumRecipe = makeRecipe(title: "Medium", prepMinutes: 10, cookMinutes: 15)
    let fastRecipe = makeRecipe(title: "Fast", prepMinutes: 5, cookMinutes: 10)

    // When
    let sortedRecipes = sortUseCase.sortByTime(recipes: [mediumRecipe, slowRecipe, fastRecipe])

    // Then
    XCTAssertEqual(sortedRecipes.map(\.title), ["Fast", "Medium", "Slow"])
  }

  func testSortRecipesUseCasePlacesRecipesWithoutTimeAtEnd() {
    // Given
    let untimedRecipe = makeRecipe(title: "Untimed", details: nil)
    let timedRecipe = makeRecipe(title: "Timed", prepMinutes: 5, cookMinutes: 10)

    // When
    let sortedRecipes = sortUseCase.sortByTime(recipes: [untimedRecipe, timedRecipe])

    // Then
    XCTAssertEqual(sortedRecipes.map(\.title), ["Timed", "Untimed"])
  }
}

private extension UseCaseTests {
  func makeRecipe(
    title: String,
    prepMinutes: Int = 0,
    cookMinutes: Int = 0,
    details: RecipeDetails? = RecipeDetails(
      servesLabel: "Serves",
      servesAmount: "2",
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
