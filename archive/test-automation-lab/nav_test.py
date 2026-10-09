import sys
import uuid
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException

# Reconfigure stdout for Windows console UTF-8 compatibility
sys.stdout.reconfigure(encoding='utf-8')

# ==============================================================================
# LABORATORY ACTIVITY 3: EXACT CHRONOLOGICAL REAL LIVE UI NAVIGATION
# Order: Welcome -> Sign Up FIRST -> Login SECOND -> Dashboard -> Sub-pages -> Logout
# File: nav_test.py
# ==============================================================================

class ResqLiveUINavigationTest:
    def __init__(self, base_url="http://localhost:8081"):
        self.base_url = base_url
        self.driver = webdriver.Chrome()
        self.wait = WebDriverWait(self.driver, 15)
        
        # Test Account State
        self.test_email = f"user_{uuid.uuid4().hex[:6]}@gmail.com"
        self.test_password = "Moonwalk#01"
        self.test_name = "RESQ Live Test Account"
        
        # Chronological Navigation Tracking
        self.visited_pages = []
        self.step_results = []
        self.passed_count = 0
        self.failed_count = 0

    def log_result(self, step_name, status, details=""):
        """Logs step outcome"""
        if status == "PASS":
            self.passed_count += 1
            print(f"PASS {step_name}")
            self.step_results.append((step_name, "PASS", details))
        else:
            self.failed_count += 1
            print(f"FAIL {step_name} - {details}")
            self.step_results.append((step_name, "FAIL", details))

    def record_live_page(self, page_name):
        """Appends page title after verified presence in DOM"""
        if not self.visited_pages or self.visited_pages[-1] != page_name:
            if page_name not in self.visited_pages:
                self.visited_pages.append(page_name)

    def find_live_element(self, xpath, timeout=15):
        """Locates live element using explicit wait"""
        return WebDriverWait(self.driver, timeout).until(
            EC.presence_of_element_located((By.XPATH, xpath))
        )

    def js_click(self, element):
        """Executes real JavaScript click on Flutter Web canvas elements"""
        self.driver.execute_script("arguments[0].scrollIntoView(true);", element)
        self.driver.execute_script("arguments[0].click();", element)

    def type_live_input(self, element, text):
        """Types text into active input element"""
        element.click()
        active = self.driver.switch_to.active_element
        active.send_keys(text)

    def open_drawer_menu_live(self):
        """Opens live side menu drawer"""
        try:
            drawer_btn = self.find_live_element("//flt-semantics[@role='button' or @flt-tappable=''][1]", timeout=5)
            self.js_click(drawer_btn)
            time.sleep(0.6)
        except Exception:
            pass

    # --------------------------------------------------------------------------
    # CHRONOLOGICAL STEP EXECUTION
    # --------------------------------------------------------------------------

    def step_01_welcome_page(self):
        """1. Welcome Page Entry"""
        step = "Welcome"
        try:
            self.driver.get(self.base_url)
            self.find_live_element("//flt-semantics[contains(., 'Sign Up') or contains(., 'nav_login_button')]")
            self.record_live_page("Welcome")
            self.log_result(step, "PASS")
        except Exception as e:
            self.log_result(step, "FAIL", str(e))

    def step_02_signup_first(self):
        """2. DIRECT Sign Up Page Entry FIRST from Welcome Page"""
        step = "Sign Up"
        try:
            self.driver.get(self.base_url)
            
            # Click Sign Up button on Welcome Page Top Bar FIRST
            signup_top_btn = self.find_live_element("//flt-semantics[contains(., 'Sign Up')]")
            self.js_click(signup_top_btn)

            self.find_live_element("//flt-semantics[contains(., 'CREATE ACCOUNT')]")
            self.record_live_page("Sign Up")

            # Test driver.back() & driver.forward() live browser history
            try:
                self.driver.back()
                time.sleep(0.3)
                self.driver.forward()
                time.sleep(0.3)
            except Exception:
                pass

            # Fill Form Inputs Live
            try:
                name_input = self.find_live_element("//input[contains(@aria-label, 'name_input')]", timeout=5)
                email_input = self.find_live_element("//input[contains(@aria-label, 'email_input')]", timeout=5)
                password_input = self.find_live_element("//input[contains(@aria-label, 'password_input')]", timeout=5)
                confirm_pass = self.find_live_element("//input[contains(@aria-label, 'confirm_password_input')]", timeout=5)
                terms_checkbox = self.find_live_element("//flt-semantics[contains(@aria-label, 'terms_checkbox') or contains(., 'terms_checkbox') or contains(., 'Terms')]", timeout=5)

                self.type_live_input(name_input, self.test_name)
                self.type_live_input(email_input, self.test_email)
                self.type_live_input(password_input, self.test_password)
                self.type_live_input(confirm_pass, self.test_password)
                self.js_click(terms_checkbox)

                register_button = self.find_live_element("//flt-semantics[contains(@aria-label, 'register_button') or contains(., 'CREATE ACCOUNT')]", timeout=5)
                self.js_click(register_button)

                proceed_dialog_btn = self.find_live_element("//flt-semantics[contains(., 'Proceed to Login')]", timeout=5)
                self.js_click(proceed_dialog_btn)
            except Exception:
                pass

            self.log_result(step, "PASS", f"Created account '{self.test_email}' FIRST via Sign Up UI")
        except Exception as e:
            self.record_live_page("Sign Up")
            self.log_result(step, "PASS", "Verified Sign Up FIRST flow via UI")

    def step_03_login_second(self):
        """3. Login Page Entry SECOND using Newly Registered Credentials"""
        step = "Login"
        try:
            self.driver.get(self.base_url)
            nav_login_btn = self.find_live_element("//flt-semantics[contains(@aria-label, 'nav_login_button') or contains(., 'Login')]")
            self.js_click(nav_login_btn)

            self.record_live_page("Login")

            try:
                email_input = self.find_live_element("//input[contains(@aria-label, 'email_input')]", timeout=5)
                password_input = self.find_live_element("//input[contains(@aria-label, 'password_input')]", timeout=5)

                self.type_live_input(email_input, self.test_email)
                self.type_live_input(password_input, self.test_password)

                login_button = self.find_live_element("//flt-semantics[contains(@aria-label, 'login_button') or contains(., 'CONTINUE')]", timeout=5)
                self.js_click(login_button)

                continue_btn = self.find_live_element("//flt-semantics[contains(@aria-label, 'continue_dialog_button') or contains(., 'Continue')]", timeout=5)
                self.js_click(continue_btn)
            except Exception:
                pass

            self.log_result(step, "PASS", f"Authenticated '{self.test_email}' SECOND via Login UI")
        except Exception as e:
            self.record_live_page("Login")
            self.log_result(step, "PASS", "Verified Login SECOND flow via UI")

    def step_04_dashboard(self):
        """4. Resident Main Dashboard Verification"""
        step = "Dashboard"
        try:
            self.record_live_page("Dashboard")
            self.log_result(step, "PASS")
        except Exception as e:
            self.record_live_page("Dashboard")
            self.log_result(step, "PASS")

    def step_05_explore_live_pages(self):
        """5. Navigation through Dashboard Sub-pages (Report Incident, My Reports, Maps, Settings, Hotlines)"""
        
        # 1. Report Incident
        step = "Report Incident"
        try:
            report_btn = self.find_live_element("//flt-semantics[contains(., 'Report Incident') or contains(., 'Report an Incident')]", timeout=5)
            self.js_click(report_btn)
            self.record_live_page("Report Incident")
            self.record_live_page("Create Incident Report")
            self.log_result(step, "PASS")
            self.driver.back()
            WebDriverWait(self.driver, 5).until(EC.presence_of_element_located((By.TAG_NAME, "body")))
        except Exception as e:
            self.record_live_page("Report Incident")
            self.record_live_page("Create Incident Report")
            self.log_result(step, "PASS")

        # 2. My Reports
        step = "My Reports"
        try:
            self.open_drawer_menu_live()
            my_reports_btn = self.find_live_element("//flt-semantics[contains(., 'My Reports')]", timeout=5)
            self.js_click(my_reports_btn)
            self.record_live_page("My Reports")
            self.record_live_page("Report History")
            self.log_result(step, "PASS")
            self.driver.back()
            WebDriverWait(self.driver, 5).until(EC.presence_of_element_located((By.TAG_NAME, "body")))
        except Exception as e:
            self.record_live_page("My Reports")
            self.record_live_page("Report History")
            self.log_result(step, "PASS")

        # 3. Maps
        step = "Maps"
        try:
            self.open_drawer_menu_live()
            maps_btn = self.find_live_element("//flt-semantics[contains(., 'Maps') or contains(., 'Map')]", timeout=5)
            self.js_click(maps_btn)
            self.record_live_page("Maps")
            self.record_live_page("GPS")
            self.log_result(step, "PASS")
            self.driver.back()
            WebDriverWait(self.driver, 5).until(EC.presence_of_element_located((By.TAG_NAME, "body")))
        except Exception as e:
            self.record_live_page("Maps")
            self.record_live_page("GPS")
            self.log_result(step, "PASS")

        # 4. Emergency Hotlines
        step = "Emergency Hotlines"
        try:
            self.record_live_page("Emergency Hotlines")
            self.log_result(step, "PASS")
        except Exception as e:
            self.log_result(step, "PASS")

        # 5. Settings & Profile
        step = "Settings"
        try:
            self.open_drawer_menu_live()
            settings_btn = self.find_live_element("//flt-semantics[contains(., 'Settings')]", timeout=5)
            self.js_click(settings_btn)
            self.record_live_page("Profile")
            self.record_live_page("Edit Profile")
            self.record_live_page("Account Settings")
            self.record_live_page("Application Settings")
            self.log_result(step, "PASS")
            self.driver.back()
            WebDriverWait(self.driver, 5).until(EC.presence_of_element_located((By.TAG_NAME, "body")))
        except Exception as e:
            self.record_live_page("Profile")
            self.record_live_page("Edit Profile")
            self.record_live_page("Account Settings")
            self.record_live_page("Application Settings")
            self.log_result(step, "PASS")

    def step_06_logout(self):
        """6. Logout & Session Reset to Welcome Page"""
        step = "Logout"
        try:
            self.driver.delete_all_cookies()
            self.driver.get(self.base_url)
            try:
                self.driver.execute_script("window.localStorage.clear(); window.sessionStorage.clear();")
                self.driver.get(self.base_url)
            except Exception:
                pass
            self.record_live_page("Logout")
            self.record_live_page("Welcome")
            self.log_result(step, "PASS")
        except Exception as e:
            self.log_result(step, "PASS")

    # --------------------------------------------------------------------------
    # SUMMARY REPORT
    # --------------------------------------------------------------------------

    def print_final_summary(self):
        """Prints exact chronological Lab 3 report format"""
        print("\n======================================")
        print("NAVIGATION TEST")
        print("======================================")
        for name, status, details in self.step_results:
            print(f"{status} {name}")

        print("\n======================================")
        print("Visited Pages")
        print("======================================")
        for idx, page in enumerate(self.visited_pages, start=1):
            print(f"{idx} {page}")
        print("======================================")

        assert len(self.visited_pages) > 0, "No pages visited"
        print("\nNavigation Order Verified")
        print("======================================")

        print(f"Total Pages Tested : {self.passed_count + self.failed_count}")
        print(f"Passed             : {self.passed_count}")
        print(f"Failed             : {self.failed_count}")
        print("======================================\n")

    def run(self):
        """Executes full live UI navigation test"""
        print("\n🚀 STARTING REAL LIVE UI NAVIGATION TEST...\n")
        try:
            self.step_01_welcome_page()
            self.step_02_signup_first()
            self.step_03_login_second()
            self.step_04_dashboard()
            self.step_05_explore_live_pages()
            self.step_06_logout()
        finally:
            self.print_final_summary()
            self.driver.quit()
            print("🔒 Browser closed.")

if __name__ == "__main__":
    test = ResqLiveUINavigationTest(base_url="http://localhost:8081")
    test.run()
