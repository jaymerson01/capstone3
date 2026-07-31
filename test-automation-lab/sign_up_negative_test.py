from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

def wait_for_element(wait, xpath):
    return wait.until(EC.presence_of_element_located((By.XPATH, xpath)))

def js_click(driver, element):
    driver.execute_script("arguments[0].scrollIntoView(true);", element)
    time.sleep(0.5)
    driver.execute_script("arguments[0].click();", element)

def run_sign_up_negative():
    driver = webdriver.Chrome()
    driver.get("http://localhost:8081")
    wait = WebDriverWait(driver, 15)

    try:
        print("Waiting for Flutter to load...")
        
        # 1. Navigate to Login Page
        print("Navigating to Login Page...")
        nav_login_btn = wait_for_element(wait, "//flt-semantics[contains(., 'nav_login_button') and not(.//flt-semantics)]")
        nav_login_btn.click()
        
        # 2. Navigate to Sign Up Page
        print("Navigating to Sign Up Page...")
        nav_signup_btn = wait_for_element(wait, "//flt-semantics[contains(., 'nav_to_signup') and not(.//flt-semantics)]")
        time.sleep(1)
        js_click(driver, nav_signup_btn)

        # 3. Wait for Sign Up Page
        wait_for_element(wait, "//flt-semantics[contains(., 'CREATE ACCOUNT')]")
        time.sleep(1)
        
        print("\n--- TEST CASE: NEGATIVE PATH (DUPLICATE EMAIL) ---")
        name_box = wait_for_element(wait, "//input[contains(@aria-label, 'name_input')]")
        name_box.click()
        time.sleep(0.5)
        driver.switch_to.active_element.send_keys("Test User")

        email_box = wait_for_element(wait, "//input[contains(@aria-label, 'email_input')]")
        email_box.click()
        time.sleep(0.5)
        # Using existing email
        driver.switch_to.active_element.send_keys("test@gmail.com")
        print("Submitting existing email: test@gmail.com")

        password_box = wait_for_element(wait, "//input[contains(@aria-label, 'password_input')]")
        password_box.click()
        time.sleep(0.5)
        driver.switch_to.active_element.send_keys("Moonwalk#01")

        confirm_password_box = wait_for_element(wait, "//input[contains(@aria-label, 'confirm_password_input')]")
        confirm_password_box.click()
        time.sleep(0.5)
        driver.switch_to.active_element.send_keys("Moonwalk#01")

        terms_checkbox = wait_for_element(wait, "//flt-semantics[contains(., 'terms_checkbox') and not(.//flt-semantics)]")
        js_click(driver, terms_checkbox)
        time.sleep(0.5)

        print("Clicking Register...")
        register_btn = wait_for_element(wait, "//flt-semantics[contains(., 'register_button') and not(.//flt-semantics)]")
        js_click(driver, register_btn)

        print("Waiting for duplicate email error snackbar...")
        wait_for_element(wait, "//flt-semantics[contains(., 'Email is already registered')]")
        print("SUCCESS: Duplicate email error caught correctly!")

        driver.save_screenshot("signup_negative_results.png")
        print("Screenshot saved as 'signup_negative_results.png'")
        
        time.sleep(2)

    finally:
        driver.quit()

if __name__ == "__main__":
    run_sign_up_negative()
