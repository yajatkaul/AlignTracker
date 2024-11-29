import mongoose, { Schema } from "mongoose";

const snagsSchema = new Schema(
  {
    employeeId: {
      type: String,
      required: true,
    },
    employeeName: {
      type: String,
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
        default: false,
      },
    ],
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
