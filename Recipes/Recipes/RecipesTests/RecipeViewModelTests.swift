import Combine
import XCTest
@testable import Recipes

@MainActor
final class RecipeViewModelTests: XCTestCase {
  private var repository: MockRecipeRepository!
  private var viewModel: RecipeViewModel!
  private var cancellables: Set<AnyCancellable>!

  override func setUp() {
    super.setUp()
    repository = MockRecipeRepository()
    viewModel = RecipeViewModel(
      getRecipeUseCase: GetRecipesUseCase(repository: repository),
      sortRecipeUseCase: SortRecipesUseCase()
    )
    cancellables = []
  }

  override func tearDown() {
    cancellables = nil
    viewModel = nil
    repository = nil
    super.tearDown()
  }

  func testInit_startsInLoadingState() {
    // Then
    XCTAssertEqual(viewModel.viewState, .loading)
  }

  func testLoadRecipes_whenRepositoryReturnsRecipes_setsSortedRecipesState() async {
    // Given
    repository.result = .success([
      makeRecipe(title: "Medium", prepMinutes: 10, cookMinutes: 15),
      makeRecipe(title: "Slow", prepMinutes: 20, cookMinutes: 30),
      makeRecipe(title: "Fast", prepMinutes: 5, cookMinutes: 10)
    ])

    // When
    await viewModel.loadRecipes()

    // Then
    guard case .recipes(let recipes) = viewModel.viewState else {
      return XCTFail("Expected recipes state, got \(viewModel.viewState)")
    }

    XCTAssertEqual(recipes.map(\.title), ["Fast", "Medium", "Slow"])
  }

  func testLoadRecipes_whenRepositoryReturnsEmptyArray_setsEmptyState() async {
    // Given
    repository.result = .success([])

    // When
    await viewModel.loadRecipes()

    // Then
    XCTAssertEqual(viewModel.viewState, .empty)
  }

  func testLoadRecipes_whenRepositoryThrowsRepositoryError_setsRepositoryErrorState() async {
    // Given
    let error = RepositoryError.fileNotFound
    repository.result = .failure(error)

    // When
    await viewModel.loadRecipes()

    // Then
    XCTAssertEqual(viewModel.viewState, .error(error.localizedDescription))
  }

  func testLoadRecipes_whenRepositoryThrowsUnexpectedError_setsGenericErrorState() async {
    // Given
    repository.result = .failure(MockError.unexpected)

    // When
    await viewModel.loadRecipes()

    // Then
    XCTAssertEqual(viewModel.viewState, .error("An unexpected error occurred."))
  }

  func testLoadRecipes_publishesRecipesState() async {
    // Given
    let stateDidUpdate = expectation(description: "View state updates to recipes")
    repository.result = .success([
      makeRecipe(title: "Fast", prepMinutes: 5, cookMinutes: 10)
    ])

    // Observe the first published state after loading starts.
    viewModel.$viewState
      .dropFirst()
      .sink { state in
        guard case .recipes(let recipes) = state else { return }
        XCTAssertEqual(recipes.map(\.title), ["Fast"])
        stateDidUpdate.fulfill()
      }
      .store(in: &cancellables)

    // When
    await viewModel.loadRecipes()

    // Then
    await fulfillment(of: [stateDidUpdate], timeout: 1.0)
  }
}

private extension RecipeViewModelTests {
  func makeRecipe(
    title: String,
    prepMinutes: Int,
    cookMinutes: Int
  ) -> Recipe {
    Recipe(
      title: title,
      description: "\(title) description",
      thumbnailURL: nil,
      thumbnailAltText: nil,
      details: RecipeDetails(
        servesLabel: "Serves",
        servesAmount: "2",
        prepLabel: "Prep",
        prepTime: "\(prepMinutes) mins",
        prepNote: nil,
        cookingLabel: "Cook",
        cookingTime: "\(cookMinutes) mins",
        cookTimeAsMinutes: cookMinutes,
        prepTimeAsMinutes: prepMinutes
      ),
      ingredients: []
    )
  }
}

private enum MockError: Error {
  case unexpected
}

private final class MockRecipeRepository: RecipeRepositoryProtocol {
  var result: Result<[Recipe], Error> = .success([])

  func fetchRecipes() async throws -> [Recipe] {
    try result.get()
  }
}
