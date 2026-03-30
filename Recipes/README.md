# Recipes

Recipes is a SwiftUI iOS application that loads recipe data from a local JSON resource, maps it into domain models, sorts it by total preparation time, and presents the content differently for portrait and landscape layouts.

## Architecture

The app adopts Clean Architecture, with MVVM in the presentation layer.

The codebase is split into three main layers:

- `Presentation`: SwiftUI views, a `RecipeViewModel`, and a lightweight `ViewModelFactory` for dependency wiring.
- `Domain`: business models, repository abstractions, and use cases for fetching and sorting recipes.
- `Data`: repository implementations and API/data-transfer models used to decode the bundled JSON payload.

This separation keeps UI code independent from data loading details and allows the domain rules to remain small, testable, and reusable.

## Key Architectural Decisions

- SwiftUI for the UI layer to keep the app declarative and reduce view-controller complexity.
- MVVM in presentation so the view model owns async loading and exposes a simple `ViewState` for the views to render.
- Use cases in the domain layer to make the application flow explicit: fetch recipes first, then sort them.
- A repository protocol to isolate the app from the concrete data source and make unit testing straightforward.
- A lightweight `ViewModelFactory` to keep feature-specific creation logic separate from app-wide dependency assembly.
- Orientation-aware composition in the root presentation flow so portrait and landscape can diverge cleanly while sharing the same underlying state and data pipeline.

## Trade-offs

- The dependency setup is intentionally lightweight. `AppContainer` and `ViewModelFactory` give the app an explicit composition model without introducing a DI framework, but this would likely evolve into feature-specific builders as the app grows.
- The current data source is local JSON only. This keeps the app deterministic and fast to test, but it does not yet address remote sync, caching, or offline invalidation policies.
- `ViewState` is intentionally compact. It makes the view layer easy to reason about, but more advanced UI behaviors such as incremental loading, refresh states, or partial failures would require expanding the state model.
- Error handling is intentionally simple. Repository and presentation errors work for the current flow, but production code would benefit from richer domain error mapping and clearer user-facing error descriptions.
- Orientation-specific presentation is implemented in a focused view rather than through a broader navigation architecture. That keeps the current requirement simple, but it would likely evolve if the product added deeper drill-down flows or split-view behavior on iPad.

## Testing

The project includes:

- Unit tests for repository behavior, domain use cases, and the view model state transitions.
- UI tests for the two primary orientation-driven experiences: portrait recipe details and landscape recipe grid rendering.

The test strategy favors validating business behavior and key user-visible flows over exhaustive snapshot-style coverage.

## What I Would Improve With More Time

- Add a remote-capable repository with structured caching, refresh policies, and clearer error recovery paths.
- Move user-facing copy into localized string resources so the UI is ready for internationalization and easier content maintenance.
- Introduce app configuration management for environment-specific values such as base URLs, feature flags, and runtime settings.
- Add an app coordinator or routing layer if navigation expands beyond the current single-flow experience.
- Strengthen accessibility and localization support, especially around dynamic type and copy externalization.
- Refine image loading and performance behavior with better caching, placeholders, and failure handling for production network conditions.

## Running the App

Open the Xcode project, build the `Recipes` scheme, and run on an iPhone simulator. The app ships with bundled sample data in `recipesSample.json`, so no additional setup is required.
