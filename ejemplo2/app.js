const express = require("express");
const app = express();

app.get("/health", (_req, res) => res.json({ status: "ok" }));
app.get("/", (_req, res) => res.send("Hello from Express!!!!!!!!!!"));

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server listening on http://0.0.0.0:${PORT}`);
});
