# Project Brief: Pocket Balance

## 1\. High-Level Vision

  * **Product Name:** Pocket Balance
  * **Mission:** A minimalist, manual-entry budgeting app designed for simplicity, privacy, and clarity.
  * **Core User Story:** "As a user, I want to manually track my income and expenses so I can get a clear, real-time picture of my financial health without connecting my bank accounts."

-----

## 2\. Core Features & User Flow

The application follows a simple, linear path:

1.  **Onboarding:** A single, elegant screen explaining the app's value proposition of manual tracking.
2.  **Authentication:** A secure phone number + OTP login system to manage user accounts, powered by Supabase Auth.
3.  **Dashboard (Home Screen):** The main view of the app. It will display the three core metrics:
      * Total Monthly Income
      * Total Monthly Expenses
      * Remaining Balance
4.  **Data Input:** A prominent Floating Action Button (`+`) will be the primary way to add data. Tapping it will give the user a choice to add a "New Income" or a "New Expense" via a simple modal form.
5.  **Detail Lists:** Simple, secondary screens where users can view, edit, and delete all their logged income and expense records.

-----

## 3\. Technical Architecture

  * **Frontend:** Native iOS application built with **SwiftUI**.
  * **Backend:** **Supabase** will be used for:
      * User Authentication (Phone/OTP).
      * PostgreSQL Database for data storage.
  * **Key Dependency:** The **`supabase-swift`** package is our only major external dependency.
  * **Design Pattern:** We will use the **MVVM (Model-View-ViewModel)** pattern to keep our code clean and scalable.

-----

## 4\. Database Schema

Our database consists of two primary tables. All data is protected by Row Level Security (RLS).

### `income` table

```sql
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key to auth.users)
- name (TEXT, e.g., "Salary")
- amount (NUMERIC)
- created_at (TIMESTAMPTZ)
```

### `expenses` table

```sql
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key to auth.users)
- name (TEXT, e.g., "Rent")
- amount (NUMERIC)
- category (TEXT, e.g., "Housing")
- expense_date (DATE)
- created_at (TIMESTAMPTZ)
```

-----

## 5\. Mandate for the AI Assistant

You are my expert iOS development partner. You will use this brief as the single source of truth for the "Pocket Balance" app. All code you generate must align with this simple, manual-entry architecture. Prioritize clean SwiftUI code, the MVVM pattern, and secure integration with the Supabase backend.
