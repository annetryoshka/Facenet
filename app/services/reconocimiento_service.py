import os
import cv2
import numpy as np
from deepface import DeepFace

DATASET_PATH = 'dataset/personas'

class ReconocimientoService:

    def __init__(self):
        os.makedirs(DATASET_PATH, exist_ok=True)
        print('✅ Servicio de reconocimiento listo')

    def registrar_persona(self, nombre: str, imagen_bytes: bytes) -> dict:
        """
        Guarda la foto de una persona nueva en el dataset.
        """
        carpeta = os.path.join(DATASET_PATH, nombre)
        os.makedirs(carpeta, exist_ok=True)

        # Contar fotos existentes para nombrar la nueva
        total    = len(os.listdir(carpeta))
        nombre_archivo = f'foto_{total + 1}.jpg'
        ruta     = os.path.join(carpeta, nombre_archivo)

        np_arr   = np.frombuffer(imagen_bytes, np.uint8)
        imagen   = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

        if imagen is None:
            return {'error': 'No se pudo leer la imagen'}

        cv2.imwrite(ruta, imagen)

        return {
            'ok':      True,
            'persona': nombre,
            'foto':    nombre_archivo,
            'total_fotos': total + 1
        }

    def identificar(self, cara_array: np.ndarray) -> dict:
        """
        Recibe un numpy array de una cara recortada
        y retorna quién es usando DeepFace.
        """
        try:
            # Guardar cara temporal para DeepFace
            ruta_temp = 'uploads/cara_temp.jpg'
            cv2.imwrite(ruta_temp, cara_array)

            resultado = DeepFace.find(
                img_path        = ruta_temp,
                db_path         = DATASET_PATH,
                model_name      = 'Facenet',
                enforce_detection = False,
                silent          = True
            )

            # Limpiar temporal
            os.remove(ruta_temp)

            if len(resultado) > 0 and len(resultado[0]) > 0:
                fila     = resultado[0].iloc[0]
                ruta_id  = fila['identity']
                # Extraer nombre de la carpeta
                nombre   = ruta_id.split(os.sep)[-2]
                distancia = float(fila['distance'])
                confianza = round((1 - distancia) * 100, 2)

                return {
                    'identificado': True,
                    'persona':      nombre,
                    'confianza':    confianza
                }
            else:
                return {
                    'identificado': False,
                    'persona':      'Desconocido',
                    'confianza':    0
                }

        except Exception as e:
            return {
                'identificado': False,
                'persona':      'Desconocido',
                'confianza':    0,
                'error':        str(e)
            }


reconocimiento_service = ReconocimientoService()