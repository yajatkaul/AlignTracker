import moment from "moment";
import Site from "../models/site.model.js";
import Tracking from "../models/tracking.model.js";
import User from "../models/user.model.js";

export const createSite = async (req, res) => {
  try {
    const {
      latitude,
      longitude,
      siteName,
      employeeId,
      timing,
      documents,
      contactNo,
    } = req.body;

    const user = await User.findById(employeeId);

    const newSite = new Site({
      siteName,
      employeeId,
      employeeName: user.displayName,
      latitude,
      longitude,
      timing,
      documents,
      contactNo,
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
    const { completed, page = 1, limit = 20 } = req.query;

    const totalSites = await Site.countDocuments({
      employeeId: req.session.userId,
      completed: completed,
    });

    const sites = await Site.find({
      employeeId: req.session.userId,
      completed: completed,
    })
      .skip((page - 1) * limit)
      .limit(Number(limit))
      .select("-password");

    const hasMore = page * limit < totalSites;

    res.status(200).json({ sites, hasMore });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const getTrackings = async (req, res) => {
  try {
    const { siteID, page = 1, limit = 20 } = req.query;

    const totalSites = await Tracking.countDocuments({
      siteID,
      userID: req.session.userId,
    });

    const trackingData = await Tracking.find({
      siteID,
      userID: req.session.userId,
    })
      .populate("userID")
      .populate("siteID")
      .skip((page - 1) * limit)
      .limit(Number(limit));

    const hasMore = page * limit < totalSites;

    res.status(200).json({ trackingData, hasMore });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const trackSite = async (req, res) => {
  try {
    const { siteID, latitude, longitude } = req.body;

    const site = await Site.findById(siteID);

    const formattedTime = moment().format("h:mm A");
    const formattedStartTime = moment().format("MM/DD/YY h:mm A");

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
    const remarks = req.body.remarks;

    const trackSite = await Tracking.findOne({
      siteID,
      finished: false,
      userID: req.session.userId,
    });
    const user = await User.findById(req.session.userId);

    user.points += 100;
    trackSite.finished = true;
    trackSite.remarks = remarks;

    trackSite.selfi = selfi.path;
    images.forEach((image) => {
      trackSite.siteImages.push(image.path);
    });
    await trackSite.save();
    await user.save();

    return res.status(200).json({ result: "Successful" });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

//Admin

export const getAllTracking = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 15,
      dateStart,
      dateEnd,
      name,
      siteName,
    } = req.query;
    // Build the filter object for MongoDB
    let filterConditions = { finished: true };

    // Filter by date range (if provided)
    if (dateStart || dateEnd) {
      filterConditions.createdAt = {};
      if (dateStart) filterConditions.createdAt.$gte = new Date(dateStart);
      if (dateEnd) filterConditions.createdAt.$lte = new Date(dateEnd);
    }

    // Filter by site name (if provided)
    if (siteName) {
      filterConditions.siteName = { $regex: siteName, $options: "i" }; // Case-insensitive search
    }

    // Filter by employee name (if provided)
    if (name) {
      filterConditions.employeeName = { $regex: name, $options: "i" }; // Case-insensitive search
    }

    const totalUsers = await Site.countDocuments(filterConditions);

    const sites = await Site.find(filterConditions)
      .skip((page - 1) * limit)
      .limit(Number(limit))
      .select("-password");

    const hasMore = page * limit < totalUsers;

    return res.status(200).json({ sites, hasMore });
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Internal server error" });
  }
};
