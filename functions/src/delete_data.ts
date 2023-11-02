import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { Collections } from "./app_contants";

export const deleteSensorData = functions
  .region("australia-southeast1")
  .https.onCall(async (data, context) => {
    const db = admin.firestore();

    // Helper function to delete all documents from a collection
    const deleteCollection = async (collectionPath: string) => {
      const collectionRef = db.collection(collectionPath);
      const querySnapshot = await collectionRef.get();

      // Batch all delete operations to improve performance
      const batch = db.batch();
      querySnapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
    };

    // Delete each collection
    for (const collectionPath of Collections) {
      if (collectionPath == "outdoor_temp_sensor") continue;
      await deleteCollection(collectionPath);
    }

    return { success: true, message: "Collections deleted successfully." };
  });
