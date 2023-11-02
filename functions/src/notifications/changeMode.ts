import * as functions from "firebase-functions";
import { MqttClient, connect } from "mqtt";

const MQTT_BROKER = "mqtt://35.244.101.9";

export const ecoMinderModeChanger = functions
  .region("australia-southeast1")
  .firestore.document("eco_minders/{minderId}")
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Check if 'mode' field has changed
    if (beforeData && afterData && beforeData.mode !== afterData.mode) {
      const topic = `/${context.params.minderId}/mode`;
      const value = afterData.mode;

      sendToMQTT(topic, value);
    }
  });

function sendToMQTT(topic: string, message: string): void {
  const client: MqttClient = connect(MQTT_BROKER);

  client.on("connect", () => {
    client.publish(topic, message, { qos: 1 }, (err) => {
      if (err) {
        console.error(`Failed to send message to MQTT topic ${topic}:`, err);
      } else {
        console.log(`Message sent to MQTT topic ${topic}`);
      }

      client.end(); // Disconnect after publishing
    });
  });
}
