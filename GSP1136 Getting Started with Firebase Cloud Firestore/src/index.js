import { initializeApp } from 'firebase/app'

// Add your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDi3G_w06a-sky-C6UplmQtV5VMBWsHyxI",
  authDomain: "qwiklabs-gcp-00-8418d4eb8bd8.firebaseapp.com",
  projectId: "qwiklabs-gcp-00-8418d4eb8bd8",
  storageBucket: "qwiklabs-gcp-00-8418d4eb8bd8.firebasestorage.app",
  messagingSenderId: "861383021586",
  appId: "1:861383021586:web:a5330da807b0fb620874cb",
  measurementId: ""
};

// Initialize Firebase
const firebaseApp = initializeApp(firebaseConfig);

console.log('Hello, Firestore!')
