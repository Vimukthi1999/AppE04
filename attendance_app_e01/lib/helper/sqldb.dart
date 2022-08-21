import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



class SqlDb{

  static Database? _db;

  Future<Database?> get db async{
    if (_db == null) {
      _db = await intialDb();
      return _db;
    }else{
      return _db;
    }
  }

  intialDb() async{
    String databasepath = await getDatabasesPath();
    String path = join(databasepath,'market.db'); // databasepath/products.db
    Database mydb = await openDatabase(path,onCreate: _onCreate,version: 1);
    return mydb;
  }


  _onCreate(Database db,int version) async{
    String sql = 'CREATE TABLE "markettbl" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "userid" TEXT,"geo_location" TEXT,"longitude" TEXT,"latitude" TEXT,"outlet_name" TEXT,"execution_type" TEXT,"remarks" TEXT,"image1" TEXT,"image2" TEXT,"image3" TEXT,"image4" TEXT,"image5" TEXT)';
    //String sql = 'CREATE TABLE "Products" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" TEXT,"description" TEXT)';
    await db.execute(sql);

    print('---------------------Create DATABASE AND Table---------------------');
  }

  // delete database
  deleteDB() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath,'');
    await deleteDatabase(path);

    print('DB Deleted !');
  }


  insertData(String table,Map<String,dynamic> json) async{
    Database? mydb = await db;
    int response = await mydb!.insert(table, json);
    //int response = await mydb!.insert(sql);
    return response;
  }

  readData(String sql) async{
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }

  Future<int?> getRowCount() async{
    try {
    String sql = 'SELECT COUNT(*) FROM markettbl';
    Database? mydb = await db;
    int? count = Sqflite.firstIntValue(await mydb!.rawQuery(sql));
    return count;
    } catch (e) {
      print(e.toString());
    }
  }

  // delete data
  deleteData(String sql) async{
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
    return response;
  }
}