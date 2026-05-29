import os
import cv2
import numpy as np
from ultralytics import YOLO


class YOLOService:

    def __init__(self):
        self.modelo     = None
        self.cargado    = False
        self.model_path = os.getenv('MODEL_PATH', 'runs/train/personas/weights/best.pt')
        self.conf       = float(os.getenv('CONF_THRESHOLD', 0.5))
        self._cargar()

    def _cargar(self):
        try:
            if os.path.exists(self.model_path):
                self.modelo  = YOLO(self.model_path)
                print(f'Modelo cargado: {self.model_path}')
            else:
                self.modelo  = YOLO('yolov8n.pt')
                print('Usando modelo base yolov8n.pt')
            self.cargado = True
        except Exception as e:
            print(f'Error: {e}')
            self.cargado = False

    def predecir(self, imagen_bytes: bytes) -> dict:
        if not self.cargado:
            return {'error': 'Modelo no cargado', 'detecciones': []}

        np_arr = np.frombuffer(imagen_bytes, np.uint8)
        frame  = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

        if frame is None:
            return {'error': 'No se pudo leer la imagen', 'detecciones': []}

        resultados  = self.modelo(frame, conf=self.conf, verbose=False)
        detecciones = []

        for resultado in resultados:
            for box in resultado.boxes:
                clase_id     = int(box.cls[0])
                confianza    = float(box.conf[0])
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                nombre_clase = resultado.names.get(clase_id, str(clase_id))

                detecciones.append({
                    'clase':     nombre_clase,
                    'confianza': round(confianza, 4),
                    'bbox': {'x1': x1, 'y1': y1, 'x2': x2, 'y2': y2}
                })

        personas = [d for d in detecciones if d['clase'] == 'person']

        return {
            'total_detecciones': len(detecciones),
            'total_personas':    len(personas),
            'detecciones':       detecciones,
        }


yolo_service = YOLOService()