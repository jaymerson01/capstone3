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
    
    # Wait for the main elements of the Welcome Page
    print("Waiting for Welcome Page...")
    wait.until(EC.presence_of_element_located((By.XPATH, "//flt-semantics[contains(., 'Report an Incident')]")))
    
    print("Clicking 'Report an Incident' button...")
    report_btn = wait.until(EC.presence_of_element_located((By.XPATH, "//flt-semantics[contains(., 'Report an Incident') and not(.//flt-semantics)]")))
    report_btn.click()
    
    print("Waiting for 'Login Required' dialog to pop up...")
    # The dialog contains a Login button which is just Custom3dButton with text 'Login'
    dialog_login_btn = wait.until(EC.presence_of_element_located((By.XPATH, "//flt-semantics[contains(., 'dialog_button_Login') and not(.//flt-semantics)]")))
    
    print("Clicking 'Login' inside the dialog to continue...")
    time.sleep(1) # small visual delay
    dialog_login_btn.click()
    
    print("Waiting for Login Page transition...")
    # Once we navigate to login page, the email input should appear
    wait.until(EC.presence_of_element_located((By.XPATH, "//input[contains(@aria-label, 'email_input')]")))
    
    print("Successfully navigated to the Login Page from the dialog!")
    print("Page title:", driver.title)
    
    # Keep the browser open for 2 more seconds just to view the result
    time.sleep(2)
    
finally:
    driver.quit()
