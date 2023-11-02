import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { DataPoint } from "./types";
import { Timestamp } from "@google-cloud/firestore";

const db = admin.firestore();

// Areas in m² for an average master bedroom
const area_floor: number = 23.2;
const area_ceiling: number = 23.2;
const area_wall: number = 50.58; // Adjusted wall area minus windows
const area_window: number = 2.22; // Total area for both windows
const areas: number[] = [area_wall, area_ceiling, area_floor, area_window];

// Typical U-values in W/m²°C for each component
const u_wall: number = 0.2;
const u_ceiling: number = 0.2;
const u_floor: number = 0.5;
const u_window: number = 2.7;
const u_values: number[] = [u_wall, u_ceiling, u_floor, u_window];

const system_efficiency: number = 0.8; // 80% efficiency

export const estimateEnergyUsageService = functions
  .region("australia-southeast1")
  .firestore.document("temp_sensor/{sensorId}")
  .onCreate(async (snapshot, context) => {
    const newTempSensorDoc = snapshot.data() as DataPoint<string>;
    const timestamp = newTempSensorDoc.timestamp;

    // Find the closest outdoor_temp_sensor doc based on timestamp
    const before = await db
      .collection("outdoor_temp_sensor")
      .where("timestamp", "<=", timestamp)
      .orderBy("timestamp", "desc")
      .limit(1)
      .get();

    const after = await db
      .collection("outdoor_temp_sensor")
      .where("timestamp", ">=", timestamp)
      .orderBy("timestamp", "asc")
      .limit(1)
      .get();

    let closestOutdoorDoc: DataPoint<string> | null = null;

    if (!before.empty) {
      closestOutdoorDoc = before.docs[0].data() as DataPoint<string>;
    }

    if (!after.empty) {
      if (
        !closestOutdoorDoc ||
        after.docs[0].data().timestamp.toMillis() - timestamp.toMillis() <
          timestamp.toMillis() - closestOutdoorDoc.timestamp.toMillis()
      ) {
        closestOutdoorDoc = after.docs[0].data() as DataPoint<string>;
      }
    }

    if (closestOutdoorDoc) {
      const indoorTemp = parseFloat(newTempSensorDoc.data);
      const outdoorTemp = parseFloat(closestOutdoorDoc.data);

      const energy = calculateEnergy(indoorTemp, outdoorTemp);

      // Store the result in est_energy collection
      await db.collection("est_energy").add({
        eco_minder_id: newTempSensorDoc.eco_minder_id,
        data: `${energy}`,
        timestamp: Timestamp.now(),
      });
    }
  });

function calculateEnergy(insideTemp: number, outsideTemp: number): number {
  const deltaT: number = insideTemp - outsideTemp;
  const QTotal: number = areas.reduce(
    (acc, area, index) => acc + area * deltaT * u_values[index],
    0
  );
  const energy: number = QTotal;
  const energyAdjusted: number = energy / system_efficiency;
  return Math.max(0, energyAdjusted);
}
