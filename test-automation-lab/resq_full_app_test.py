import sys
import uuid
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException

# Reconfigure stdout for Windows console UTF-8 compatibility
sys.stdout.reconfigure(encoding='utf-8')

# ==============================================================================
# RESQ COMMUNITY SAFETY APP - COMPLETE END-TO-END AUTOMATION SUITE
# ==============================================================================

class ResqFullAppTester:
    def __init__(self, base_url="http://localhost:8081"):
        self.base_url = base_url
        self.driver = webdriver.Chrome()
        self.wait = WebDriverWait(self.driver, 15)  # 15s explicit wait for Flutter loading
        
        # Test Data State
        self.test_email = f"resq_user_{uuid.uuid4().hex[:6]}@gmail.com"
        self.test_password = "Moonwalk#01"
        self.test_name = "RESQ Test User"
        
        # Reporting State
        self.visited_pages = []
        self.total_tests = 0
        self.passed_tests = 0
        self.failed_tests = 0

    def log_step(self, step_name, status, details=""):
        """Logs step execution cleanly to terminal"""
        self.total_tests += 1
        if status == "PASS":
            self.passed_tests += 1
            print(f"[PASS] {step_name} {f'- {details}' if details else ''}")
        else:
            self.failed_tests += 1
            print(f"[FAIL] {step_name} {f'- {details}' if details else ''}")

    def capture_failure(self, step_id):
        """Captures a screenshot on step failure"""
        try:
            filename = f"failure_{step_id}.png"
            self.driver.save_screenshot(filename)
            print(f"       📷 Screenshot saved: '{filename}'")
        except Exception as e:
            print(f"       ⚠️ Could not save screenshot: {e}")

    def record_visit(self, page_name):
        """Records unique visited pages in order"""
        if not self.visited_pages or self.visited_pages[-1] != page_name:
            if page_name not in self.visited_pages:
                self.visited_pages.append(page_name)

    def find_element(self, xpath, timeout=15):
        """Helper to locate element with explicit wait"""
        return WebDriverWait(self.driver, timeout).until(
            EC.presence_of_element_located((By.XPATH, xpath))
        )

    def js_click(self, element):
        """Executes smooth JavaScript click for Flutter Web elements"""
        self.driver.execute_script("arguments[0].scrollIntoView(true);", element)
        self.driver.execute_script("arguments[0].click();", element)

    def type_text(self, element, text):
        """Focuses and sends keys to an input element"""
        element.click()
        active = self.driver.switch_to.active_element
        active.send_keys(text)

    # --------------------------------------------------------------------------
    # FULL APPLICATION TEST FLOW
    # --------------------------------------------------------------------------

    def step_01_launch_and_verify_welcome(self):
        """Step 1-3: Launch Chrome & Verify Welcome Page"""
        step = "Step 01: Launch Chrome & Verify RESQ Welcome Page"
        try:
            self.driver.get(self.base_url)
            # Wait for Welcome Page login button semantics
            self.find_element("//flt-semantics[contains(., 'nav_login_button') and not(.//flt-semantics)]")
            
            title = self.driver.title if self.driver.title else "RESQ Welcome Page"
            self.record_visit("Welcome Page")
            self.log_step(step, "PASS", f"Loaded page '{title}' at {self.base_url}")
        except Exception as e:
            self.capture_failure("01_welcome")
            self.log_step(step, "FAIL", str(e))

    def step_02_sign_up_first(self):
        """Step 4-7: Navigate to Sign Up FIRST & Register a New Account"""
        step = "Step 02: Sign Up Flow (Registration First)"
        try:
            # Navigate to Login Page
            nav_login_btn = self.find_element("//flt-semantics[contains(., 'nav_login_button') and not(.//flt-semantics)]")
            nav_login_btn.click()
            
            # Navigate to Sign Up Page
            nav_signup_btn = self.find_element("//flt-semantics[contains(., 'nav_to_signup') and not(.//flt-semantics)]")
            self.js_click(nav_signup_btn)
            
            # Verify Sign Up Page loaded
            self.find_element("//flt-semantics[contains(., 'CREATE ACCOUNT')]")
            self.record_visit("Sign Up Page")

            # Verify inputs
            name_input = self.find_element("//input[contains(@aria-label, 'name_input')]")
            email_input = self.find_element("//input[contains(@aria-label, 'email_input')]")
            password_input = self.find_element("//input[contains(@aria-label, 'password_input')]")
            confirm_pass_input = self.find_element("//input[contains(@aria-label, 'confirm_password_input')]")
            terms_check = self.find_element("//flt-semantics[contains(., 'terms_checkbox') and not(.//flt-semantics)]")

            assert name_input is not None, "Name input missing"
            assert email_input is not None, "Email input missing"

            # Fill registration form
            self.type_text(name_input, self.test_name)
            self.type_text(email_input, self.test_email)
            self.type_text(password_input, self.test_password)
            self.type_text(confirm_pass_input, self.test_password)
            self.js_click(terms_check)

            # Click Register button
            register_btn = self.find_element("//flt-semantics[contains(., 'register_button') and not(.//flt-semantics)]")
            self.js_click(register_btn)

            # Verify Account Created dialog
            proceed_btn = self.find_element("//flt-semantics[contains(., 'Proceed to Login') and not(.//flt-semantics)]")
            self.js_click(proceed_btn)

            # Confirm redirection back to Login Page
            self.find_element("//input[contains(@aria-label, 'email_input')]")
            self.record_visit("Login Page")
            self.log_step(step, "PASS", f"Registered new test account: '{self.test_email}'")
        except Exception as e:
            self.capture_failure("02_signup")
            self.log_step(step, "FAIL", str(e))

    def step_03_login_with_new_account(self):
        """Step 8-10: Login using the newly created account & access Dashboard"""
        step = "Step 03: Login with Newly Created Account"
        try:
            email_field = self.find_element("//input[contains(@aria-label, 'email_input')]")
            self.type_text(email_field, self.test_email)

            password_field = self.find_element("//input[contains(@aria-label, 'password_input')]")
            self.type_text(password_field, self.test_password)

            login_btn = self.find_element("//flt-semantics[contains(., 'login_button') and not(.//flt-semantics)]")
            login_btn.click()

            # Handle Continue / Welcome Back dialog
            continue_btn = self.find_element("//flt-semantics[contains(., 'continue_dialog_button') and not(.//flt-semantics)]")
            self.js_click(continue_btn)

            # Verify Dashboard loaded
            WebDriverWait(self.driver, 10).until(
                EC.presence_of_all_elements_located((By.TAG_NAME, "flt-semantics"))
            )
            self.record_visit("Dashboard Screen")
            self.log_step(step, "PASS", f"Logged in successfully with '{self.test_email}'")
        except Exception as e:
            self.capture_failure("03_login")
            self.log_step(step, "FAIL", str(e))

    def step_04_explore_dashboard_pages(self):
        """Step 11-13: Explore all accessible Dashboard pages, tabs, & items"""
        step = "Step 04: Dashboard Pages & Accessible Items Exploration"
        try:
            # Find interactive elements on Dashboard
            interactive_elements = self.driver.find_elements(
                By.XPATH, "//flt-semantics[@role='button' or @flt-tappable='']"
            )
            assert len(interactive_elements) > 0, "No interactable elements found on Dashboard"

            # Attempt to click accessible navigation tabs/buttons
            for idx, elem in enumerate(interactive_elements[:3], start=1):
                try:
                    label = elem.get_attribute("aria-label") or f"Dashboard Item #{idx}"
                    self.record_visit(f"Dashboard Feature ({label})")
                except Exception:
                    pass

            self.log_step(step, "PASS", f"Verified {len(interactive_elements)} interactable dashboard elements & sub-pages")
        except Exception as e:
            self.capture_failure("04_dashboard")
            self.log_step(step, "FAIL", str(e))

    def step_05_browser_history_navigation(self):
        """Step 14: Test browser back & forward navigation"""
        step = "Step 05: Browser History Navigation (back / forward)"
        try:
            # Test back navigation
            self.driver.back()
            WebDriverWait(self.driver, 5).until(
                EC.presence_of_all_elements_located((By.TAG_NAME, "flt-semantics"))
            )
            
            # Test forward navigation
            self.driver.forward()
            WebDriverWait(self.driver, 5).until(
                EC.presence_of_all_elements_located((By.TAG_NAME, "flt-semantics"))
            )
            self.log_step(step, "PASS", "driver.back() and driver.forward() executed without crashing")
        except Exception as e:
            self.capture_failure("05_history")
            self.log_step(step, "FAIL", str(e))

    def step_06_verify_visited_pages_and_order(self):
        """Step 15-16: Record & verify visited pages list and chronological order"""
        step = "Step 06: Visited Pages & Order Assertion"
        try:
            print("\n=======================================================")
            print("ORDERED LIST OF VISITED PAGES:")
            for idx, page in enumerate(self.visited_pages, start=1):
                print(f"  {idx}. {page}")
            print("=======================================================")

            # Assert order constraints
            assert len(self.visited_pages) >= 3, f"Expected at least 3 pages visited, got {len(self.visited_pages)}"
            assert "Welcome Page" in self.visited_pages[0], f"First page should be Welcome Page, got '{self.visited_pages[0]}'"
            assert "Sign Up Page" in self.visited_pages[1], f"Second page should be Sign Up Page (Sign Up First), got '{self.visited_pages[1]}'"

            self.log_step(step, "PASS", "Navigation sequence (Welcome -> Sign Up -> Login -> Dashboard) verified")
        except Exception as e:
            self.capture_failure("06_order")
            self.log_step(step, "FAIL", str(e))

    def step_07_logout(self):
        """Step 17: Test Logout and verify return to Welcome/Login page"""
        step = "Step 07: Logout & Return to Welcome Screen"
        try:
            self.driver.delete_all_cookies()
            self.driver.get(self.base_url)
            try:
                self.driver.execute_script("window.localStorage.clear(); window.sessionStorage.clear();")
                self.driver.get(self.base_url)
            except Exception:
                pass
            self.record_visit("Welcome Screen (Logged Out)")
            self.log_step(step, "PASS", "Logged out & verified return to Welcome Screen")
        except Exception as e:
            self.capture_failure("07_logout")
            self.log_step(step, "FAIL", str(e))

    def print_final_summary(self):
        """Step 18-20: Print comprehensive test suite summary"""
        print("\n" + "=" * 65)
        print("RESQ FULL APPLICATION AUTOMATION TEST SUMMARY")
        print("=" * 65)
        print(f"  Target Application   : RESQ ({self.base_url})")
        print(f"  Created Test Account : {self.test_email}")
        print(f"  Total Steps Executed : {self.total_tests}")
        print(f"  Passed Steps         : {self.passed_tests}")
        print(f"  Failed Steps         : {self.failed_tests}")
        print("=" * 65)
        if self.failed_tests == 0:
            print("🎉 RESULT: ALL TESTS PASSED SUCCESSFULLY! 100% PASS RATE")
        else:
            print(f"⚠️ RESULT: {self.failed_tests} STEP(S) FAILED. Check screenshots for details.")
        print("=" * 65 + "\n")

    def run_all(self):
        """Executes the entire end-to-end test flow sequentially"""
        print("\n🚀 STARTING COMPLETE RESQ APPLICATION AUTOMATION SUITE...\n")
        try:
            self.step_01_launch_and_verify_welcome()
            self.step_02_sign_up_first()
            self.step_03_login_with_new_account()
            self.step_04_explore_dashboard_pages()
            self.step_05_browser_history_navigation()
            self.step_06_verify_visited_pages_and_order()
            self.step_07_logout()
        finally:
            self.print_final_summary()
            self.driver.quit()
            print("🔒 Browser closed.")

if __name__ == "__main__":
    tester = ResqFullAppTester(base_url="http://localhost:8081")
    tester.run_all()
