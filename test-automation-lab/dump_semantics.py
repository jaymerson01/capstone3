from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

driver = webdriver.Chrome()
driver.get("http://localhost:8081")
wait = WebDriverWait(driver, 15)

time.sleep(5) # wait for flutter to load

nav_login_btn = wait.until(EC.presence_of_element_located((By.XPATH, "//flt-semantics[contains(., 'nav_login_button') and not(.//flt-semantics)]")))
nav_login_btn.click()
time.sleep(1)

email_box = wait.until(EC.presence_of_element_located((By.XPATH, "//input[contains(@aria-label, 'email_input')]")))
email_box.click()
time.sleep(0.5)
driver.switch_to.active_element.send_keys("test@gmail.com")

password_box = driver.find_element(By.XPATH, "//input[contains(@aria-label, 'password_input')]")
password_box.click()
time.sleep(0.5)
driver.switch_to.active_element.send_keys("password123")

login_btn = wait.until(EC.presence_of_element_located((By.XPATH, "//flt-semantics[contains(., 'login_button') and not(.//flt-semantics)]")))
login_btn.click()
time.sleep(3) # wait for success dialog to appear

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
