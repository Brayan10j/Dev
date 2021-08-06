const express = require("express");
const router = express.Router();
const path = require("path");
const multer = require("multer");
var storage = multer.memoryStorage()
var upload = multer({ storage: storage })


router.get("/example", async (req, res) => {
  res.json({ responsive: req.query });
});

router.get("/singUp", async (req, res) => {
  res.json({ responsive: req.query });
});

router.post("/hashFile", upload.any(), async (req, res) =>  {
  try {
    const crypto = require("crypto");
    const hashSum = crypto.createHash("sha256");
    hashSum.update(req.files[0].buffer);
    const hex = hashSum.digest("hex");
    res.json({ responsive: hex });
  } catch (error) {
    return res.status(404).send(error);
  }
});

module.exports = router;
