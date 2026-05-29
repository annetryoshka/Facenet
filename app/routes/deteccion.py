from flask import Blueprint, request, jsonify
from ..services.yolo_service import yolo_service
from ..models.database import db, Deteccion
from datetime import datetime

deteccion_bp = Blueprint('deteccion', __name__, url_prefix='/api/deteccion')

EXTENSIONES_OK = {'png', 'jpg', 'jpeg', 'webp'}

def extension_valida(nombre):
    return '.' in nombre and nombre.rsplit('.', 1)[1].lower() in EXTENSIONES_OK


@deteccion_bp.post('/imagen')
def detectar_imagen():
    if 'imagen' not in request.files:
        return jsonify({'error': 'Campo "imagen" requerido'}), 400

    archivo = request.files['imagen']

    if not extension_valida(archivo.filename):
        return jsonify({'error': 'Extensión no permitida'}), 400

    imagen_bytes = archivo.read()
    resultado    = yolo_service.predecir(imagen_bytes)

    if 'error' in resultado:
        return jsonify(resultado), 500

    for det in resultado['detecciones']:
        db.session.add(Deteccion(
            clase     = det['clase'],
            confianza = det['confianza'],
            fuente    = 'imagen',
        ))
    db.session.commit()

    return jsonify({
        'ok':             True,
        'total_personas': resultado['total_personas'],
        'total_objetos':  resultado['total_detecciones'],
        'detecciones':    resultado['detecciones'],
        'timestamp':      datetime.utcnow().isoformat(),
    }), 200


@deteccion_bp.get('/historial')
def historial():
    limite = request.args.get('limite', 50, type=int)
    clase  = request.args.get('clase', None)

    query = Deteccion.query.order_by(Deteccion.timestamp.desc())

    if clase:
        query = query.filter_by(clase=clase)

    registros = query.limit(limite).all()

    return jsonify({
        'ok':    True,
        'total': len(registros),
        'data':  [r.to_dict() for r in registros],
    })


@deteccion_bp.get('/estadisticas')
def estadisticas():
    from sqlalchemy import func

    total    = Deteccion.query.count()
    personas = Deteccion.query.filter_by(clase='person').count()
    conf_prom = db.session.query(func.avg(Deteccion.confianza)).scalar() or 0

    return jsonify({
        'ok': True,
        'estadisticas': {
            'total_detecciones':  total,
            'total_personas':     personas,
            'confianza_promedio': round(conf_prom, 4),
        }
    })