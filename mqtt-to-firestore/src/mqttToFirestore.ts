import { connect } from "mqtt";
import * as admin from "firebase-admin";

// Check if running on GCP
const isRunningOnGCP = process.env.GCP_PROJECT !== undefined;

// Initialize Firebase using the local service account credentials
const serviceAccount = require("/Users/Ethan/Developer/Projects/Usyd/PervasiveComputing/FinalProject/pervasive-final-project-5047/eco_minder_flutter_app/mqtt-to-firestore/firebase-service-account.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Connect to MQTT server
console.log("connecting mqtt server...");
const client = connect("mqtt://35.244.101.9");

client.on("connect", () => {
  console.log("Connected to MQTT server.");

  // Subscribe to topics
  client.subscribe([
    "/sensor/body",
    "/sensor/location",
    "/sensor/temp",
    "/sensor/light",
    "/sensor/iaq",
  ]);
});

client.on("message", (topic, message) => {
  console.log(`get data: ${topic} ${message.toString()}`);

  try {
    const data = JSON.parse(message.toString());
    addData(topic, data);
  } catch (error: any) {
    // Handle JSON parsing error here
    console.error(`Error parsing JSON for topic ${topic}: ${error.message}`);
  }
});

function addData(topic: string, data: any) {
  const timestamp = admin.firestore.Timestamp.now();
  data.timestamp = timestamp;

  switch (topic) {
    case "/sensor/body":
      db.collection("body_sensor").add({
        data: data.data,
        eco_minder_id: data.id,
      });
      break;
    case "/sensor/location":
      db.collection("location_sensor").add({
        data: data.data,
        eco_minder_id: data.id,
      });
      break;
    case "/sensor/temp":
      db.collection("temp_sensor").add({
        data: data.data,
        eco_minder_id: data.id,
      });
      break;
    case "/sensor/light":
      db.collection("light_sensor").add({
        data: data.data,
        eco_minder_id: data.id,
      });
      break;
    case "/sensor/iaq":
      db.collection("iaq_sensor").add({
        data: data.data,
        eco_minder_id: data.id,
      });
      break;
    default:
      console.log(`No handler for topic ${topic}`);
  }
}

// Keep the process running
process.on("SIGINT", function () {
  client.end();
  process.exit();
});
