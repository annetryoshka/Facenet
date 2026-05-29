from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()


class Deteccion(db.Model):
    __tablename__ = 'detecciones'

    id        = db.Column(db.Integer, primary_key=True)
    clase     = db.Column(db.String(50), nullable=False)
    confianza = db.Column(db.Float, nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    fuente    = db.Column(db.String(20), default='imagen')

    def to_dict(self):
        return {
            'id':        self.id,
            'clase':     self.clase,
            'confianza': round(self.confianza, 4),
            'timestamp': self.timestamp.isoformat(),
            'fuente':    self.fuente,
        }