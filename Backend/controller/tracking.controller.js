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
    const sites = await Site.find({ employeeId: req.session.userId });

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

    if (!trackSite) {
      const newTrackSite = new Tracking({
        siteID,
        userID: req.session.userId,
        locations: [],
        startTime: Date.now(),
        finished: false,
        started: true,
      });

      newTrackSite.locations.push([latitude, longitude]);
      await newTrackSite.save();

      return res.status(200);
    }

    if (trackSite.finished) {
      return res.status(200);
    }

    trackSite.locations.push([latitude, longitude]);
    await trackSite.save();

    return res.status(200);
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const completeSite = async (req, res) => {
  try {
    const { siteID } = req.query;

    const trackSite = await Tracking.findOne({ siteID });
    const user = await User.findById(req.session.userId);

    user.points += 100;
    trackSite.finished = true;
    await trackSite.save();
    await user.save();

    return res.status(200);
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const checkSiteStatus = async (req, res) => {
  try {
    const { siteID } = req.query;
    const trackSite = await Tracking.findOne({ siteID });

    res
      .status(200)
      .json({ started: trackSite.started, finished: trackSite.finished });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};
