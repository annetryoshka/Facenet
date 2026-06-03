from ..models.database import db, Empleado
from datetime import datetime, time

class EmpleadoService:

    @staticmethod
    def registrar_empleado(nombre: str, email: str, telefono: str, 
                          puesto: str, salario: float, 
                          hora_entrada: str, hora_salida: str, 
                          descuento_atraso: float = 0.0) -> dict:
        """
        Registra un nuevo empleado con su horario y descuentos.
        """
        existente = Empleado.query.filter_by(nombre=nombre).first()
        if existente:
            return {'error': 'El empleado ya existe'}

        empleado = Empleado(
            nombre           = nombre,
            email            = email,
            telefono         = telefono,
            puesto           = puesto,
            salario          = salario,
            hora_entrada     = hora_entrada,
            hora_salida      = hora_salida,
            descuento_atraso = descuento_atraso,
        )
        db.session.add(empleado)
        db.session.commit()

        return {
            'ok':       True,
            'empleado': empleado.to_dict(),
            'mensaje':  f'Empleado {nombre} registrado'
        }

    @staticmethod
    def obtener_empleado(nombre: str) -> dict:
        """Obtiene info del empleado"""
        empleado = Empleado.query.filter_by(nombre=nombre).first()
        
        if not empleado:
            return {'error': 'Empleado no encontrado'}

        return {
            'ok':       True,
            'empleado': empleado.to_dict()
        }

    @staticmethod
    def calcular_descuento(nombre: str, hora_acceso: datetime) -> dict:
        """
        Calcula si hay descuento por atraso o salida temprana.
        Retorna el % de descuento y el monto.
        """
        empleado = Empleado.query.filter_by(nombre=nombre).first()
        
        if not empleado:
            return {'error': 'Empleado no encontrado'}

        hora_acc = hora_acceso.time()
        hora_ent = datetime.strptime(empleado.hora_entrada, '%H:%M').time()
        hora_sal = datetime.strptime(empleado.hora_salida, '%H:%M').time()

        descuento_pct = 0.0
        razon = 'Sin descuento'

        # Verificar atraso en entrada
        if hora_acc > hora_ent:
            descuento_pct = empleado.descuento_atraso
            minutos_atraso = int((datetime.combine(datetime.today(), hora_acc) - 
                                 datetime.combine(datetime.today(), hora_ent)).total_seconds() / 60)
            razon = f'Atraso de {minutos_atraso} minutos'

        # Verificar salida temprana (si está registrando salida)
        elif hora_acc < hora_sal:
            descuento_pct = empleado.descuento_atraso * 0.5  # Descuento menor por salida temprana
            minutos_temprano = int((datetime.combine(datetime.today(), hora_sal) - 
                                   datetime.combine(datetime.today(), hora_acc)).total_seconds() / 60)
            razon = f'Salida {minutos_temprano} minutos antes'

        monto_descuento = (empleado.salario * descuento_pct) / 100

        return {
            'ok':                True,
            'empleado':          empleado.nombre,
            'salario':           empleado.salario,
            'descuento_pct':     round(descuento_pct, 2),
            'monto_descuento':   round(monto_descuento, 2),
            'salario_final':     round(empleado.salario - monto_descuento, 2),
            'razon':             razon,
        }

    @staticmethod
    def listar_empleados() -> list:
        """Retorna lista de todos los empleados"""
        empleados = Empleado.query.all()
        return [e.to_dict() for e in empleados]