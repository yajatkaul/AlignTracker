import moment from "moment";
import Site from "../models/site.model.js";
import Tracking from "../models/tracking.model.js";
import User from "../models/user.model.js";

export const createSite = async (req, res) => {
  try {
    const { latitude, longitude, siteName, employeeId, timing } = req.body;

    const newSite = new Site({
      siteName,
      employeeId,
      latitude,
      longitude,
      timing,
    });

    await newSite.save();

    res.status(200).json({ result: "Site created" });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const getSites = async (req, res) => {
  try {
    const { completed } = req.query;

    const sites = await Site.find({
      employeeId: req.session.userId,
      finished: completed,
    });

    res.status(200).json(sites);
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const trackSite = async (req, res) => {
  try {
    const { siteID, latitude, longitude } = req.body;

    const trackSite = await Tracking.findOne({ siteID });

    const formattedTime = moment().format("h:mm A");
    const formattedStartTime = moment().format("MM/DD/YY h:mm A");

    if (!trackSite) {
      const newTrackSite = new Tracking({
        siteID,
        userID: req.session.userId,
        locations: [],
        startTime: formattedStartTime,
        finished: false,
        started: true,
        siteImages: [],
        pauses: [],
      });

      newTrackSite.locations.push([latitude, longitude, formattedTime]);
      await newTrackSite.save();

      return res.status(200).json({ result: "Successful" });
    }

    if (trackSite.finished) {
      return res.status(400).json({ result: "Already finished" });
    }

    if (!trackSite.started) {
      trackSite.started = true;
    }

    trackSite.locations.push([latitude, longitude, formattedTime]);
    await trackSite.save();

    return res.status(200).json({ result: "Successful" });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const locationStatusChecker = async (req, res) => {
  try {
    const { siteID, status } = req.body;

    const formattedTime = moment().format("h:mm A");

    const trackSite = await Tracking.findOne({ siteID });

    trackSite.locationStatus.push([status, formattedTime]);
    await trackSite.save();

    return res.status(200).json({ result: "Successful" });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const completeSite = async (req, res) => {
  try {
    const { siteID } = req.query;

    const images = req.files["image"] || [];
    const selfi = req.files["selfi"] ? req.files["selfi"][0] : null;

    const trackSite = await Tracking.findOne({ siteID });
    const site = await Site.findById(siteID);
    const user = await User.findById(req.session.userId);

    user.points += 100;
    trackSite.finished = true;
    site.finished = true;

    trackSite.selfi = selfi.path;
    images.forEach((image) => {
      trackSite.siteImages.push(image.path);
    });
    await trackSite.save();
    await user.save();
    await site.save();

    return res.status(200).json({ result: "Successful" });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const checkSiteStatus = async (req, res) => {
  try {
    const { siteID } = req.query;
    const trackSite = await Tracking.findOne({ siteID });
    if (!trackSite) {
      return res.status(200).json({ started: false, finished: false });
    }
    res
      .status(200)
      .json({ started: trackSite.started, finished: trackSite.finished });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};
