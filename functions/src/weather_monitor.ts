import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { Timestamp } from "@google-cloud/firestore";
import axios from "axios";
const db = admin.firestore();

export const monitorWeather = functions
  .region("australia-southeast1")
  .firestore.document("temp_sensor/{documentId}")
  .onCreate(async (snap, context) => {
    // Fetch the last run timestamp from the server_state collection
    const serverStateDoc = await db
      .collection("server_state")
      .doc("lastRunTimestamp")
      .get();
    const currentTime = Timestamp.now();
    const thirtyMinutesMillis = 30 * 60 * 1000;

    if (serverStateDoc.exists) {
      const lastRunTimestamp = serverStateDoc.data()?.timestamp;
      if (
        lastRunTimestamp &&
        currentTime.toMillis() - lastRunTimestamp.toMillis() <
          thirtyMinutesMillis
      ) {
        console.log(
          "Exiting early because the function was executed less than 30 minutes ago."
        );
        return null;
      }
    }

    const collection = db.collection("location_sensor");
    let latestEntries: {
      [id: string]: FirebaseFirestore.QueryDocumentSnapshot;
    } = {};

    const snapshot = await collection.orderBy("timestamp", "desc").get();

    // Filter out only the latest doc for each ID
    snapshot.forEach((doc) => {
      const data = doc.data();
      if (
        !latestEntries[data.id] ||
        data.timestamp.toDate() >
          latestEntries[data.id].data().timestamp.toDate()
      ) {
        latestEntries[data.id] = doc;
      }
    });

    // For each ID, get the weather using lat and long
    for (const id in latestEntries) {
      const latitude = latestEntries[id].data().data.latitude;
      const longitude = latestEntries[id].data().data.longitude;

      // Fetch weather data (You will need to implement this function)
      const weather = await fetchWeather(latitude, longitude);
      console.log(
        `Weather for ID ${id} at (${latitude}, ${longitude}): ${weather}`
      );

      await db.collection("outdoor_temp_sensor").add({
        id: id,
        timestamp: Timestamp.now(),
        data: weather,
      });
    }

    // Update the last run timestamp
    await db
      .collection("server_state")
      .doc("lastRunTimestamp")
      .set({ timestamp: currentTime });

    return null;
  });

async function fetchWeather(
  latitude: number,
  longitude: number
): Promise<string> {
  const API_KEY = "58aaf10a6f34f6aa02d5f8bc4c8706f9";
  //   const API_KEY = functions.config().openweathermap.key;
  const ENDPOINT = `https://api.openweathermap.org/data/2.5/weather?lat=${latitude}&lon=${longitude}&appid=${API_KEY}`;
  try {
    const response = await axios.get(ENDPOINT);
    const data = response.data;

    if (data && data.main) {
      const temperature = data.main.temp - 273.15;

      return `${temperature.toFixed(2)}`;
    }
    throw new Error("Could not fetch weather data");
  } catch (error) {
    console.error("Error fetching weather:", error);
    throw error;
  }
}
