part of 'generated.dart';

class ListScholarshipsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListScholarshipsVariablesBuilder(this._dataConnect, );
  Deserializer<ListScholarshipsData> dataDeserializer = (dynamic json)  => ListScholarshipsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListScholarshipsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListScholarshipsData, void> ref() {
    
    return _dataConnect.query("ListScholarships", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListScholarshipsScholarships {
  final String id;
  final String title;
  final String provider;
  final String location;
  final double amount;
  final String currency;
  final String subjects;
  final String description;
  final String color;
  final DateTime? deadline;
  ListScholarshipsScholarships.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  provider = nativeFromJson<String>(json['provider']),
  location = nativeFromJson<String>(json['location']),
  amount = nativeFromJson<double>(json['amount']),
  currency = nativeFromJson<String>(json['currency']),
  subjects = nativeFromJson<String>(json['subjects']),
  description = nativeFromJson<String>(json['description']),
  color = nativeFromJson<String>(json['color']),
  deadline = json['deadline'] == null ? null : nativeFromJson<DateTime>(json['deadline']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListScholarshipsScholarships otherTyped = other as ListScholarshipsScholarships;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    provider == otherTyped.provider && 
    location == otherTyped.location && 
    amount == otherTyped.amount && 
    currency == otherTyped.currency && 
    subjects == otherTyped.subjects && 
    description == otherTyped.description && 
    color == otherTyped.color && 
    deadline == otherTyped.deadline;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, provider.hashCode, location.hashCode, amount.hashCode, currency.hashCode, subjects.hashCode, description.hashCode, color.hashCode, deadline.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['provider'] = nativeToJson<String>(provider);
    json['location'] = nativeToJson<String>(location);
    json['amount'] = nativeToJson<double>(amount);
    json['currency'] = nativeToJson<String>(currency);
    json['subjects'] = nativeToJson<String>(subjects);
    json['description'] = nativeToJson<String>(description);
    json['color'] = nativeToJson<String>(color);
    if (deadline != null) {
      json['deadline'] = nativeToJson<DateTime?>(deadline);
    }
    return json;
  }

  ListScholarshipsScholarships({
    required this.id,
    required this.title,
    required this.provider,
    required this.location,
    required this.amount,
    required this.currency,
    required this.subjects,
    required this.description,
    required this.color,
    this.deadline,
  });
}

@immutable
class ListScholarshipsData {
  final List<ListScholarshipsScholarships> scholarships;
  ListScholarshipsData.fromJson(dynamic json):
  
  scholarships = (json['scholarships'] as List<dynamic>)
        .map((e) => ListScholarshipsScholarships.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListScholarshipsData otherTyped = other as ListScholarshipsData;
    return scholarships == otherTyped.scholarships;
    
  }
  @override
  int get hashCode => scholarships.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['scholarships'] = scholarships.map((e) => e.toJson()).toList();
    return json;
  }

  ListScholarshipsData({
    required this.scholarships,
  });
}

