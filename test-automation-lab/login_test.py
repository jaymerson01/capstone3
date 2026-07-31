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
    
    print("Navigating to Login Page...")
    nav_login_btn = wait.until(EC.presence_of_element_located((By.XPATH, "//flt-semantics[contains(., 'nav_login_button') and not(.//flt-semantics)]")))
    nav_login_btn.click()
    
    print("Waiting for email input...")
    email_box = wait.until(EC.presence_of_element_located((By.XPATH, "//input[contains(@aria-label, 'email_input')]")))
    email_box.click()
    time.sleep(0.5)
    
    print("Entering email...")
    driver.switch_to.active_element.send_keys("test@gmail.com")
    
    password_box = driver.find_element(By.XPATH, "//input[contains(@aria-label, 'password_input')]")
    password_box.click()
    time.sleep(0.5)
    
    print("Entering password...")
    driver.switch_to.active_element.send_keys("password123")
    
    print("Clicking login button...")
    login_btn = wait.until(EC.presence_of_element_located((By.XPATH, "//flt-semantics[contains(., 'login_button') and not(.//flt-semantics)]")))
    login_btn.click()
    
    print("Waiting for success dialog...")
    continue_btn = wait.until(EC.presence_of_element_located((By.XPATH, "//flt-semantics[contains(., 'continue_dialog_button') and not(.//flt-semantics)]")))
    continue_btn.click()
    
    # Wait up to 5 seconds for the next UI elements to appear on the screen
    print("Waiting for dashboard page to load...")
    results_wait = WebDriverWait(driver, 5)
    results_wait.until(EC.presence_of_all_elements_located((By.TAG_NAME, "flt-semantics")))
    
    print("Page title:", driver.title)
    
    # Take a screenshot of the results page
    driver.save_screenshot("results.png")
    print("Screenshot saved as 'results.png' in your project folder.")
    
    # Count the number of visible interactive elements (acting as links/buttons in Flutter semantics)
    interactive_elements = driver.find_elements(By.XPATH, "//flt-semantics[@role='button' or @flt-tappable='']")
    print(f"Number of interactable elements found on page: {len(interactive_elements)}")
    
    # Keep the browser open for 2 more seconds just to view the result
    time.sleep(2)

finally:
    driver.quit()
