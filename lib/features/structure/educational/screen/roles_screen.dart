import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class RolesScreen extends StatelessWidget {
   RolesScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Roles & Responsibilities')),
      body: ListView.builder(
        itemCount: roles.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, i) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ExpansionTile(
            leading: Icon(Icons.group, color: appColor.primary),
            title: Text(
              roles[i]['group']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(roles[i]['responsibility']!),
              ),
            ],
          ),
        ),
      ),
    );
  }
final List<Map<String, String>> roles = [
  {
    'group': 'individual',
    'responsibility':
    'Educate yourself and others on menstruation and proper hygiene practices.\n'
        'Practice proper hygiene by changing menstrual products regularly and using clean water.\n'
        'Break the stigma by speaking openly and respectfully about menstruation.\n'
        'Support peers—especially young girls—by sharing accurate information and emotional support.\n'
        'Encourage healthy habits like proper disposal of used menstrual materials and using clean, safe products.'
  },
  {
    'group': 'communities',
    'responsibility':
    'Create safe and private sanitation facilities, especially in schools and public places.\n'
        'Organize community awareness campaigns to dispel myths and taboos.\n'
        'Engage parents, teachers, and religious leaders to support open discussions about menstruation.\n'
        'Establish community support groups where women and girls can share experiences and learn.\n'
        'Promote local production of affordable menstrual products to increase accessibility.'
  },
  {
    'group': 'government',
    'responsibility':
    'Implement menstrual health education in school curricula.\n'
        'Ensure access to clean water and sanitation facilities in schools and public spaces.\n'
        'Subsidize or make menstrual products tax-free to improve affordability.\n'
        'Develop and enforce policies supporting menstrual health rights and workplace accommodations.\n'
        'Support research and data collection to improve MHM programs and policies.'
  },
  {
    'group': 'private sector',
    'responsibility':
    'Produce affordable, sustainable, and safe menstrual hygiene products.\n'
        'Run menstrual health education programs as part of corporate social responsibility (CSR).\n'
        'Create inclusive workplace policies that support menstruating employees (e.g., menstrual leave, proper restroom facilities).\n'
        'Partner with NGOs or government to distribute products to underserved areas.\n'
        'Innovate eco-friendly alternatives to reduce environmental impact.'
  },
  {
    'group': 'NGOs and civil societies',
    'responsibility':
    'Run awareness campaigns in schools, rural areas, and urban slums.\n'
        'Distribute menstrual products to girls and women in need, especially during emergencies or in low-income areas.\n'
        'Train health educators and community volunteers to spread accurate information.\n'
        'Advocate for policy changes and increased government funding for menstrual health.\n'
        'Monitor and evaluate MHM programs to ensure effectiveness and reach.'
  },
];
}
