# Development Reflection

Claude helped me save time by suggesting the project structure, implementing Flutter UI components, and generating initial code for the timer, session history, and daily quote feature.

AI assistance also helped me understand unfamiliar implementation details and create tests. However, I learned that generated code should not be accepted without verification. I had to inspect the logic, run tests, and fix issues such as date comparisons and streak calculations in the legacy code.

One important lesson was to validate edge cases instead of checking only whether the application runs. Unit tests and widget tests helped identify incorrect behavior and improve reliability.

When Claude usage became unavailable, I used ChatGPT for additional debugging and implementation guidance. I kept the changes understandable and verified them using Flutter tests and static analysis.

If I worked on this project again, I would plan the test cases earlier, make smaller Git commits throughout development, and manually verify every user flow before submission.