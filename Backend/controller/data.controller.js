import Snag from "../models/snags.model.js";
import Survey from "../models/survey.model.js";

export const getSnags = async (req, res) => {
  try {
    const snags = await Snag.find({ siteId: req.query.siteId });

    res.status(200).json(snags);
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const createSnags = async (req, res) => {
  try {
    const images = req.files["images"];
    const { topic, issue } = req.body;
    const { siteId } = req.query;

    const newSnag = new Snag({
      employeeId: req.session.userId,
      siteId,
      topic,
      issue,
    });

    images.forEach((image) => {
      newSnag.images.push(image.path);
    });
    await newSnag.save();

    res.status(200).json({ result: "Created Successfully" });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const closeSnags = async (req, res) => {
  try {
    const images = req.files["images"];
    const { closeComment } = req.body;
    const { siteId } = req.query;

    const snag = await Snag.findOne({ siteId });

    if (snag.status == "Closed") {
      return res.status(400).json({ error: "Already closed" });
    }

    snag.status = "Closed";

    images.forEach((image) => {
      snag.snagCloseimages.push(image.path);
    });
    snag.closeComment = closeComment;
    await snag.save();

    res.status(200).json({ result: "Closed Successfully" });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const getSurvey = async (req, res) => {
  try {
    const { siteId } = req.query;

    const survey = await Survey.findOne({ siteId: siteId });

    res.status(200).json(survey);
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const createSurvey = async (req, res) => {
  try {
    const { siteId } = req.query;
    const { fileNames } = req.body;

    const fileNamesArray = Array.isArray(fileNames)
      ? fileNames
      : typeof fileNames === "string"
      ? JSON.parse(fileNames)
      : [];

    let survey = await Survey.findOne({ siteId });

    if (survey == null) {
      survey = new Survey({ siteId });
    }

    const images = req.files["images"];
    const documents = req.files["documents"];

    documents.forEach((document, index) => {
      survey.documents.push([fileNamesArray[index], document.path]);
    });

    images.forEach((image) => {
      survey.images.push(image.path);
    });

    await survey.save();

    res.status(200).json({ result: "Created Successfully" });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};
