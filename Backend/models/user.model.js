import mongoose from "mongoose";

//Schema
const userSchema = new mongoose.Schema(
  {
    profilePic: {
      type: String,
      default: "/uploads/default.jpg",
    },
    displayName: {
      type: String,
      required: true,
      minlength: 5,
    },
    password: {
      type: String,
      required: true,
      minlength: 5,
    },
    role: {
      type: String,
      default: "Member",
      enum: ["Member", "Employee", "Admin"],
    },
    points: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true }
);

const User = mongoose.model("User", userSchema);

export default User;
