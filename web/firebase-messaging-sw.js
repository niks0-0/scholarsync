// Firebase Cloud Messaging Service Worker for ScholarSync Web
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBNWrYf9TYTdnjJX-KOPpxYyWjcV4nOiiU",
  authDomain: "scholarsync-app-2026.firebaseapp.com",
  projectId: "scholarsync-app-2026",
  storageBucket: "scholarsync-app-2026.firebasestorage.app",
  messagingSenderId: "127188603534",
  appId: "1:127188603534:web:e7f3524f5afa46689fefdf"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message:', payload);
  const notificationTitle = payload.notification ? payload.notification.title : 'ScholarSync Update';
  const notificationOptions = {
    body: payload.notification ? payload.notification.body : 'You have a new academic update.',
    icon: '/favicon.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
