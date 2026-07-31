from selenium import webdriver
import time

# Initialize Chrome driver (Selenium Manager will handle the driver download automatically)
driver = webdriver.Chrome()

# Open Google
driver.get("https://www.google.com")

# Print the page title
print("Page title:", driver.title)

# Wait for 5 seconds as requested by the activity instructions
time.sleep(5)

# Close the browser
driver.quit()
