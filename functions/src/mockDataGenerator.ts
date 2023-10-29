import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { Timestamp } from "@google-cloud/firestore";

type IntervalUnit = "minutes" | "hours" | "days";

interface MockDataRequest {
  id: string;
  timeSpan: number;
  intervalUnit: IntervalUnit;
}

interface DataPoint<T> {
  id: string;
  data: T;
  timestamp: Date;
}

export const createMockData = functions.https.onCall(
  async (request: MockDataRequest, context) => {
    const { id, timeSpan, intervalUnit } = request;

    const getIntervalMillis = () => {
      switch (intervalUnit) {
        case "minutes":
          return 60 * 1000;
        case "hours":
          return 60 * 60 * 1000;
        case "days":
          return 24 * 60 * 60 * 1000;
        default:
          return 60 * 1000;
      }
    };

    const numDataPoints = timeSpan;
    const intervalMillis = getIntervalMillis();
    let currentTimestamp = Date.now();

    const generateDataForSensor = (dataFunc: () => any) => {
      return Array.from({ length: numDataPoints }, () => {
        const point: DataPoint<String> = {
          id,
          data: dataFunc(),
          // Convert the millisecond timestamp to a Firestore Timestamp
          timestamp: Timestamp.fromMillis(currentTimestamp).toDate(),
        };
        currentTimestamp = currentTimestamp - intervalMillis;
        return point;
      });
    };

    const mockData = {
      body_sensor: generateDataForSensor(() =>
        Math.random() > 0.5 ? "true" : "false"
      ),
      location_sensor: generateDataForSensor(() =>
        JSON.stringify({
          latitude: (Math.random() * 180 - 90).toFixed(6),
          longitude: (Math.random() * 360 - 180).toFixed(6),
        })
      ),
      temp_sensor: generateDataForSensor(() =>
        (Math.random() * 40 - 10).toFixed(2)
      ),
      light_sensor: generateDataForSensor(() =>
        (Math.random() * 100000).toFixed(2)
      ),
      iaq_sensor: generateDataForSensor(() => (Math.random() * 500).toFixed(2)),
    };

    const db = admin.firestore();
    const batch = db.batch();

    for (const sensorPath in mockData) {
      const dataPoints = mockData[sensorPath as keyof typeof mockData];
      for (const dataPoint of dataPoints) {
        const docRef = db.collection(sensorPath).doc();
        batch.set(docRef, dataPoint);
      }
    }

    await batch.commit();
    return { success: true };
  }
);
