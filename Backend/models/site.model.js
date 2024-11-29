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
    employeeName: {
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
    drawing: [
      {
        type: String,
        required: true,
      },
    ],
    documents: [
      {
        type: String,
        required: true,
      },
    ],
    contactNo: {
      type: String,
      required: true,
    },
    finished: {
      type: Boolean,
      default: false,
    },
    completed: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

const Site = mongoose.model("Site", siteSchema);

export default Site;
