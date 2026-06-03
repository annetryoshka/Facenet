from dotenv import load_dotenv
load_dotenv()

from backend import create_app
import os

app = create_app()

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    print("=" * 45)
    print("Backend Reconocimiento de personas")
    print(f"http://localhost:{port}")
    print("GET  /api/salud")
    print("POST /api/deteccion/imagen")
    print("GET  /api/deteccion/historial")
    print("GET  /api/deteccion/estadisticas")
    print("POST /api/dataset/subir")
    print("=" * 45)
    app.run(host='0.0.0.0', port=port, debug=True)