import { conmysql } from "../db.js";

// Obtener todos los usuarios
export const getUsuariosAll = async (req, res) => {
  try {
    const [result] = await conmysql.query(`
      SELECT usuarios.id, usuarios.rol_id, usuarios.nombre, usuarios.apellido, usuarios.email, 
             usuarios.fecha_registro, usuarios.ultimo_inicio_sesion, usuarios.activo, 
             roles.nombre AS rol_nombre
      FROM usuarios
      LEFT JOIN roles ON usuarios.rol_id = roles.id
    `);
    res.json(result);
  } catch (error) {
    return res.status(500).json({ message: "Error al obtener usuarios", error });
  }
};

// Obtener un usuario por ID
export const getUsuarioById = async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await conmysql.query(`
      SELECT usuarios.id, usuarios.rol_id, usuarios.nombre, usuarios.apellido, usuarios.email, 
             usuarios.fecha_registro, usuarios.ultimo_inicio_sesion, usuarios.activo, 
             roles.nombre AS rol_nombre
      FROM usuarios
      LEFT JOIN roles ON usuarios.rol_id = roles.id
      WHERE usuarios.id = ?`, 
      [id]
    );

    if (result.length === 0) {
      return res.status(404).json({ message: "Usuario no encontrado" });
    }

    res.json(result[0]);
  } catch (error) {
    return res.status(500).json({ message: "Error al obtener el usuario", error });
  }
};

// Crear un nuevo usuario
export const createUsuario = async (req, res) => {
  try {
    const { rol_id, nombre, apellido, email, password, activo } = req.body;
    const [result] = await conmysql.query(`
      INSERT INTO usuarios (rol_id, nombre, apellido, email, password_hash, activo) 
      VALUES (?, ?, ?, ?, ?, ?)`,
      [rol_id, nombre, apellido, email, password, activo || 1]
    );

    res.status(201).json({
      id: result.insertId,
      rol_id,
      nombre,
      apellido,
      email,
      activo: activo || 1,
    });
  } catch (error) {
    return res.status(500).json({ message: "Error al crear el usuario", error });
  }
};

// Actualizar un usuario
export const updateUsuario = async (req, res) => {
  try {
    const { id } = req.params;
    const { rol_id, nombre, apellido, email, password, activo } = req.body;

    const [result] = await conmysql.query(`
      UPDATE usuarios 
      SET rol_id = ?, nombre = ?, apellido = ?, email = ?, password_hash = ?, activo = ? 
      WHERE id = ?`,
      [rol_id, nombre, apellido, email, password, activo, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Usuario no encontrado" });
    }

    res.json({ id, rol_id, nombre, apellido, email, activo });
  } catch (error) {
    return res.status(500).json({ message: "Error al actualizar el usuario", error });
  }
};

// Eliminar un usuario
export const deleteUsuario = async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await conmysql.query("DELETE FROM usuarios WHERE id = ?", [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "Usuario no encontrado" });
    }

    res.json({ message: "Usuario eliminado exitosamente" });
  } catch (error) {
    return res.status(500).json({ message: "Error al eliminar el usuario", error });
  }
};
