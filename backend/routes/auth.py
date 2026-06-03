from flask import Blueprint, request, jsonify, current_app
from ..services.yolo_service import yolo_service
from ..services.reconocimiento_service import reconocimiento_service
from ..models.database import Empleado
import os
import jwt
from datetime import datetime, timedelta

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')


@auth_bp.post('/login')
def login():
    try:
        usuario = request.form.get('usuario')
        password = request.form.get('password')

        # Primero intentamos autenticar por imagen (si se envía)
        if 'imagen' in request.files:
            imagen = request.files['imagen']
            imagen_bytes = imagen.read()

            caras, frame = yolo_service.detectar_caras(imagen_bytes)
            if caras:
                # Ordenar por confianza de detección YOLO (mayor primero)
                caras_sorted = sorted(caras, key=lambda c: c.get('confianza', 0), reverse=True)
                for cara in caras_sorted:
                    ident = reconocimiento_service.identificar(cara['imagen'])
                    if ident.get('identificado'):
                        nombre = ident.get('persona')
                        confianza = float(ident.get('confianza', 0))

                        empleado = Empleado.query.filter_by(nombre=nombre).first()
                        if not empleado:
                            return jsonify({'ok': False, 'error': 'Usuario no registrado'}), 404

                        if empleado.puesto is None or empleado.puesto.lower() not in ('admin', 'administrador'):
                            return jsonify({'ok': False, 'error': 'Usuario no es administrador'}), 403

                        umbral = float(os.getenv('AUTH_CONF_THRESHOLD', '80'))
                        if confianza >= umbral:
                            # Generar JWT
                            horas = int(os.getenv('AUTH_TOKEN_HOURS', '4'))
                            exp_ts = int((datetime.utcnow() + timedelta(hours=horas)).timestamp())
                            payload = {
                                'sub': empleado.nombre,
                                'role': 'admin',
                                'exp': exp_ts
                            }
                            token = jwt.encode(payload, current_app.config['SECRET_KEY'], algorithm='HS256')
                            return jsonify({'ok': True, 'token': token, 'empleado': empleado.to_dict()}), 200
                        else:
                            return jsonify({'ok': False, 'error': 'Confianza insuficiente', 'confianza': confianza}), 401

        # Si no fue posible por imagen, intentar fallback por contraseña (ADMIN_PASSWORD)
        admin_pw = os.getenv('ADMIN_PASSWORD')
        if password and usuario and admin_pw and password == admin_pw:
            empleado = Empleado.query.filter((Empleado.nombre == usuario) | (Empleado.email == usuario)).first()
            if empleado and empleado.puesto and empleado.puesto.lower() in ('admin', 'administrador'):
                horas = int(os.getenv('AUTH_TOKEN_HOURS', '4'))
                exp_ts = int((datetime.utcnow() + timedelta(hours=horas)).timestamp())
                payload = {
                    'sub': empleado.nombre,
                    'role': 'admin',
                    'exp': exp_ts
                }
                token = jwt.encode(payload, current_app.config['SECRET_KEY'], algorithm='HS256')
                return jsonify({'ok': True, 'token': token, 'empleado': empleado.to_dict()}), 200
            return jsonify({'ok': False, 'error': 'Usuario no encontrado o no es admin'}), 404

        return jsonify({'ok': False, 'error': 'No se pudo autenticar por imagen ni por contraseña'}), 401

    except Exception as e:
        return jsonify({'ok': False, 'error': str(e)}), 500

