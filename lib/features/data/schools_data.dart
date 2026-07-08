class SchoolData {
  final String name;
  final String lga;

  const SchoolData({
    required this.name,
    required this.lga,
  });
}

const List<SchoolData> kSchools = [
  SchoolData(name: 'Ado Girls Secondary School Onitsha', lga: 'Onitsha North'),
  SchoolData(name: 'Onitsha High School Onitsha', lga: 'Onitsha North'),
  SchoolData(name: 'Community Central School Nteje', lga: 'Oyi'),
  SchoolData(name: 'Nkwo Community School Ogbunike', lga: 'Oyi'),
  SchoolData(name: 'Capital City Secondary School Awka', lga: 'Awka South'),
  SchoolData(name: 'Community Secondary School Okpuno', lga: 'Awka South'),
  SchoolData(name: 'Community Secondary School Nawfia', lga: 'Njikoka'),
  SchoolData(name: 'Girl\'s Secondary School Abagana', lga: 'Njikoka'),
  SchoolData(name: 'Okpunoeze Central School Uruagu', lga: 'Nnewi North'),
  SchoolData(name: 'Obiofia Central School Nnewi', lga: 'Nnewi North'),
  SchoolData(name: 'Girls Secondary School Ogbunka', lga: 'Orumba South'),
  SchoolData(name: 'Ishingwu Central School Umunze', lga: 'Orumba South'),
];