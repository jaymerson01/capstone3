const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const readline = require('readline');

const prisma = new PrismaClient();

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function prompt(question) {
  return new Promise((resolve) => rl.question(question, resolve));
}

async function seedAdmin() {
  console.log('==========================================');
  console.log('🔐 RESQ ADMIN ACCOUNT SEED / RESET TOOL');
  console.log('==========================================\n');
  console.log('This tool creates or resets the admin@safe.gov account in PostgreSQL.\n');

  const password = await prompt('Enter the new admin password (min 8 chars): ');

  if (!password || password.length < 8) {
    console.error('❌ Password must be at least 8 characters.');
    rl.close();
    await prisma.$disconnect();
    process.exit(1);
  }

  const confirmPassword = await prompt('Confirm password: ');
  if (password !== confirmPassword) {
    console.error('❌ Passwords do not match.');
    rl.close();
    await prisma.$disconnect();
    process.exit(1);
  }

  rl.close();

  console.log('\n🔄 Hashing password securely...');
  const hashedPassword = await bcrypt.hash(password, 12);

  const existing = await prisma.user.findUnique({ where: { email: 'admin@safe.gov' } });

  if (existing) {
    console.log('⚠️  admin@safe.gov already exists. Updating password and ensuring admin role...');
    await prisma.user.update({
      where: { email: 'admin@safe.gov' },
      data: {
        password: hashedPassword,
        role: 'admin',
        isActive: true,
        isArchived: false,
      },
    });
    console.log('✅ Admin account updated successfully!');
  } else {
    console.log('📝 Creating new admin@safe.gov account...');
    await prisma.user.create({
      data: {
        name: 'Super Admin',
        email: 'admin@safe.gov',
        password: hashedPassword,
        role: 'admin',
        isActive: true,
        isArchived: false,
      },
    });
    console.log('✅ Admin account created successfully!');
  }

  console.log('\n===========================================');
  console.log('Admin credentials for Flutter login:');
  console.log('  Email: admin@safe.gov');
  console.log('  Password: (the password you just entered)');
  console.log('  Role: admin');
  console.log('===========================================\n');

  await prisma.$disconnect();
}

seedAdmin().catch(async (e) => {
  console.error(e);
  rl.close();
  await prisma.$disconnect();
  process.exit(1);
});
