class SchoolData {
  final String name;
  final String lga;

  const SchoolData({
    required this.name,
    required this.lga,
  });
}

const List<SchoolData> kSchools = [
  SchoolData(name: 'Ogbaru High School Ogbakuba', lga: 'Ogbaru'),
  SchoolData(name: 'Ideke Grammar Secondary School Ideke', lga: 'Ogbaru'),
  SchoolData(name: 'Unity Comprehensive Girls High School Okpoko', lga: 'Ogbaru'),
  SchoolData(name: 'Community Girls Secondary School Okpoko', lga: 'Ogbaru'),
  SchoolData(name: 'Community Secondary School Atani', lga: 'Ogbaru'),
  SchoolData(name: 'Government Technical College Osomala', lga: 'Ogbaru'),
  SchoolData(name: 'Community Secondary School Odekpe', lga: 'Ogbaru'),
  SchoolData(name: 'Josephine Odua Memorial Secondary School Akili-Ozizor', lga: 'Ogbaru'),
];