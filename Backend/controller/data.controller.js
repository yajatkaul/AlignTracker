import Snag from "../models/snags.model.js";

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
