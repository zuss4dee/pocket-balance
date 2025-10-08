# 🔧 Database Migration Troubleshooting Guide

## 🚨 **Common Issues and Solutions**

### **Issue 1: "Column already exists" Error**
**Problem**: `ERROR: column "email" of relation "profiles" already exists`

**Solution**: The column already exists, so skip this step. Run this to check:
```sql
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'profiles';
```

### **Issue 2: "Column does not exist" Error**
**Problem**: `ERROR: column "phone_number" does not exist`

**Solution**: Your table might already have a `phone` column. Check with:
```sql
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'profiles' AND column_name LIKE '%phone%';
```

### **Issue 3: "Constraint already exists" Error**
**Problem**: `ERROR: constraint "unique_phone" already exists`

**Solution**: The constraint already exists, so skip this step. Check existing constraints:
```sql
SELECT constraint_name FROM information_schema.table_constraints 
WHERE table_name = 'profiles';
```

### **Issue 4: "Index already exists" Error**
**Problem**: `ERROR: relation "profiles_phone_idx" already exists`

**Solution**: The index already exists, so skip this step. Check existing indexes:
```sql
SELECT indexname FROM pg_indexes WHERE tablename = 'profiles';
```

---

## 🛠️ **Step-by-Step Manual Migration**

### **Step 1: Check Current Table Structure**
```sql
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;
```

### **Step 2: Add Missing Columns (if needed)**
```sql
-- Only run if email column doesn't exist
ALTER TABLE profiles ADD COLUMN email TEXT;

-- Only run if you have phone_number column (not phone)
-- ALTER TABLE profiles RENAME COLUMN phone_number TO phone;
```

### **Step 3: Add Indexes (if needed)**
```sql
-- Only run if indexes don't exist
CREATE INDEX IF NOT EXISTS profiles_phone_idx ON profiles(phone);
CREATE INDEX IF NOT EXISTS profiles_email_idx ON profiles(email);
```

### **Step 4: Add Constraints (if needed)**
```sql
-- Only run if constraints don't exist
-- ALTER TABLE profiles ADD CONSTRAINT unique_phone UNIQUE (phone);
-- ALTER TABLE profiles ADD CONSTRAINT unique_email UNIQUE (email);
```

### **Step 5: Verify Final Structure**
```sql
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;
```

**Expected Result**:
```
column_name | data_type | is_nullable
------------|-----------|------------
id          | uuid      | NO
full_name   | text      | NO
phone       | text      | YES
email       | text      | YES
created_at  | timestamptz| YES
updated_at  | timestamptz| YES
```

---

## 🔍 **Quick Diagnostic Commands**

### **Check if Migration is Needed**
```sql
-- Check if email column exists
SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'email'
);

-- Check if phone column exists (not phone_number)
SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'phone'
);
```

### **Check Current Constraints**
```sql
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'profiles';
```

### **Check Current Indexes**
```sql
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'profiles';
```

---

## ✅ **Migration Complete Checklist**

- [ ] `email` column exists in `profiles` table
- [ ] `phone` column exists in `profiles` table (not `phone_number`)
- [ ] `profiles_phone_idx` index exists
- [ ] `profiles_email_idx` index exists
- [ ] `unique_phone` constraint exists (optional)
- [ ] `unique_email` constraint exists (optional)

---

## 🆘 **If All Else Fails**

### **Option 1: Drop and Recreate Table**
```sql
-- WARNING: This will delete all profile data!
DROP TABLE IF EXISTS profiles CASCADE;

-- Recreate with correct structure
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Re-enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Recreate policies
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
```

### **Option 2: Contact Support**
If you're still having issues, the problem might be with your Supabase setup. Check:
- Your Supabase project is active
- You have the correct permissions
- Your database is not in maintenance mode

---

## 📞 **Need Help?**

If you're still stuck, try:
1. Check the Supabase logs for detailed error messages
2. Verify your table structure with the diagnostic commands above
3. Run the migration commands one by one instead of all at once
4. Make sure you're running the SQL in the correct Supabase project
