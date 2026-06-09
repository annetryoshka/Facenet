import os
import cv2
import numpy as np
from ultralytics import YOLO


class YOLOService:

    def __init__(self):
        self.modelo  = None
        self.cargado = False
        self.conf    = float(os.getenv('CONF_THRESHOLD', 0.5))
        self._cargar()

    def _cargar(self):
        try:
            # YOLOv8 entrenado para detectar caras
            if os.path.exists('yolov8n-face.pt'):
                self.modelo = YOLO('yolov8n-face.pt')
                print('Modelo facial cargado')
            else:
                self.modelo = YOLO('yolov8n.pt')
                print('Usando modelo base')
            self.cargado = True
        except Exception as e:
            print(f'Error: {e}')

    def detectar_caras(self, imagen_bytes: bytes):
        """
        Recibe bytes de imagen y retorna
        lista de caras recortadas como numpy arrays.
        """
        np_arr = np.frombuffer(imagen_bytes, np.uint8)
        frame  = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

        if frame is None:
            return [], frame

        resultados = self.modelo(frame, conf=self.conf, verbose=False)
        caras      = []

        for resultado in resultados:
            for box in resultado.boxes:
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                # Recortar la cara del frame
                cara = frame[y1:y2, x1:x2]
                if cara.size > 0:
                    caras.append({
                        'imagen': cara,
                        'bbox': {'x1': x1, 'y1': y1, 'x2': x2, 'y2': y2},
                        'confianza': float(box.conf[0])
                    })

        return caras, frame


yolo_service = YOLOService()