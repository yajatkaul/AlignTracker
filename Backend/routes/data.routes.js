import express from "express";
import upload from "../utils/multer.js";
import multer from "multer";
import { createSnags, getSnags } from "../controller/data.controller.js";

const router = express.Router();

router.get("/getSnags", getSnags);

router.post("/createSnag", (req, res, next) => {
  upload.fields([{ name: "images", maxCount: 10 }])(req, res, function (err) {
    if (err instanceof multer.MulterError) {
      // Handle Multer-specific errors
      if (err.code === "LIMIT_FILE_SIZE") {
        return res
          .status(400)
          .json({ error: "File size exceeds the 100MB limit." });
      }
      return res.status(400).json({ error: err.message });
    } else if (err) {
      console.log(err);
      return res.status(500).json({ error: "An unknown error occurred." });
    }
    // Proceed to your controller if no errors
    createSnags(req, res, next);
  });
});

export default router;
