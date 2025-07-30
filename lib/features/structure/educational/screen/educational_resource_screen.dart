import 'package:flow_savvy/features/structure/gemini/gemini_search_screen.dart';
import 'package:flutter/material.dart';

class EducationalResourceScreen extends StatefulWidget {
  @override
  _EducationalResourceScreenState createState() => _EducationalResourceScreenState();
}

class _EducationalResourceScreenState extends State<EducationalResourceScreen> {
  int selectedIndex = -1;

  final List<Map<String, dynamic>> resources = [
    {'title': 'Myths vs Facts', 'icon': Icons.question_answer},
    {'title': 'Essential Information', 'icon': Icons.info},
    {'title': 'Hygiene Tips', 'icon': Icons.clean_hands},
    {'title': 'Our Roles', 'icon': Icons.group},
    {'title': 'FAQs', 'icon': Icons.help},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Educational Resources'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/search');

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => GeminiSearchScreen()),
          // );
        },
        child: Icon(Icons.question_mark),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Learn, understand, and share knowledge about menstruation. '
                  'This section provides facts, hygiene tips, roles we can all play, and answers to frequently asked questions.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: selectedIndex == -1
                  ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: resources.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            resources[index]['icon'],
                            size: 40,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            resources[index]['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : Column(
                children: [
                  ListTile(
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          selectedIndex = -1;
                        });
                      },
                    ),
                    title: Text(
                      resources[selectedIndex]['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(child: _buildContent(selectedIndex)),
                ],
              ),
            ),
            //SizedBox(height: MediaQuery.of(context).size.height * 0.06),
            // Container(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       Navigator.pushNamed(context, '/search');
            //
            //       // Navigator.push(
            //       //   context,
            //       //   MaterialPageRoute(builder: (context) => GeminiSearchScreen()),
            //       // );
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.green.shade400,
            //       foregroundColor: Colors.white,
            //     ),
            //     child: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Text("Looking for more info?️", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            //         SizedBox(width: MediaQuery.of(context).size.width * 0.02),
            //      //   Icon(Icons.arrow_forward)
            //       ],
            //     ),
            //   ),
            // )
          ],

        ),

      ),

    );
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return ListView.builder(
          itemCount: mythsAndFacts.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, i) =>
              Card(
                child: ListTile(
                  title: Text("Myth: ${mythsAndFacts[i]['myth']}"),
                  subtitle: Text("Fact: ${mythsAndFacts[i]['fact']}"),
                ),
              ),
        );
      case 1:
        return ListView.builder(
          itemCount: essentialInfo.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, i) =>
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(essentialInfo[i]),
              ),
        );
      case 2:
        return ListView.builder(
          itemCount: hygieneTips.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, i) =>
              ListTile(
                leading: Icon(Icons.clean_hands),
                title: Text(hygieneTips[i]),
              ),
        );
      case 3:
        return ListView.builder(
          itemCount: roles.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, i) =>
              ExpansionTile(
                title: Text(roles[i]['group']!),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(roles[i]['responsibility']!),
                  )
                ],
              ),
        );
      case 4:
        return ListView.builder(
          itemCount: faqs.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, i) =>
              ExpansionTile(
                title: Text(faqs[i]['question']!),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(faqs[i]['answer']!),
                  )
                ],
              ),
        );
      default:
        return Center(child: Text("No content found."));
    }


  }

  final List<Map<String, String>> mythsAndFacts = [
    {
      'myth': 'You can’t get pregnant during your period.',
      'fact': 'While less likely, pregnancy can still occur during menstruation, especially with irregular cycles.'
    },
    {
      'myth': 'Menstrual blood is impure or dirty.',
      'fact': 'Menstrual blood is a natural bodily fluid composed of blood and uterine tissue. It\'s not impure.'
    },
    {
      'myth': 'Swimming during menstruation is unsafe.',
      'fact': 'Swimming is safe during menstruation when using appropriate products like tampons or menstrual cups.'
    },
    {
      'myth': 'Exercising during your period is harmful.',
      'fact': 'Exercise can alleviate menstrual cramps and improve mood.'
    },
    {
      'myth': 'Tampons can get lost inside the body.',
      'fact': 'Tampons cannot get lost; the vaginal canal has no pathway to other parts of the body.'
    },
    {
      'myth': 'Periods should last exactly 28 days.',
      'fact': 'Menstrual cycles vary between individuals, typically ranging from 21 to 35 days.'
    },
    {
      'myth': 'Menstrual cycles synchronize among women who live together.',
      'fact': 'There\'s no scientific evidence supporting menstrual synchronization.'
    },
    {
      'myth': 'Menstruation is a sign of impurity.',
      'fact': 'Menstruation is a natural biological process and not a reflection of cleanliness or purity.'
    },
    {
      'myth': 'You shouldn’t bathe during your period.',
      'fact': 'Bathing during menstruation is hygienic and can relieve cramps.'
    },
    {
      'myth': 'Using tampons can break the hymen and affect virginity.',
      'fact': 'Virginity is a social concept, and tampon use doesn’t determine it.'
    },
    {
      'myth': 'Menstrual blood attracts sharks.',
      'fact': 'There\'s no evidence that menstruation increases shark attacks.'
    },
    {
      'myth': 'You can’t have sex during menstruation.',
      'fact': 'Sex during menstruation is a personal choice and is safe with proper hygiene.'
    },
    {
      'myth': 'Menstruation should be kept secret.',
      'fact': 'Open discussions about menstruation promote health and reduce stigma.'
    },
    {
      'myth': 'Menstrual cramps are just minor discomforts.',
      'fact': 'Some individuals experience severe cramps, known as dysmenorrhea, which can be debilitating.'
    },
    {
      'myth': 'Menstruation is a punishment or curse.',
      'fact': 'Menstruation is a natural reproductive process, not a punishment.'
    },
    {
      'myth': 'Menstruating women should not enter religious places.',
      'fact': 'This belief is rooted in cultural myths; menstruation doesn’t affect one’s spiritual purity.'
    },
    {
      'myth': 'Menstruating women shouldn’t cook or touch food.',
      'fact': 'There’s no scientific basis for this; menstruation doesn’t contaminate food.'
    },
    {
      'myth': 'Menstruating women should avoid bathing.',
      'fact': 'Regular bathing during menstruation is hygienic and beneficial.'
    },
    {
      'myth': 'Menstruating women should be isolated.',
      'fact': 'Isolation practices are harmful and based on misconceptions.'
    },
    {
      'myth': 'Menstrual blood can be used in black magic.',
      'fact': 'Such beliefs are superstitions without scientific evidence.'
    },
    {
      'myth': 'Menstruating women shouldn’t touch plants.',
      'fact': 'There’s no evidence that menstruation affects plant health.'
    },
    {
      'myth': 'Menstruating women shouldn’t touch others.',
      'fact': 'Menstruation doesn’t make someone untouchable; this is a discriminatory belief.'
    },
    {
      'myth': 'Menstruating women shouldn’t participate in daily activities.',
      'fact': 'Menstruation doesn’t impede one’s ability to perform daily tasks.'
    },
    {
      'myth': 'Menstruating women shouldn’t attend school or work.',
      'fact': 'With proper menstrual hygiene, there’s no reason to miss school or work.'
    },
    {
      'myth': 'Menstruating women shouldn’t touch water sources.',
      'fact': 'This belief is unfounded; menstruation doesn’t contaminate water.'
    },
  ]; // Already provided
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
  ]; // Already provided
  final List<String> hygieneTips = [
    'Change sanitary products every 4–6 hours.',
    'Wash the genital area with warm water and mild soap.',
    'Avoid using scented products that can cause irritation.',
    'Always wash your hands before and after changing sanitary products.',
    'Dispose of used sanitary products properly—wrap them and place in a bin.',
    'Wear breathable cotton underwear to help prevent infections.',
    'Take a shower daily to maintain overall cleanliness.',
    'Avoid douching as it can disrupt the vagina’s natural balance.',
    'Do not flush sanitary products; use designated disposal bins.',
    'Keep your pubic area clean and dry to reduce moisture build-up.',
    'Change underwear daily and keep an extra pair during your period.',
    'Trim pubic hair regularly to maintain hygiene (optional but helpful).',
    'Use unscented, pH-balanced wipes if necessary while outside.',
    'Properly clean reusable menstrual products (like cups or cloth pads) after each use.',
  ]; // Already provided
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
