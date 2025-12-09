# Web Application - README

## 📱 Public Web Interface for Product Search

This is a standalone web application that allows users to search for product prices without installing the mobile app.

## 🚀 Features

- ✅ **Landing Page** with Navy Premium UI matching the Flutter app
- ✅ **Manual Search** - Search products by name
- ✅ **Barcode Scanner** - Scan product barcodes using device camera
- ✅ **Category Filter** - Filter products by category
- ✅ **Real-time Data** - Fetches data from Firebase Firestore
- ✅ **Responsive Design** - Works on mobile and desktop browsers
- ✅ **Read-Only Access** - Users can only view prices, not edit

## 📂 File Structure

```
web_public/
├── index.html              # Main HTML file
├── css/
│   └── styles.css         # Navy Premium themed styles
└── js/
    ├── firebase-config.js # Firebase initialization
    ├── barcode-scanner.js # Barcode scanning module
    └── app.js            # Main application logic
```

## 🔧 Setup Instructions

### 1. Firebase Security Rules

**IMPORTANT:** You need to update Firebase Firestore Security Rules to allow public read access to products.

Go to Firebase Console → Firestore Database → Rules, and update:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow public READ access to products
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null; // Only authenticated users can write
    }
    
    // Keep other collections private
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /payment_proofs/{proofId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 2. Local Testing

Simply open `index.html` in a web browser:

```bash
# Option 1: Double-click index.html in File Explorer

# Option 2: Use a local server (recommended for camera access)
cd web_public
python -m http.server 8000
# Then open http://localhost:8000
```

**Note:** For barcode scanner to work, you need HTTPS or localhost. Modern browsers block camera access on non-secure connections.

### 3. Deployment Options

#### Option A: Firebase Hosting (Recommended)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase Hosting
firebase init hosting
# Select your project: app-search-cost
# Public directory: web_public
# Single-page app: No
# Overwrite index.html: No

# Deploy
firebase deploy --only hosting
```

Your site will be available at: `https://app-search-cost.web.app`

#### Option B: Netlify

1. Go to [netlify.com](https://netlify.com)
2. Drag and drop the `web_public` folder
3. Your site will be live instantly!

#### Option C: GitHub Pages

1. Create a GitHub repository
2. Upload `web_public` contents
3. Enable GitHub Pages in repository settings
4. Your site will be at: `https://yourusername.github.io/repo-name`

## 🎨 UI Theme

The web app uses the same **Navy Premium** color scheme as the Flutter app:

- **Premium Navy**: `#0A1A2F`
- **Soft Navy**: `#153354`
- **Gold Medium**: `#E9C678`
- **Success Green**: `#4CAF50`

## 📱 Browser Compatibility

- ✅ Chrome/Edge (Desktop & Mobile)
- ✅ Firefox (Desktop & Mobile)
- ✅ Safari (Desktop & Mobile)
- ✅ Opera

**Camera/Barcode Scanner Requirements:**
- HTTPS connection (or localhost for testing)
- Camera permission granted by user

## 🔒 Security

- **Read-Only Access**: Users can only view product data
- **No Authentication Required**: Public access for price checking
- **Admin Functions**: Only available in Flutter mobile app
- **Data Validation**: All data comes from Firestore with security rules

## 🐛 Troubleshooting

### Products Not Loading

1. Check browser console (F12) for errors
2. Verify Firebase Security Rules allow public read access
3. Check internet connection
4. Verify Firebase project ID in `firebase-config.js`

### Barcode Scanner Not Working

1. Ensure you're using HTTPS or localhost
2. Grant camera permissions when prompted
3. Try a different browser
4. Check if camera is already in use by another app

### Images Not Displaying

- Base64 images from Flutter app should work automatically
- If using Cloudinary URLs, ensure they're publicly accessible
- Check browser console for CORS errors

## 📊 Performance

- **First Load**: ~2-3 seconds (includes Firebase SDK)
- **Subsequent Loads**: Instant (cached assets)
- **Product Search**: Real-time filtering
- **Barcode Scan**: 1-2 seconds detection time

## 🔄 Updating Products

Products are automatically synced from the Flutter admin app. Any changes made in the admin panel will be reflected in the web app immediately.

## 📞 Support

For issues or questions, contact the app administrator.

---

**Version**: 1.0.0  
**Last Updated**: December 2024
