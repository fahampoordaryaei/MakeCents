part of 'generated.dart';

class ListScholarshipsVariablesBuilder {
  final FirebaseDataConnect _dataConnect;
  ListScholarshipsVariablesBuilder(this._dataConnect);
  Deserializer<ListScholarshipsData> dataDeserializer = (dynamic json) =>
      ListScholarshipsData.fromJson(jsonDecode(json));

  Future<QueryResult<ListScholarshipsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListScholarshipsData, void> ref() {
    return _dataConnect.query(
      "ListScholarships",
      dataDeserializer,
      emptySerializer,
      null,
    );
  }
}

@immutable
class ListScholarshipsScholarships {
  final String id;
  final String title;
  final String provider;
  final String email;
  final double amount;
  final String currency;
  final List<ListScholarshipsScholarshipsCoursesViaScholarshipCourse>
  courses_via_ScholarshipCourse;
  final String description;
  final String color;
  ListScholarshipsScholarships.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']),
      title = nativeFromJson<String>(json['title']),
      provider = nativeFromJson<String>(json['provider']),
      email = nativeFromJson<String>(json['email']),
      amount = nativeFromJson<double>(json['amount']),
      currency = nativeFromJson<String>(json['currency']),
      courses_via_ScholarshipCourse =
          (json['courses_via_ScholarshipCourse'] as List<dynamic>)
              .map(
                (e) =>
                    ListScholarshipsScholarshipsCoursesViaScholarshipCourse.fromJson(
                      e,
                    ),
              )
              .toList(),
      description = nativeFromJson<String>(json['description']),
      color = nativeFromJson<String>(json['color']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListScholarshipsScholarships otherTyped =
        other as ListScholarshipsScholarships;
    return id == otherTyped.id &&
        title == otherTyped.title &&
        provider == otherTyped.provider &&
        email == otherTyped.email &&
        amount == otherTyped.amount &&
        currency == otherTyped.currency &&
        courses_via_ScholarshipCourse ==
            otherTyped.courses_via_ScholarshipCourse &&
        description == otherTyped.description &&
        color == otherTyped.color;
  }

  @override
  int get hashCode => Object.hashAll([
    id.hashCode,
    title.hashCode,
    provider.hashCode,
    email.hashCode,
    amount.hashCode,
    currency.hashCode,
    courses_via_ScholarshipCourse.hashCode,
    description.hashCode,
    color.hashCode,
  ]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['provider'] = nativeToJson<String>(provider);
    json['email'] = nativeToJson<String>(email);
    json['amount'] = nativeToJson<double>(amount);
    json['currency'] = nativeToJson<String>(currency);
    json['courses_via_ScholarshipCourse'] = courses_via_ScholarshipCourse
        .map((e) => e.toJson())
        .toList();
    json['description'] = nativeToJson<String>(description);
    json['color'] = nativeToJson<String>(color);
    return json;
  }

  ListScholarshipsScholarships({
    required this.id,
    required this.title,
    required this.provider,
    required this.email,
    required this.amount,
    required this.currency,
    required this.courses_via_ScholarshipCourse,
    required this.description,
    required this.color,
  });
}

@immutable
class ListScholarshipsScholarshipsCoursesViaScholarshipCourse {
  final String id;
  final String name;
  ListScholarshipsScholarshipsCoursesViaScholarshipCourse.fromJson(dynamic json)
    : id = nativeFromJson<String>(json['id']),
      name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final ListScholarshipsScholarshipsCoursesViaScholarshipCourse otherTyped =
        other as ListScholarshipsScholarshipsCoursesViaScholarshipCourse;
    return id == otherTyped.id && name == otherTyped.name;
  }

  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  ListScholarshipsScholarshipsCoursesViaScholarshipCourse({
    required this.id,
    required this.name,
  });
}

@immutable
class ListScholarshipsData {
  final List<ListScholarshipsScholarships> scholarships;
  ListScholarshipsData.fromJson(dynamic json)
    : scholarships = (json['scholarships'] as List<dynamic>)
          .map((e) => ListScholarshipsScholarships.fromJson(e))
          .toList();
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
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

  ListScholarshipsData({required this.scholarships});
}
