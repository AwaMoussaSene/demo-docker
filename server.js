const express = require("express");
const app = express();
const PORT = process.env.PORT || 3000;

// hello
app.get("/", (req, res) => {
  res.send("Hello from Node.js Express + Docker + GitHub Actions 🚀 Awa M Sene");
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
