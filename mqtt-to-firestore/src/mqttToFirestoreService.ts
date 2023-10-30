import { MqttClient, connect } from "mqtt";
import * as admin from "firebase-admin";

const db = admin.firestore();
let client: MqttClient;

// Connect to MQTT server
export const startMQTTService = () => {
  console.log("connecting mqtt server...");
  client = connect("mqtt://35.244.101.9");

  client.on("connect", () => {
    console.log("Connected to MQTT server.");
    client.subscribe([
      "/sensor/body",
      "/sensor/location",
      "/sensor/temp",
      "/sensor/light",
      "/sensor/iaq",
    ]);
  });

  client.on("message", (topic, message) => {
    console.log(`get data: ${topic} ${message.toString()}`);

    try {
      const data = JSON.parse(message.toString());
      addData(topic, data);
    } catch (error: any) {
      console.error(`Error parsing JSON for topic ${topic}: ${error.message}`);
    }
  });
  function addData(topic: string, data: any) {
    const timestamp = admin.firestore.Timestamp.now();
    data.timestamp = timestamp;

    switch (topic) {
      case "/sensor/body":
        db.collection("body_sensor").add({
          data: data.data,
          eco_minder_id: data.id,
        });
        break;
      case "/sensor/location":
        db.collection("location_sensor").add({
          data: data.data,
          eco_minder_id: data.id,
        });
        break;
      case "/sensor/temp":
        db.collection("temp_sensor").add({
          data: data.data,
          eco_minder_id: data.id,
        });
        break;
      case "/sensor/light":
        db.collection("light_sensor").add({
          data: data.data,
          eco_minder_id: data.id,
        });
        break;
      case "/sensor/iaq":
        db.collection("iaq_sensor").add({
          data: data.data,
          eco_minder_id: data.id,
        });
        break;
      default:
        console.log(`No handler for topic ${topic}`);
    }
  }
};

export const stopMQTTService = () => {
  client.end();
};
