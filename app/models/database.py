from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()


class Deteccion(db.Model):
    __tablename__ = 'detecciones'

    id         = db.Column(db.Integer, primary_key=True)
    persona    = db.Column(db.String(100), nullable=False)
    tipo       = db.Column(db.String(20), nullable=False)  # 'entrada' o 'salida'
    confianza  = db.Column(db.Float, nullable=False)
    timestamp  = db.Column(db.DateTime, default=datetime.utcnow)
    estado     = db.Column(db.String(20), default='dentro')  # 'dentro' o 'fuera'

    def to_dict(self):
        return {
            'id':        self.id,
            'persona':   self.persona,
            'tipo':      self.tipo,
            'confianza': round(self.confianza, 4),
            'timestamp': self.timestamp.isoformat(),
            'estado':    self.estado,
        }
        
class Empleado(db.Model):
    __tablename__ = 'empleados'

    id              = db.Column(db.Integer, primary_key=True)
    nombre          = db.Column(db.String(100), nullable=False, unique=True)
    email           = db.Column(db.String(100))
    telefono        = db.Column(db.String(20))
    puesto          = db.Column(db.String(50))
    salario         = db.Column(db.Float)
    hora_entrada    = db.Column(db.String(5))  # "08:00"
    hora_salida     = db.Column(db.String(5))  # "17:00"
    descuento_atraso= db.Column(db.Float, default=0.0)  # % de descuento
    fecha_registro  = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id':               self.id,
            'nombre':           self.nombre,
            'email':            self.email,
            'telefono':         self.telefono,
            'puesto':           self.puesto,
            'salario':          self.salario,
            'hora_entrada':     self.hora_entrada,
            'hora_salida':      self.hora_salida,
            'descuento_atraso': self.descuento_atraso,
        }


class PersonaActiva(db.Model):
    """Registra quién está dentro del establecimiento ahora"""
    __tablename__ = 'personas_activas'

    id          = db.Column(db.Integer, primary_key=True)
    nombre      = db.Column(db.String(100), nullable=False, unique=True)
    entrada     = db.Column(db.DateTime, default=datetime.utcnow)
    ultima_visto = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'nombre':      self.nombre,
            'entrada':     self.entrada.isoformat(),
            'ultima_visto': self.ultima_visto.isoformat(),
        }