from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

def run_sanity_check():
    print("Initializing WebDriver...")
    driver = webdriver.Chrome()
    
    try:
        print("Opening the application at http://localhost:8081...")
        driver.get("http://localhost:8081")
        wait = WebDriverWait(driver, 15)
        
        # Wait for the Flutter app to load by checking for the welcome page logo or button
        print("Waiting for Flutter Web app to load...")
        wait.until(EC.presence_of_element_located((By.XPATH, "//flt-semantics[contains(., 'nav_login_button') and not(.//flt-semantics)]")))
        
        print("SUCCESS: The application opened and loaded successfully!")
        print("Page Title:", driver.title)
        
        driver.save_screenshot("sanity_check_success.png")
        print("Screenshot saved as 'sanity_check_success.png'")
        
        # Keep it open for just a second so you can see it before it closes
        time.sleep(2)
        
    finally:
        print("Closing the browser...")
        driver.quit()

if __name__ == "__main__":
    run_sanity_check()
