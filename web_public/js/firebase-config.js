// Firebase Configuration
// Using the correct Firebase project: app-cost-deff0

const firebaseConfig = {
    apiKey: 'AIzaSyAl48ZyesmtstYWloY3fbKvawf7TtqHcYA',
    authDomain: 'app-cost-deff0.firebaseapp.com',
    projectId: 'app-cost-deff0',
    storageBucket: 'app-cost-deff0.firebasestorage.app',
    messagingSenderId: '598468362354',
    appId: '1:598468362354:web:40e7779416b7b22dbd42eb'
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Get Firestore instance
const db = firebase.firestore();

console.log('✅ Firebase initialized successfully with project: app-cost-deff0');
