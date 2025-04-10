// import 'package:flutter/material.dart';

// class PersonalInfoPage extends StatefulWidget {
//   const PersonalInfoPage({super.key});

//   @override
//   State<PersonalInfoPage> createState() => _PersonalInfoPageState();
// }

// class _PersonalInfoPageState extends State<PersonalInfoPage> {
//   double _progress = 0.3;

//   Future<void> _goToNextPage() async {
   
//     setState(() {
//       _progress = 1.0;
//     });

//     await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const SecondPage()),
//     );

//     setState(() {
//       _progress = 0.3;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(

//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               'assets/images/1.jpg',
//               fit: BoxFit.cover,
//             ),
//           ),
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.white.withOpacity(0.8),
//                     Colors.transparent,
//                   ],
//                   stops: const [0.3, 0.8],
//                 ),
//               ),
//             ),
//           ),
//           // Основной контент страницы
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Прогресс-бар (фиксированная ширина)
//                   Center(
//                     child: SizedBox(
//                       width: 180,
//                       child: LinearProgressIndicator(
//                         value: _progress,
//                         backgroundColor: Colors.grey[300],
//                         valueColor:
//                             const AlwaysStoppedAnimation<Color>(Colors.blue),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16.0),
//                   // Заголовок
//                   const Text(
//                     'Открывай новое',
//                     style: TextStyle(
//                       color: Colors.blue,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8.0),
//                   // Дополнительный текст
//                   const Text(
//                     'Немного дополнительного текста, чтобы заинтересовать пользователя и рассказать о возможностях приложения.',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const Spacer(),
//                   // Кнопка перехода на вторую страницу
//                   Center(
//                     child: Container(
//                       width: 80,
//                       height: 80,
//                       decoration: const BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.black,
//                       ),
//                       child: Center(
//                         child: InkWell(
//                           onTap: _goToNextPage,
//                           child: Container(
//                             width: 60,
//                             height: 60,
//                             decoration: const BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.blue,
//                             ),
//                             child: const Center(
//                               child: Icon(
//                                 Icons.arrow_forward,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// class SecondPage extends StatefulWidget {
//   const SecondPage({Key? key}) : super(key: key);

//   @override
//   State<SecondPage> createState() => _SecondPageState();
// }

// class _SecondPageState extends State<SecondPage> {
//   double _progress = 1.0;
//   double? _selectedSize;

//   List<double> _generateShoeSizes() {
//     List<double> sizes = [];
//     for (double size = 4; size <= 18; size += 0.5) {
//       sizes.add(size);
//     }
//     return sizes;
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<double> shoeSizes = _generateShoeSizes();
    
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: SizedBox(
//                   width: 180,
//                   child: LinearProgressIndicator(
//                     value: _progress,
//                     backgroundColor: Colors.grey[300],
//                     valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16.0),
//               const Text(
//                 'Кроссовки',
//                 style: TextStyle(
//                   color: Colors.blue,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8.0),
//               const Text(
//                 "Какой у вас размер?",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16.0),
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   childAspectRatio: 2.5,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                 ),
//                 itemCount: shoeSizes.length,
//                 itemBuilder: (context, index) {
//                   double size = shoeSizes[index];
//                   bool isSelected = _selectedSize == size;

//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedSize = size;
//                       });
//                     },
//                     child: Container(
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         color: isSelected ? Colors.black : Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: isSelected ? Colors.black : Colors.grey,
//                           width: 1.5,
//                         ),
//                       ),
//                       child: Text(
//                         size.toString(),
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: isSelected ? Colors.white : Colors.black,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 24.0),
//               Center(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
//                   ),
//                   onPressed: () {},
//                   child: const Text(
//                     'Закончить',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
