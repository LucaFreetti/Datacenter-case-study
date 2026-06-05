# 🏭 Data Center Performance Monitoring

**Stack:** PostgreSQL · Python · Power BI · SQLAlchemy  
**Author:** Luca Frittitta · June 2026

---

## Overview

End-to-end data pipeline simulating an operational monitoring system for an industrial data center, inspired by **Medielettra** — a company specializing in technological systems and electrical certification. The project covers the full lifecycle from relational database modeling to interactive KPI visualization.

---

## Pipeline

```
01 Database  ──►  02 Python  ──►  03 Power BI
PostgreSQL        NumPy / Pandas    Interactive Dashboard
Star Schema       Synthetic Data    Operational KPIs
SQLAlchemy        EDA (Matplotlib   Seasonal PUE
                  & Seaborn)        Incident Analysis
```

---

## Database Schema (Star Schema)

| Table | Type | Key Columns |
|---|---|---|
| `dim_equipment` | Dimensional | equipment_id, equipment_name, equipment_type, manufacturer |
| `dim_location` | Dimensional | location_id, room_name, floor |
| `dim_date` | Dimensional | date_id, full_date, day, month, quarter, year |
| `fact_metrics` | Fact | timestamp, equipment_id, temperature, humidity, power_kw, pue, ups_load_pct, server_utilization_pct |
| `fact_incidents` | Fact | timestamp, equipment_id, incident_type, severity, downtime_minutes |

---

## Dataset

- **87,600 metric records** — hourly readings across 10 devices for the full year 2025
- **200 incident records** — randomly distributed across device types and severity levels
- Realistic simulation logic: **seasonal temperature offsets** and **hourly workload multipliers**

### Equipment (10 devices across 3 rooms)

| Type | Count | Manufacturer | Location |
|---|---|---|---|
| UPS | 2 | Schneider | Server Room A |
| Cooling | 2 | Vertiv | Server Room A / B |
| Server Rack | 6 | Dell | Server Room A / B / Network Room |

### Incident Distribution

| Type | Frequency |
|---|---|
| UPS Failure | 35% |
| Cooling Failure | 35% |
| Network Failure | 20% |
| Power Outage | 10% |

---

## Key Insights (Power BI Dashboard)

| Area | Finding |
|---|---|
| **Seasonal PUE** | Annual average PUE: **1.31**. Peaks at **1.34** in summer (Jul–Sep) due to higher ambient temperatures impacting cooling efficiency. |
| **Consumption by time slot** | Business hours (8–18) average **340 kWh** — **31% higher** than night hours (260 kWh), consistent with peak server utilization. |
| **Critical incidents** | Power Outage and UPS Failure generate the longest downtimes (**98 and 86 min** avg). Cooling Failure accounts for **35%** of all events. |
| **System uptime** | **97% uptime** annually — approx. 11 days of total inactivity. |

> ⚠️ Incident counts were generated randomly and have no correlation with temperature or other operational metrics.

---

## SQL Queries

```sql
-- Average power consumption per device
SELECT equipment_id, ROUND(AVG(power_kw), 2) AS avg_power
FROM fact_metrics
GROUP BY equipment_id ORDER BY avg_power DESC;

-- Average temperature per room
SELECT l.room_name, ROUND(AVG(f.temperature), 2) AS avg_temp
FROM fact_metrics f
JOIN dim_location l ON f.location_id = l.location_id
GROUP BY l.room_name;

-- Average downtime by severity
SELECT severity, ROUND(AVG(downtime_minutes), 2)
FROM fact_incidents
GROUP BY severity;

-- Top 5 devices by incident count
SELECT equipment_id, COUNT(*) AS incidents
FROM fact_incidents
GROUP BY equipment_id
ORDER BY incidents DESC LIMIT 5;
```

---

## Possible Future Developments

- Integration with real-time sensor data via IoT
- Predictive failure model using anomaly detection
- Automated alerts on critical thresholds (temperature > 26°C, PUE > 1.5)

---

## Files

| File | Description |
|---|---|
| `notebook.ipynb` | Full Python pipeline: data generation, EDA, DB loading |
| `Dataset.sql` | PostgreSQL schema + INSERT statements + analytical queries |
| `Medielettra_project_LucaFrittitta.pdf` | Project summary with dashboard screenshots |
