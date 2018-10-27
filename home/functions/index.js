// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

const config = require("./config.json");

exports.testFunction = functions.https.onRequest((req, res) => {
    if (req.query.key !== config.keys.testFunction) return res.status(401).send();
    // Grab the text parameter.
    const functionValue = Boolean(req.query.command);
    console.log(`Setting function value to ${functionValue} based on query value ${req.query.command}`);
    // Push the new message into the Realtime Database using the Firebase Admin SDK.
    return admin.database().ref('/').child("testFunction").set(functionValue).then(() => {
        return res.status(200).send();
    });
});
