from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import sys

# Ensure UTF-8 output
sys.stdout.reconfigure(encoding='utf-8')

driver = webdriver.Chrome()
driver.get("http://localhost:8080")
try:
    wait = WebDriverWait(driver, 10)
    wait.until(EC.presence_of_element_located((By.XPATH, "//flt-semantics[contains(., 'nav_login_button') and not(.//flt-semantics)]"))).click()
    
    email_box = wait.until(EC.presence_of_element_located((By.XPATH, "//input[contains(@aria-label, 'email_input')]")))
    email_box.send_keys("test@gmail.com")
    
    password_box = driver.find_element(By.XPATH, "//input[contains(@aria-label, 'password_input')]")
    password_box.send_keys("password123")
    
    login_btn = driver.find_element(By.XPATH, "//flt-semantics[contains(@aria-label, 'login_button')]")
    login_btn.click()
    
    time.sleep(3)
    
    # Dump the DOM so we can see if it's an error dialog or a success dialog
    print(driver.page_source)
    
finally:
    driver.quit()
