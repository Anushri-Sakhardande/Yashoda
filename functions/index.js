/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

//const {onRequest} = require("firebase-functions/v2/https");
//const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Triggered when a new announcement is created
exports.sendAnnouncementNotification = functions.firestore
  .document("announcements/{announcementId}")
  .onCreate(async (snap, context) => {
    const announcement = snap.data();

    const title = announcement.title || "Health Announcement";
    const body = announcement.message || "Check the app for more details.";

    // Get all tokens of mothers
    const usersSnapshot = await admin.firestore()
      .collection("users")
      .where("role", "in", ["Pregnant", "NewMother"])
      .get();

    const tokens = [];

    usersSnapshot.forEach((doc) => {
      const data = doc.data();
      if (data.fcmToken) {
        tokens.push(data.fcmToken);
      }
    });

    if (tokens.length === 0) {
      console.log("No tokens found for recipients.");
      return;
    }

    const message = {
      notification: {
        title: title,
        body: body,
      },
      tokens: tokens,
    };

    try {
      const response = await admin.messaging().sendMulticast(message);
      console.log(`Successfully sent to ${response.successCount} users`);
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  });
