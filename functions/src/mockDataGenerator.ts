import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { Timestamp } from "@google-cloud/firestore";
import { DataPoint } from "./types";
import { createEcoMinderNUserIfNotExist } from "./utils";

type IntervalUnit = "seconds" | "minutes" | "hours" | "days";
const db = admin.firestore();

interface MockDataRequest {
  eco_minder_id: string;
  timeSpan: number;
  intervalUnit: IntervalUnit;
}

export const createMockData = functions
  .region("australia-southeast1")
  .https.onCall(async (data: MockDataRequest, context) => {
    const { eco_minder_id: eco_minder_id, timeSpan, intervalUnit } = data;

    await createEcoMinderNUserIfNotExist(eco_minder_id);

    const getIntervalMillis = () => {
      switch (intervalUnit) {
        case "seconds":
          return 1000;
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
          eco_minder_id: eco_minder_id,
          data: dataFunc(),
          // Convert the millisecond timestamp to a Firestore Timestamp
          timestamp: Timestamp.fromMillis(currentTimestamp),
        };
        currentTimestamp = currentTimestamp - intervalMillis;
        return point;
      });
    };

    const mockData = {
      body_sensor: generateDataForSensor(() =>
        Math.random() > 0.5 ? "1" : "0"
      ),
      location_sensor: generateDataForSensor(() => {
        return {
          latitude: "-33.89201546932559",
          longitude: "151.19042141925632",
        };
      }),
      temp_sensor: generateDataForSensor(() => randomFloat(22, 30).toFixed(2)),
      outdoor_temp_sensor: generateDataForSensor(() =>
        randomFloat(22, 30).toFixed(2)
      ),
      light_sensor: generateDataForSensor(() => randomFloat(0, 300).toFixed(2)),
      iaq_sensor: generateDataForSensor(() => randomFloat(0, 500).toFixed(2)),
    };

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
  });

function randomFloat(min: number, max: number): number {
  return Math.random() * (max - min) + min;
}
