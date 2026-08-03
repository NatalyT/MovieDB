# MovieDB

## Overview
MovieDB is an iOS app that browses popular movies using The Movie Database (TMDB) API. Users can scroll through a grid of popular movies, view detailed information including cast and crew, explore actor profiles, search for movies with autocomplete suggestions, and play trailers.

The app is built entirely in SwiftUI and targets iOS 17.

---

## Features
- Browse popular movies in a responsive grid layout
- View movie details: poster, backdrop, release date, genres, runtime, user score, tagline, overview, and top billed cast
- Browse full cast and crew list
- View person details: photo, personal info, biography with expandable text, and known-for movies
- Navigate between movies and people (movie -> cast member -> their movies -> ...)
- Play movie trailers via YouTube (opens in an in-app Safari browser)
- Search movies with debounced autocomplete suggestions
- Falls back to local results when the API search returns empty or fails
- Pagination with infinite scroll (loads next page near the end of the list)
- Pull-to-refresh on the movie list
- Localized in English and German (String Catalog)

---

## Architecture & Design Decisions
The app follows Clean Architecture with MVVM, organized by feature:

- **Views (SwiftUI)**
  Render UI based on a ViewState enum. No business logic.
- **ViewModels (@MainActor, ObservableObject)**
  Own the UI state, handle loading, format data for display.
- **Repository protocol**
  Abstracts data access. The API client conforms directly since this is a read-only, single-source app.
- **DTOs**
  Separate API response structures from domain models. Two DTOs exist for movies: one for list endpoints (genre IDs only) and one for detail (full genres, runtime, videos, release dates).
- **Domain models**
  Plain structs with no framework dependencies.

### Key choices
- **Grid layout** over List -- matches the TMDB website and is more visual.
- **ViewState enum** (`loading`, `loaded`, `empty`, `error`) for each screen -- makes state transitions explicit and testable.
- **Pre-formatted display types** -- ViewModels produce ready-to-render strings (e.g., "2h 28m", "75%"), keeping Views free of formatting logic.
- **`append_to_response`** for regional release dates, videos, credits, and person movie credits -- single API call instead of multiple requests.
- **SFSafariViewController** for trailers -- YouTube embeds don't work reliably in WKWebView on iOS.
- **API-first search with local fallback** -- avoids UI flicker from showing local results then replacing with API results.

Navigation uses SwiftUI's declarative `NavigationStack` with value-based routing. In a larger app, a coordinator/router pattern would centralize navigation decisions.

Dependencies are injected via initializers. No third-party libraries are used.

---

## Error Handling
- Network errors, HTTP status codes, and decoding failures are mapped to user-friendly localized messages via `ErrorMapping`.
- Full-screen error states with retry are shown on initial load failure.
- Pagination errors are shown inline below the grid without clearing existing content.
- Search falls back to local filtering on API failure.

---

## Testing
Unit tests cover ViewModels, mappers, and the search component (88 tests total):

- **MovieListViewModelTests** -- initial load, pagination, duplicate filtering, load more error, refresh, search suggestion forwarding
- **MovieDetailViewModelTests** -- load/error/retry, formatting for year, score, runtime, genres, trailer URL, tagline, cast and crew mapping
- **PersonDetailViewModelTests** -- load/error/retry, personal info formatting (gender, birthday, place of birth), biography, photo URL, known-for movies mapping and limit
- **MovieMapperTests** -- DTO-to-domain mapping for movies, detail with genres/runtime/trailer/cast/crew, regional release dates
- **PersonMapperTests** -- person mapping, gender values, birthday parsing, known-for sorting and filtering
- **MovieSearchTests** -- debounce, API results, cancel, empty/whitespace queries

A `FakeMoviesRepository` with stubs and call tracking is used for all tests. Async state changes are observed via `XCTestExpectation` with Combine.

---

## Limitations & Possible Improvements
Due to time constraints, some features were intentionally left out:

- YouTube trailer playback requires a physical device (the iOS Simulator lacks the media codecs needed by YouTube's web player)
- Image caching and retry (`AsyncImage` doesn't retry on failure or provide caching control)
- Segmented control for Now Playing / Popular / Upcoming
- Search result pagination
- Offline support and persistent storage
- Coordinator/router pattern for centralized navigation (current SwiftUI declarative approach works well for this app size)
- Modularization into SPM packages (Domain, Data, Presentation)
- Broader test coverage (e.g., HTTPClient, integration tests)

The current architecture allows these features to be added without major refactoring.

---

## How to Run
1. Copy `Secrets.xcconfig.example` to `Secrets.xcconfig` at the project root
2. Open `MovieDB.xcodeproj`
3. Select an iPhone simulator (iOS 17+)
4. Run the app (Cmd+R)

A TMDB Bearer Token is included in `Secrets.xcconfig.example` for review purposes and will be revoked after the review. The token is stored in a `.gitignore`d `.xcconfig` file and injected via Info.plist at build time.
