const http = require('http');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();
const BASE_URL = 'http://localhost:5000';

function request(method, path, data = null, token = null) {
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
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        try {
          const json = JSON.parse(body);
          resolve({ status: res.statusCode, body: json });
        } catch (e) {
          resolve({ status: res.statusCode, body: body });
        }
      });
    });

    req.on('error', (err) => reject(err));

    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

async function runTests() {
  console.log('==============================================');
  console.log('🧪 RUNNING END-TO-END RESQ BACKEND VERIFICATION');
  console.log('==============================================\n');

  try {
    // 1. Health Endpoint Test
    console.log('Step 5: Testing Health Endpoint...');
    const health = await request('GET', '/api/health');
    console.log(` Health Status: ${health.status}`, health.body);
    if (health.status !== 200) throw new Error('Health check failed');
    console.log('✅ Health check PASSED!\n');

    // 2. Resident Signup Test
    console.log('Step 6a: Testing Resident Signup...');
    const testEmail = `resident_${Date.now()}@example.com`;
    const signup = await request('POST', '/api/v1/auth/signup', {
      name: 'Test Resident',
      email: testEmail,
      password: 'password123',
    });
    console.log(` Signup Status: ${signup.status}`, signup.body);
    if (signup.status !== 201 || signup.body.user.role !== 'user') {
      throw new Error('Resident signup failed or role not enforced to user');
    }
    const residentToken = signup.body.token;
    console.log('✅ Resident Signup PASSED! (Role enforced: "user")\n');

    // 3. Resident Login Test
    console.log('Step 6b: Testing Resident Login...');
    const login = await request('POST', '/api/v1/auth/login', {
      email: testEmail,
      password: 'password123',
    });
    console.log(` Login Status: ${login.status}`, login.body);
    if (login.status !== 200) throw new Error('Resident login failed');
    console.log('✅ Resident Login PASSED!\n');

    // 4. Get Current User Test
    console.log('Step 6c: Testing Get Current User...');
    const me = await request('GET', '/api/v1/auth/me', null, residentToken);
    console.log(` Get User Status: ${me.status}`, me.body);
    if (me.status !== 200) throw new Error('Get current user failed');
    console.log('✅ Get Current User PASSED!\n');

    // 5. Create Incident Report Test
    console.log('Step 7: Testing Create Incident Report...');
    const createReport = await request(
      'POST',
      '/api/v1/incidents',
      {
        incidentType: 'Theft',
        reporterName: 'Test Resident',
        location: 'Area 1',
        description: 'Stolen laptop near computer lab',
        urgencyLevel: 'High',
      },
      residentToken
    );
    console.log(` Create Incident Status: ${createReport.status}`, createReport.body);
    if (createReport.status !== 201) throw new Error('Create incident failed');
    const incidentId = createReport.body.incident.id;
    console.log('✅ Create Incident PASSED!\n');

    // 6. Retrieve My Incidents Test
    console.log('Step 8: Testing Retrieve My Incidents...');
    const myIncidents = await request('GET', '/api/v1/incidents/my-reports', null, residentToken);
    console.log(` My Incidents Status: ${myIncidents.status}, Total: ${myIncidents.body.incidents?.length}`);
    if (myIncidents.status !== 200 || !myIncidents.body.incidents?.length) throw new Error('Retrieve my incidents failed');
    console.log('✅ Retrieve My Incidents PASSED!\n');

    // 7. Admin Login & Status Update Test
    console.log('Step 9a: Provisioning Admin Account in DB...');
    const adminEmail = `admin_${Date.now()}@safe.gov`;
    const adminSignup = await request('POST', '/api/v1/auth/signup', {
      name: 'Super Admin',
      email: adminEmail,
      password: 'adminpassword123',
    });
    
    // Elevate account to admin in database to simulate official admin account
    await prisma.user.update({
      where: { email: adminEmail },
      data: { role: 'admin' },
    });

    const adminLogin = await request('POST', '/api/v1/auth/login', {
      email: adminEmail,
      password: 'adminpassword123',
    });
    const adminToken = adminLogin.body.token;

    console.log('Step 9b: Testing Admin Incident Status Update...');
    const updateStatus = await request(
      'PATCH',
      `/api/v1/incidents/${incidentId}/status`,
      { status: 'inProgress' },
      adminToken
    );
    console.log(` Update Status Response: ${updateStatus.status}`, updateStatus.body);
    if (updateStatus.status !== 200 || updateStatus.body.incident?.status !== 'inProgress') {
      throw new Error('Admin status update failed');
    }
    console.log('✅ Admin Status Update PASSED!\n');

    console.log('==============================================');
    console.log('🎉 ALL BACKEND & API VERIFICATION TESTS PASSED!');
    console.log('==============================================');
    await prisma.$disconnect();
    process.exit(0);
  } catch (err) {
    console.error('❌ VERIFICATION TEST FAILED:', err.message);
    await prisma.$disconnect();
    process.exit(1);
  }
}

setTimeout(runTests, 1000);
