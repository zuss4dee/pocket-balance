# Disable Nonce Validation in Supabase

## 🚨 **Issue**
Google Sign-In is failing with "Nonces mismatch" error because Supabase is expecting a nonce but Google Sign-In isn't providing one in the ID token.

## 🔧 **Solution: Disable Nonce Validation**

### **Step 1: Go to Supabase Dashboard**
1. Open your Supabase project dashboard
2. Go to **Authentication** → **Providers**
3. Find **Google** provider

### **Step 2: Update Google Provider Settings**
1. **Click on Google provider** to edit
2. **Find "Nonce validation"** setting
3. **Disable/Turn OFF** nonce validation
4. **Save** the changes

### **Step 3: Alternative - Update Supabase Configuration**
If you can't find the nonce validation setting, you may need to:

1. **Go to Project Settings** → **API**
2. **Find "JWT Settings"**
3. **Look for nonce validation** options
4. **Disable** if available

### **Step 4: Test Google Sign-In**
1. **Build and run** your app
2. **Tap "Continue with Google"**
3. **Should work** without nonce errors!

## 🔍 **Why This Happens**
- **Google Sign-In SDK** doesn't always include nonce in ID tokens
- **Supabase** by default expects nonce for security
- **Disabling nonce validation** allows Google Sign-In to work

## ⚠️ **Security Note**
- **Nonce validation** is a security feature that prevents replay attacks
- **Disabling it** reduces security but allows Google Sign-In to work
- **For production apps**, consider implementing proper nonce handling

## 🎯 **Expected Result**
After disabling nonce validation, Google Sign-In should work without the "Nonces mismatch" error.
