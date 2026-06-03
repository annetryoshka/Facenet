from flask import Blueprint, request, jsonify
from werkzeug.utils import secure_filename
from ..models.database import db, Deteccion
import os

dataset_bp = Blueprint('dataset', __name__, url_prefix='/api/dataset')

CLASES_VALIDAS = {'persona', 'no_persona'}
EXTENSIONES_OK = {'jpg', 'jpeg', 'png', 'webp'}

def ext_ok(nombre):
    return '.' in nombre and nombre.rsplit('.', 1)[1].lower() in EXTENSIONES_OK


@dataset_bp.post('/subir')
def subir_imagenes():
    clase = request.form.get('clase', '').strip().lower()

    if clase not in CLASES_VALIDAS:
        return jsonify({'error': f'Clase inválida. Usa: {list(CLASES_VALIDAS)}'}), 400

    archivos = request.files.getlist('imagenes')

    if not archivos:
        return jsonify({'error': 'No se recibieron archivos'}), 400

    destino = os.path.join('dataset', 'images', 'train', clase)
    os.makedirs(destino, exist_ok=True)

    guardados = []
    errores   = []

    for archivo in archivos:
        if not ext_ok(archivo.filename):
            errores.append(f'{archivo.filename}: extensión no permitida')
            continue

        nombre = secure_filename(archivo.filename)
        ruta   = os.path.join(destino, nombre)
        archivo.save(ruta)
        guardados.append(nombre)

    return jsonify({
        'ok':       True,
        'clase':    clase,
        'guardados': len(guardados),
        'archivos': guardados,
        'errores':  errores,
    }), 201


@dataset_bp.get('/info')
def info_dataset():
    data = {}
    for clase in CLASES_VALIDAS:
        carpeta = os.path.join('dataset', 'images', 'train', clase)
        data[clase] = len(os.listdir(carpeta)) if os.path.exists(carpeta) else 0

    return jsonify({'ok': True, 'dataset': data})