import mongoose, { Schema } from "mongoose";

const siteSchema = new Schema(
  {
    siteName: {
      type: String,
      required: true,
    },
    employeeId: {
      type: String,
      required: true,
    },
    latitude: {
      type: String,
      required: true,
    },
    longitude: {
      type: String,
      required: true,
    },
    timing: {
      type: String,
      required: true,
    },
    started: {
      type: Boolean,
      default: false,
    },
    finished: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

const Site = mongoose.model("Site", siteSchema);

export default Site;
