from flask import Blueprint, request, jsonify
from ..services.empleado_service import EmpleadoService
from datetime import datetime

empleados_bp = Blueprint('empleados', __name__, url_prefix='/api/empleados')


@empleados_bp.post('/registrar')
def registrar_empleado():
    """
    Registra un nuevo empleado CON FOTO.
    Body (multipart/form-data):
    - nombre: "James"
    - email: "james@company.com"
    - telefono: "123456789"
    - puesto: "Desarrollador"
    - salario: 5000
    - hora_entrada: "08:00"
    - hora_salida: "17:00"
    - descuento_atraso: 5.0
    - foto: <archivo.jpg>
    """
    from ..services.reconocimiento_service import reconocimiento_service
    
    # Validar campos
    campos_requeridos = ['nombre', 'email', 'puesto', 'salario', 'hora_entrada', 'hora_salida']
    for campo in campos_requeridos:
        if campo not in request.form:
            return jsonify({'error': f'Campo "{campo}" requerido'}), 400

    # Validar foto
    if 'foto' not in request.files:
        return jsonify({'error': 'Foto del empleado requerida'}), 400

    nombre = request.form['nombre'].strip()
    foto = request.files['foto']

    if foto.filename == '':
        return jsonify({'error': 'Selecciona una foto'}), 400

    # registrar empleado en BD
    resultado_emp = EmpleadoService.registrar_empleado(
        nombre           = nombre,
        email            = request.form.get('email'),
        telefono         = request.form.get('telefono'),
        puesto           = request.form['puesto'],
        salario          = float(request.form['salario']),
        hora_entrada     = request.form['hora_entrada'],
        hora_salida      = request.form['hora_salida'],
        descuento_atraso = float(request.form.get('descuento_atraso', 0))
    )

    if 'error' in resultado_emp:
        return jsonify(resultado_emp), 400

    # registrar cara
    imagen_bytes = foto.read()
    resultado_cara = reconocimiento_service.registrar_persona(nombre, imagen_bytes)

    return jsonify({
        'ok':       True,
        'empleado': resultado_emp['empleado'],
        'cara':     resultado_cara,
        'mensaje':  f'Empleado {nombre} registrado con foto'
    }), 201


@empleados_bp.get('/<nombre>')
def obtener_empleado(nombre):
    """Obtiene información de un empleado"""
    resultado = EmpleadoService.obtener_empleado(nombre)
    return jsonify(resultado), 200 if 'ok' in resultado else 404


@empleados_bp.post('/<nombre>/descuento')
def calcular_descuento(nombre):
    """
    Calcula el descuento por atraso/salida temprana.
    Body JSON (opcional):
    {
        "hora_acceso": "2026-06-02T08:15:00"  # Si no se envía usa hora actual
    }
    """
    data = request.get_json() or {}
    
    if 'hora_acceso' in data:
        hora = datetime.fromisoformat(data['hora_acceso'])
    else:
        hora = datetime.utcnow()

    resultado = EmpleadoService.calcular_descuento(nombre, hora)
    return jsonify(resultado), 200 if 'ok' in resultado else 404


@empleados_bp.get('/')
def listar_empleados():
    """Lista todos los empleados"""
    empleados = EmpleadoService.listar_empleados()
    return jsonify({
        'ok':        True,
        'total':     len(empleados),
        'empleados': empleados
    }), 200