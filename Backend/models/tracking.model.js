import mongoose, { Schema } from "mongoose";

const trackSchema = new Schema(
  {
    siteID: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Site",
      required: true,
    },
    userID: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    locations: [
      {
        type: Array,
        required: true,
      },
    ],
    locationStatus: [
      {
        type: Array,
        required: true,
      },
    ],
    startTime: {
      type: String,
      required: true,
    },
    endTime: {
      type: String,
    },
    started: {
      type: Boolean,
      default: false,
    },
    finished: {
      type: Boolean,
      default: false,
    },
    selfi: {
      type: String,
    },
    remarks: {
      type: String,
      default: "No Remakrs",
    },
    siteImages: [
      {
        type: String,
      },
    ],
  },
  { timestamps: true }
);

const Tracking = mongoose.model("Tracking", trackSchema);

export default Tracking;
