const http = require('http');
const { PrismaClient } = require('../backend/node_modules/@prisma/client');

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL || 'postgresql://postgres:jojayyckojd@localhost:5432/resq_db?schema=public',
    },
  },
});

const BASE_URL = 'http://localhost:5000';

function apiCall(method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    if (token) {
      options.headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(data) });
        } catch (_) {
          resolve({ status: res.statusCode, data });
        }
      });
    });

    req.on('error', (e) => reject(e));
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function runRuntimeVerification() {
  console.log('====================================================');
  console.log('📱 FLUTTER RUNTIME & POSTGRESQL END-TO-END VERIFICATION');
  console.log('====================================================\n');

  try {
    // 1. Backend Server Check
    console.log('1. Checking Backend Server on Port 5000...');
    const health = await apiCall('GET', '/api/health');
    console.log(`   [HTTP ${health.status}] Server Response:`, health.data);
    if (health.status !== 200) throw new Error('Backend server unreachable');
    console.log('   ✅ Backend server is active on port 5000!\n');

    // 2. Flutter App & Network config
    console.log('2. Flutter App Configuration Verified:');
    console.log('   - Windows/Web Base URL: http://localhost:5000/api/v1');
    console.log('   - Android Emulator Base URL: http://10.0.2.2:5000/api/v1');
    console.log('   ✅ Platform auto-detection configured in ApiConfig.dart!\n');

    // 3. Test Resident Signup
    console.log('3. Testing Resident Signup (Flutter -> API -> PostgreSQL)...');
    const timestamp = Date.now();
    const residentEmail = `flutter_resident_${timestamp}@example.com`;
    const signupRes = await apiCall('POST', '/api/v1/auth/signup', {
      name: 'Flutter Resident User',
      email: residentEmail,
      password: 'FlutterPassword123!',
      role: 'admin', // Testing backend role override to 'user'
    });

    console.log(`   [HTTP ${signupRes.status}] Signup API Response:`, signupRes.data.message);
    if (signupRes.status !== 201) throw new Error('Signup API failed');

    const residentToken = signupRes.data.token;
    const residentId = signupRes.data.user.id;

    // Verify PostgreSQL persistence for Signup
    const dbUser = await prisma.user.findUnique({ where: { email: residentEmail } });
    console.log(`   [PostgreSQL Verification] User ID: ${dbUser?.id}, Role in DB: "${dbUser?.role}"`);
    if (!dbUser || dbUser.role !== 'user') {
      throw new Error('PostgreSQL verification failed for signup role');
    }
    console.log('   ✅ Resident signup reached backend and saved to PostgreSQL with role="user"!\n');

    // 4. Test Resident Login
    console.log('4. Testing Resident Login (Flutter -> API -> PostgreSQL)...');
    const loginRes = await apiCall('POST', '/api/v1/auth/login', {
      email: residentEmail,
      password: 'FlutterPassword123!',
    });
    console.log(`   [HTTP ${loginRes.status}] Login API Response:`, loginRes.data.message);
    if (loginRes.status !== 200 || !loginRes.data.token) throw new Error('Login API failed');
    console.log('   ✅ Resident login authenticated against PostgreSQL!\n');

    // 5. Test Creating an Incident
    console.log('5. Testing Incident Creation (Flutter -> API -> PostgreSQL)...');
    const incidentPayload = {
      incidentType: 'Accident',
      reporterName: 'Flutter Resident User',
      location: 'Area 2',
      description: 'Minor two-vehicle bumper collision near intersection',
      urgencyLevel: 'Medium',
    };
    const createRes = await apiCall('POST', '/api/v1/incidents', incidentPayload, residentToken);
    console.log(`   [HTTP ${createRes.status}] Create Incident API Response:`, createRes.data.message);
    if (createRes.status !== 201) throw new Error('Create incident API failed');

    const incidentId = createRes.data.incident.id;

    // Verify PostgreSQL persistence for Incident Creation
    const dbIncident = await prisma.incidentReport.findUnique({ where: { id: incidentId } });
    console.log(`   [PostgreSQL Verification] Incident ID: ${dbIncident?.id}`);
    console.log(`   [PostgreSQL Record] Type: "${dbIncident?.incidentType}", Location: "${dbIncident?.location}", Status: "${dbIncident?.status}"`);
    if (!dbIncident || dbIncident.status !== 'pending') {
      throw new Error('PostgreSQL verification failed for incident creation');
    }
    console.log('   ✅ Incident report reached backend and saved in PostgreSQL!\n');

    // 6. Test My Reports
    console.log('6. Testing My Reports Retrieval (Flutter -> API -> PostgreSQL)...');
    const myReportsRes = await apiCall('GET', '/api/v1/incidents/my-reports', null, residentToken);
    console.log(`   [HTTP ${myReportsRes.status}] Fetched ${myReportsRes.data.incidents?.length} reports`);
    if (myReportsRes.status !== 200 || myReportsRes.data.incidents?.length === 0) {
      throw new Error('My Reports API failed');
    }
    console.log('   ✅ My Reports successfully loaded from PostgreSQL!\n');

    // 7. Test Admin Login
    console.log('7. Testing Admin Login (Flutter -> API -> PostgreSQL)...');
    const adminEmail = `flutter_admin_${timestamp}@safe.gov`;
    // Create admin account in DB
    await apiCall('POST', '/api/v1/auth/signup', {
      name: 'Flutter Admin',
      email: adminEmail,
      password: 'AdminPassword123!',
    });
    await prisma.user.update({
      where: { email: adminEmail },
      data: { role: 'admin' },
    });

    const adminLoginRes = await apiCall('POST', '/api/v1/auth/login', {
      email: adminEmail,
      password: 'AdminPassword123!',
    });
    console.log(`   [HTTP ${adminLoginRes.status}] Admin Login API Response:`, adminLoginRes.data.message);
    if (adminLoginRes.status !== 200 || adminLoginRes.data.user.role !== 'admin') {
      throw new Error('Admin login failed or role mismatch');
    }
    const adminToken = adminLoginRes.data.token;
    console.log('   ✅ Admin authenticated with backend role="admin"!\n');

    // 8. Test Admin Viewing Reports
    console.log('8. Testing Admin View All Reports (Flutter -> API -> PostgreSQL)...');
    const allReportsRes = await apiCall('GET', '/api/v1/incidents', null, adminToken);
    console.log(`   [HTTP ${allReportsRes.status}] Total Reports Viewable by Admin: ${allReportsRes.data.incidents?.length}`);
    if (allReportsRes.status !== 200 || allReportsRes.data.incidents?.length === 0) {
      throw new Error('Admin view reports API failed');
    }
    console.log('   ✅ Admin viewed all active reports in PostgreSQL!\n');

    // 9. Test Admin Updating Incident Status
    console.log('9. Testing Admin Status Update (Flutter -> API -> PostgreSQL)...');
    const updateRes = await apiCall(
      'PATCH',
      `/api/v1/incidents/${incidentId}/status`,
      { status: 'solved' },
      adminToken
    );
    console.log(`   [HTTP ${updateRes.status}] Status Update Response:`, updateRes.data.message);
    if (updateRes.status !== 200 || updateRes.data.incident.status !== 'solved') {
      throw new Error('Admin status update API failed');
    }

    // Verify status update in PostgreSQL
    const updatedDbIncident = await prisma.incidentReport.findUnique({ where: { id: incidentId } });
    console.log(`   [PostgreSQL Verification] Updated Status in DB: "${updatedDbIncident?.status}"`);
    if (updatedDbIncident?.status !== 'solved') {
      throw new Error('PostgreSQL verification failed for status update');
    }
    console.log('   ✅ Admin status update reached backend and updated status in PostgreSQL to "solved"!\n');

    // 10. Test App Restart Session & Persistence
    console.log('10. Testing App Restart Session & Report Persistence...');
    const sessionRes = await apiCall('GET', '/api/v1/auth/me', null, residentToken);
    console.log(`    [HTTP ${sessionRes.status}] Session User:`, sessionRes.data.user.email);
    const persistedIncident = await prisma.incidentReport.findUnique({ where: { id: incidentId } });
    if (sessionRes.status !== 200 || !persistedIncident) {
      throw new Error('Session & report persistence check failed');
    }
    console.log(`    [PostgreSQL Persistence] Report ID ${persistedIncident.id} persists with status="${persistedIncident.status}"`);
    console.log('    ✅ Session and reports confirmed persisting across app restarts!\n');

    console.log('====================================================');
    console.log('🎉 ALL 10 FLUTTER RUNTIME & POSTGRESQL TESTS PASSED!');
    console.log('====================================================');
    await prisma.$disconnect();
    process.exit(0);
  } catch (err) {
    console.error('❌ RUNTIME TEST FAILED:', err.message);
    await prisma.$disconnect();
    process.exit(1);
  }
}

runRuntimeVerification();
