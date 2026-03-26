# Prompt Enhancer

Prompt Enhancer is a production-oriented Flutter application for refining raw prompts into structured, reusable prompt assets. It combines a multi-provider LLM abstraction, secure API key management, persistent history, local trend analysis, and usage analytics in a single mobile-first workspace.

The app is built with Clean Architecture, a feature-first folder structure, Riverpod for state management, GoRouter for navigation, Dio for network access, Hive for local persistence, and flutter_secure_storage for credentials.

## Product Summary

Prompt Enhancer helps a user move from rough intent to reusable prompt output.

Core product goals:
- Refine unstructured text into clearer, more actionable prompts.
- Support multiple LLM providers behind a normalized service contract.
- Persist prompt activity for reuse, analytics, and trend discovery.
- Keep provider keys secure and out of general local storage.
- Work without a custom backend for analytics and history features.

Primary user value:
- Faster prompt authoring.
- Consistent output structure.
- Reuse of successful prompts.
- Visibility into usage patterns.
- Flexible provider switching.

## Implemented Feature Set

### 1. Prompt Workspace
The home screen is the main execution surface.

What it does:
- Accepts multiline prompt input.
- Detects the topic of the prompt before refinement.
- Refines the prompt using the active LLM provider.
- Displays refined output, detected topic, confidence, reasoning depth, token count, provider, and latency.
- Allows copying the refined output.
- Automatically saves successful runs into history.

Business outcome:
- A user can turn a rough prompt idea into a clearer, more reusable prompt in one flow.

### 2. History
The history feature stores and reuses previous prompt runs.

What it does:
- Persists prompt runs locally using Hive.
- Stores original prompt, refined prompt, detected topic, provider, token count, latency, and timestamp.
- Supports filtering by topic, provider, and date range.
- Supports copy, delete, and rerun actions.
- Rerun loads the original prompt back into the prompt workspace.

Business outcome:
- Teams or individual users can iterate on successful prompts instead of rewriting them from scratch.

### 3. Settings
The settings feature manages secure credentials and app preferences.

What it does:
- Stores provider API keys using flutter_secure_storage.
- Supports multiple providers: OpenAI, Gemini, Claude, Hugging Face, and Perplexity.
- Provides inline API key entry and update on each provider card.
- Displays masked key state in the UI.
- Supports copy with a mock biometric guard.
- Supports delete for provider keys.
- Persists theme preference: light, dark, system.
- Persists language preference: English (`en`) and Hindi (`hi`).
- Persists default provider selection.

Business outcome:
- A user can configure the app without editing source code or embedding credentials in the app bundle.

### 4. Trending
Trending is derived locally from saved history.

What it does:
- Analyzes recent history from the last 7 days.
- Groups prompt runs by topic.
- Sorts topics by usage count and recency.
- Displays trending topics in a responsive grid.
- Copies the most recent original prompt for a topic when tapped.
- Includes a Firebase sync placeholder for future remote analytics expansion.

Business outcome:
- Users can see what kinds of prompts they rely on most and quickly reuse recent patterns.

### 5. Usage Metrics
Metrics are computed entirely from local history.

What it does:
- Calculates total tokens per provider.
- Calculates average response time overall and per provider.
- Calculates prompts per day.
- Renders analytics with `fl_chart`.
- Uses bar charts for provider token totals.
- Uses line charts for prompts-per-day trends.

Business outcome:
- Users can understand provider usage, prompt volume, and performance over time without needing an external dashboard.

## Business Flows

### Flow 1: First-Time Setup
1. User opens the app and lands on the splash screen.
2. User enters the main workspace.
3. User opens Settings.
4. User pastes an API key for one or more providers.
5. User chooses a default provider.
6. User optionally changes theme or language.

Result:
- The app is ready to execute prompt refinement calls.

### Flow 2: Prompt Refinement
1. User enters raw prompt text in the home screen.
2. App validates input length and provider configuration.
3. App detects prompt topic using the active provider.
4. App sends a refinement request using the topic context.
5. App normalizes the provider response.
6. App displays topic, confidence, refined output, tokens, provider, and latency.
7. App saves the run into history.
8. App refreshes history, trending, and metrics consumers.

Result:
- One prompt run becomes both a usable output and a reusable data point.

### Flow 3: Reuse From History
1. User opens History.
2. User filters by topic, provider, or date.
3. User taps `Rerun` on a previous item.
4. Original prompt is loaded into the home workspace.
5. User edits or reruns the prompt.

Result:
- Previous successful prompts become templates for future work.

### Flow 4: Trend Discovery
1. User accumulates prompt history over time.
2. Trending analyzes the last 7 days of topic activity.
3. User taps a trending topic card.
4. The latest original prompt for that topic is copied.

Result:
- Frequently used prompt themes become easy to identify and reuse.

### Flow 5: Usage Review
1. User opens Metrics.
2. App aggregates local history.
3. User reviews provider token totals, average latency, and daily prompt counts.

Result:
- Prompt activity becomes measurable and reviewable without backend analytics.

## Technical Architecture

### Architectural Style
The app follows a Clean Architecture plus feature-first structure.

High-level layers:
- `presentation`: UI widgets, page composition, Riverpod controllers/notifiers, state classes.
- `domain`: entities, repository contracts, and use cases.
- `data`: repository implementations, adapters, models, and service implementations.
- `core`: shared infrastructure such as networking, storage, constants, theme, and DI.
- `shared`: reusable design-system widgets and layout shell.

### Folder Structure
```text
lib/
  app/
    providers/
    router/
  core/
    constants/
    di/
    network/
    storage/
    theme/
    utils/
  features/
    prompt/
      data/
      domain/
      presentation/
    history/
      data/
      domain/
      presentation/
    settings/
      data/
      domain/
      presentation/
    trending/
      data/
      domain/
      presentation/
    metrics/
      data/
      domain/
      presentation/
  shared/
    widgets/
```

### State Management
Riverpod is used for:
- Dependency injection.
- Feature controller lifecycle.
- App preference state.
- Prompt execution state.
- Analytics and history refresh coordination.

Important practices already implemented:
- `select(...)` is used in key areas to reduce rebuilds.
- Controllers are separated from UI widgets.
- Cross-feature refresh is triggered after prompt saves and history deletes.

### Routing
GoRouter is used for app navigation.

Routes:
- `/splash`
- `/home`
- `/history`
- `/trending`
- `/metrics`
- `/settings`

Navigation behavior:
- Splash is the initial route.
- Shared app shell uses a drawer on smaller screens.
- Shared app shell uses a NavigationRail on larger screens.

## LLM Integration Design

### Abstraction
The app uses a repository + adapter pattern for LLM providers.

Primary contract:
- `LLMService.refinePrompt(String input)`
- `LLMService.detectTopic(String input)`

Normalized models:
- `LLMResponse`
- `TopicResult`

### Supported Providers
Implemented provider services:
- OpenAI
- Gemini
- Claude
- Hugging Face
- Perplexity

### Provider Selection
Active provider resolution order:
1. Preferred provider stored in settings.
2. Environment fallback from `PROMPT_PROVIDER`.
3. Default fallback to OpenAI.

API key resolution order:
1. Securely stored API key for the selected provider.
2. Shared `PROMPT_API_KEY` environment variable.
3. Provider-specific environment variable.

### Default Models
Current default models:
- OpenAI: `gpt-4.1-mini`
- Gemini: `gemini-2.0-flash`
- Claude: `claude-3-5-sonnet-latest`
- Hugging Face: `meta-llama/Llama-3.1-70B-Instruct`
- Perplexity: `sonar`

### Request Flow
Prompt execution path:
1. UI triggers `PromptController`.
2. Controller calls `DetectTopicUseCase`.
3. Controller calls `RefinePromptUseCase`.
4. `PromptRepositoryImpl` enriches refinement input with topic metadata.
5. Provider-specific `LLMService` sends a Dio request.
6. Adapter parses provider response into normalized models.
7. Controller updates UI state and persists history.

## Storage Design

### Secure Storage
Used for:
- Provider API keys.

Technology:
- `flutter_secure_storage`

Reason:
- API keys must not be stored in normal local storage.

### Local Storage
Used for:
- Prompt history.
- Theme preference.
- Language preference.
- Preferred provider.

Technology:
- Hive via `HiveStorageService`

### Stored History Schema
A history item contains:
- `prompt`
- `refined_prompt`
- `topic`
- `tokens`
- `provider`
- `latency_ms`
- `timestamp`

## Analytics and Derived Data

### Trending Derivation
Trending is derived from local history by:
- Taking only entries within the last 7 days.
- Ignoring blank topics.
- Grouping entries by normalized topic string.
- Sorting first by usage count, then by recency.

### Metrics Derivation
Metrics are derived from local history by:
- Summing tokens per provider.
- Counting prompts grouped by date.
- Averaging valid latency values.
- Calculating overall totals from all history items.

## Error Handling Strategy

The app maps infrastructure and network failures into a unified `AppException` model.

Covered categories include:
- Network failures
- Timeouts
- Unauthorized responses
- Forbidden responses
- Not found responses
- Validation errors
- Conflict errors
- Server errors
- Hive storage errors
- Secure storage errors
- Unknown failures

Behavioral goals:
- Avoid leaking provider-specific error shapes into UI code.
- Keep messaging consistent across features.
- Preserve feature resilience when one subsystem fails.

Example:
- Prompt refinement can succeed even if saving history fails, and the user still receives the refined output.

## Responsive UI and UX

The UI is built with Material 3 and shared primitives.

Shared widget set includes:
- `AppButton`
- `AppCard`
- `AppTextField`
- `AppStateView`
- `AppShellScaffold`

Responsive behavior:
- Drawer navigation on smaller widths.
- NavigationRail on larger widths.
- Responsive prompt workspace layout.
- Grid-based layouts for provider settings and trending.
- Chart-first metrics layout for larger screens.

## Theme and Localization

### Theme
Supported modes:
- Light
- Dark
- System

Theme notes:
- Material 3 is enabled.
- Seed-based color scheme is used.
- Shared shape, button, input, chip, and scaffold styling are centralized in `core/theme/app_theme.dart`.

### Localization
Current runtime locale choices:
- English (`en`)
- Hindi (`hi`)

Current limitation:
- Locale switching is wired into the app shell, but most custom screen copy is still authored in English.

## Configuration

### Environment Variables
The app supports runtime configuration through `--dart-define` values.

Common defines:
- `PROMPT_PROVIDER`
- `PROMPT_API_KEY`
- `PROMPT_MODEL`
- `PROMPT_BASE_URL`
- `PROMPT_REFINE_PATH`
- `PROMPT_DETECT_TOPIC_PATH`
- `PROMPT_TEMPERATURE`
- `PROMPT_MAX_TOKENS`

Provider-specific API key defines:
- `OPENAI_API_KEY`
- `GEMINI_API_KEY`
- `CLAUDE_API_KEY`
- `HUGGING_FACE_API_KEY`
- `PERPLEXITY_API_KEY`

Example:
```bash
flutter run \
  --dart-define=PROMPT_PROVIDER=openai \
  --dart-define=OPENAI_API_KEY=your_key_here \
  --dart-define=PROMPT_MODEL=gpt-4.1-mini
```

Note:
- Securely stored keys in Settings take precedence over environment API keys for the active provider.

## Development Workflow

### Requirements
- Latest stable Flutter SDK
- Dart SDK compatible with `^3.11.1`
- Android and iOS toolchains configured if running on devices/emulators

### Install Dependencies
```bash
flutter pub get
```

### Run the App
```bash
flutter run
```

### Static Analysis
```bash
flutter analyze
```

### Tests
```bash
flutter test
```

## Existing Test Coverage

Current automated coverage includes:
- Prompt controller unit tests
- OpenAI service normalization and error-mapping tests
- Splash-to-home navigation widget smoke test

Current test files:
- `test/features/prompt/presentation/providers/prompt_controller_test.dart`
- `test/features/prompt/data/services/openai_service_test.dart`
- `test/widget_test.dart`

## Dependencies

Main runtime dependencies:
- `flutter_riverpod`
- `go_router`
- `dio`
- `hive`
- `hive_flutter`
- `flutter_secure_storage`
- `fl_chart`
- `flutter_localizations`
- `freezed_annotation`
- `json_annotation`

Main dev dependencies:
- `build_runner`
- `freezed`
- `json_serializable`
- `flutter_test`
- `flutter_lints`

## Current Constraints and Future Extensions

Already planned or partially scaffolded:
- Replace mock biometric check with real platform authentication.
- Add full app localization for Hindi and future languages.
- Expand test coverage across more pages and repositories.
- Replace Firebase placeholder in Trending with real cloud sync.
- Add stronger persistence and migration coverage for Hive schema changes.
- Extend provider configuration UI for base URLs, models, and advanced request settings.

## Why This App Matters

Prompt Enhancer is not just a UI wrapper around an LLM call. It is a small but complete prompt operations' workspace.

It treats prompt refinement as a repeatable business process:
- configure providers securely,
- refine prompts consistently,
- store what worked,
- analyze usage patterns,
- and feed that knowledge back into future prompt creation.
