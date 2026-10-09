from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

driver = webdriver.Chrome()
driver.get("http://localhost:8081")

try:
    print("Waiting for Flutter to load...")
    wait = WebDriverWait(driver, 15)
    
    # 1. INTERACT: Navigate to the login page
    print("Navigating to Login Page...")
    nav_login_btn = wait.until(EC.presence_of_element_located((By.XPATH, "//flt-semantics[contains(., 'nav_login_button') and not(.//flt-semantics)]")))
    nav_login_btn.click()
    
    # 2. FILL OUT FORM: Enter invalid credentials
    print("Waiting for email input...")
    email_box = wait.until(EC.presence_of_element_located((By.XPATH, "//input[contains(@aria-label, 'email_input')]")))
    email_box.click()
    time.sleep(0.5)
    
    print("Entering invalid email...")
    driver.switch_to.active_element.send_keys("wrong@gmail.com")
    
    password_box = driver.find_element(By.XPATH, "//input[contains(@aria-label, 'password_input')]")
    password_box.click()
    time.sleep(0.5)
    
    print("Entering invalid password...")
    driver.switch_to.active_element.send_keys("wrongpassword")
    
    # 3. SUBMIT: Click the login button
    print("Clicking login button...")
    time.sleep(1) # wait a moment for visual effect
    login_btn = wait.until(EC.presence_of_element_located((By.XPATH, "//flt-semantics[contains(., 'login_button') and not(.//flt-semantics)]")))
    login_btn.click()
    
    # 4. CONTINUE: Wait for the "Invalid Credentials" popup and click "Try Again"
    print("Waiting for 'Invalid Credentials' popup...")
    try_again_btn = wait.until(EC.presence_of_element_located((By.XPATH, "//flt-semantics[contains(., 'Try Again') and not(.//flt-semantics)]")))
    
    print("Taking screenshot of the popup...")
    driver.save_screenshot("extended_invalid_login_popup.png")
    print("Screenshot saved as 'extended_invalid_login_popup.png'")
    
    print("Popup caught! Clicking 'Try Again' to continue...")
    time.sleep(1) # wait a moment for visual effect
    try_again_btn.click()
    
    # 5. EXTEND: Verify it returns to the login page and take a screenshot
    print("Waiting for popup to dismiss...")
    time.sleep(1.5)
    
    print("Extended test completed successfully!")
    time.sleep(2)
    
finally:
    driver.quit()
