import mongoose, { Schema } from "mongoose";

const surveySchema = new Schema(
  {
    siteId: {
      type: String,
      ref: "Site",
      required: true,
      unique: true,
    },
    images: [
      {
        type: String,
        default: [],
      },
    ],
    documents: [
      {
        type: Array,
        default: [],
      },
    ],
  },
  { timestamps: true }
);

const Survey = mongoose.model("Survey", surveySchema);

export default Survey;
