class SchoolData {
  final String name;
  final String lga;

  const SchoolData({
    required this.name,
    required this.lga,
  });
}

const List<SchoolData> kSchools = [
  SchoolData(name: 'Excel College', lga: 'Surulere'),
  SchoolData(name: 'Greenfield Academy', lga: 'Ikeja'),
  SchoolData(name: 'Sunrise Secondary School', lga: 'Eti-Osa'),
  SchoolData(name: 'Heritage International School', lga: 'Alimosho'),
  SchoolData(name: 'Pinnacle Academy', lga: 'Kosofe'),
];