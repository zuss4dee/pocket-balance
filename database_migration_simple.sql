-- =====================================================
-- Pocket Balance Database Migration - SIMPLE VERSION
-- =====================================================
-- Run these SQL commands ONE BY ONE in your Supabase SQL Editor
-- =====================================================

-- STEP 1: Add email column (run this first)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- STEP 2: Check if phone_number column exists, then rename it
-- (Only run this if you have a phone_number column)
-- ALTER TABLE profiles RENAME COLUMN phone_number TO phone;

-- STEP 3: Add performance indexes
CREATE INDEX IF NOT EXISTS profiles_phone_idx ON profiles(phone);
CREATE INDEX IF NOT EXISTS profiles_email_idx ON profiles(email);

-- STEP 4: Add unique constraints (run these one by one)
-- ALTER TABLE profiles ADD CONSTRAINT unique_phone UNIQUE (phone);
-- ALTER TABLE profiles ADD CONSTRAINT unique_email UNIQUE (email);

-- STEP 5: Verify the table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;
