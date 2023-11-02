import { FieldValue } from "firebase-admin/firestore";

export interface DataPoint<T> {
  eco_minder_id: string;
  data: T;
  timestamp: Date;
}

export interface MyUser {
  eco_minder_id: string | null;
  email: string | null;
  token: string | null;
  name: string | null;
  notification_mode: "none" | "medium" | "high";
  uid: string;
}

export interface EcoMinder {
  create_at: FieldValue;
  eco_minder_id: string;
  mode: "mild" | "alert";
  name: string;
  uid: string;
}
