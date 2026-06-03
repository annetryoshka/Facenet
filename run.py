from dotenv import load_dotenv
load_dotenv()

from backend import create_app
import os

app = create_app()

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    print("=" * 45)
    print("Backend Reconocimiento de Personas - Hotel")
    print(f"http://localhost:{port}")
    print("GET   /api/salud")
    print("POST  /api/deteccion/imagen")
    print("GET   /api/deteccion/historial")
    print("GET   /api/deteccion/estadisticas")
    print("POST  /api/dataset/subir")
    print("GET   /api/empleados/")        # <-- Mensaje informativo
    print("DELETE /api/empleados/<nombre>") # <-- Mensaje informativo
    print("=" * 45)
    app.run(host='0.0.0.0', port=port, debug=True)