# Test Automation Lab Guide

This document outlines the Selenium automation scripts built for our Flutter Web application. It serves as a guide for group members to understand what each script does and how to execute them successfully.

---

## 🛠️ Prerequisites & Setup
Before running any of the scripts below, ensure that:
1. **The Flutter Web app is running locally.** 
   Open your terminal in the `community_safety_app` directory and run:
   ```bash
   flutter run -d edge --web-port=8081
   ```
2. **Python and Selenium are installed.**
   Ensure you have your environment set up and the `selenium` package installed via `pip install selenium`.

All scripts should be executed from the `test-automation-lab` directory.

---

## 📦 Module 5: Basic Application Testing

### Activity 1: Sanity Check
**Script:** `sanity_check.py`
* **What it does:** This is a fundamental health check. It simply opens a Chrome browser, navigates to our local app URL (`http://localhost:8081`), and verifies that the Flutter application loads the initial Welcome Page without crashing. It takes a screenshot to prove the app is online.
* **How to run:** 
  ```bash
  python sanity_check.py
  ```

### Activity 2: Basic Interaction & Extended Flow
**Scripts:** `first_script.py` and `extended_script.py`
* **What they do:** 
  * `first_script.py`: Opens the app, waits for it to load, and clicks the **"Report Incident"** button to interact with the first layer of the application.
  * `extended_script.py`: Extends the interaction further. After clicking "Report Incident," the app prompts the user to log in. The script clicks the **"Login"** button on the dialog, navigates to the Login Page, inputs *invalid* credentials (`wrong@gmail.com`), submits the form, and finally verifies that the **"Invalid Credentials"** popup appears before dismissing it.
* **How to run:** 
  ```bash
  python first_script.py
  python extended_script.py
  ```

---

## 📦 Module 6: End-to-End Workflow Testing

### Activity 1: Complete Login Flow
**Script:** `login_test.py`
* **What it does:** Tests the "Happy Path" (Success) for user authentication. It navigates to the Login page, enters valid pre-existing credentials (`test@gmail.com` / `password123`), clicks Login, waits for the "Welcome Back" success dialog, clicks "Continue", and verifies that the user is successfully routed to the Dashboard.
* **How to run:** 
  ```bash
  python login_test.py
  ```

### Activity 2: Registration / Sign Up Flow
**Scripts:** `sign_up_success_test.py` and `sign_up_negative_test.py`
* **What they do:** 
  * `sign_up_negative_test.py` **(Negative Case):** Navigates to the Sign Up page and fills out the form using an email that *already exists* in our mock database (`test@gmail.com`). It uses a strong password (`Moonwalk#01`), agrees to the terms, and clicks Register. It then verifies that the system correctly rejects the registration by catching the red error snackbar: *"Email is already registered"*.
  * `sign_up_success_test.py` **(Success Case):** Navigates to the Sign Up page, automatically generates a brand-new, unique email address (e.g., `newuser_1a2b3c@gmail.com`), fills out the form with a valid strong password, accepts the terms, and submits. It then waits for the "Account Created!" success dialog to appear and verifies the user is redirected back to the login page upon clicking "Proceed to Login".
* **How to run:** 
  ```bash
  python sign_up_negative_test.py
  python sign_up_success_test.py
  ```

---
*Generated for the ResQ Capstone Project Automation Lab.*
