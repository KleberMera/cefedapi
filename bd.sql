-- Crear base de datos
CREATE DATABASE gestion_finanzas_personales;
USE gestion_finanzas_personales;

-- Tabla de Roles
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Tabla de Usuarios
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rol_id INT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_inicio_sesion DATETIME,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (rol_id) REFERENCES roles(id)
);

-- Tabla de Recuperación de Contraseña
CREATE TABLE recuperacion_password (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    token VARCHAR(255) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion DATETIME,
    usado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Tabla de Categorías de Transacción
CREATE TABLE categorias_transaccion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo ENUM('Ingreso', 'Gasto') NOT NULL,
    usuario_id INT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Tabla de Transacciones
CREATE TABLE transacciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    categoria_id INT,
    monto DECIMAL(10,2) NOT NULL,
    fecha DATE NOT NULL,
    descripcion TEXT,
    tipo ENUM('Ingreso', 'Gasto') NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (categoria_id) REFERENCES categorias_transaccion(id)
);

-- Tabla de Estrategias de Pago de Deuda
CREATE TABLE estrategias_pago (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

-- Tabla de Deudas
CREATE TABLE deudas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    acreedor VARCHAR(150) NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL,
    saldo_pendiente DECIMAL(10,2) NOT NULL,
    tasa_interes DECIMAL(5,2) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_limite DATE NOT NULL,
    estrategia_id INT,
    estado ENUM('Activa', 'Pagada', 'Parcialmente Pagada') DEFAULT 'Activa',
    tipo_deuda VARCHAR(100),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (estrategia_id) REFERENCES estrategias_pago(id)
);

-- Tabla de Historial de Pagos de Deudas
CREATE TABLE historial_pagos_deuda (
    id INT AUTO_INCREMENT PRIMARY KEY,
    deuda_id INT,
    monto_pagado DECIMAL(10,2) NOT NULL,
    fecha_pago DATE NOT NULL,
    saldo_restante DECIMAL(10,2) NOT NULL,
    metodo_pago VARCHAR(100),
    FOREIGN KEY (deuda_id) REFERENCES deudas(id)
);

-- Tabla de Metas de Ahorro
CREATE TABLE metas_ahorro (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    nombre VARCHAR(150) NOT NULL,
    monto_objetivo DECIMAL(10,2) NOT NULL,
    monto_actual DECIMAL(10,2) DEFAULT 0,
    fecha_inicio DATE NOT NULL,
    fecha_limite DATE NOT NULL,
    estado ENUM('En Progreso', 'Completada', 'No Iniciada') DEFAULT 'No Iniciada',
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Tabla de Notificaciones
CREATE TABLE notificaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    tipo ENUM('Pago', 'Meta', 'Recordatorio', 'Alerta') NOT NULL,
    mensaje TEXT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    leido BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Tabla de Calendario de Pagos
CREATE TABLE calendario_pagos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    descripcion VARCHAR(255) NOT NULL,
    fecha_pago DATE NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    tipo ENUM('Deuda', 'Factura', 'Otro') NOT NULL,
    recurrente BOOLEAN DEFAULT FALSE,
    frecuencia ENUM('Diario', 'Semanal', 'Mensual', 'Anual') NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);


CREATE TABLE cuotas_deuda (
    id INT AUTO_INCREMENT PRIMARY KEY,
    deuda_id INT ,
    fecha_vencimiento DATE NOT NULL,
    monto_cuota DECIMAL(10, 2) NOT NULL,
    estado ENUM('pendiente', 'pagada', 'vencida') DEFAULT 'pendiente',
    fecha_pago DATE NULL,
    FOREIGN KEY (deuda_id) REFERENCES deudas(id) ON DELETE CASCADE
);


-- Insertar roles predeterminados
INSERT INTO roles (nombre, descripcion) VALUES 
('Administrador', 'Acceso completo al sistema'),
('Cliente', 'Acceso limitado a funciones de gestión personal');

-- Insertar estrategias de pago predeterminadas
INSERT INTO estrategias_pago (nombre, descripcion) VALUES 
('Bola de Nieve', 'Pagar primero las deudas más pequeñas'),
('Avalancha', 'Pagar primero las deudas con mayor tasa de interés');

-- Índices para optimizar consultas
CREATE INDEX idx_usuario_transacciones ON transacciones(usuario_id);
CREATE INDEX idx_usuario_deudas ON deudas(usuario_id);
CREATE INDEX idx_deuda_historial_pago ON historial_pagos_deuda(deuda_id);
CREATE INDEX idx_notificaciones_usuario ON notificaciones(usuario_id);





-- Insertar dos usuarios clientes
INSERT INTO usuarios (rol_id, nombre, apellido, email, password_hash, activo) VALUES 
(2, 'Maria', 'González', 'maria.gonzalez@email.com', '$2y$10$9oBOD5C5P.../H2KvK1M6N6', TRUE),
(2, 'Juan', 'Pérez', 'juan.perez@email.com', '$2y$10$7xA3B2C1D.../K9L8M7N6O5', TRUE);

-- Categorías de transacción
INSERT INTO categorias_transaccion (nombre, tipo, usuario_id) VALUES 
-- Categorías para María
('Salario', 'Ingreso', (SELECT id FROM usuarios WHERE email = 'maria.gonzalez@email.com')),
('Freelance', 'Ingreso', (SELECT id FROM usuarios WHERE email = 'maria.gonzalez@email.com')),
('Alimentación', 'Gasto', (SELECT id FROM usuarios WHERE email = 'maria.gonzalez@email.com')),
('Transporte', 'Gasto', (SELECT id FROM usuarios WHERE email = 'maria.gonzalez@email.com')),

-- Categorías para Juan
('Salario', 'Ingreso', (SELECT id FROM usuarios WHERE email = 'juan.perez@email.com')),
('Bonificación', 'Ingreso', (SELECT id FROM usuarios WHERE email = 'juan.perez@email.com')),
('Alimentación', 'Gasto', (SELECT id FROM usuarios WHERE email = 'juan.perez@email.com')),
('Entretenimiento', 'Gasto', (SELECT id FROM usuarios WHERE email = 'juan.perez@email.com'));

-- Transacciones para María
INSERT INTO transacciones (usuario_id, categoria_id, monto, fecha, tipo) VALUES
-- Ingresos
((SELECT id FROM usuarios WHERE email = 'maria.gonzalez@email.com'), 
 (SELECT id FROM categorias_transaccion WHERE nombre = 'Salario' AND usuario_id = (SELECT id FROM usuarios WHERE email = 'maria.gonzalez@email.com')), 
 2000.00, '2024-01-15', 'Ingreso'),
((SELECT id FROM usuarios WHERE email = 'maria.gonzalez@email.com'), 
 (SELECT id FROM categorias_transaccion WHERE nombre = 'Freelance' AND usuario_id = (SELECT id FROM usuarios WHERE email = 'maria.gonzalez@email.com')), 
 500.00, '2024-01-25', 'Ingreso'),

-- Gastos
((SELECT id FROM usuarios WHERE email = 'maria.gonzalez@email.com'), 
 (SELECT id FROM categorias_transaccion WHERE nombre = 'Alimentación' AND usuario_id = (SELECT id FROM usuarios WHERE email = 'maria.gonzalez@email.com')), 
 300.00, '2024-01-20', 'Gasto'),
((SELECT id FROM usuarios WHERE email = 'maria.gonzalez@email.com'), 
 (SELECT id FROM categorias_transaccion WHERE nombre = 'Transporte' AND usuario_id = (SELECT id FROM usuarios WHERE email = 'maria.gonzalez@email.com')), 
 150.00, '2024-01-22', 'Gasto');

-- Transacciones para Juan
INSERT INTO transacciones (usuario_id, categoria_id, monto, fecha, tipo) VALUES
-- Ingresos
((SELECT id FROM usuarios WHERE email = 'juan.perez@email.com'), 
 (SELECT id FROM categorias_transaccion WHERE nombre = 'Salario' AND usuario_id = (SELECT id FROM usuarios WHERE email = 'juan.perez@email.com')), 
 2500.00, '2024-01-15', 'Ingreso'),
((SELECT id FROM usuarios WHERE email = 'juan.perez@email.com'), 
 (SELECT id FROM categorias_transaccion WHERE nombre = 'Bonificación' AND usuario_id = (SELECT id FROM usuarios WHERE email = 'juan.perez@email.com')), 
 1000.00, '2024-01-25', 'Ingreso'),

-- Gastos
((SELECT id FROM usuarios WHERE email = 'juan.perez@email.com'), 
 (SELECT id FROM categorias_transaccion WHERE nombre = 'Alimentación' AND usuario_id = (SELECT id FROM usuarios WHERE email = 'juan.perez@email.com')), 
 400.00, '2024-01-20', 'Gasto'),
((SELECT id FROM usuarios WHERE email = 'juan.perez@email.com'), 
 (SELECT id FROM categorias_transaccion WHERE nombre = 'Entretenimiento' AND usuario_id = (SELECT id FROM usuarios WHERE email = 'juan.perez@email.com')), 
 250.00, '2024-01-22', 'Gasto');

-- Deudas con método Avalancha
-- María (500€ en 4 meses, totalmente pagada)
INSERT INTO deudas (
    usuario_id, 
    acreedor, 
    monto_total, 
    saldo_pendiente, 
    tasa_interes, 
    fecha_inicio, 
    fecha_limite, 
    estrategia_id, 
    estado
) VALUES (
    (SELECT id FROM usuarios WHERE email = 'maria.gonzalez@email.com'),
    'Préstamo Personal',
    500.00,
    0.00,
    15.0,
    '2024-01-15',
    '2024-05-15',
    (SELECT id FROM estrategias_pago WHERE nombre = 'Avalancha'),
    'Pagada'
);

-- Historial de pagos para María
INSERT INTO historial_pagos_deuda (
    deuda_id, 
    monto_pagado, 
    fecha_pago, 
    saldo_restante,
    metodo_pago
) VALUES 
(LAST_INSERT_ID(), 130.00, '2024-02-15', 370.00, 'Transferencia'),
(LAST_INSERT_ID(), 170.00, '2024-03-15', 200.00, 'Transferencia'),
(LAST_INSERT_ID(), 200.00, '2024-04-15', 0.00, 'Transferencia');

-- Juan (1500€ en 5 meses, 3 letras pagadas)
INSERT INTO deudas (
    usuario_id, 
    acreedor, 
    monto_total, 
    saldo_pendiente, 
    tasa_interes, 
    fecha_inicio, 
    fecha_limite, 
    estrategia_id, 
    estado
) VALUES (
    (SELECT id FROM usuarios WHERE email = 'juan.perez@email.com'),
    'Crédito Personal',
    1500.00,
    750.00,
    18.0,
    '2024-01-15',
    '2024-06-15',
    (SELECT id FROM estrategias_pago WHERE nombre = 'Avalancha'),
    'Parcialmente Pagada'
);

-- Historial de pagos para Juan
INSERT INTO historial_pagos_deuda (
    deuda_id, 
    monto_pagado, 
    fecha_pago, 
    saldo_restante,
    metodo_pago
) VALUES 
((SELECT LAST_INSERT_ID()), 250.00, '2024-02-15', 1250.00, 'Transferencia'),
(LAST_INSERT_ID(), 300.00, '2024-03-15', 950.00, 'Transferencia'),
(LAST_INSERT_ID(), 200.00, '2024-04-15', 750.00, 'Transferencia');

-- Metas de Ahorro
-- María
INSERT INTO metas_ahorro (
    usuario_id, 
    nombre, 
    monto_objetivo, 
    monto_actual, 
    fecha_inicio, 
    fecha_limite, 
    estado
) VALUES (
    (SELECT id FROM usuarios WHERE email = 'maria.gonzalez@email.com'),
    'Viaje de Verano',
    2000.00,
    500.00,
    '2024-01-15',
    '2024-07-15',
    'En Progreso'
);

-- Juan
INSERT INTO metas_ahorro (
    usuario_id, 
    nombre, 
    monto_objetivo, 
    monto_actual, 
    fecha_inicio, 
    fecha_limite, 
    estado
) VALUES (
    (SELECT id FROM usuarios WHERE email = 'juan.perez@email.com'),
    'Compra de Electrodoméstico',
    1500.00,
    750.00,
    '2024-01-15',
    '2024-06-15',
    'En Progreso'
);