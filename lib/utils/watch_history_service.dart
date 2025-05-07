import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveToWatchHistory(String profile, String type, Map<String, dynamic> item) async {
  final docRef = FirebaseFirestore.instance.collection('watch_history').doc(profile);
  final doc = await docRef.get();

  if (!doc.exists) {
    // Create document if it doesn't exist
    await docRef.set({type: [item]});
    return;
  }

  final data = doc.data() ?? {};
  final List<dynamic> currentItems = List.from(data[type] ?? []);

  // Check if item already exists (by unique ID or title)
  final alreadyExists = currentItems.any((element) {
    if (type == 'videos') {
      return element['id'] == item['id'];
    } else if (type == 'games') {
      return element['url'] == item['url'];
    } else if (type == 'books') {
      return element['title'] == item['title'];
    }
    return false;
  });

  if (!alreadyExists) {
    currentItems.add(item);
    await docRef.update({type: currentItems});
  }
}
