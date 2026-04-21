# Online Grocery Store (510nix/iOS)

A SwiftUI + Firebase based iOS grocery shopping application with:
- Customer shopping flow (browse, search, cart, checkout, order history)
- Admin management flow (product CRUD, order management/status updates)
- Real-time stock reservation/release logic
- Personalized recommendations
- Nutrition information lookup
- Local order notifications

---

## Table of Contents
- [Project Overview](#project-overview)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [System Diagrams](#system-diagrams)
- [Project Structure](#project-structure)
- [Core Data Models](#core-data-models)
- [Firebase Data Design](#firebase-data-design)
- [Application Flows](#application-flows)
- [Setup & Run](#setup--run)
- [Configuration Notes](#configuration-notes)
- [Testing](#testing)
- [Future Improvements](#future-improvements)

---

## Project Overview
This project is an end-to-end online grocery store mobile app for iOS.  
It separates user roles into:
- **Customer**: register/login, browse products, check nutrition, add to cart, checkout, and track past orders.
- **Admin**: secure admin login, product management (CRUD), view all orders, and update order status.

Backend services are powered by **Firebase Authentication** and **Cloud Firestore**, while the UI is built with **SwiftUI**.

---

## Key Features

### Customer Features
- Email/password registration and login
- Browse all available products
- Filter by category and search by name/category
- Product detail screen with:
  - live stock/availability view
  - nutrition data
  - recommendation suggestions
- Cart management:
  - add/update/remove items
  - running totals
  - stock reservation/release handling
- Checkout with delivery details
- Order placement and order history
- Local notifications for order lifecycle events

### Admin Features
- Admin-only flow entry (email-based role check)
- View all products
- Add product
- Edit product
- Delete product
- View all customer orders
- Update order statuses (`pending` → `confirmed` → `delivered`)

### Smart Enhancements
- Recommendation engine based on user views + order history
- Nutrition integration from CalorieNinjas API
- Firestore transaction-based stock reservation

---

## Tech Stack
- **Language**: Swift
- **UI**: SwiftUI
- **Backend**: Firebase
  - Firebase Auth
  - Cloud Firestore
- **Notifications**: UserNotifications (local notifications)
- **Architecture style**: View + Service-oriented structure with observable state (`ObservableObject`)
- **Platform**: iOS

---

## System Diagrams

### 1) Use Case Diagram (`use.png`)
![Use Case Diagram](https://github.com/user-attachments/assets/1733bbc7-4105-4f82-b7f3-02599604e5d9)

### 2) Architecture Diagram (`arch.png`)
![Architecture Diagram](https://github.com/user-attachments/assets/80ef2559-bc25-4b69-8591-629d44281d0b)

### 3) Entity-Relationship Diagram (`erd.png`)
![ER Diagram](https://github.com/user-attachments/assets/9f744fc4-132d-446c-89ab-6003b7ccff2a)

### 4) Checkout Flow Diagram (`chekout_flow.png`)
![Checkout Flow Diagram](https://github.com/user-attachments/assets/21002d83-edff-42cd-874f-cc20cfef3ad0)

---

## Project Structure

Main files in the repository:

- **App Entry**
  - `online_grocery_storeApp.swift`
  - `ContentView.swift`

- **Authentication**
  - `AuthService.swift`
  - `LoginView.swift`
  - `RegisterView.swift`

- **Customer Experience**
  - `HomeView.swift`
  - `ProductCard.swift`
  - `ProductDetailView.swift`
  - `CartView.swift`
  - `CheckoutView.swift`
  - `OrderHistoryView.swift`

- **Admin Experience**
  - `AdminView.swift`
  - `AdminProductsView.swift`
  - `AdminAddProductView.swift`
  - `AdminEditProductView.swift`
  - `AdminOrdersView.swift`

- **Services**
  - `APIService.swift`
  - `FirebaseService.swift`
  - `RecommendationService.swift`
  - `NutritionService.swift`
  - `NotificationService.swift`

- **Models**
  - `Product.swift`
  - `CartItem.swift`
  - `Order.swift`
  - `CartViewModel.swift`

---

## Core Data Models

### Product
- `id`
- `name`
- `category`
- `price`
- `imageURL`
- `description`
- `unit`
- `isAvailable`
- `stock`

### CartItem
- `id`
- `product`
- `quantity`
- computed total price

### Order
- `id`
- `userId`
- `items`
- `totalAmount`
- `status`
- `createdAt`
- `address`
- `phone`
- `note`

---

## Firebase Data Design

### Collections
- `products`
- `orders`
- `users/{userId}/viewHistory`
- `users/{userId}/orderHistory`

### Product document
Contains product metadata, stock, and availability.

### Order document
Contains order metadata, status, delivery info, and denormalized order items.

---

## Application Flows

### Authentication Flow
1. User opens app.
2. If authenticated:
   - admin email → Admin flow
   - otherwise → Customer flow
3. If not authenticated:
   - Login/Register flow.

### Product + Cart Flow
1. Customer browses/searches/filter products.
2. Product details fetch nutrition and recommendations.
3. Add-to-cart reserves stock via Firestore transaction.
4. Quantity changes reserve/release stock accordingly.

### Checkout Flow
1. Customer enters address and phone.
2. App creates `Order`.
3. Order is saved to Firestore.
4. Recommendation history is updated.
5. Local notification is shown.
6. Cart is cleared after successful order placement.

### Admin Order Flow
1. Admin views all orders.
2. Admin updates status to confirmed/delivered.
3. Changes are persisted to Firestore.

---

## Setup & Run

### Prerequisites
- macOS with Xcode
- iOS Simulator or physical iOS device
- Firebase project
- Valid `GoogleService-Info.plist`

### Steps
1. Clone this repository.
2. Open the project in Xcode.
3. Add/verify `GoogleService-Info.plist` in the app target.
4. Ensure Firebase Authentication and Firestore are enabled in your Firebase project.
5. Create required Firestore collections (`products`, `orders`, `users` subcollections).
6. Build and run on simulator/device.

---

## Configuration Notes
- **Admin access logic** currently checks for `admin@grocery.com` email in `ContentView.swift`.
- Firestore offline persistence is disabled in app initialization.
- Notification permission is requested at app launch.
- Nutrition API key is configured in `NutritionService.swift`.

> For production, move secrets (API keys) to secure configuration management and avoid hardcoding.

---

## Testing
- Existing test files:
  - `online_grocery_storeTests.swift`
  - `online_grocery_storeUITests.swift`
  - `online_grocery_storeUITestsLaunchTests.swift`

Run tests from Xcode test navigator (`⌘U`).

---

## Future Improvements
- Replace email-based admin check with role-based claims
- Add robust input validation and error handling
- Add pagination and better query indexing
- Add payment integration
- Add remote push notifications for order updates
- Add stronger test coverage for services and flows
