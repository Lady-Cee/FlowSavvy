class SchoolData {
  final String name;
  final String lga;
  final String contactName;
  final String contactPhone;

  const SchoolData({
    required this.name,
    required this.lga,
    required this.contactName,
    required this.contactPhone,
  });
}

const List<SchoolData> kSchools = [
  SchoolData(
    name: 'Excel College',
    lga: 'Surulere',
    contactName: 'Mrs Adebayo',
    contactPhone: '08012345678',
  ),
  SchoolData(
    name: 'Greenfield Academy',
    lga: 'Ikeja',
    contactName: 'Mr Okonkwo',
    contactPhone: '08023456789',
  ),
  SchoolData(
    name: 'Sunrise Secondary School',
    lga: 'Eti-Osa',
    contactName: 'Mrs Fashola',
    contactPhone: '08034567890',
  ),
  SchoolData(
    name: 'Heritage International School',
    lga: 'Alimosho',
    contactName: 'Mr Ibrahim',
    contactPhone: '08045678901',
  ),
  SchoolData(
    name: 'Pinnacle Academy',
    lga: 'Kosofe',
    contactName: 'Mrs Nwosu',
    contactPhone: '08056789012',
  ),
];