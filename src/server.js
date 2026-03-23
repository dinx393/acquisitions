import app from './app.js';



const PORT = process.env.PORT || 3000; 

app.listen(PORT, () => {
  console.log(`Listening on http://localhost:${PORT}`);
});

app.use((err, req, res, next) => {
  console.error('💥 Express caught an error:', err);
  res.status(500).json({ error: 'Internal Server Error', message: err.message });
});