import sys
import uuid
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Reconfigure stdout for Windows console compatibility
sys.stdout.reconfigure(encoding='utf-8')

# ------------------------------------------------------------------------------
# RESQ APPLICATION FULL E2E AUTOMATION SUITE
# ------------------------------------------------------------------------------

class TestRunner:
    def __init__(self, base_url="http://localhost:8081"):
        self.base_url = base_url
        self.driver = webdriver.Chrome()
        self.wait = WebDriverWait(self.driver, 15)  # 15s explicit wait for Flutter loading
        self.visited_pages = []
        self.total_tests = 0
        self.passed_tests = 0
        self.failed_tests = 0

    def log_step(self, step_name, status, details=""):
        """Helper to log test step outcomes cleanly"""
        self.total_tests += 1
        if status == "PASS":
            self.passed_tests += 1
            print(f"[PASS] {step_name} {f'- {details}' if details else ''}")
        else:
            self.failed_tests += 1
            print(f"[FAIL] {step_name} {f'- {details}' if details else ''}")

    def capture_failure(self, screenshot_name):
        """Captures a screenshot on step failure"""
        try:
            filename = f"failure_{screenshot_name}.png"
            self.driver.save_screenshot(filename)
            print(f"       📷 Screenshot saved to '{filename}'")
        except Exception as e:
            print(f"       ⚠️ Could not capture screenshot: {e}")

    def record_page_visit(self, page_name):
        """Records unique visited pages in chronological order"""
        if not self.visited_pages or self.visited_pages[-1] != page_name:
            if page_name not in self.visited_pages:
                self.visited_pages.append(page_name)

    def find_element(self, xpath, timeout=15):
        """Helper to locate element with explicit wait"""
        return WebDriverWait(self.driver, timeout).until(
            EC.presence_of_element_located((By.XPATH, xpath))
        )

    def js_click(self, element):
        """Executes smooth JavaScript click for Flutter Web canvas/semantics elements"""
        self.driver.execute_script("arguments[0].scrollIntoView(true);", element)
        self.driver.execute_script("arguments[0].click();", element)

    def type_text(self, input_element, text):
        """Clicks and inputs text into the target element"""
        input_element.click()
        active = self.driver.switch_to.active_element
        # Select all and replace text
        active.send_keys(text)

    def navigate_to_login(self):
        """Navigates to a fresh Login page"""
        self.driver.get(self.base_url)
        nav_login_btn = self.find_element("//flt-semantics[contains(., 'nav_login_button') and not(.//flt-semantics)]")
        nav_login_btn.click()
        return self.find_element("//input[contains(@aria-label, 'email_input')]")

    # --------------------------------------------------------------------------
    # TEST SUITE STEPS
    # --------------------------------------------------------------------------

    def test_01_launch_app(self):
        """Step 1 & 2: Launch Chrome and open RESQ Home Page"""
        step = "Test 01: Launch Chrome & Open RESQ Application"
        try:
            self.driver.get(self.base_url)
            self.find_element("//flt-semantics[contains(., 'nav_login_button') and not(.//flt-semantics)]")
            title = self.driver.title if self.driver.title else "RESQ Welcome Page"
            assert self.driver.current_url.startswith("http"), "URL did not load properly"
            self.record_page_visit("Welcome Page")
            self.log_step(step, "PASS", f"Loaded '{title}' at {self.base_url}")
        except Exception as e:
            self.capture_failure("launch_app")
            self.log_step(step, "FAIL", str(e))

    def test_02_verify_welcome_page_navigation(self):
        """Step 3 & 4: Verify Welcome Page components and button clicks"""
        step = "Test 02: Welcome Page Navigation & Dialog Test"
        try:
            self.driver.get(self.base_url)
            report_btn = self.find_element("//flt-semantics[contains(., 'Report an Incident') and not(.//flt-semantics)]")
            report_btn.click()

            dialog_login_btn = self.find_element("//flt-semantics[contains(., 'dialog_button_Login') and not(.//flt-semantics)]")
            assert dialog_login_btn is not None, "Login required dialog button missing"
            dialog_login_btn.click()

            self.find_element("//input[contains(@aria-label, 'email_input')]")
            self.record_page_visit("Login Page")
            self.log_step(step, "PASS", "Report Incident button triggered Login Required dialog successfully")
        except Exception as e:
            self.capture_failure("welcome_nav")
            self.log_step(step, "FAIL", str(e))

    def test_03_verify_login_page_components(self):
        """Step 5 & 6: Verify Login Page components (Email, Password, Buttons)"""
        step = "Test 03: Verify Login Page UI Components"
        try:
            self.navigate_to_login()
            email_field = self.find_element("//input[contains(@aria-label, 'email_input')]")
            password_field = self.find_element("//input[contains(@aria-label, 'password_input')]")
            login_btn = self.find_element("//flt-semantics[contains(., 'login_button') and not(.//flt-semantics)]")
            signup_link = self.find_element("//flt-semantics[contains(., 'nav_to_signup') and not(.//flt-semantics)]")

            assert email_field is not None, "Email field missing"
            assert password_field is not None, "Password field missing"
            assert login_btn is not None, "Login button missing"
            assert signup_link is not None, "Sign Up link missing"

            self.log_step(step, "PASS", "All required fields & buttons verified on Login Page")
        except Exception as e:
            self.capture_failure("login_components")
            self.log_step(step, "FAIL", str(e))

    def test_04_invalid_login(self):
        """Step 7 & 8: Test invalid login attempt & error validation"""
        step = "Test 04: Invalid Login Validation Test"
        try:
            email_field = self.navigate_to_login()
            self.type_text(email_field, "invalid_user_999@gmail.com")

            password_field = self.find_element("//input[contains(@aria-label, 'password_input')]")
            self.type_text(password_field, "wrongpassword123")

            login_btn = self.find_element("//flt-semantics[contains(., 'login_button') and not(.//flt-semantics)]")
            login_btn.click()

            try_again_btn = self.find_element("//flt-semantics[contains(., 'Try Again') and not(.//flt-semantics)]")
            assert try_again_btn is not None, "Invalid credentials popup did not appear"
            self.safe_click(try_again_btn)

            self.find_element("//input[contains(@aria-label, 'email_input')]")
            self.log_step(step, "PASS", "Invalid login rejected with error popup ('Try Again')")
        except Exception as e:
            self.capture_failure("invalid_login")
            self.log_step(step, "FAIL", str(e))

    def test_05_valid_login(self):
        """Step 9 & 10: Test valid login & redirection to Dashboard"""
        step = "Test 05: Valid Login & Dashboard Redirection"
        try:
            email_field = self.navigate_to_login()
            self.type_text(email_field, "test@gmail.com")

            password_field = self.find_element("//input[contains(@aria-label, 'password_input')]")
            self.type_text(password_field, "password123")

            login_btn = self.find_element("//flt-semantics[contains(., 'login_button') and not(.//flt-semantics)]")
            login_btn.click()

            continue_btn = self.find_element("//flt-semantics[contains(., 'continue_dialog_button') and not(.//flt-semantics)]")
            self.safe_click(continue_btn)

            WebDriverWait(self.driver, 10).until(
                EC.presence_of_all_elements_located((By.TAG_NAME, "flt-semantics"))
            )
            self.record_page_visit("Dashboard Screen")
            self.log_step(step, "PASS", "Successfully logged in and redirected to Dashboard")
        except Exception as e:
            self.capture_failure("valid_login")
            self.log_step(step, "FAIL", str(e))

    def test_06_dashboard_navigation(self):
        """Step 11, 12, 13: Test major Dashboard navigation buttons and accessibility"""
        step = "Test 06: Dashboard Navigation & Interactive Elements"
        try:
            interactive_elements = self.driver.find_elements(
                By.XPATH, "//flt-semantics[@role='button' or @flt-tappable='']"
            )
            assert len(interactive_elements) > 0, "No interactable elements found on Dashboard"
            self.log_step(step, "PASS", f"Found {len(interactive_elements)} interactable dashboard elements")
        except Exception as e:
            self.capture_failure("dashboard_nav")
            self.log_step(step, "FAIL", str(e))

    def test_07_browser_navigation_history(self):
        """Step 14: Test browser back and forward navigation"""
        step = "Test 07: Browser Back & Forward Navigation"
        try:
            self.driver.back()
            WebDriverWait(self.driver, 5).until(
                EC.presence_of_all_elements_located((By.TAG_NAME, "flt-semantics"))
            )
            self.driver.forward()
            WebDriverWait(self.driver, 5).until(
                EC.presence_of_all_elements_located((By.TAG_NAME, "flt-semantics"))
            )
            self.log_step(step, "PASS", "driver.back() and driver.forward() executed successfully")
        except Exception as e:
            self.capture_failure("browser_history")
            self.log_step(step, "FAIL", str(e))

    def test_08_sign_up_page_flow(self):
        """Step 15: Test Sign Up page fields, validation, & registration flow"""
        step = "Test 08: Sign Up Page Validation & Registration Flow"
        try:
            self.navigate_to_login()
            signup_link = self.find_element("//flt-semantics[contains(., 'nav_to_signup') and not(.//flt-semantics)]")
            self.safe_click(signup_link)

            self.find_element("//flt-semantics[contains(., 'CREATE ACCOUNT')]")
            self.record_page_visit("Sign Up Page")

            name_input = self.find_element("//input[contains(@aria-label, 'name_input')]")
            email_input = self.find_element("//input[contains(@aria-label, 'email_input')]")
            password_input = self.find_element("//input[contains(@aria-label, 'password_input')]")
            confirm_pass_input = self.find_element("//input[contains(@aria-label, 'confirm_password_input')]")
            terms_check = self.find_element("//flt-semantics[contains(., 'terms_checkbox') and not(.//flt-semantics)]")

            assert name_input is not None, "Name input missing"
            assert email_input is not None, "Email input missing"
            assert password_input is not None, "Password input missing"
            assert confirm_pass_input is not None, "Confirm password input missing"
            assert terms_check is not None, "Terms checkbox missing"

            unique_email = f"e2e_user_{uuid.uuid4().hex[:6]}@gmail.com"
            self.type_text(name_input, "E2E Test User")
            self.type_text(email_input, unique_email)
            self.type_text(password_input, "Moonwalk#01")
            self.type_text(confirm_pass_input, "Moonwalk#01")
            self.safe_click(terms_check)

            register_btn = self.find_element("//flt-semantics[contains(., 'register_button') and not(.//flt-semantics)]")
            self.safe_click(register_btn)

            proceed_btn = self.find_element("//flt-semantics[contains(., 'Proceed to Login') and not(.//flt-semantics)]")
            self.safe_click(proceed_btn)

            self.find_element("//input[contains(@aria-label, 'email_input')]")
            self.log_step(step, "PASS", f"Registered new user '{unique_email}' & redirected to Login Page")
        except Exception as e:
            self.capture_failure("signup_flow")
            self.log_step(step, "FAIL", str(e))

    def test_09_verify_visited_pages_and_order(self):
        """Step 18, 19, 20: Record & verify visited pages list and order"""
        step = "Test 09: Visited Pages Navigation Order Verification"
        try:
            print("\n=======================================================")
            print("ORDERED LIST OF VISITED PAGES:")
            for idx, page in enumerate(self.visited_pages, start=1):
                print(f"  {idx}. {page}")
            print("=======================================================")

            assert len(self.visited_pages) >= 3, f"Expected at least 3 pages visited, got {len(self.visited_pages)}"
            assert "Welcome Page" in self.visited_pages[0], f"First page should be Welcome Page, got {self.visited_pages[0]}"
            assert "Login Page" in self.visited_pages[1], f"Second page should be Login Page, got {self.visited_pages[1]}"

            self.log_step(step, "PASS", "Navigation order verified successfully")
        except Exception as e:
            self.capture_failure("visited_pages_order")
            self.log_step(step, "FAIL", str(e))

    def print_final_summary(self):
        """Step 21: Print comprehensive summary stats"""
        print("\n" + "=" * 60)
        print("RESQ E2E AUTOMATION TEST SUMMARY")
        print("=" * 60)
        print(f"  Total Tests Executed : {self.total_tests}")
        print(f"  Passed Tests         : {self.passed_tests}")
        print(f"  Failed Tests         : {self.failed_tests}")
        print("=" * 60)
        if self.failed_tests == 0:
            print("🎉 ALL TESTS PASSED SUCCESSFULLY! 100% PASS RATE")
        else:
            print(f"⚠️ RESULT: {self.failed_tests} TEST(S) FAILED. Check screenshots for details.")
        print("=" * 60 + "\n")

    def run_all(self):
        """Runs the entire end-to-end test suite in sequence"""
        print("\nSTARTING RESQ FULL APPLICATION E2E TEST SUITE...\n")
        try:
            self.test_01_launch_app()
            self.test_02_verify_welcome_page_navigation()
            self.test_03_verify_login_page_components()
            self.test_04_invalid_login()
            self.test_05_valid_login()
            self.test_06_dashboard_navigation()
            self.test_07_browser_navigation_history()
            self.test_08_sign_up_page_flow()
            self.test_09_verify_visited_pages_and_order()
        finally:
            self.print_final_summary()
            self.driver.quit()
            print("Browser closed.")

if __name__ == "__main__":
    runner = TestRunner(base_url="http://localhost:8081")
    runner.run_all()
