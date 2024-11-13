import express from "express";
import {
  checkSiteStatus,
  completeSite,
  createSite,
  getSites,
  locationStatusChecker,
  trackSite,
} from "../controller/tracking.controller.js";
import upload from "../utils/multer.js";
import multer from "multer";

const router = express.Router();

router.post("/createSite", createSite);
router.post("/trackSite", trackSite);

router.get("/getSites", getSites);
router.get("/checkSiteStatus", checkSiteStatus);

router.post("/locationStatusChecker", locationStatusChecker);
router.post("/completeSite", (req, res, next) => {
  upload.fields([
    { name: "image", maxCount: 10 },
    { name: "selfi", maxCount: 1 },
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
    completeSite(req, res, next);
  });
});

export default router;
