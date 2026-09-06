const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

// Default admin credentials — CHANGE THIS PASSWORD after first login!
const ADMIN_EMAIL = 'admin@safe.gov';
const ADMIN_NAME = 'Super Admin';
const ADMIN_DEFAULT_PASSWORD = 'ResQAdmin2026!';

async function seedAdmin() {
  console.log('==========================================');
  console.log('🔐 RESQ ADMIN ACCOUNT SEEDER');
  console.log('==========================================\n');

  try {
    console.log(`📝 Hashing password for ${ADMIN_EMAIL}...`);
    const hashedPassword = await bcrypt.hash(ADMIN_DEFAULT_PASSWORD, 12);

    const existing = await prisma.user.findUnique({
      where: { email: ADMIN_EMAIL },
    });

    if (existing) {
      console.log('⚠️  admin@safe.gov already exists. Updating to ensure correct role and password...');
      await prisma.user.update({
        where: { email: ADMIN_EMAIL },
        data: {
          name: ADMIN_NAME,
          password: hashedPassword,
          role: 'admin',
          isActive: true,
          isArchived: false,
        },
      });
      console.log('✅ Admin account UPDATED successfully!\n');
    } else {
      console.log('📝 Creating admin@safe.gov account in PostgreSQL...');
      await prisma.user.create({
        data: {
          name: ADMIN_NAME,
          email: ADMIN_EMAIL,
          password: hashedPassword,
          role: 'admin',
          isActive: true,
          isArchived: false,
        },
      });
      console.log('✅ Admin account CREATED successfully!\n');
    }

    console.log('==========================================');
    console.log('🎉 ADMIN LOGIN CREDENTIALS:');
    console.log('   Email:    admin@safe.gov');
    console.log(`   Password: ${ADMIN_DEFAULT_PASSWORD}`);
    console.log('   Role:     admin');
    console.log('==========================================');
    console.log('\n⚠️  IMPORTANT: Change this password after your first login.');

    await prisma.$disconnect();
    process.exit(0);
  } catch (err) {
    console.error('❌ Seeder failed:', err.message);
    await prisma.$disconnect();
    process.exit(1);
  }
}

seedAdmin();
