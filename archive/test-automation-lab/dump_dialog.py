from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

driver = webdriver.Chrome()
driver.get("http://localhost:8081")
wait = WebDriverWait(driver, 15)

print("Waiting for Flutter to load...")
wait.until(EC.presence_of_element_located((By.XPATH, "//flt-semantics[contains(., 'Report an Incident')]")))

report_btn = wait.until(EC.presence_of_element_located((By.XPATH, "//flt-semantics[contains(., 'Report an Incident') and not(.//flt-semantics)]")))
report_btn.click()
time.sleep(2)

print("===== SEMANTICS =====")
for e in driver.find_elements(By.CSS_SELECTOR, "flt-semantics"):
    try:
        text = e.text
        html = e.get_attribute("innerHTML")
        print(f"HTML: {html}")
    except:
        pass
print("=====================")
driver.quit()
