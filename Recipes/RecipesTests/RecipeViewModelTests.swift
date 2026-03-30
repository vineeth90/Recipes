import XCTest
@testable import Recipes

@MainActor
final class RecipeViewModelTests: XCTestCase {

    func testLoadRecipesGivenRepositoryReturnsRecipesWhenLoadingThenPublishesSortedRecipesAndClearsTransientState() async {
        // Given
        let slowRecipe = makeRecipe(title: "Slow", prepMinutes: 20, cookMinutes: 30)
        let fastRecipe = makeRecipe(title: "Fast", prepMinutes: 5, cookMinutes: 10)
        let mediumRecipe = makeRecipe(title: "Medium", prepMinutes: 10, cookMinutes: 15)
        let repository = MockRecipeRepository(result: .success([mediumRecipe, slowRecipe, fastRecipe]))
        let viewModel = makeViewModel(repository: repository)

        // When
        await viewModel.loadRecipes()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.recipes.map(\.title), ["Fast", "Medium", "Slow"])
        XCTAssertEqual(viewModel.firstRecipe?.title, "Fast")
    }

    func testLoadRecipesGivenRepositoryFailureWhenLoadingThenPublishesRepositoryErrorAndStopsLoading() async {
        // Given
        let repositoryError = RepositoryError.fileNotFound
        let repository = MockRecipeRepository(result: .failure(repositoryError))
        let viewModel = makeViewModel(repository: repository)

        // When
        await viewModel.loadRecipes()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.recipes.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, repositoryError.localizedDescription)
        XCTAssertNil(viewModel.firstRecipe)
    }

    func testLoadRecipesGivenUnexpectedFailureWhenLoadingThenPublishesGenericErrorAndStopsLoading() async {
        // Given
        let repository = MockRecipeRepository(result: .failure(MockError.unexpected))
        let viewModel = makeViewModel(repository: repository)

        // When
        await viewModel.loadRecipes()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.recipes.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, "An unexpected error occurred.")
        XCTAssertNil(viewModel.firstRecipe)
    }

    func testLoadRecipesGivenSuspendedFetchWhenLoadingStartsThenSetsLoadingBeforeRepositoryCompletes() async {
        // Given
        let repository = SuspendedRecipeRepository()
        let viewModel = makeViewModel(repository: repository)
        let loadTask = Task {
            await viewModel.loadRecipes()
        }

        // When
        await repository.awaitFetchStart()

        // Then
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)

        repository.resume(returning: [makeRecipe(title: "Fast", prepMinutes: 5, cookMinutes: 10)])
        await loadTask.value
    }

    func testFirstRecipeGivenInitialStateWhenNotLoadedThenReturnsNil() {
        // Given
        let repository = MockRecipeRepository(result: .success([]))
        let viewModel = makeViewModel(repository: repository)

        // When
        let firstRecipe = viewModel.firstRecipe

        // Then
        XCTAssertNil(firstRecipe)
        XCTAssertTrue(viewModel.recipes.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
}

private extension RecipeViewModelTests {
    func makeViewModel(repository: RecipeRepositoryProtocol) -> RecipeViewModel {
        RecipeViewModel(
            getRecipeUseCase: GetRecipesUseCase(repository: repository),
            sortRecipeUseCase: SortRecipesUseCase()
        )
    }

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
    private let result: Result<[Recipe], Error>

    init(result: Result<[Recipe], Error>) {
        self.result = result
    }

    func fetchRecipes() async throws -> [Recipe] {
        try result.get()
    }
}

private actor FetchState {
    var continuation: CheckedContinuation<[Recipe], Error>?
    var fetchStartedContinuation: CheckedContinuation<Void, Never>?
    var didStartFetch = false

    func markFetchStarted() {
        didStartFetch = true
        fetchStartedContinuation?.resume()
        fetchStartedContinuation = nil
    }

    func waitForFetchStart() async {
        if didStartFetch {
            return
        }

        await withCheckedContinuation { continuation in
            fetchStartedContinuation = continuation
        }
    }

    func setContinuation(_ continuation: CheckedContinuation<[Recipe], Error>) {
        self.continuation = continuation
    }

    func resume(returning recipes: [Recipe]) {
        continuation?.resume(returning: recipes)
        continuation = nil
    }
}

private final class SuspendedRecipeRepository: RecipeRepositoryProtocol {
    private let state = FetchState()

    func fetchRecipes() async throws -> [Recipe] {
        await state.markFetchStarted()
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                await state.setContinuation(continuation)
            }
        }
    }

    func awaitFetchStart() async {
        await state.waitForFetchStart()
    }

    func resume(returning recipes: [Recipe]) {
        Task {
            await state.resume(returning: recipes)
        }
    }
}
