import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const deleteSensorData = functions.https.onCall(
  async (data, context) => {
    const db = admin.firestore();

    const collections = [
      "body_sensor",
      "location_sensor",
      "temp_sensor",
      "light_sensor",
      "iaq_sensor",
    ];

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
    for (const collectionPath of collections) {
      await deleteCollection(collectionPath);
    }

    return { success: true, message: "Collections deleted successfully." };
  }
);
