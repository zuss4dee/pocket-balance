# 🗑️ Account Deletion - Direct Admin API Setup (Alternative)

## 🚨 **Quick Fix Without Edge Functions**

If you prefer not to use Edge Functions, here's a direct approach using the Admin API.

---

## 🔧 **Step 1: Get Your Service Role Key**

1. Go to **Supabase Dashboard** → **Settings** → **API**
2. Copy your **Service Role Key** (starts with `eyJ...`)
3. **Keep this secret** - it has admin privileges!

---

## 🔧 **Step 2: Update SupabaseService.swift**

Replace the `deleteUserFromAuth` function with this:

```swift
private func deleteUserFromAuth(userId: UUID) async throws {
    // Use Supabase Admin API to delete the user from auth.users
    // Replace YOUR_SERVICE_ROLE_KEY with your actual service role key
    
    let serviceRoleKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6eGFnYmJrZHp1cW1jZXZxZ3doIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTgxMzUyNywiZXhwIjoyMDc1Mzg5NTI3fQ.7z8pw0pAte1FtRKRNkWCbyMDwHv9mDWUgieO1KG5MJo"
    
    // Create admin client with service role key
    let adminClient = SupabaseClient(
        supabaseURL: supabaseURL,
        supabaseKey: serviceRoleKey
    )
    
    // Delete user from auth.users using admin privileges
    try await adminClient.auth.admin.deleteUser(id: userId)
    
    print("✅ User deleted from auth.users")
}
```

---

## ⚠️ **Security Warning**

**This approach stores the service role key in your app code, which is less secure than using Edge Functions.**

**Recommended**: Use the Edge Function approach instead for production apps.

---

## 🚀 **Testing**

1. **Update the code** with your service role key
2. **Build and run** the app
3. **Create a test account** and add data
4. **Delete the account** - should now work completely
5. **Try to sign back in** - should fail

---

## ✅ **Expected Result**

After this fix:
- ✅ User account is completely deleted from `auth.users`
- ✅ All data is removed from database
- ✅ User cannot sign back in
- ✅ Settings information is completely gone

This provides **100% account deletion**! 🎉
