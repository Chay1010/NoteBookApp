class Note{
  String? id;
  String title;
  String description;
  DateTime createdAt;
  DateTime modifiedAt;
  String uid;


  Note({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.modifiedAt,
    required this.uid,
  });


  Map<String, dynamic> toMap(){
    return {
      'title' : title,
      'description' : description,
      'createdAt' : createdAt.toString(),
      'modifiedAt' : modifiedAt.toString(),
      'uid' : uid,
    };
  }
}