import * as admin from "firebase-admin";

// Check if running on GCP
const isRunningOnGCP = process.env.GCP_PROJECT !== undefined;

// Initialize Firebase using the local service account credentials
const serviceAccount = require("/Users/Ethan/Developer/Projects/Usyd/PervasiveComputing/FinalProject/pervasive-final-project-5047/eco_minder_flutter_app/mqtt-to-firestore/firebase-service-account.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Start the MQTT service
import { startMQTTService, stopMQTTService } from "./mqttToFirestoreService";

startMQTTService();

sendNotification();
setInterval(async () => {
  await sendNotification();
}, 5 * 60 * 1000);

async function sendNotification() {
  // Here, for simplicity, I'm broadcasting to all tokens.
  // Ideally, you should fetch specific tokens or use topics.
  const message = {
    topic: "all",
    notification: {
      title: "Hello",
      body: "World!",
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("Notification sent successfully:", response);
  } catch (error) {
    console.log("Error sending notification:", error);
  }
}

process.on("SIGINT", function () {
  stopMQTTService();
  process.exit();
});
