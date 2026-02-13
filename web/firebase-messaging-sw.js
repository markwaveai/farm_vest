importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyC0XUQqk51NGLazlnaGKsPAgjkNNbgZR-E",
    appId: "1:612299373064:web:5d5ea121566c54b30eefbd",
    messagingSenderId: "612299373064",
    projectId: "markwave-481315",
    storageBucket: "markwave-481315.firebasestorage.app",
    measurementId: "G-F2RTN0NXXD",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
    console.log("Received background message ", payload);
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: "/favicon.png",
    };

    return self.registration.showNotification(
        notificationTitle,
        notificationOptions
    );
});
