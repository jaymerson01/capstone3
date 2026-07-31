from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import uuid

# Helper to find elements faster in Flutter Web
def wait_for_element(wait, xpath):
    return wait.until(EC.presence_of_element_located((By.XPATH, xpath)))

def run_sign_up_test():
    driver = webdriver.Chrome()
    driver.get("http://localhost:8081")
    wait = WebDriverWait(driver, 15)

    try:
        print("Waiting for Flutter to load...")
        
        # 1. Navigate to Login Page from Welcome Page
        print("Navigating to Login Page...")
        nav_login_btn = wait_for_element(wait, "//flt-semantics[contains(., 'nav_login_button') and not(.//flt-semantics)]")
        nav_login_btn.click()
        
        # 2. Wait for Login Page to load and navigate to Sign Up Page
        print("Navigating to Sign Up Page...")
        nav_signup_btn = wait_for_element(wait, "//flt-semantics[contains(., 'nav_to_signup') and not(.//flt-semantics)]")
        time.sleep(1) # wait for animation
        nav_signup_btn.click()

        # 3. Wait for Sign Up Page to load
        wait_for_element(wait, "//flt-semantics[contains(., 'CREATE ACCOUNT')]")
        time.sleep(1) # Wait for page transition animation
        
        print("\n--- TEST CASE 1: NEGATIVE PATH (DUPLICATE EMAIL) ---")
        name_box = wait_for_element(wait, "//flt-semantics[contains(., 'name_input')]")
        name_box.click()
        time.sleep(0.5)
        driver.switch_to.active_element.send_keys("Test User")

        email_box = wait_for_element(wait, "//flt-semantics[contains(., 'email_input')]")
        email_box.click()
        time.sleep(0.5)
        # Using the existing email test@gmail.com which is pre-seeded in the mock database
        driver.switch_to.active_element.send_keys("test@gmail.com")

        password_box = wait_for_element(wait, "//flt-semantics[contains(., 'password_input')]")
        password_box.click()
        time.sleep(0.5)
        driver.switch_to.active_element.send_keys("password123")

        confirm_password_box = wait_for_element(wait, "//flt-semantics[contains(., 'confirm_password_input')]")
        confirm_password_box.click()
        time.sleep(0.5)
        driver.switch_to.active_element.send_keys("password123")

        # Click Terms Checkbox
        terms_checkbox = wait_for_element(wait, "//flt-semantics[contains(., 'terms_checkbox') and not(.//flt-semantics)]")
        terms_checkbox.click()
        time.sleep(0.5)

        # Click Register
        print("Submitting existing email...")
        register_btn = wait_for_element(wait, "//flt-semantics[contains(., 'register_button') and not(.//flt-semantics)]")
        register_btn.click()

        # Wait for Error Snackbar
        print("Waiting for duplicate email error...")
        wait_for_element(wait, "//flt-semantics[contains(., 'Email is already registered')]")
        print("SUCCESS: Duplicate email error caught correctly!")

        # --- TEST CASE 2: SUCCESS PATH (NEW EMAIL) ---
        print("\n--- TEST CASE 2: SUCCESS PATH (NEW EMAIL) ---")
        
        # Clear the email field (in flutter web, clearing input can be tricky, easiest is to just delete characters or click and backspace)
        email_box.click()
        time.sleep(0.5)
        # Just select all and delete to be safe, but a safer bet in flutter is to use a fresh session or just backspace
        active_element = driver.switch_to.active_element
        active_element.clear() # might not work on flutter web
        
        # Let's generate a unique email!
        unique_email = f"newuser_{uuid.uuid4().hex[:6]}@gmail.com"
        active_element.send_keys(unique_email)
        print(f"Submitting new unique email: {unique_email}")

        # The password is the same, just click register again
        register_btn.click()

        print("Waiting for success dialog...")
        # Check if the Success Dialog appears by looking for the "Proceed to Login" button!
        success_dialog_btn = wait_for_element(wait, "//flt-semantics[contains(., 'Proceed to Login') and not(.//flt-semantics)]")
        print("SUCCESS: Account Created dialog appeared!")
        
        # Click Proceed to Login
        success_dialog_btn.click()
        
        # Wait for transition back to Login Page
        print("Waiting for transition back to Login page...")
        wait_for_element(wait, "//input[contains(@aria-label, 'email_input')]")
        print("SUCCESS: Redirected to login page!")
        print("Page title:", driver.title)
        
        driver.save_screenshot("signup_results.png")
        print("Screenshot saved as 'signup_results.png'")
        
        time.sleep(2)

    finally:
        driver.quit()

if __name__ == "__main__":
    run_sign_up_test()
