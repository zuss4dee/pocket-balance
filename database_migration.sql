-- =====================================================
-- Pocket Balance Database Migration - FIXED VERSION
-- =====================================================
-- Run this SQL in your Supabase SQL Editor to fix existing database
-- =====================================================

-- 1. Add missing email column to profiles table (if it doesn't exist)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'email') THEN
        ALTER TABLE profiles ADD COLUMN email TEXT;
    END IF;
END $$;

-- 2. Check if phone_number column exists and rename it to phone
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'profiles' AND column_name = 'phone_number') THEN
        ALTER TABLE profiles RENAME COLUMN phone_number TO phone;
    END IF;
END $$;

-- 3. Add indexes for better performance (only if they don't exist)
CREATE INDEX IF NOT EXISTS profiles_phone_idx ON profiles(phone);
CREATE INDEX IF NOT EXISTS profiles_email_idx ON profiles(email);

-- 4. Add unique constraints to prevent duplicate phone/email (only if they don't exist)
DO $$ 
BEGIN
    -- Add unique constraint for phone if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE constraint_name = 'unique_phone' AND table_name = 'profiles') THEN
        ALTER TABLE profiles ADD CONSTRAINT unique_phone UNIQUE (phone);
    END IF;
    
    -- Add unique constraint for email if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE constraint_name = 'unique_email' AND table_name = 'profiles') THEN
        ALTER TABLE profiles ADD CONSTRAINT unique_email UNIQUE (email);
    END IF;
END $$;

-- 5. Update existing data if needed (optional)
-- This will sync phone numbers from auth.users to profiles table
UPDATE profiles 
SET phone = auth.users.phone 
FROM auth.users 
WHERE profiles.id = auth.users.id 
AND auth.users.phone IS NOT NULL 
AND (profiles.phone IS NULL OR profiles.phone = '');

-- This will sync emails from auth.users to profiles table  
UPDATE profiles 
SET email = auth.users.email 
FROM auth.users 
WHERE profiles.id = auth.users.id 
AND auth.users.email IS NOT NULL 
AND (profiles.email IS NULL OR profiles.email = '');

-- 6. Verify the changes
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;
