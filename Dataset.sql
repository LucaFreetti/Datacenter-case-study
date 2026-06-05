CREATE TABLE IF NOT EXISTS dim_equipment(
equipment_id SERIAL PRIMARY KEY,
equipment_name VARCHAR(100) NOT NULL,
equipment_type VARCHAR(50) NOT NULL,
manufacturer  VARCHAR(50)
);
----------------------------------------------
CREATE TABLE IF NOT EXISTS dim_location(
location_id SERIAL PRIMARY KEY,
room_name VARCHAR(100) NOT NULL,
floor INT
);
-----------------------------------------------
CREATE TABLE IF NOT EXISTS dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day INT,
    month INT,
    quarter INT,
    year INT
);
----------------------------------------------
CREATE TABLE IF NOT EXISTS fact_metrics (
    metric_id SERIAL PRIMARY KEY,

    timestamp TIMESTAMP NOT NULL,

    equipment_id INT NOT NULL,
    location_id INT NOT NULL,

    temperature NUMERIC(5,2),
    humidity NUMERIC(5,2),

    power_kw NUMERIC(10,2),

    pue NUMERIC(4,2),

    ups_load_pct NUMERIC(5,2),

    server_utilization_pct NUMERIC(5,2),

    FOREIGN KEY (equipment_id)
        REFERENCES dim_equipment(equipment_id),

    FOREIGN KEY (location_id)
        REFERENCES dim_location(location_id)
);

----------------------------------------------
CREATE TABLE IF NOT EXISTS fact_incidents (

    incident_id SERIAL PRIMARY KEY,

    timestamp TIMESTAMP NOT NULL,

    equipment_id INT NOT NULL,

    incident_type VARCHAR(100),

    severity VARCHAR(20),

    downtime_minutes INT,

    FOREIGN KEY (equipment_id)
        REFERENCES dim_equipment(equipment_id)
);

--------------------------------------------
INSERT INTO dim_equipment
(equipment_name, equipment_type, manufacturer)
VALUES
('UPS_A1','UPS','Schneider'),
('UPS_B1','UPS','Schneider'),
('Cooling_01','Cooling','Vertiv'),
('Cooling_02','Cooling','Vertiv'),
('Rack_01','Server','Dell'),
('Rack_02','Server','Dell'),
('Rack_03','Server','Dell'),
('Rack_04','Server','Dell'),
('Rack_05','Server','Dell'),
('Rack_06','Server','Dell');
--------------------------------------------
INSERT INTO dim_location
(room_name, floor)
VALUES
('Server Room A',1),
('Server Room B',1),
('Network Room',1);
---------------------------------------------
/*Consumo medio per dispositivo */
SELECT
    equipment_id,
    ROUND(AVG(power_kw),2) AS avg_power
FROM fact_metrics
GROUP BY equipment_id
ORDER BY avg_power DESC;

/*Temperatura media per stanza */
SELECT
    l.room_name,
    ROUND(AVG(f.temperature),2) AS avg_temp
FROM fact_metrics f
JOIN dim_location l
ON f.location_id = l.location_id
GROUP BY l.room_name;

/*Media minuti per severitá durante un down */
SELECT
    severity,
    ROUND(AVG(downtime_minutes),2)
FROM fact_incidents
GROUP BY severity;

/*Top 5 dispositivi con piú incidenti */
SELECT
    equipment_id,
    COUNT(*) AS incidents
FROM fact_incidents
GROUP BY equipment_id
ORDER BY incidents DESC
LIMIT 5;
