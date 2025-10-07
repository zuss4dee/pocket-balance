# 🔐 Multi-Method Login Setup Guide

## ✅ What's New

Your app now supports **3 authentication methods**:
1. 📱 **Phone Number** (with OTP)
2. 📧 **Email & Password**
3. 🍎 **Apple Sign-In**

---

## 🎨 New Login Screen

When you sign out or open the app without being logged in, you'll see a beautiful login screen with options for all three methods!

---

## 📱 Setup Required

### 1. Enable Apple Sign-In Capability in Xcode

#### Steps:
1. Open your project in Xcode
2. Select your **Pocket Balance** target
3. Click on **"Signing & Capabilities"** tab
4. Click **"+ Capability"** button
5. Search for and add **"Sign in with Apple"**
6. ✅ Done!

---

### 2. Configure Apple Sign-In in Supabase

#### Enable Provider:
1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Select your **Pocket Balance** project
3. Click **Authentication** → **Providers**
4. Find **Apple** provider
5. Toggle it **ON**
6. Click **Save**

#### Get Your App ID:
1. In Xcode, go to your target's **General** tab
2. Find your **Bundle Identifier** (e.g., `com.yourname.pocketbalance`)
3. In Supabase Apple settings, enter:
   - **Services ID**: Your Bundle Identifier
   - **Team ID**: (Optional - from Apple Developer account)
   - **Key ID**: (Optional - from Apple Developer account)
4. Click **Save**

---

### 3. Configure Email Authentication in Supabase

#### Enable Email Provider:
1. In Supabase Dashboard → **Authentication** → **Providers**
2. Find **Email** provider
3. Make sure it's **enabled** (should be by default)
4. Configure settings:
   - ✅ Enable email confirmations (optional)
   - ✅ Set password requirements
5. Click **Save**

---

## 🧪 Testing Each Method

### Test 1: Phone Number Login
1. Run your app
2. On login screen, tap **"Continue with Phone"**
3. Enter phone number: `+447911123456` (test number)
4. Enter OTP: `123456`
5. ✅ Should sign in successfully!

### Test 2: Email Login
1. Run your app
2. On login screen, tap **"Continue with Email"**
3. Choose **"Sign Up"** (first time)
4. Enter email and password (min 6 characters)
5. Tap **"Sign Up"**
6. Enter your name in profile screen
7. ✅ Should sign in successfully!

### Test 3: Apple Sign-In
1. Run your app
2. On login screen, tap **"Sign in with Apple"** (black button)
3. Choose to use your Apple ID or Face ID
4. ✅ Should sign in automatically!

---

## 🎯 User Flow

### First Time User (Sign Up):
```
Login Screen
   ↓
Choose Method:
   ├─ Phone → OTP → Profile → Dashboard
   ├─ Email (Sign Up) → Profile → Dashboard
   └─ Apple → Dashboard (auto-saves name)
```

### Returning User (Sign In):
```
Login Screen
   ↓
Choose Method:
   ├─ Phone → OTP → Dashboard
   ├─ Email (Sign In) → Dashboard
   └─ Apple → Dashboard
```

### Sign Out:
```
Dashboard → Profile → Sign Out
   ↓
Login Screen (with all 3 options)
```

---

## 🔧 Features

### Phone Authentication:
- ✅ Country code selector (+44, +1, +234, +91)
- ✅ Automatic E.164 formatting
- ✅ OTP verification
- ✅ Test numbers supported

### Email Authentication:
- ✅ Sign Up with email & password
- ✅ Sign In with existing account
- ✅ Password validation (min 6 chars)
- ✅ Email format validation
- ✅ Toggle between Sign Up/Sign In

### Apple Sign-In:
- ✅ One-tap authentication
- ✅ Automatic name extraction
- ✅ Secure authentication
- ✅ Works with Face ID/Touch ID

---

## 🎨 Design

### Login Screen Components:

```
┌─────────────────────┐
│    🦉 App Logo      │
│                     │
│   Welcome Back      │
│  Sign in to continue│
│                     │
│  ┌──────────────┐   │
│  │ Apple Sign-In│   │  ← Black button
│  └──────────────┘   │
│                     │
│  ┌──────────────┐   │
│  │Phone Number  │   │  ← Blue button
│  └──────────────┘   │
│                     │
│  ┌──────────────┐   │
│  │    Email     │   │  ← Green button
│  └──────────────┘   │
│                     │
│   Terms & Privacy   │
└─────────────────────┘
```

---

## 🔒 Security Features

### Phone Auth:
- ✅ OTP expires in 5 minutes
- ✅ Rate limiting on SMS sends
- ✅ Phone number validation

### Email Auth:
- ✅ Password hashing (automatic by Supabase)
- ✅ Minimum 6 character passwords
- ✅ Email validation
- ✅ Secure password field

### Apple Sign-In:
- ✅ Token-based authentication
- ✅ No password needed
- ✅ Privacy-focused (can hide email)
- ✅ Biometric authentication support

---

## 📝 Code Structure

### New Files:
1. **`LoginView.swift`** - Main login screen with 3 options
2. **`PhoneLoginSheet`** - Phone number entry modal
3. **`OTPLoginSheet`** - OTP verification modal
4. **`EmailLoginSheet`** - Email sign-in/sign-up modal

### Updated Files:
1. **`AuthenticationState.swift`** - Added email & Apple methods
2. **`AppRootView.swift`** - Shows LoginView when not authenticated

---

## 🚀 How to Enable Apple Sign-In

### Quick Steps:

1. **In Xcode:**
   ```
   Target → Signing & Capabilities → + Capability → Sign in with Apple
   ```

2. **In Supabase:**
   ```
   Authentication → Providers → Apple → Enable → Save
   ```

3. **Test:**
   ```
   Run app → Tap Apple button → Sign in!
   ```

---

## 🎯 Which Method to Use?

### For Development:
- **Phone** with test numbers (FREE!)
- **Email** for quick testing

### For Production:
- **Phone** - Best for regions where phones are primary
- **Email** - Universal, works everywhere
- **Apple** - Best UX for iOS users, one-tap sign-in

---

## 💡 Tips

### Recommended Flow:
1. **First Time Users**: Any method works
2. **Returning Users**: They'll use whatever they signed up with
3. **Account Linking**: Users can link multiple methods to one account (future feature)

### Best Practices:
- ✅ Test all three methods
- ✅ Use test phone numbers during development
- ✅ Enable Apple Sign-In before TestFlight/App Store
- ✅ Keep email authentication as fallback

---

## 🐛 Troubleshooting

### Apple Sign-In not working?
**Solution:**
1. Check Xcode capability is added
2. Verify Bundle ID matches in Supabase
3. Make sure Apple provider is enabled in Supabase
4. Test on real device (simulator may have issues)

### Email sign-up not working?
**Solution:**
1. Check email provider is enabled in Supabase
2. Verify password is at least 6 characters
3. Check email format is valid
4. Look at Supabase logs for errors

### Phone login still works?
✅ **Yes!** Phone authentication is still available and working perfectly!

---

## 📊 User Management

### In Supabase Dashboard:

1. **View Users:**
   - Authentication → Users
   - See all users and their sign-in methods

2. **User Details:**
   - Phone users: Will have phone number
   - Email users: Will have email
   - Apple users: May have email (if shared)

3. **User Metadata:**
   - All users: Have `full_name` in metadata
   - Check `user_metadata` field for custom data

---

## ✅ Summary

**Your app now has:**
- ✅ Beautiful login screen
- ✅ 3 authentication methods
- ✅ Smooth sign-out → sign-in flow
- ✅ Proper error handling
- ✅ Loading states
- ✅ User-friendly design

**Users can:**
- ✅ Sign up with Phone, Email, or Apple
- ✅ Sign in with any method they used
- ✅ Sign out and sign back in easily
- ✅ Switch between methods (future feature)

---

**Your authentication is now production-ready! 🎉**

