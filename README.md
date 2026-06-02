# Facenet — Sistema de Reconocimiento Facial

Backend Flask + DeepFace + YOLO para identificación facial en tiempo real.

## Instalación

```bash
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

## Ejecutar

```bash
python run.py
```

Servidor en `http://localhost:5000`

## Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/salud` | Verificar conexión |
| POST | `/api/deteccion/imagen` | Detectar e identificar caras |
| POST | `/api/deteccion/registrar` | Registrar persona nueva |
| GET | `/api/deteccion/historial` | Ver historial |

##  Estructura
Facenet/
├── app/
│   ├── models/database.py
│   ├── routes/
│   │   ├── salud.py
│   │   ├── deteccion.py
│   │   └── dataset.py
│   └── services/
│       ├── yolo_service.py
│       └── reconocimiento_service.py
├── dataset/personas/        # Base de datos de caras
├── .env
├── requirements.txt
└── run.py

## Tecnologías

- **Flask** — Servidor REST
- **YOLO** — Detección de caras
- **DeepFace** — Identificación facial
- **SQLite** — Base de datos
- **DeepFace** — Machine Learning

## Registrar persona

POST a `/api/deteccion/registrar`:
Body (multipart/form-data):

nombre: Juan
imagen: <archivo.jpg>


## Identificar

POST a `/api/deteccion/imagen`:
Body (multipart/form-data):

imagen: <archivo.jpg>

Response:
```json
{
  "ok": true,
  "total_caras": 1,
  "personas": [
    {
      "persona": "Juan",
      "identificado": true,
      "confianza": 89.5
    }
  ]
}
```
