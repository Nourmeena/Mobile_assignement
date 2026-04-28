const express = require('express');
const cors = require('cors');
const low = require('lowdb');
const FileSync = require('lowdb/adapters/FileSync');
const path = require('path');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// ─── JSON Database Setup ──────────────────────────────────────────────────────

const adapter = new FileSync(path.join(__dirname, 'tasks.json'));
const db = low(adapter);

db.defaults({ tasks: [], nextId: 1 }).write();

// ─── Helper ───────────────────────────────────────────────────────────────────

function getNextId() {
  const id = db.get('nextId').value();
  db.set('nextId', id + 1).write();
  return id;
}

// ─── Routes ───────────────────────────────────────────────────────────────────

// GET /api/tasks?userId=1
app.get('/api/tasks', (req, res) => {
  const { userId } = req.query;
  let tasks = db.get('tasks').value();
  if (userId) {
    tasks = tasks.filter(t => t.userId === Number(userId));
  }
  res.json(tasks);
});

// GET /api/tasks/:id
app.get('/api/tasks/:id', (req, res) => {
  const task = db.get('tasks').find({ id: Number(req.params.id) }).value();
  if (!task) return res.status(404).json({ error: 'Task not found' });
  res.json(task);
});

// POST /api/tasks  — create or upsert
app.post('/api/tasks', (req, res) => {
  const { id, title, description, dueDate, priority, isCompleted, isFavorite, userId } = req.body;

  if (!title || !dueDate || !priority) {
    return res.status(400).json({ error: 'title, dueDate, and priority are required' });
  }

  const existing = id ? db.get('tasks').find({ id: Number(id) }).value() : null;

  if (existing) {
    db.get('tasks').find({ id: Number(id) }).assign({
      title, description, dueDate, priority,
      isCompleted: isCompleted ?? existing.isCompleted,
      isFavorite: isFavorite ?? existing.isFavorite,
      userId: userId ?? existing.userId,
    }).write();
    return res.status(200).json(db.get('tasks').find({ id: Number(id) }).value());
  }

  const newTask = {
    id: id ?? getNextId(),
    title,
    description: description ?? null,
    dueDate,
    priority,
    isCompleted: isCompleted ?? 0,
    isFavorite: isFavorite ?? 0,
    userId: userId ?? null,
  };

  db.get('tasks').push(newTask).write();
  res.status(201).json(newTask);
});

// PUT /api/tasks/:id
app.put('/api/tasks/:id', (req, res) => {
  const taskId = Number(req.params.id);
  const existing = db.get('tasks').find({ id: taskId }).value();
  if (!existing) return res.status(404).json({ error: 'Task not found' });

  const { title, description, dueDate, priority, isCompleted, isFavorite, userId } = req.body;

  db.get('tasks').find({ id: taskId }).assign({
    title: title ?? existing.title,
    description: description ?? existing.description,
    dueDate: dueDate ?? existing.dueDate,
    priority: priority ?? existing.priority,
    isCompleted: isCompleted ?? existing.isCompleted,
    isFavorite: isFavorite ?? existing.isFavorite,
    userId: userId ?? existing.userId,
  }).write();

  res.json(db.get('tasks').find({ id: taskId }).value());
});

// DELETE /api/tasks/:id
app.delete('/api/tasks/:id', (req, res) => {
  const taskId = Number(req.params.id);
  const existing = db.get('tasks').find({ id: taskId }).value();
  if (!existing) return res.status(404).json({ error: 'Task not found' });

  db.get('tasks').remove({ id: taskId }).write();
  res.json({ message: 'Task deleted', id: taskId });
});

// ─── Start ────────────────────────────────────────────────────────────────────

const server = app.listen(PORT, () => {
  console.log(`\nStudent Task Manager API running at http://localhost:${PORT}`);
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`\nError: Port ${PORT} is already in use.`);
    console.error(`Run this to free it:  npx kill-port ${PORT}`);
    console.error(`Or on Windows:        netstat -ano | findstr :${PORT}  then  taskkill /PID <pid> /F`);
    process.exit(1);
  } else {
    throw err;
  }
});
