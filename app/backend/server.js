const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("Smart Notes application is running securely on Azure App Service.");
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`Smart Notes app listening on port ${port}`);
});
