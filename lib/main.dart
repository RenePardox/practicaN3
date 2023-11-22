import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Finanzas',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Finanzas'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Registrar Egreso'),
          onPressed: () async {
            // Ejemplo de registro de egreso
            double egreso = 50.0; // Monto del egreso a registrar

            await registrarEgreso(egreso);
          },
        ),
      ),
    );
  }

  Future<Database> openDB() async {
    // Abrir la base de datos (o crear si no existe)
    return openDatabase(
      join(await getDatabasesPath(), 'finanzas_database.db'),
      onCreate: (db, version) {
        // Crear tablas si la base de datos no existe
        return db
            .execute(
          'CREATE TABLE ingresos(id INTEGER PRIMARY KEY, monto REAL, fecha TEXT)',
        )
            .then((_) {
          return db.execute(
            'CREATE TABLE egresos(id INTEGER PRIMARY KEY, monto REAL, fecha TEXT)',
          );
        });
      },
      version: 1,
    );
  }

  Future<double> obtenerTotalIngresos() async {
    // Obtener el total de ingresos desde la base de datos
    final Database db = await openDB();
    final List<Map<String, dynamic>> ingresos = await db.query('ingresos');

    double total = 0.0;
    for (Map<String, dynamic> ingreso in ingresos) {
      total += ingreso['monto'] as double;
    }

    return total;
  }

  Future<double> obtenerTotalEgresos() async {
    // Obtener el total de egresos desde la base de datos
    final Database db = await openDB();
    final List<Map<String, dynamic>> egresos = await db.query('egresos');

    double total = 0.0;
    for (Map<String, dynamic> egreso in egresos) {
      total += egreso['monto'] as double;
    }

    return total;
  }

  Future<void> registrarEgreso(double monto) async {
    final double totalIngresos = await obtenerTotalIngresos();
    final double totalEgresos = await obtenerTotalEgresos();

    // Verificar que el egreso no supere los ingresos
    if (totalIngresos >= totalEgresos + monto) {
      final Database db = await openDB();
      await db.insert(
        'egresos',
        {'monto': monto, 'fecha': DateTime.now().toString()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Egreso de \$${monto.toStringAsFixed(2)} registrado con éxito.');
    } else {
      print('Error: No puedes gastar más de lo que has ingresado.');
    }
  }
}
