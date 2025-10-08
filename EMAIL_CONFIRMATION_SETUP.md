# 📧 Email Confirmation Setup Guide

## 🚨 **Why No Email is Being Sent**

Your Supabase project likely has email confirmation **disabled**. Here's how to fix it:

---

## 🔧 **Step 1: Enable Email Confirmation in Supabase**

### **1. Go to Supabase Dashboard**
- Open: https://app.supabase.com
- Select your project: `dzxagbbkdzuqmcevqgwh`

### **2. Navigate to Authentication Settings**
- Go to **Authentication** → **Settings**
- Scroll down to **"Email"** section

### **3. Enable Email Confirmation**
- ✅ **Enable email confirmations**: Turn this ON
- ✅ **Enable email change confirmations**: Turn this ON
- ✅ **Enable phone confirmations**: Turn this ON (if you want phone OTP)

### **4. Configure Email Templates**
- Go to **Authentication** → **Email Templates**
- Customize the **"Confirm signup"** template
- Make sure the redirect URL is set to: `pocketbalance://auth`

---

## 🔧 **Step 2: Configure SMTP (Email Provider)**

### **Option A: Use Supabase's Built-in Email (Limited)**
- Supabase provides basic email service
- Good for testing, limited for production

### **Option B: Configure Custom SMTP (Recommended)**
- Go to **Authentication** → **Settings** → **SMTP Settings**
- Configure with your email provider:

#### **For Gmail:**
```
SMTP Host: smtp.gmail.com
SMTP Port: 587
SMTP User: your-email@gmail.com
SMTP Pass: your-app-password
SMTP Admin Email: your-email@gmail.com
```

#### **For SendGrid:**
```
SMTP Host: smtp.sendgrid.net
SMTP Port: 587
SMTP User: apikey
SMTP Pass: your-sendgrid-api-key
SMTP Admin Email: your-email@domain.com
```

---

## 🔧 **Step 3: Update URL Configuration**

### **1. Go to Authentication → URL Configuration**
- **Site URL**: `pocketbalance://auth`
- **Redirect URLs**: 
  - `pocketbalance://auth`
  - `https://dzxagbbkdzuqmcevqgwh.supabase.co/auth/v1/callback`

### **2. Update Email Templates**
- **Confirm signup** template should redirect to: `pocketbalance://auth`
- **Reset password** template should redirect to: `pocketbalance://auth`

---

## 🔧 **Step 4: Test Email Configuration**

### **1. Test in Supabase Dashboard**
- Go to **Authentication** → **Users**
- Try creating a test user
- Check if confirmation email is sent

### **2. Test in Your App**
- Try the email signup flow
- Check your email inbox
- Check spam folder if needed

---

## 🚨 **Common Issues & Solutions**

### **Issue 1: "Email confirmation disabled"**
**Solution**: Enable email confirmations in Supabase settings

### **Issue 2: "No SMTP configured"**
**Solution**: Set up SMTP with your email provider

### **Issue 3: "Redirect URL not configured"**
**Solution**: Add your app's URL scheme to redirect URLs

### **Issue 4: "Email goes to spam"**
**Solution**: 
- Configure proper SPF/DKIM records
- Use a reputable email service (SendGrid, Mailgun)
- Customize email templates

---

## 🎯 **Quick Test Checklist**

- [ ] Email confirmations enabled in Supabase
- [ ] SMTP configured (or using Supabase default)
- [ ] URL scheme configured: `pocketbalance://auth`
- [ ] Redirect URLs added to Supabase
- [ ] Email templates updated with correct redirect URL
- [ ] Test signup in your app
- [ ] Check email inbox (and spam folder)

---

## 📞 **Need Help?**

If you're still having issues:

1. **Check Supabase logs** in the dashboard
2. **Verify SMTP settings** are correct
3. **Test with a different email provider**
4. **Check your app's URL scheme** is properly configured

---

## 🎉 **Expected Result**

After completing these steps:
1. User signs up with email
2. Confirmation email is sent immediately
3. User clicks link in email
4. App opens and user is authenticated
5. User can complete profile setup

The email confirmation flow should work smoothly! 🚀
