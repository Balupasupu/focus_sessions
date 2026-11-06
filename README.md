# Focus Sessions

A simple Flutter Android application that helps users stay focused, track completed sessions, and review their productivity.

## Features

- Select focus durations: 15, 25, and 45 minutes.
- Live countdown timer.
- End a focus session early.
- Add a one-line note after completing or stopping a session.
- Save session history locally.
- View session history with newest sessions first.
- See planned and actual session durations.
- Swipe to delete a session with confirmation.
- Daily quote fetched from the ZenQuotes API.
- Fallback quotes when the API is unavailable.
- Provider-based state management.

## Tech Stack

- Flutter and Dart
- Provider
- SharedPreferences
- HTTP
- ZenQuotes API
- Flutter Test

## Project Structure

```text
lib/
  models/
  providers/
  screens/
  services/
  widgets/
  legacy/

test/
docs/
```

## Setup and Run

1. Clone the repository.
2. Open the project directory.
3. Install dependencies:

```bash
flutter pub get
```

4. Run the application:

```bash
flutter run
```

## State Management

Provider is used to manage shared application state, including the timer and session history. This keeps business logic separate from the UI.

## Local Persistence

SharedPreferences is used to store session history locally as serialized JSON. It is suitable for this small application because the data is simple and does not require a relational database.

## Daily Quote API

The application fetches a random quote from:

`https://zenquotes.io/api/random`

Loading, API errors, invalid responses, and fallback quotes are handled by the quote service and provider.

## Testing

Run all tests:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

**Current validation:** All tests passed and no analyzer issues were found.

## Legacy StreakCounter

The assignment-provided legacy StreakCounter implementation is maintained under `lib/legacy/`. Its date handling and streak calculation bugs are covered by tests in the test directory.

## Known Limitations

- Quote availability depends on the external API and internet connectivity.
- Session data is stored locally on the device.
- Manual verification of all app flows is still in progress.

## Documentation

- `CLAUDE.md` – Project instructions.
- `docs/PROMPT_LOG.md` – AI-assisted development log.
- `docs/REFLECTION.md` – Development reflection.

## Demo Video

## Demo Video

[Watch Focus Sessions App Demo](https://drive.google.com/file/d/12oy3xoR9ewx4rzQnK72LWg8iG24OOJ2H/view?usp=sharing)


Add the 2–3 minute application demonstration video link here before submission.