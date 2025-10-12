# 🔍 Google Sign-In Setup Guide

## 🚨 **Current Status**
Google Sign-In button is added but **not yet functional**. You need to complete the setup below.

---

## 📱 **Step 1: Add Google Sign-In SDK to Xcode**

### **Option A: Swift Package Manager (Recommended)**

1. **Open your project in Xcode**
2. **File** → **Add Package Dependencies**
3. **Enter URL**: `https://github.com/google/GoogleSignIn-iOS`
4. **Click "Add Package"**
5. **Select "GoogleSignIn"** and click "Add Package"

### **Option B: CocoaPods (Alternative)**

1. **Install CocoaPods** (if not already installed):
   ```bash
   sudo gem install cocoapods
   ```

2. **Create Podfile** in your project root:
   ```ruby
   platform :ios, '15.0'
   use_frameworks!

   target 'Pocket Balance' do
     pod 'GoogleSignIn'
   end
   ```

3. **Install pods**:
   ```bash
   pod install
   ```

4. **Open .xcworkspace** file instead of .xcodeproj

---

## 🔧 **Step 2: Configure Google Sign-In in Xcode**

### **2.1 Add URL Scheme**

1. **Open your project in Xcode**
2. **Select your target** → **Info** tab
3. **Expand "URL Types"**
4. **Click "+" to add new URL Type**
5. **Enter**:
   - **Identifier**: `GoogleSignIn`
   - **URL Schemes**: `YOUR_REVERSED_CLIENT_ID` (from Google Console)

### **2.2 Add GoogleService-Info.plist**

1. **Download** `GoogleService-Info.plist` from Google Console
2. **Drag it** into your Xcode project
3. **Make sure** "Add to target" is checked
4. **Click "Finish"**

---

## 🌐 **Step 3: Create Google OAuth App**

### **3.1 Go to Google Cloud Console**

1. **Visit**: https://console.cloud.google.com/
2. **Create new project** or select existing
3. **Enable Google+ API** (if not already enabled)

### **3.2 Create OAuth 2.0 Credentials**

1. **Go to**: APIs & Services → Credentials
2. **Click "Create Credentials"** → **OAuth 2.0 Client IDs**
3. **Application type**: iOS
4. **Name**: Pocket Balance iOS
5. **Bundle ID**: Your app's bundle identifier
6. **Download** the configuration file

### **3.3 Get Your Credentials**

From the downloaded file, you'll need:
- **CLIENT_ID**
- **REVERSED_CLIENT_ID** (for URL scheme)

---

## 🔧 **Step 4: Configure Supabase**

### **4.1 Enable Google Provider**

1. **Go to**: https://app.supabase.com/
2. **Select your project**
3. **Authentication** → **Providers**
4. **Find Google** provider
5. **Toggle ON**

### **4.2 Configure Google Settings**

1. **Client ID**: From Google Console
2. **Client Secret**: From Google Console
3. **Redirect URL**: `https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback`

---

## 💻 **Step 5: Update Your Code**

### **5.1 Update AppDelegate (if using UIKit)**

```swift
import GoogleSignIn

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
          let plist = NSDictionary(contentsOfFile: path),
          let clientId = plist["CLIENT_ID"] as? String else {
        fatalError("GoogleService-Info.plist not found or CLIENT_ID missing")
    }
    
    GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
    return true
}

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
}
```

### **5.2 Update AuthenticationState.swift**

Replace the placeholder `signInWithGoogle()` function:

```swift
@MainActor
func signInWithGoogle() async {
    isLoading = true
    errorMessage = nil
    
    do {
        print("🔍 Starting Google Sign-In...")
        
        guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else {
            throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No presenting view controller"])
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
        let user = result.user
        
        guard let idToken = user.idToken?.tokenString else {
            throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No ID token"])
        }
        
        // Sign in to Supabase with Google token
        try await client.auth.signInWithIdToken(credentials: .init(provider: .google, idToken: idToken))
        
        // Save user's name if available
        if let fullName = user.profile?.name {
            self.fullName = fullName
            let attributes = UserAttributes(data: ["full_name": .string(fullName)])
            try await client.auth.update(user: attributes)
        }
        
        isLoading = false
        isAuthenticated = true
        currentStep = .completed
        print("✅ Google Sign-In successful")
        
    } catch {
        isLoading = false
        errorMessage = "Google Sign-In failed. Please try again."
        print("❌ Error with Google Sign-In: \(error.localizedDescription)")
    }
}
```

---

## 🧪 **Step 6: Test Google Sign-In**

### **6.1 Build and Run**

1. **Build your project** in Xcode
2. **Run on device** (Google Sign-In doesn't work in simulator)
3. **Tap "Continue with Google"**
4. **Complete Google sign-in flow**

### **6.2 Expected Flow**

1. **Tap Google button** → Google sign-in screen appears
2. **Select Google account** → Grant permissions
3. **Return to app** → User is signed in
4. **Check Supabase** → User appears in Authentication → Users

---

## 🚨 **Common Issues & Solutions**

### **Issue 1: "No presenting view controller"**
**Solution**: Make sure you're testing on a real device, not simulator

### **Issue 2: "Invalid client"**
**Solution**: Check your CLIENT_ID and Bundle ID match exactly

### **Issue 3: "Redirect URI mismatch"**
**Solution**: Verify the redirect URI in Google Console matches Supabase

### **Issue 4: "GoogleService-Info.plist not found"**
**Solution**: Make sure the file is added to your Xcode project target

---

## 🎯 **Quick Checklist**

- [ ] Google Sign-In SDK added to project
- [ ] GoogleService-Info.plist added to project
- [ ] URL scheme configured in Xcode
- [ ] Google OAuth app created
- [ ] Supabase Google provider enabled
- [ ] Code updated with real implementation
- [ ] Tested on real device

---

## 🚀 **After Setup**

Once everything is configured:

1. **Google button will work** - users can sign in with Google
2. **User data syncs** - name and email from Google account
3. **Seamless experience** - one-tap sign-in for users
4. **Supabase integration** - user appears in your database

---

## 📞 **Need Help?**

If you run into issues:

1. **Check Xcode console** for error messages
2. **Verify Google Console** settings match your app
3. **Test on real device** (not simulator)
4. **Check Supabase logs** for authentication errors

The Google Sign-In setup is more complex than Apple Sign-In, but once configured, it provides excellent user experience! 🎉
