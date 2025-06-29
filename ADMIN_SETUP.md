# Admin Setup Guide

This guide explains how to manually create admin users and track login activity in your Certify App.

## New Features Added

### 1. Last Login Tracking
- ✅ **Automatic tracking**: Every time a user signs in with Google, their `lastLogin` timestamp is updated
- ✅ **First-time users**: New users get both `createdAt` and `lastLogin` timestamps
- ✅ **Existing users**: Only `lastLogin` is updated on subsequent logins

### 2. Admin User Creation (Two Methods)
- ✅ **Auto-Generate UID**: Create admin users with just email (no UID needed)
- ✅ **Use Existing UID**: Create admin users with specific Firebase Auth UID
- ✅ **Role management**: Set users as admin, CA, or recipient
- ✅ **Debug info**: See your UID for easy copying

## How to Create an Admin User

### Method 1: Auto-Generate UID (Recommended for New Projects)

**Perfect when you don't have any users in Firebase yet!**

1. **Go to Profile** screen
2. **Tap "Admin Setup"** button
3. **Select "Auto-Generate UID"** mode (default)
4. **Fill in the form**:
   - **Email Address**: Your email address
   - **Role**: Choose `admin`, `ca`, or `recipient` (default is `admin`)
5. **Tap "Create Admin User (Auto UID)"**
6. **Copy the generated UID** from the success message

### Method 2: Use Existing UID

**Use this if you already have a Firebase Auth user**

1. **Sign in** to the app with your Google account
2. **Go to Profile** screen
3. **Look for the blue "Debug Info" box**
4. **Copy your UID** (it looks like: `abc123def456...`)
5. **Tap "Admin Setup"** button
6. **Select "Use Existing UID"** mode
7. **Fill in the form**:
   - **User UID**: Paste your copied UID
   - **Email Address**: Your email address
   - **Role**: Choose `admin`, `ca`, or `recipient`
8. **Tap "Create Admin User"**

### Step 3: Verify
1. Go to **Admin Panel** (if you have admin access)
2. You should see your user with the admin role
3. The admin panel now shows:
   - User email
   - Role
   - Creation date
   - Last login time

## User Data Structure

When you create an admin user, this data is stored in Firestore:

```json
{
  "email": "your.email@upm.edu.my",
  "role": "admin",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "lastLogin": "2024-01-01T00:00:00.000Z",
  "isAdmin": true,
  "uid": "auto-generated-uid" // Only for auto-generated UIDs
}
```

## Admin Panel Features

The updated admin panel now shows:
- ✅ **User email**
- ✅ **Current role**
- ✅ **Account creation date**
- ✅ **Last login time** (formatted as "X days/hours/minutes ago")
- ✅ **Role editing** (change user roles)

## Troubleshooting

### "Permission denied" error
- Make sure you're signed in with a UPM email
- Check that your Firebase project has proper security rules

### UID not showing
- Make sure you're signed in to the app
- Try signing out and back in
- Check the debug console for any errors

### Admin panel not accessible
- Ensure your user has the `admin` role
- Check that the role was set correctly in Firestore

### Auto-generate UID not working
- Check your internet connection
- Verify Firebase is properly configured
- Check the debug console for any errors

## Security Notes

⚠️ **Important**: 
- Only use the admin setup for development/testing
- Remove or secure this feature before production
- The admin setup screen should be protected in production
- Consider adding authentication checks to the admin setup

## Code Changes Made

1. **`lib/services/auth_service.dart`**:
   - Added `lastLogin` tracking to Google sign-in
   - Added `createAdminUser()` method (with UID)
   - Added `createAdminUserWithEmail()` method (auto-generate UID)
   - Added `updateLastLogin()` method
   - Added `getUserData()` method

2. **`lib/main.dart`**:
   - Added `AdminSetupScreen` with dual mode support
   - Updated `AdminPanelScreen` to show login times
   - Added debug UID display in `ProfileScreen`
   - Added admin setup button in profile

## Quick Start for New Projects

1. **Run your app** (no need to sign in first)
2. **Go to Profile** → **Admin Setup**
3. **Select "Auto-Generate UID"**
4. **Enter your email** and choose role
5. **Create admin user**
6. **Copy the generated UID** for future reference
7. **Sign in with Google** to test admin access

## Fixing UID Mismatch Issues

If you created an admin user with auto-generated UID but the Admin Panel doesn't appear after signing in with Google, follow these steps:

### Method 1: Automatic Linking (Recommended)
The app now automatically links your Google Auth UID to existing admin users with the same email. Simply:
1. **Sign in with Google** using the same email as your admin user
2. **The app will automatically** link your accounts
3. **Check Profile** to see your role is now loaded

### Method 2: Manual Linking
If automatic linking doesn't work:
1. **Sign in with Google** first
2. **Go to Profile** → **Admin Setup**
3. **Tap "Link Current User to Admin"** button
4. **Check Profile** to verify your role is now `admin`

### Method 3: Debug and Refresh
1. **Go to Profile** and check the debug info
2. **Tap "Refresh Role"** button
3. **Check console logs** for role detection
4. **Sign out and back in** if needed

## Troubleshooting UID Issues

### "Current role: null" in console
- This means the app can't find your user document
- Use the "Link Current User to Admin" button
- Or sign out and back in to trigger automatic linking

### Admin panel still not visible
- Check that your role shows as `admin` in Profile
- Verify the user document exists in Firebase with correct UID
- Try the manual linking method above

## Next Steps

1. Test the admin creation with auto-generated UID
2. Verify you can access admin features
3. Remove or secure the admin setup for production
4. Consider adding email verification for admin creation 