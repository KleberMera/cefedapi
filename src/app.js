import express from "express";

import usuarios_routes from "./routes/usuarios_routes.js";

import multer from "multer"; // Importa Multer
import path from "path"; // Para manejar rutas
import cors from "cors"; // Importa CORS

const app = express();
app.use(cors({ origin: "http://localhost:4200" }));
app.use(express.json()); //interprete los objetos enviados como json

// Configuración de Multer para almacenar archivos en la carpeta 'uploads'
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads"); // Carpeta donde se guardarán los archivos
  },
  filename: (req, file, cb) => {
    // Renombra el archivo para evitar conflictos
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

// Middleware de Multer para manejar la carga de archivos
const upload = multer({ storage });

// Rutas para la carga de archivos
app.post("/upload", upload.single("file"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: "No se ha enviado ningún archivo" });
  }
  res.status(200).json({
    message: "Archivo cargado exitosamente",
    filePath: `/uploads/${req.file.filename}`,
  });
});

// Servir archivos estáticos de la carpeta 'uploads'
app.use("/uploads", express.static(path.resolve("uploads")));

// Ruta principal
app.get("/", (req, res) => {
  res.send("Hola desde el servidor");
});

app.use("/api", usuarios_routes);

app.get("/", (req, res) => {
  res.send("Hola desde el servidor");
});

app.use((req, res, next) => {
  res.status(400).json({ message: "Pagina no encontrada" });
});

export default app;
