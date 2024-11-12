import mongoose, { Schema } from "mongoose";

const trackSchema = new Schema(
  {
    siteID: {
      type: String,
      unique: true,
      required: true,
    },
    userID: {
      type: String,
      required: true,
    },
    locations: [
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
  },
  { timestamps: true }
);

const Tracking = mongoose.model("Tracking", trackSchema);

export default Tracking;
