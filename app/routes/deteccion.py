from flask import Blueprint, request, jsonify
from ..services.yolo_service import yolo_service
from ..services.reconocimiento_service import reconocimiento_service
from ..models.database import db, Deteccion
from datetime import datetime

deteccion_bp = Blueprint('deteccion', __name__, url_prefix='/api/deteccion')

EXTENSIONES_OK = {'png', 'jpg', 'jpeg', 'webp'}

def extension_valida(nombre):
    return '.' in nombre and nombre.rsplit('.', 1)[1].lower() in EXTENSIONES_OK


@deteccion_bp.post('/imagen')
def detectar_imagen():
    """
    Recibe imagen, detecta caras con YOLO
    e identifica cada cara con DeepFace.
    """
    if 'imagen' not in request.files:
        return jsonify({'error': 'Campo "imagen" requerido'}), 400

    archivo = request.files['imagen']

    if not extension_valida(archivo.filename):
        return jsonify({'error': 'Extensión no permitida'}), 400

    imagen_bytes = archivo.read()

    # Paso 1: YOLO detecta caras
    caras, frame = yolo_service.detectar_caras(imagen_bytes)

    if not caras:
        return jsonify({
            'ok':       True,
            'mensaje':  'No se detectaron caras',
            'personas': []
        }), 200

    # Paso 2: DeepFace identifica cada cara
    resultados = []
    for cara in caras:
        identificacion = reconocimiento_service.identificar(cara['imagen'])

        resultado = {
            'persona':      identificacion['persona'],
            'identificado': identificacion['identificado'],
            'confianza':    identificacion['confianza'],
            'bbox':         cara['bbox'],
        }
        resultados.append(resultado)

        # Guardar en base de datos
        db.session.add(Deteccion(
            clase     = identificacion['persona'],
            confianza = identificacion['confianza'] / 100,
            fuente    = 'imagen',
        ))

    db.session.commit()

    return jsonify({
        'ok':              True,
        'total_caras':     len(caras),
        'personas':        resultados,
        'timestamp':       datetime.utcnow().isoformat(),
    }), 200


@deteccion_bp.post('/registrar')
def registrar_persona():
    """
    Registra una nueva persona en el dataset.
    Body: imagen + nombre
    """
    if 'imagen' not in request.files:
        return jsonify({'error': 'Campo "imagen" requerido'}), 400

    if 'nombre' not in request.form:
        return jsonify({'error': 'Campo "nombre" requerido'}), 400

    nombre       = request.form['nombre'].strip()
    imagen_bytes = request.files['imagen'].read()

    resultado = reconocimiento_service.registrar_persona(nombre, imagen_bytes)

    return jsonify(resultado), 201


@deteccion_bp.get('/historial')
def historial():
    limite = request.args.get('limite', 50, type=int)
    registros = Deteccion.query.order_by(
        Deteccion.timestamp.desc()
    ).limit(limite).all()

    return jsonify({
        'ok':    True,
        'total': len(registros),
        'data':  [r.to_dict() for r in registros],
    })


@deteccion_bp.get('/estadisticas')
def estadisticas():
    from sqlalchemy import func
    total     = Deteccion.query.count()
    conf_prom = db.session.query(
        func.avg(Deteccion.confianza)
    ).scalar() or 0

    return jsonify({
        'ok': True,
        'estadisticas': {
            'total_detecciones':  total,
            'confianza_promedio': round(conf_prom, 4),
        }
    })