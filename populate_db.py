from backend import create_app
from backend.models.database import db, Empleado, Deteccion
from datetime import datetime, timedelta
import random

app = create_app()

with app.app_context():
    # Limpiar datos previos (opcional)
    # db.session.query(Deteccion).delete()
    # db.session.query(Empleado).delete()
    
    # Crear empleados
    empleados = [
    Empleado(
        nombre="Han Jisung",
        email="hann@company.com",
        telefono="123456789",
        puesto="Desarrollador",
        salario=5000.0,
        hora_entrada="08:00",
        hora_salida="17:00",
        descuento_atraso=5.0,
    ),
    Empleado(
        nombre="Im Nayeon",
        email="nayeon@company.com",
        telefono="987654321",
        puesto="Diseñador",
        salario=4500.0,
        hora_entrada="09:00",
        hora_salida="18:00",
        descuento_atraso=3.0,
    ),
    Empleado(
        nombre="Diana Estrada",
        email="didiana@company.com",
        telefono="555666777",
        puesto="Gerente",
        salario=6000.0,
        hora_entrada="07:30",
        hora_salida="16:30",
        descuento_atraso=2.0,
    ),
    Empleado(
        nombre="Mark Lee",
        email="mark@company.com",
        telefono="444555666",
        puesto="Técnico",
        salario=3500.0,
        hora_entrada="08:00",
        hora_salida="17:00",
        descuento_atraso=4.0,
    ),
    # 5 NUEVOS
    Empleado(
        nombre="Sofia Mendez",
        email="sofia@company.com",
        telefono="111222333",
        puesto="Contador",
        salario=4000.0,
        hora_entrada="08:30",
        hora_salida="17:30",
        descuento_atraso=3.5,
    ),
    Empleado(
        nombre="Juan Torres",
        email="juan@company.com",
        telefono="222333444",
        puesto="Analista",
        salario=4800.0,
        hora_entrada="08:00",
        hora_salida="17:00",
        descuento_atraso=4.5,
    ),
    Empleado(
        nombre="María González",
        email="maria@company.com",
        telefono="333444555",
        puesto="Recursos Humanos",
        salario=4200.0,
        hora_entrada="07:45",
        hora_salida="16:45",
        descuento_atraso=2.5,
    ),
    Empleado(
        nombre="Roberto Silva",
        email="roberto@company.com",
        telefono="666777888",
        puesto="Jefe de Proyecto",
        salario=5500.0,
        hora_entrada="08:00",
        hora_salida="17:00",
        descuento_atraso=3.0,
    ),
    Empleado(
        nombre="Laura Fernández",
        email="laura@company.com",
        telefono="777888999",
        puesto="QA Tester",
        salario=4300.0,
        hora_entrada="09:00",
        hora_salida="18:00",
        descuento_atraso=4.0,
    ),
]
    
    db.session.add_all(empleados)
    db.session.commit()
    
    # Crear detecciones (últimos 7 días)
    hoy = datetime.utcnow()
    
    for dias_atras in range(7):
        fecha = hoy - timedelta(days=dias_atras)
        
        for empleado in empleados:
            # Entrada (08:00 - 09:30)
            hora_entrada = fecha.replace(hour=random.randint(8, 9), minute=random.randint(0, 30))
            deteccion_entrada = Deteccion(
                persona=empleado.nombre,
                tipo="entrada",
                confianza=random.uniform(0.85, 0.99),
                timestamp=hora_entrada,
                estado="dentro",
            )
            db.session.add(deteccion_entrada)
            
            # Salida (17:00 - 18:00)
            hora_salida = fecha.replace(hour=random.randint(17, 18), minute=random.randint(0, 59))
            deteccion_salida = Deteccion(
                persona=empleado.nombre,
                tipo="salida",
                confianza=random.uniform(0.85, 0.99),
                timestamp=hora_salida,
                estado="fuera",
            )
            db.session.add(deteccion_salida)
    
    db.session.commit()
    print("✅ Base de datos poblada exitosamente!")
    print(f"   - {len(empleados)} empleados creados")
    print(f"   - {len(empleados) * 2 * 7} detecciones creadas")