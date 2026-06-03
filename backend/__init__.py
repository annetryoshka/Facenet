from flask import Flask
from flask_cors import CORS
from .models.database import db
from .services.acceso_service import AccesoService
from .routes.empleados import empleados_bp
import os

def create_app():
    app = Flask(__name__)

    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-key')
    app.config['UPLOAD_FOLDER'] = os.getenv('UPLOAD_FOLDER', 'uploads/')
    app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///reconocimiento.db'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    

    CORS(app)
    db.init_app(app)

    from .routes.salud import salud_bp
    from .routes.deteccion import deteccion_bp
    from .routes.dataset import dataset_bp
    from .routes.empleados import empleados_bp
    from .routes.auth import auth_bp

    app.register_blueprint(salud_bp)
    app.register_blueprint(deteccion_bp)
    app.register_blueprint(dataset_bp)
    app.register_blueprint(empleados_bp)
    app.register_blueprint(auth_bp)

    with app.app_context():
        db.create_all()

    return app