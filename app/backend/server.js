const express = require("express");
const app = express();

app.use(express.json());

let notes = [
  {
    id: 1,
    title: "Welcome",
    content: "This is a test note stored in the Smart Notes API."
  }
];

app.get("/", (req, res) => {
  res.send(`
    <h1>Smart Notes</h1>
    <p>Application deployed securely on Azure App Service.</p>
    <p>Available endpoints:</p>
    <ul>
      <li>GET /health</li>
      <li>GET /notes</li>
      <li>POST /notes</li>
      <li>PUT /notes/:id</li>
      <li>DELETE /notes/:id</li>
    </ul>
  `);
});

app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    service: "Smart Notes API",
    environment: "Azure App Service"
  });
});

app.get("/notes", (req, res) => {
  res.json(notes);
});

app.post("/notes", (req, res) => {
  const { title, content } = req.body;

  if (!title || !content) {
    return res.status(400).json({
      error: "Title and content are required."
    });
  }

  const note = {
    id: notes.length + 1,
    title,
    content
  };

  notes.push(note);
  res.status(201).json(note);
});

app.put("/notes/:id", (req, res) => {
  const noteId = parseInt(req.params.id);
  const { title, content } = req.body;

  const note = notes.find((n) => n.id === noteId);

  if (!note) {
    return res.status(404).json({
      error: "Note not found."
    });
  }

  if (title) note.title = title;
  if (content) note.content = content;

  res.json(note);
});

app.delete("/notes/:id", (req, res) => {
  const noteId = parseInt(req.params.id);
  const initialLength = notes.length;

  notes = notes.filter((n) => n.id !== noteId);

  if (notes.length === initialLength) {
    return res.status(404).json({
      error: "Note not found."
    });
  }

  res.json({
    message: "Note deleted successfully."
  });
});

const port = process.env.PORT || 8080;

app.listen(port, () => {
  console.log(`Smart Notes app listening on port ${port}`);
});
