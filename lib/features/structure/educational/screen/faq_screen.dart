import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQs')),
      body: ListView.builder(
        itemCount: faqs.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, i) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ExpansionTile(
            leading: const Icon(Icons.question_answer, color: Colors.pink),
            title: Text(
              faqs[i]['question']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(faqs[i]['answer']!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<Map<String, String>> faqs = [
  {
    'question': 'Can I exercise during my period?',
    'answer': 'Yes, light to moderate exercise can help alleviate cramps and improve mood.'
  },
  {
    'question': 'Is it safe to use tampons?',
    'answer': 'Yes, when used correctly and changed regularly, tampons are safe.'
  },
  {
    'question': 'What is menstruation?',
    'answer': 'Menstruation is the monthly shedding of the uterine lining, resulting in bleeding through the vagina.'
  },
  {
    'question': 'At what age do girls usually start menstruating?',
    'answer': 'Most girls begin menstruating between ages 10 and 15, though it can vary.'
  },
  {
    'question': 'What is a menstrual cycle?',
    'answer': 'The menstrual cycle is the monthly process where the body prepares for pregnancy, including ovulation and menstruation.'
  },
  {
    'question': 'How long does a menstrual cycle last?',
    'answer': 'A typical menstrual cycle lasts about 28 days, but it can range from 21 to 35 days.'
  },
  {
    'question': 'How many days does menstruation last?',
    'answer': 'Menstruation usually lasts between 3 to 7 days.'
  },
  {
    'question': 'How do I calculate my menstrual cycle?',
    'answer': 'Start counting from the first day of your period to the day before your next period begins. This is your cycle length.'
  },
  {
    'question': 'What is the fertile window?',
    'answer': 'The fertile window is the period when pregnancy is most likely, spanning 5 days before ovulation and the day of ovulation itself.'
  },
  {
    'question': 'Can I track my cycle using apps?',
    'answer': 'Yes, apps like Flo, Clue, and Period Tracker help monitor menstrual cycles, predict ovulation, and track symptoms.'
  },
  {
    'question': 'Is it normal to have irregular cycles?',
    'answer': 'Occasional irregularities are common, especially during adolescence or perimenopause.'
  },
  {
    'question': 'Can stress affect my menstrual cycle?',
    'answer': 'Yes, high stress levels can lead to delayed or missed periods.'
  },
  {
    'question': 'What is menstrual hygiene management (MHM)?',
    'answer': 'MHM involves using clean menstrual products and maintaining proper hygiene during menstruation.'
  },
  {
    'question': 'How often should I change my menstrual product?',
    'answer': 'Change pads every 4–6 hours, tampons every 4–8 hours, and empty menstrual cups every 8–12 hours.'
  },
  {
    'question': 'Is it safe to swim during menstruation?',
    'answer': 'Yes, using tampons or menstrual cups makes swimming safe during your period.'
  },
  {
    'question': 'Can poor menstrual hygiene cause infections?',
    'answer': 'Yes, improper hygiene can lead to infections like UTIs or RTIs.'
  },
  {
    'question': 'What is Toxic Shock Syndrome (TSS)?',
    'answer': 'Toxic Shock Syndrome is a rare but serious condition linked to prolonged tampon use. Change tampons regularly to reduce the risk.'
  },
  {
    'question': 'Can I exercise while menstruating?',
    'answer': 'Exercise can help reduce cramps and improve mood.'
  },
  {
    'question': 'How can I relieve menstrual cramps?',
    'answer': 'Apply heat, take pain relievers, exercise, and stay hydrated to relieve cramps.'
  },
  {
    'question': 'What is PMS?',
    'answer': 'PMS stands for Premenstrual Syndrome, which includes symptoms like mood swings and bloating before menstruation.'
  },
  {
    'question': 'What is PMDD?',
    'answer': 'Premenstrual Dysphoric Disorder (PMDD) is a severe form of PMS that affects daily life.'
  },
  {
    'question': 'What is PCOS?',
    'answer': 'Polycystic Ovary Syndrome (PCOS) is a hormonal disorder causing irregular periods and other symptoms.'
  },
  {
    'question': 'What is endometriosis?',
    'answer': 'Endometriosis is a condition where tissue similar to the uterine lining grows outside the uterus, causing pain and potentially affecting fertility.'
  },
  {
    'question': 'What is amenorrhea?',
    'answer': 'Amenorrhea is the absence of menstruation, which can be primary (no periods by age 15) or secondary (missing periods for three months or more).'
  },
  {
    'question': 'When should I see a doctor about my period?',
    'answer': 'If you experience very heavy bleeding, severe pain, missed periods, or significant changes in your cycle, consult a doctor.'
  },
  {
    'question': 'Should I see a doctor for heavy bleeding?',
    'answer': 'Yes, if you are soaking through pads quickly or bleeding lasts more than 7 days, seek medical attention.'
  },
  {
    'question': 'Is it normal to have blood clots during menstruation?',
    'answer': 'Small clots are normal, but large or frequent clots should be evaluated by a doctor.'
  },
  {
    'question': 'What are the signs of a urinary tract infection (UTI)?',
    'answer': 'Symptoms include a burning sensation during urination, frequent urge to urinate, and cloudy urine.'
  },
  {
    'question': 'Does diet affect menstruation?',
    'answer': 'A balanced diet supports regular cycles, while extreme dieting or poor nutrition can disrupt menstruation.'
  },
  {
    'question': 'Can exercise influence my period?',
    'answer': 'Regular exercise promotes overall health, but excessive intense activity can lead to missed periods.'
  },
  {
    'question': 'How does menopause affect menstruation?',
    'answer': 'Menopause marks the end of menstrual cycles, typically between ages 45 and 55, with periods becoming irregular before stopping.'
  },
  {
    'question': 'What is period poverty?',
    'answer': 'Period poverty refers to inadequate access to menstrual products and hygiene facilities.'
  },
  {
    'question': 'How does menstruation affect school attendance?',
    'answer': 'Lack of products and facilities can cause girls to miss school during their periods.'
  },
  {
    'question': 'Are there cultural taboos around menstruation?',
    'answer': 'Yes, many cultures have myths and restrictions around menstruation, leading to stigma and misinformation.'
  },
]; // Already provided

}
