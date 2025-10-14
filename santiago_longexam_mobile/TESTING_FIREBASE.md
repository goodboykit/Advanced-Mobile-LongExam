# Firebase Items - Testing & Verification Guide

## ✅ What Has Been Configured

Your application is now **fully configured** to use Firebase Firestore for items management. Here's everything that was done:

### 1. **ItemService Updated** (`lib/services/item_service.dart`)
- ✅ Full Firebase Firestore integration
- ✅ Automatic fallback to MongoDB if Firebase fails
- ✅ Easy switching with `useFirebase` flag (currently set to `true`)
- ✅ All CRUD operations supported (Create, Read, Update, Delete)

### 2. **ItemModel Enhanced** (`lib/models/item_model.dart`)
- ✅ Smart date parsing for both MongoDB and Firebase formats
- ✅ Handles Firebase Timestamp objects automatically
- ✅ Handles MongoDB string dates
- ✅ Backward compatible with existing code

### 3. **Main App Updated** (`lib/main.dart`)
- ✅ Firebase initialization with proper error handling
- ✅ Firestore offline persistence enabled (works offline!)
- ✅ Unlimited cache size for better performance
- ✅ Debug logging for easy troubleshooting

### 4. **Firebase Console**
- ✅ Firestore database enabled
- ✅ `items` collection created
- ✅ Sample item added with all required fields

---

## 🧪 Testing Steps

### Step 1: Verify Firebase Configuration

**Check that `useFirebase` is set to `true`:**

Open: `lib/services/item_service.dart`

Look for line 13:
```dart
bool useFirebase = true;  // ✅ Should be true
```

### Step 2: Run the App

```bash
cd santiago_longexam_mobile
flutter clean
flutter pub get
flutter run
```

**Expected Console Output:**
```
✅ Firebase initialized successfully with offline persistence
```

### Step 3: Test Items Screen

1. **Open the app**
2. **Navigate to Items tab** (first tab, should auto-open)
3. **You should see**: The "Laptop" item you created in Firebase Console

**Expected Behavior:**
- ✅ Item loads successfully
- ✅ Image appears (or placeholder if no image)
- ✅ Name: "Laptop" (or whatever you named it)
- ✅ Description: "High-performance laptop" (or your description)
- ✅ Quantities displayed correctly

**If you see "Loading items..." forever:**
- Check your internet connection
- Check Firebase Console → Rules (should allow read/write)
- Check console for errors

**If you see "No items to display":**
- Verify the collection name is exactly `items` (lowercase)
- Verify you added at least one document in Firebase Console
- Check Firebase Console → Data tab to see your items

### Step 4: Test Create Item

1. **Tap the blue "+" button** (Floating Action Button)
2. **Fill in the form:**
   - Name: "Wireless Mouse"
   - Description: "Ergonomic mouse with long battery life"
   - Photo URL: "https://via.placeholder.com/150"
   - Qty Total: 100
   - Qty Available: 95
   - Active: ON
3. **Tap "Save"**

**Expected Behavior:**
- ✅ Dialog closes
- ✅ Snackbar shows "Item added."
- ✅ New item appears at the top of the list
- ✅ Item is visible in Firebase Console immediately

**Verify in Firebase Console:**
1. Go to Firebase Console → Firestore Database
2. Click on `items` collection
3. You should see your new document with all fields
4. `createdAt` and `updatedAt` should have timestamp values

### Step 5: Test Update Item

1. **Tap on any item** in the list
2. **Detail screen opens**
3. **Tap the edit button** (pencil icon)
4. **Change some values** (e.g., increase quantity)
5. **Tap "Save"**

**Expected Behavior:**
- ✅ Item updates successfully
- ✅ Changes reflected immediately in the list
- ✅ Changes visible in Firebase Console
- ✅ `updatedAt` timestamp updates in Firebase

### Step 6: Test Delete Item

1. **Tap on any item** to open detail screen
2. **Tap delete button** (trash icon)
3. **Confirm deletion**

**Expected Behavior:**
- ✅ Item removed from list
- ✅ Item removed from Firebase Console
- ✅ Snackbar shows confirmation message

### Step 7: Test Offline Functionality

**This is a bonus feature enabled by offline persistence!**

1. **Load items** while online (so they cache)
2. **Turn off WiFi/Mobile data**
3. **Navigate away and back to Items tab**

**Expected Behavior:**
- ✅ Items still load from cache
- ✅ No error messages
- ✅ Can still browse items

**Create item while offline:**
1. **Stay offline**
2. **Try to create a new item**

**Expected Behavior:**
- ⚠️ Will show error (Firebase needs connection to write)
- ✅ Once back online, you can create items again

**Turn WiFi back on:**
- ✅ Any pending changes sync automatically

---

## 🔍 Troubleshooting

### Problem: "Failed to load items from Firebase"

**Solutions:**
1. Check Firebase Console → Rules
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /items/{itemId} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

2. Make sure you're logged in with Firebase Auth
   - Go to Profile tab
   - Check if email is shown
   - If not, logout and login again

3. Check internet connection

### Problem: "Permission Denied"

**Solution:** Update Firestore Rules to allow authenticated users:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /items/{itemId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Or for development/testing (less secure):
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

### Problem: Items not showing after creation

**Solutions:**
1. Check Firebase Console to see if item was created
2. Pull down to refresh the list
3. Check console for error messages
4. Verify `createdAt` field exists in Firebase document

### Problem: Timestamps showing as null

**Solution:** This should be fixed now with the `_parseDateTime` helper method. If still happening:
1. Check that documents in Firebase have `createdAt` and `updatedAt` fields
2. Verify they are `timestamp` type, not `string` type

### Problem: App crashes when loading items

**Solutions:**
1. Check console for specific error
2. Verify Firebase is initialized: Look for "✅ Firebase initialized successfully"
3. Check that ItemModel fields match Firebase document fields
4. Common field mismatches:
   - `name` must be string
   - `description` must be array
   - `qtyTotal` must be number
   - `qtyAvailable` must be number
   - `isActive` must be boolean

---

## 📊 How to Monitor Firebase Usage

### View Real-time Data

1. **Firebase Console** → **Firestore Database** → **Data tab**
2. See all your items in real-time
3. Any changes in the app appear here immediately

### Monitor Operations

1. **Firebase Console** → **Firestore Database** → **Usage tab**
2. See:
   - Document reads
   - Document writes
   - Document deletes
   - Storage used

### Check Logs

**In Flutter Console:**
```
✅ Firebase initialized successfully with offline persistence
Loading items...
Loaded 2 items
```

**In Firebase Console:**
- Go to **Firestore Database** → **Logs** (if available)
- See all operations

---

## 🔄 Switch Back to MongoDB (If Needed)

If you need to use MongoDB instead:

1. **Open:** `lib/services/item_service.dart`
2. **Change line 13:**
   ```dart
   bool useFirebase = false;  // Use MongoDB
   ```
3. **Restart the app** (hot reload won't work)
4. **Make sure MongoDB server is running:**
   ```bash
   cd path/to/your/backend
   npm start
   ```

---

## ✅ Verification Checklist

Use this checklist to verify everything works:

- [ ] Firebase initialized successfully (check console logs)
- [ ] Items collection exists in Firebase Console
- [ ] At least one item visible in Firebase Console
- [ ] Items screen loads without errors
- [ ] Can see items in the app
- [ ] Can tap an item to view details
- [ ] Can create new item via "+" button
- [ ] New item appears in Firebase Console immediately
- [ ] Can update an item
- [ ] Changes reflected in Firebase Console
- [ ] Can delete an item
- [ ] Item removed from Firebase Console
- [ ] Offline mode caches items (bonus feature)
- [ ] No console errors or warnings

---

## 🚀 Next Steps

### 1. Add More Sample Data

You can add more items directly in Firebase Console or through the app.

### 2. Customize Security Rules

Update rules to match your app's requirements:
- Allow only item owners to edit
- Add role-based permissions
- Implement data validation

### 3. Add Real-time Updates (Optional)

The current implementation fetches items once. You can upgrade to real-time:

```dart
// In ItemService
Stream<List<ItemModel>> streamItems() {
  return _firestore
      .collection(_collectionName)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ItemModel.fromJson({
        '_id': doc.id,
        ...data,
      });
    }).toList();
  });
}
```

### 4. Add Search Functionality

Implement search by name or description using Firestore queries.

### 5. Add Pagination

For large datasets, implement pagination:

```dart
// Load more items
final QuerySnapshot snapshot = await _firestore
    .collection(_collectionName)
    .orderBy('createdAt', descending: true)
    .limit(20)  // Load 20 at a time
    .get();
```

---

## 📝 Summary

Your app now has:

✅ **Dual backend support** (Firebase + MongoDB)
✅ **Automatic fallback** (if one fails, tries the other)
✅ **Offline persistence** (works without internet)
✅ **Smart date parsing** (handles both formats)
✅ **Production-ready** (proper error handling)
✅ **Easy maintenance** (one flag to switch backends)

**Default Mode:** Firebase (set to `true`)

**To verify it's working:**
1. Run the app
2. Check for "✅ Firebase initialized successfully"
3. Go to Items tab
4. See your items from Firebase
5. Create/Update/Delete items
6. Verify changes in Firebase Console

**Everything should work seamlessly! 🎉**

If you encounter any issues, check the Troubleshooting section above or refer to the main `FIREBASE_SETUP_GUIDE.md`.
