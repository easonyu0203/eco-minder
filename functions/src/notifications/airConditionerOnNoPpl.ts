import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { DataPoint, EcoMinder, MyUser } from "../types";
import { sendNotification } from "../utils";

const THRESHOLD = 5;
const db = admin.firestore();

export const airPolluteNotificationService = functions
  .region("australia-southeast1")
  .firestore.document("temp_sensor/{sensorId}")
  .onCreate(async (snapshot, context) => {
    const { ecoMinder, user } =
      (await getUserAndEcoMinder(snapshot.data() as DataPoint<string>)) || {};
    if (!ecoMinder || !user) return;

    // TODO: get the lastest temp_sensor, outdoor_temp_sensor of this ecoMinder, both collection's doc have fields: timestamp, eco_minder_id
    const tempDocs = await db
      .collection("temp_sensor")
      .where("eco_minder_id", "==", ecoMinder.eco_minder_id)
      .orderBy("timestamp", "desc")
      .limit(1)
      .get();

    const outdoorTempDocs = await db
      .collection("outdoor_temp_sensor")
      .where("eco_minder_id", "==", ecoMinder.eco_minder_id)
      .orderBy("timestamp", "desc")
      .limit(1)
      .get();

    // calculate the difference between the lastest temp_sensor and outdoor_temp_sensor is bigger than THRESHOLD
    const temp = tempDocs.docs[0].data() as DataPoint<string>;
    const outdoorTemp = outdoorTempDocs.docs[0].data() as DataPoint<string>;
    const diff = Math.abs(Number(temp.data) - Number(outdoorTemp.data));

    // if diff bigger than threshold, send notification
    if (diff > THRESHOLD) {
      await sendAirConditionOnNoPplNotification({ token: user.token! });
    }
  });

async function sendAirConditionOnNoPplNotification({
  token,
}: {
  token: string;
}) {
  console.log("sending air air condition on notification...");
  await sendNotification({
    targetToken: token,
    title: "🌬️ Air conditioner still on!",
    body: "Hey there! 😊 seems like the air conditioner still on. forgot to turn it off? 🌳🍃",
  });
}

async function getUserAndEcoMinder(
  dataPoint: DataPoint<string>
): Promise<{ ecoMinder: EcoMinder; user: MyUser } | null> {
  const ecoMinderDoc = await db
    .collection("eco_minders")
    .doc(dataPoint.eco_minder_id)
    .get();
  if (!ecoMinderDoc.exists) return null;

  const ecoMinder = ecoMinderDoc.data()! as EcoMinder;
  const userDoc = await db.collection("users").doc(ecoMinder.uid).get();
  const user = userDoc.data() as MyUser | undefined;

  if (!userDoc.exists || !user?.token || user?.notification_mode == "none")
    return null;

  return { ecoMinder, user };
}
