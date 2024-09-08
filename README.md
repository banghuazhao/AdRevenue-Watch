# AdRevenue-Watch (Work in Progress)

This iOS app is currently under development. It is built using **SwiftUI** and **Swift Concurrency** to fetch and display AdMob network reports. The app follows **MVVM + Clean Architecture** to maintain a scalable and maintainable codebase.

## Project Status

🚧 **Work in Progress**: This app is actively being developed, with ongoing improvements and feature additions.

## Features (In Progress)

- Fetch AdMob network reports using the Google AdMob API.
- Display data such as clicks, ad requests, impressions, and estimated earnings.
- Supports authentication via OAuth2 with Google Sign-In.
- Uses **MVVM + Clean Architecture** for a clean, testable, and maintainable codebase.

### Planned Features

- Create AdMobAccountUseCase, AdMobAccountRepository, AdMobReportUseCase, AdMobReportRepository
- More granular report filtering options.
- Error handling
- Improved UI for better data presentation.

## Architecture

This project follows **MVVM + Clean Architecture**, with a focus on separating concerns into four layers:

### 1. **View (SwiftUI)**:
   - Handles UI and displays data provided by the **ViewModel**.

### 2. **ViewModel**:
   - Prepares data for the **View** and handles user interactions.
   - Interacts with the **UseCase** to execute business logic.

### 3. **UseCase**:
   - Contains business logic and interacts with the **Repository** for data.

### 4. **Repository**:
   - Manages API requests and handles data retrieval from external sources (Google AdMob API).

## Technologies

- **SwiftUI**: For building the user interface.
- **Swift Concurrency**: Using `async/await` for handling asynchronous tasks.
- **MVVM + Clean Architecture**: Ensures separation of concerns and testability.
- **Google AdMob API**: Fetches network reports from the AdMob API.

## Setup Instructions

### 1. Prerequisites:
- A Google Cloud project with access to the **Google AdMob API**.
- OAuth2 credentials set up in the Google Cloud Console.
- Create `Secret.xcconfig` file in `Config` folder and add your credentials
```
GIDClientID = Your_GIDClientID
GOOGLE_REDIRECT_URL_SCHEMES = Your_GOOGLE_REDIRECT_URL_SCHEMES
```
