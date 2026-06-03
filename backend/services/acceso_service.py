from ..models.database import db, Deteccion, PersonaActiva
from datetime import datetime

class AccesoService:

    @staticmethod
    def registrar_acceso(persona: str, confianza: float) -> dict:
        """
        Registra entrada/salida automáticamente.
        Si la persona está en la BD de activas → es SALIDA
        Si no está → es ENTRADA
        """
        activa = PersonaActiva.query.filter_by(nombre=persona).first()

        if activa:
            #salida pq ya estaba dentro del laburo
            tipo = 'salida'
            db.session.delete(activa)
        else:
            #entrada al laburo pq no estaba jujuujj
            tipo = 'entrada'
            nueva_activa = PersonaActiva(nombre=persona)
            db.session.add(nueva_activa)

        deteccion = Deteccion(
            persona    = persona,
            tipo       = tipo,
            confianza  = confianza,
            estado     = 'fuera' if tipo == 'salida' else 'dentro'
        )
        db.session.add(deteccion)
        db.session.commit()

        return {
            'persona': persona,
            'tipo': tipo,
            'hora': datetime.utcnow().isoformat(),
        }

    @staticmethod
    def obtener_personas_dentro():
        """Quién está dentro del edificio AHORA"""
        activas = PersonaActiva.query.all()
        return [p.to_dict() for p in activas]

    @staticmethod
    def historial_persona(nombre: str):
        """Historial completo de una persona"""
        registros = Deteccion.query.filter_by(persona=nombre).order_by(
            Deteccion.timestamp.desc()
        ).all()
        return [r.to_dict() for r in registros]

    @staticmethod
    def reporte_diario():
        """Reporte de quién entró hoy"""
        from sqlalchemy import func
        hoy = datetime.utcnow().date()
        
        entradas = db.session.query(
            Deteccion.persona,
            func.count(Deteccion.id).label('accesos'),
            func.min(Deteccion.timestamp).label('primera_entrada'),
            func.max(Deteccion.timestamp).label('ultima_salida')
        ).filter(func.date(Deteccion.timestamp) == hoy).group_by(
            Deteccion.persona
        ).all()

        return [
            {
                'persona': e.persona,
                'accesos': e.accesos,
                'entrada': e.primera_entrada.isoformat() if e.primera_entrada else None,
                'salida':  e.ultima_salida.isoformat() if e.ultima_salida else None,
            }
            for e in entradas
        ]