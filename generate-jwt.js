const jwt = require('jsonwebtoken');

try {
  console.log('🚀 Starting JWT generation...');
  
  // 🔧 REPLACE THESE VALUES WITH YOUR ACTUAL VALUES
  const teamId = 'J9G532HF4B';  // From Apple Developer Portal → Membership
  const keyId = 'W8LBS4B443';    // From Apple Developer Portal → Keys
  const servicesId = 'com.adeosun.pocketbalance.auth';  // Your Services ID

  // 🔧 REPLACE WITH YOUR ACTUAL .p8 FILE CONTENTS
  const privateKey = `-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgOtPmTXOBBZ7lJPFZ
F7gsoWRYXL1wgIgpi+VKbHz/sBqgCgYIKoZIzj0DAQehRANCAAToC6wWKMwwdI6l
pP74nk8FfI+lG3+JIJDDdAM88yNgBQr0+8RV6ZQ3IRpzcm0gR8ABQl1m+3lOT1GW
WehAQEVB
-----END PRIVATE KEY-----`;

  console.log('📋 Using values:');
  console.log('Team ID:', teamId);
  console.log('Key ID:', keyId);
  console.log('Services ID:', servicesId);
  console.log('Private Key length:', privateKey.length);

  // Generate JWT token
  const token = jwt.sign(
    {
      iss: teamId,
      iat: Math.floor(Date.now() / 1000),
      exp: Math.floor(Date.now() / 1000) + (86400 * 180), // 6 months
      aud: 'https://appleid.apple.com',
      sub: servicesId
    },
    privateKey,
    {
      algorithm: 'ES256',
      header: {
        kid: keyId
      }
    }
  );

  console.log('🎉 JWT Token Generated!');
  console.log('Copy this token to Supabase:');
  console.log('');
  console.log(token);
  console.log('');
  console.log('📋 Values used:');
  console.log('Team ID:', teamId);
  console.log('Key ID:', keyId);
  console.log('Services ID:', servicesId);

} catch (error) {
  console.error('❌ Error generating JWT:');
  console.error(error.message);
  console.error('Stack trace:', error.stack);
}