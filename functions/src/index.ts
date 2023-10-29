import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

// Initialize Firebase using the local service account credentials
const serviceAccount = require("/Users/Ethan/Developer/Projects/Usyd/PervasiveComputing/FinalProject/pervasive-final-project-5047/eco_minder_flutter_app/mqtt-to-firestore/firebase-service-account.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

import { createMockData } from "./mockDataGenerator";
import { deleteSensorData } from "./delete_data";

export { createMockData, deleteSensorData };

export const hello = functions.https.onCall((data, context) => {
  return { message: "Hello from Firebase!" };
});
