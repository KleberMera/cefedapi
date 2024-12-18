-- 1. Clasificación de Transacciones por Categoría para un Usuario
-- Total de gastos por categoría para María
SELECT 
    ct.nombre AS Categoria, 
    COUNT(*) AS Numero_Transacciones,
    SUM(t.monto) AS Total_Gastos,
    (SUM(t.monto) / (SELECT SUM(monto) FROM transacciones WHERE usuario_id = t.usuario_id AND tipo = 'Gasto')) * 100 AS Porcentaje_Gasto
FROM transacciones t
JOIN categorias_transaccion ct ON t.categoria_id = ct.id
WHERE t.usuario_id = 2
    AND t.tipo = 'Gasto'
GROUP BY ct.nombre
ORDER BY Total_Gastos DESC;

-- 2. Balance Diario para Juan
SELECT 
    DATE(fecha) AS Fecha,
    SUM(CASE WHEN tipo = 'Ingreso' THEN monto ELSE 0 END) AS Total_Ingresos,
    SUM(CASE WHEN tipo = 'Gasto' THEN monto ELSE 0 END) AS Total_Gastos,
    SUM(CASE WHEN tipo = 'Ingreso' THEN monto ELSE -monto END) AS Balance_Diario
FROM transacciones
WHERE usuario_id = 2
GROUP BY DATE(fecha)
ORDER BY Fecha;

-- 3. Balance Semanal para María
WITH SemanalBalance AS (
    SELECT 
        YEARWEEK(fecha) AS Semana,
        SUM(CASE WHEN tipo = 'Ingreso' THEN monto ELSE 0 END) AS Total_Ingresos,
        SUM(CASE WHEN tipo = 'Gasto' THEN monto ELSE 0 END) AS Total_Gastos,
        SUM(CASE WHEN tipo = 'Ingreso' THEN monto ELSE -monto END) AS Balance_Semanal
    FROM transacciones
    WHERE usuario_id = 2
    GROUP BY YEARWEEK(fecha)
)
SELECT 
    Semana,
    Total_Ingresos,
    Total_Gastos,
    Balance_Semanal,
    ROUND((Total_Gastos / Total_Ingresos) * 100, 2) AS Porcentaje_Gastos
FROM SemanalBalance
ORDER BY Semana;

-- 4. Balance Mensual Consolidado
SELECT 
    YEAR(fecha) AS Año,
    MONTH(fecha) AS Mes,
    SUM(CASE WHEN tipo = 'Ingreso' THEN monto ELSE 0 END) AS Total_Ingresos,
    SUM(CASE WHEN tipo = 'Gasto' THEN monto ELSE 0 END) AS Total_Gastos,
    SUM(CASE WHEN tipo = 'Ingreso' THEN monto ELSE -monto END) AS Balance_Mensual
FROM transacciones
WHERE usuario_id = (SELECT id FROM usuarios WHERE email = 'juan.perez@email.com')
GROUP BY YEAR(fecha), MONTH(fecha)
ORDER BY Año, Mes;

-- 5. Seguimiento de Progreso de Reducción de Deudas
-- Para María (deuda completamente pagada)
SELECT 
    d.acreedor,
    d.monto_total AS Monto_Original,
    d.tasa_interes AS Tasa_Interes,
    COUNT(hpd.id) AS Numero_Pagos,
    SUM(hpd.monto_pagado) AS Total_Pagado,
    d.monto_total - SUM(hpd.monto_pagado) AS Saldo_Restante,
    (SUM(hpd.monto_pagado) / d.monto_total) * 100 AS Porcentaje_Pagado,
    MIN(hpd.fecha_pago) AS Primer_Pago,
    MAX(hpd.fecha_pago) AS Ultimo_Pago,
    d.estado AS Estado_Deuda
FROM deudas d
JOIN historial_pagos_deuda hpd ON d.id = hpd.deuda_id
WHERE d.usuario_id = 2
GROUP BY d.id, d.acreedor, d.monto_total, d.tasa_interes, d.estado;

-- 6. Seguimiento de Progreso de Reducción de Deudas
-- Para Juan (deuda parcialmente pagada)
SELECT 
    d.acreedor,
    d.monto_total AS Monto_Original,
    d.saldo_pendiente AS Saldo_Actual,
    d.tasa_interes AS Tasa_Interes,
    COUNT(hpd.id) AS Numero_Pagos,
    SUM(hpd.monto_pagado) AS Total_Pagado,
    (SUM(hpd.monto_pagado) / d.monto_total) * 100 AS Porcentaje_Pagado,
    MIN(hpd.fecha_pago) AS Primer_Pago,
    MAX(hpd.fecha_pago) AS Ultimo_Pago,
    d.estado AS Estado_Deuda
FROM deudas d
JOIN historial_pagos_deuda hpd ON d.id = hpd.deuda_id
WHERE d.usuario_id = 2
GROUP BY d.id, d.acreedor, d.monto_total, d.saldo_pendiente, d.tasa_interes, d.estado;