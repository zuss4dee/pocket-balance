# 🚀 Backend Setup Guide - Pocket Balance

## ✅ What I've Done

1. ✅ Created `database_schema.sql` - SQL script for your database tables
2. ✅ Created Services folder for backend code
3. ✅ Your Supabase credentials are configured in `AuthenticationState.swift`

---

## 📝 What YOU Need to Do

### **STEP 1: Run the SQL in Supabase** (5 minutes)

1. Open your browser and go to: https://app.supabase.com
2. Select your project
3. Click **SQL Editor** in the left sidebar
4. Click **"+ New query"** button
5. Open the file `database_schema.sql` (in your project root)
6. **Copy ALL the SQL** from that file
7. **Paste it** into the Supabase SQL Editor
8. Click the **"Run"** button (or press Cmd+Enter)
9. You should see: **"Success. No rows returned"**

This creates 6 tables:
- ✅ profiles
- ✅ income
- ✅ expenses  
- ✅ subscriptions
- ✅ budget_categories
- ✅ credit_cards

Plus security policies (RLS) to protect your data!

---

### **STEP 2: Add SupabaseService.swift to Xcode** (2 minutes)

I'll create this file for you in the next message. You'll need to:

1. In Xcode, right-click on the **"Services"** folder
2. Select **"New File..."**
3. Choose **"Swift File"**
4. Name it: `SupabaseService.swift`
5. Copy the code I provide into this file
6. Make sure **"Pocket Balance" target** is checked
7. Save the file (Cmd+S)

---

### **STEP 3: Test Authentication** (5 minutes)

After the above steps, we'll test:
1. Phone number authentication works
2. Data saves to Supabase
3. Data loads from Supabase

---

## 🔥 What Happens Next

Once you complete Steps 1 & 2, I will:
1. ✅ Update your views to save data to Supabase
2. ✅ Update your views to load data from Supabase
3. ✅ Add proper error handling
4. ✅ Test the full flow

---

## 🆘 Troubleshooting

**SQL fails?**
- Make sure you copied ALL the SQL
- Check for any error messages
- Try running it again (it's safe to re-run)

**Can't find Services folder in Xcode?**
- Close and reopen Xcode
- Or add it manually: Right-click project → Add Files

---

Let me know when you've completed Step 1 (running the SQL)!
