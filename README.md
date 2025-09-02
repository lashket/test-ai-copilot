# Test Task

Flutter chat application with AI assistant.

## Technologies

flutter_bloc, dio, equatable, uuid, intl, json_annotation, json_serializable, flutter_test, mocktail, bloc_test, build_runner, very_good_analysis

## Architecture

Tried to follow clean architecture approach with domain, data and presentation layers.

## Testing

Used AI extensively for writing tests, then reviewed them manually. Created 62 tests covering main functionality.

## Code Quality

Set up pipeline for code formatting and analyzer checks.

## Running the Project

Set environment variables using dart define:

```bash
flutter run --dart-define=CONVAI_API_KEY=your_api_key_here --dart-define=CONVAI_BASE_URL=https://your-base-url.com
```
