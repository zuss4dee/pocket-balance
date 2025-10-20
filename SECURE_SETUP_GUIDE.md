# Pocket Balance - Secure Setup Guide

## ⚠️ SECURITY NOTICE
This guide contains NO exposed credentials. All sensitive information has been moved to secure configuration files.

## Required Setup Steps

### 1. Supabase Configuration
1. Create a Supabase project at https://app.supabase.com
2. Get your project URL and API keys from Project Settings > API
3. Update `Config/Info-Config.plist` with your credentials:
   - `SUPABASE_URL`: Your project URL
   - `SUPABASE_ANON_KEY`: Your anon/public key
   - `SUPABASE_SERVICE_ROLE_KEY`: Your service role key (keep secret!)

### 2. Google Sign-In Setup
1. Go to Google Cloud Console
2. Create OAuth 2.0 credentials
3. Download `GoogleService-Info.plist`
4. Add it to your Xcode project (already in .gitignore)

### 3. Apple Sign-In Setup
1. Enable Sign in with Apple in your Apple Developer account
2. Configure the capability in Xcode
3. Update URL schemes in Info.plist

### 4. Database Schema
Run the SQL from `database_schema.sql` in your Supabase SQL editor.

## Security Best Practices
- Never commit credentials to version control
- Use environment variables for production
- Rotate keys regularly
- Monitor access logs

## Support
For technical support, contact: support@pocketbalance.com
