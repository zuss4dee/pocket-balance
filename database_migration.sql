-- =====================================================
-- Pocket Balance Database Migration
-- =====================================================
-- Run this SQL in your Supabase SQL Editor to fix existing database
-- =====================================================

-- 1. Add missing email column to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- 2. Rename phone_number to phone for consistency
ALTER TABLE profiles RENAME COLUMN phone_number TO phone;

-- 3. Add indexes for better performance
CREATE INDEX IF NOT EXISTS profiles_phone_idx ON profiles(phone);
CREATE INDEX IF NOT EXISTS profiles_email_idx ON profiles(email);

-- 4. Add unique constraints to prevent duplicate phone/email
ALTER TABLE profiles ADD CONSTRAINT unique_phone UNIQUE (phone);
ALTER TABLE profiles ADD CONSTRAINT unique_email UNIQUE (email);

-- 5. Update existing data if needed (optional)
-- This will sync phone numbers from auth.users to profiles table
UPDATE profiles 
SET phone = auth.users.phone 
FROM auth.users 
WHERE profiles.id = auth.users.id 
AND auth.users.phone IS NOT NULL 
AND profiles.phone IS NULL;

-- This will sync emails from auth.users to profiles table  
UPDATE profiles 
SET email = auth.users.email 
FROM auth.users 
WHERE profiles.id = auth.users.id 
AND auth.users.email IS NOT NULL 
AND profiles.email IS NULL;
