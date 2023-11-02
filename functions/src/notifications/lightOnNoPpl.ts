import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { DataPoint, MyUser } from "../types";
import { sendNotification } from "../utils";

const db = admin.firestore();

export const lightOnNoPplService = functions
  .region("australia-southeast1")
  .firestore.document("light_sensor/{sensorId}")
  .onCreate(async (snapshot, context) => {
    var usersRef = await db.collection("users");
    var query = await usersRef
      .where("eco_minder_id", "==", snapshot.data().eco_minder_id)
      .where("notification_mode", "!=", "none")
      .get();
    var user = query.docs[0].data() as MyUser;
    if (
      user.eco_minder_id == null ||
      user.token == null ||
      user.notification_mode == "none"
    )
      return;

    if (await IsLightOnNoPpl(user)) {
      await sendNotification({
        targetToken: user.token,
        title: "💡 Oops! Light's on without anyone around!",
        body: "Hey there! Noticed the light's on but no one's in the room. Mind turning it off? 😊",
      });
    }
  });

async function IsLightOnNoPpl(user: MyUser) {
  const twentyMinutesAgo = new Date(Date.now() - 20 * 60 * 1000);
  var lightDocs = await db
    .collection("light_sensor")
    .where("eco_minder_id", "==", user.eco_minder_id)
    .where("timestamp", ">=", twentyMinutesAgo)
    .orderBy("timestamp", "desc")
    .get();
  var bodyDocs = await db
    .collection("body_sensor")
    .where("eco_minder_id", "==", user.eco_minder_id)
    .where("timestamp", ">=", twentyMinutesAgo)
    .orderBy("timestamp", "desc")
    .get();
  var lightDataPoints = lightDocs.docs.map(
    (doc) => doc.data() as DataPoint<string>
  );
  var bodyDataPoints = bodyDocs.docs.map(
    (doc) => doc.data() as DataPoint<string>
  );

  console.log(lightDataPoints);
  console.log(bodyDataPoints);

  let lightOnFor20Minute = true;

  lightDataPoints.forEach((dataPoint) => {
    if (Number(dataPoint.data) <= 300) {
      lightOnFor20Minute = false;
    }
  });

  let NoBody = true;
  bodyDataPoints.forEach((dataPoint) => {
    if (Number(dataPoint.data) == 1) {
      NoBody = false;
    }
  });

  return lightOnFor20Minute && NoBody;
}
