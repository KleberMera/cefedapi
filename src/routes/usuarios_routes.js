import { Router } from "express";
import {
  getUsuariosAll,
  getUsuarioById,
  createUsuario,
  updateUsuario,
  deleteUsuario,
} from "../controladores/usuariosCtrl.js";

const router = Router();

// Rutas CRUD para usuarios
router.get("/usuarios", getUsuariosAll); // Obtener todos los usuarios
router.get("/usuarios/:id", getUsuarioById); // Obtener usuario por ID
router.post("/usuarios", createUsuario); // Crear un nuevo usuario
router.put("/usuarios/:id", updateUsuario); // Actualizar un usuario existente
router.delete("/usuarios/:id", deleteUsuario); // Eliminar un usuario

export default router;
