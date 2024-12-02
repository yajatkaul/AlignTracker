import express from "express";
import upload from "../utils/multer.js";
import multer from "multer";
import {
  closeSnags,
  createSnags,
  createSurvey,
  getSnags,
  getSurvey,
} from "../controller/data.controller.js";

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

router.post("/closeSnag", (req, res, next) => {
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
    closeSnags(req, res, next);
  });
});

router.get("/getSurvey", getSurvey);

router.post("/createSurvey", (req, res, next) => {
  upload.fields([
    { name: "images", maxCount: 10 },
    { name: "documents", maxCount: 10 },
  ])(req, res, function (err) {
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
    createSurvey(req, res, next);
  });
});

export default router;
