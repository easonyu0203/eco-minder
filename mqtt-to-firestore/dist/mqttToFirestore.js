"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const mqtt_1 = require("mqtt");
const admin = __importStar(require("firebase-admin"));
// Initialize Firebase
const serviceAccount = require("/Users/Ethan/Developer/Projects/Usyd/PervasiveComputing/FinalProject/pervasive-final-project-5047/eco_minder_flutter_app/mqtt-to-firestore/firebase-service-account.json");
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});
const db = admin.firestore();
// Connect to MQTT server
console.log("connecting mqtt server...");
const client = (0, mqtt_1.connect)("mqtt://35.244.101.9");
client.on("connect", () => {
    console.log("Connected to MQTT server.");
    // Subscribe to topics
    client.subscribe([
        "/sensor/body",
        "/sensor/location",
        "/sensor/temp",
        "/sensor/light",
        "/sensor/iaq",
    ]);
});
client.on("message", (topic, message) => {
    console.log(topic);
    const data = JSON.parse(message.toString());
    switch (topic) {
        case "/sensor/body":
            db.collection("body_sensor").add(data);
            break;
        case "/sensor/location":
            db.collection("location_sensor").add(data);
            break;
        case "/sensor/temp":
            db.collection("temp_sensor").add(data);
            break;
        case "/sensor/light":
            db.collection("light_sensor").add(data);
            break;
        case "/sensor/iaq":
            db.collection("iaq_sensor").add(data);
            break;
        default:
            console.log(`No handler for topic ${topic}`);
    }
});
// Keep the process running
process.on("SIGINT", function () {
    client.end();
    process.exit();
});
//# sourceMappingURL=mqttToFirestore.js.map