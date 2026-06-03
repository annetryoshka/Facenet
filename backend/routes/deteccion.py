from flask import Blueprint, request, jsonify
from ..services.yolo_service import yolo_service
from ..services.reconocimiento_service import reconocimiento_service
from ..services.acceso_service import AccesoService
from ..models.database import db, Deteccion
from datetime import datetime

deteccion_bp = Blueprint('deteccion', __name__, url_prefix='/api/deteccion')

EXTENSIONES_OK = {'png', 'jpg', 'jpeg', 'webp'}

def extension_valida(nombre):
    return '.' in nombre and nombre.rsplit('.', 1)[1].lower() in EXTENSIONES_OK


@deteccion_bp.post('/imagen')
def detectar_imagen():
    """
    Detecta caras, identifica y REGISTRA ENTRADA/SALIDA automáticamente.
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
            'accesos':  []
        }), 200

    # Paso 2: DeepFace identifica + AccesoService registra entrada/salida
    resultados = []
    for cara in caras:
        identificacion = reconocimiento_service.identificar(cara['imagen'])

        if identificacion['identificado']:
            # Registrar entrada/salida automáticamente
            acceso = AccesoService.registrar_acceso(
                identificacion['persona'],
                identificacion['confianza'] / 100
            )
            resultado = {
                'persona':      identificacion['persona'],
                'identificado': True,
                'confianza':    identificacion['confianza'],
                'tipo_acceso':  acceso['tipo'],  # 'entrada' o 'salida'
                'hora':         acceso['hora'],
            }
        else:
            resultado = {
                'persona':      'Desconocido',
                'identificado': False,
                'confianza':    0,
                'tipo_acceso':  'acceso_denegado',
            }

        resultados.append(resultado)

    return jsonify({
        'ok':      True,
        'accesos': resultados,
        'timestamp': datetime.utcnow().isoformat(),
    }), 200

@deteccion_bp.post('/registrar-empleado-completo')
def registrar_empleado_completo():
    """
    Registra empleado COMPLETO con todos los datos + foto.
    Body (multipart/form-data):
    - nombre, email, telefono, puesto, salario, hora_entrada, hora_salida, descuento_atraso, foto
    """
    from ..services.empleado_service import EmpleadoService
    from ..services.reconocimiento_service import reconocimiento_service
    
    # Validar campos
    campos = ['nombre', 'email', 'puesto', 'salario', 'hora_entrada', 'hora_salida']
    for campo in campos:
        if campo not in request.form:
            return jsonify({'error': f'Campo {campo} requerido'}), 400
    
    if 'foto' not in request.files:
        return jsonify({'error': 'Foto requerida'}), 400
    
    foto = request.files['foto']
    imagen_bytes = foto.read()
    
    # 1. Registrar en BD de empleados
    resultado_emp = EmpleadoService.registrar_empleado(
        nombre           = request.form['nombre'],
        email            = request.form['email'],
        telefono         = request.form.get('telefono', ''),
        puesto           = request.form['puesto'],
        salario          = float(request.form['salario']),
        hora_entrada     = request.form['hora_entrada'],
        hora_salida      = request.form['hora_salida'],
        descuento_atraso = float(request.form.get('descuento_atraso', 0))
    )
    
    if 'error' in resultado_emp:
        return jsonify(resultado_emp), 400
    
    # 2. Registrar cara en DeepFace
    resultado_cara = reconocimiento_service.registrar_persona(
        request.form['nombre'],
        imagen_bytes
    )
    
    return jsonify({
        'ok':       True,
        'empleado': resultado_emp['empleado'],
        'cara':     resultado_cara,
        'mensaje':  f"Empleado {request.form['nombre']} registrado correctamente"
    }), 201

@deteccion_bp.post('/registrar')
def registrar_persona():
    """Registra una nueva persona en el dataset"""
    if 'imagen' not in request.files:
        return jsonify({'error': 'Campo "imagen" requerido'}), 400

    if 'nombre' not in request.form:
        return jsonify({'error': 'Campo "nombre" requerido'}), 400

    nombre       = request.form['nombre'].strip()
    imagen_bytes = request.files['imagen'].read()

    resultado = reconocimiento_service.registrar_persona(nombre, imagen_bytes)

    return jsonify(resultado), 201


@deteccion_bp.get('/dentro')
def personas_dentro():
    """¿Quién está dentro del edificio AHORA?"""
    personas = AccesoService.obtener_personas_dentro()
    return jsonify({
        'ok':      True,
        'total':   len(personas),
        'personas': personas
    })


@deteccion_bp.get('/historial/<nombre>')
def historial_persona(nombre):
    """Historial completo de una persona"""
    registros = AccesoService.historial_persona(nombre)
    return jsonify({
        'ok':     True,
        'persona': nombre,
        'total':  len(registros),
        'data':   registros
    })


@deteccion_bp.get('/reporte/hoy')
def reporte_hoy():
    """Reporte de accesos de hoy"""
    reporte = AccesoService.reporte_diario()
    return jsonify({
        'ok':      True,
        'fecha':   datetime.utcnow().date().isoformat(),
        'total_personas': len(reporte),
        'reporte': reporte
    })


@deteccion_bp.get('/historial')
def historial():
    """Historial general"""
    limite = request.args.get('limite', 50, type=int)
    registros = Deteccion.query.order_by(
        Deteccion.timestamp.desc()
    ).limit(limite).all()

    return jsonify({
        'ok':    True,
        'total': len(registros),
        'data':  [r.to_dict() for r in registros],
    })