import User from "../models/user.model.js";

const checkAdmin = async (req, res, next) => {
  try {
    const token = req.session.userId;

    if (!token) {
      return res.status(401).json({ result: "No token provided" });
    }

    const user = await User.findById(token).select("-password");

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    if (user.role != "Admin") {
      return res.status(400).json({ error: "Unauthorized" });
    }

    next();
  } catch (err) {
    console.log(err.message);
    res.status(500).json({ err: "Internal Error" });
  }
};

export default checkAdmin;