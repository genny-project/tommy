import 'package:internmatch/models/BaseEntity.dart';



int count = 0;
Future<List> fetchBaseEntity(String valueFilter) async {
  List <BaseEntity> beList = await BaseEntity.fetchBaseEntitys("JNL", "PRI_STATUS", valueFilter);
  return beList;
}
