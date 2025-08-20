import 'package:flutter/material.dart';

class EssentialInfoScreen extends StatelessWidget {
   EssentialInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Essential Menstrual Info')),
      body: ListView.builder(
        itemCount: essentialInfo.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, i) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Icon(Icons.info_outline, color: Colors.blue),
            title: Text(essentialInfo[i]),
          ),
        ),
      ),
    );
  }

  final List<String> essentialInfo = [
  'Menstruation is a natural biological process.',
  'The average menstrual cycle is about 28 days.',
  'It is normal for cycles to vary between individuals.',
  'A typical period lasts between 3 to 7 days.',
  'Menstruation occurs when the uterus sheds its lining because an egg was not fertilized.',
  'The average amount of blood lost during a period is between 30 and 40 milliliters.',
  'The first menstruation, or menarche, typically occurs between ages 9 and 16.',
  'Periods can start to occur irregularly as women approach menopause.',
  'Periods can start to occur irregularly as women approach menopause, usually between ages 45 and 55',
  'Menstruation is controlled by hormonal changes, primarily estrogen and progesterone',
  'It is normal for periods to be light, heavy, or in between',
  'Some women may experience premenstrual syndrome (PMS), which can cause mood swings, bloating, and fatigue',
  'Menstrual cycles can be affected by stress, health conditions, and changes in diet or exercise',
  'Tracking menstrual cycles can help in understanding reproductive health',
  'Tampons, pads, menstrual cups, and period panties are common products used to manage menstruation',
  'Not all women experience cramps, but they are common, especially during the first few days of menstruation',
  'Irregular periods can be caused by hormonal imbalances, stress, or health issues such as polycystic ovary syndrome (PCOS)',
  'Menstruation is a sign of a functioning reproductive system in people with ovaries',
  'It is normal to experience changes in cycle length or flow throughout life, especially during puberty and menopause',
  'Good menstrual hygiene practices are important to prevent infections and discomfort',
  'Some cultures and communities may have specific beliefs or taboos surrounding menstruation',
]; //
}
