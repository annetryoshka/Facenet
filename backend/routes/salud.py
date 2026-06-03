from flask import Blueprint, jsonify

salud_bp = Blueprint('salud', __name__, url_prefix='/api')

@salud_bp.get('/salud')
def salud():
    return jsonify({
        'estado':  'activo',
        'version': '1.0.0',
        'mensaje': 'Backend funciona :v'
    })