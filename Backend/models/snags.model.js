import mongoose, { Schema } from "mongoose";

const snagsSchema = new Schema(
  {
    employeeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    siteId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Site",
      required: true,
    },
    topic: {
      type: String,
      required: true,
    },
    issue: {
      type: String,
      required: true,
    },
    images: [
      {
        type: String,
        default: [],
      },
    ],
    snagCloseimages: [
      {
        type: String,
        default: [],
      },
    ],
    closeComment: {
      type: String,
    },
    status: {
      type: String,
      default: "Open",
      enum: ["Open", "Closed"],
    },
  },
  { timestamps: true }
);

const Snag = mongoose.model("Snag", snagsSchema);

export default Snag;
