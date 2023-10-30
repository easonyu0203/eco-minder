import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { Collections } from "./app_contants";

// Assuming admin.initializeApp() is called somewhere else in your code
const db = admin.firestore();

interface Response {
  body_sensor?: boolean;
  location_sensor?: string;
  temp_sensor?: number;
  light_sensor?: number;
  iaq_sensor?: number;
}

export const getSensorsSnapshot = functions
  .region("australia-southeast1")
  .https.onCall(async (data, context) => {
    let results: Response = {};

    // Loop through each collection and get the latest document based on timestamp
    for (const collection of Collections) {
      const snapshot = await db
        .collection(collection)
        .orderBy("timestamp", "desc")
        .limit(1)
        .get();

      if (!snapshot.empty && snapshot.docs[0].exists) {
        results[collection as keyof Response] = snapshot.docs[0].data() as any;
      }
    }

    return results;
  });
