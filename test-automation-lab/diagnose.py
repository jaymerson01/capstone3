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
    time.sleep(5)
    print(driver.page_source)
finally:
    driver.quit()
