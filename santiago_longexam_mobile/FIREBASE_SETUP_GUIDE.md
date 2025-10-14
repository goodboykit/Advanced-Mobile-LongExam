# Firebase Setup Guide for Items Functionality

This guide will help you set up Firebase Firestore to handle your items instead of relying on the MongoDB backend.

## Overview

Your app now supports **BOTH** Firebase Firestore and MongoDB for items management. You can switch between them by changing a single flag in the code.

---

## Step 1: Verify Firebase Project Setup

### 1.1 Check if Firebase is already configured

Your project already has Firebase installed with these dependencies:
- `firebase_core: ^3.15.2`
- `firebase_auth: ^5.7.0`
- `cloud_firestore: ^5.6.12`
- `firebase_storage: ^12.3.2`

### 1.2 Verify Firebase Console Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Log in with your Google account
3. Make sure you have a project created (or create a new one)
4. Your project should already be connected since you're using Firebase Auth

---

## Step 2: Enable Cloud Firestore

### 2.1 Enable Firestore in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click on **"Firestore Database"** in the left sidebar (under "Build")
4. Click **"Create database"** button
5. Choose a location:
   - **Production mode** (recommended for production)
   - **Test mode** (recommended for development - easier to start with)

   For development, choose **Test mode** which allows read/write for 30 days.

6. Select a Cloud Firestore location (choose the one closest to your users)
   - Example: `asia-southeast1` for Southeast Asia
   - Example: `us-central` for US

7. Click **"Enable"**

### 2.2 Set up Security Rules (Important!)

After enabling Firestore, you need to set up security rules:

#### For Development/Testing (Temporary - 30 days):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 12, 31);
    }
  }
}
```

#### For Production (Recommended - Secure):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write items
    match /items/{itemId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth != null;
    }

    // Block all other collections by default
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

To update rules:
1. In Firebase Console, go to **Firestore Database**
2. Click on the **"Rules"** tab
3. Paste the rules above
4. Click **"Publish"**

---

## Step 3: Switch Your App to Use Firebase

### 3.1 Enable Firebase Mode

Open the file: `lib/services/item_service.dart`

Find this line (around line 13):
```dart
bool useFirebase = true;
```

Make sure it's set to `true` (it already is by default).

### 3.2 How It Works

The `ItemService` now has three types of methods:

1. **Firebase-specific methods**:
   - `getItemsFromFirebase()`
   - `createItemInFirebase(ItemModel item)`
   - `updateItemInFirebase(String id, ItemModel item)`
   - `deleteItemFromFirebase(String id)`

2. **MongoDB-specific methods**:
   - `getItemsFromMongoDB()`
   - `createItemInMongoDB(dynamic article)`
   - `updateItemInMongoDB(String id, dynamic article)`
   - `deleteItemFromMongoDB(String id, dynamic article)`

3. **Unified methods** (automatically use Firebase or MongoDB based on the flag):
   - `getItems()` - Used throughout your app
   - `createItem(dynamic article)`
   - `updateItem(String id, dynamic article)`
   - `deleteItem(String id, dynamic article)`

### 3.3 Automatic Fallback

The service includes automatic fallback:
- If Firebase fails, it automatically tries MongoDB
- This ensures your app keeps working even if one service is down

---

## Step 4: Test Firebase Items

### 4.1 Run Your App

```bash
cd santiago_longexam_mobile
flutter run
```

### 4.2 Add Test Data Manually in Firebase Console

Since your collection will be empty initially, let's add some test items:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click **"Firestore Database"** in the left sidebar
4. Click **"Start collection"**
5. Collection ID: `items`
6. Click **"Next"**
7. Add a document with these fields:

**Document fields:**
```
Field Name       | Type      | Value
-----------------|-----------|---------------------------------
name             | string    | Sample Item
description      | array     | ["This is a sample item"]
photoUrl         | string    | https://via.placeholder.com/150
qtyTotal         | number    | 100
qtyAvailable     | number    | 100
isActive         | boolean   | true
createdAt        | timestamp | (click "current time")
updatedAt        | timestamp | (click "current time")
```

8. Click **"Save"**

### 4.3 Verify in Your App

1. Open your app
2. Navigate to the items/home screen
3. You should now see the test item you just created
4. Try creating, updating, or deleting items through the app
5. Verify changes appear in Firebase Console → Firestore Database

---

## Step 5: Add Sample Data Programmatically (Optional)

If you want to add sample data through your app, here's a helper you can use:

Create a new file: `lib/utils/firebase_seeder.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSeeder {
  static Future<void> seedItems() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final sampleItems = [
      {
        'name': 'Laptop',
        'description': ['High-performance laptop for work and gaming'],
        'photoUrl': 'https://via.placeholder.com/150',
        'qtyTotal': 50,
        'qtyAvailable': 45,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Wireless Mouse',
        'description': ['Ergonomic wireless mouse with long battery life'],
        'photoUrl': 'https://via.placeholder.com/150',
        'qtyTotal': 200,
        'qtyAvailable': 180,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'USB-C Cable',
        'description': ['Fast charging USB-C cable, 2 meters'],
        'photoUrl': 'https://via.placeholder.com/150',
        'qtyTotal': 500,
        'qtyAvailable': 450,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var item in sampleItems) {
      await firestore.collection('items').add(item);
    }

    print('✅ Sample items added successfully!');
  }
}
```

Then call it once from your main screen or a button:
```dart
// Add this import
import 'package:santiago_longexam_mobile/utils/firebase_seeder.dart';

// Call it once
await FirebaseSeeder.seedItems();
```

---

## Step 6: Switch Between Firebase and MongoDB

### To Use Firebase:
```dart
// In lib/services/item_service.dart (line 13)
bool useFirebase = true;
```

### To Use MongoDB:
```dart
// In lib/services/item_service.dart (line 13)
bool useFirebase = false;
```

**Note**: After changing this flag, restart your app (hot reload won't work for this change).

---

## Step 7: Monitor Your Data

### View Data in Firebase Console:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click **"Firestore Database"**
4. You'll see all your collections and documents
5. You can manually add, edit, or delete data here

### Monitor Usage:
1. In Firebase Console, go to **"Firestore Database"**
2. Click the **"Usage"** tab
3. Monitor:
   - Document reads
   - Document writes
   - Document deletes
   - Storage usage

---

## Step 8: Understanding Firebase Limits (Free Tier)

Firebase Spark Plan (Free) includes:
- **Stored data**: 1 GiB
- **Document reads**: 50,000 per day
- **Document writes**: 20,000 per day
- **Document deletes**: 20,000 per day

For most development and small production apps, this is plenty!

If you exceed these limits, consider:
1. Upgrading to Blaze Plan (pay-as-you-go)
2. Optimizing queries (use pagination, limit results)
3. Caching data locally

---

## Step 9: Troubleshooting

### Problem: "Permission Denied" Error

**Solution**: Check your Firestore Security Rules
1. Go to Firebase Console → Firestore Database → Rules
2. For development, use test mode rules (see Step 2.2)
3. Make sure you're logged in (Firebase Auth)

### Problem: "Collection Not Found" Error

**Solution**: Create the collection manually
1. Go to Firebase Console → Firestore Database
2. Click "Start collection"
3. Collection ID: `items`
4. Add at least one document (see Step 4.2)

### Problem: App Still Shows MongoDB Error

**Solution**:
1. Verify `useFirebase = true` in `item_service.dart`
2. Completely restart the app (stop and run again)
3. Check that you have internet connection
4. Verify Firebase is initialized in `main.dart`

### Problem: Data Not Syncing

**Solution**:
1. Check internet connection
2. Check Firebase Console to see if data appears there
3. Try pulling down to refresh in the app
4. Check logs for any error messages

---

## Step 10: Best Practices

### 1. Use Pagination for Large Lists
```dart
// Limit results to 50 items
final QuerySnapshot snapshot = await _firestore
    .collection('items')
    .orderBy('createdAt', descending: true)
    .limit(50)
    .get();
```

### 2. Add Indexes for Complex Queries
If you get "index required" errors:
- Firebase Console will provide a direct link to create the index
- Click the link and create the index automatically

### 3. Cache Data Locally
Enable offline persistence:
```dart
// In main.dart, after Firebase.initializeApp()
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### 4. Handle Errors Gracefully
The service already includes try-catch blocks, but always show user-friendly messages.

---

## Summary

✅ **What You Have Now:**
- Dual backend support (Firebase + MongoDB)
- Automatic fallback if one service fails
- Full CRUD operations for items
- Easy switching between backends

✅ **What You Need To Do:**
1. Enable Firestore in Firebase Console
2. Set up security rules
3. Verify `useFirebase = true` in code
4. Add sample data (manually or programmatically)
5. Test your app

✅ **Benefits:**
- No need for local MongoDB backend server
- Works anywhere with internet
- Automatic syncing
- Real-time updates capability
- Free tier includes generous limits

---

## Quick Reference

**Firebase Console**: https://console.firebase.google.com/

**Service File**: `lib/services/item_service.dart`

**Switch Backend**: Change `useFirebase` flag (line 13)

**Collection Name**: `items`

**Required Fields**:
- `name` (string)
- `description` (array of strings)
- `photoUrl` (string)
- `qtyTotal` (number)
- `qtyAvailable` (number)
- `isActive` (boolean)
- `createdAt` (timestamp)
- `updatedAt` (timestamp)

---

## Need Help?

If you encounter issues:
1. Check the troubleshooting section above
2. Verify all steps are completed
3. Check Flutter console for error messages
4. Verify Firebase Console shows your data
5. Make sure you're logged in with Firebase Auth

Good luck! 🚀
