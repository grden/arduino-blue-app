// import 'package:flutter/material.dart';

// import '../utils/theme/color_manager.dart';
// import 'sizedbox.dart';

// class DeviceTileWidget extends StatelessWidget {
//   const DeviceTileWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: ColorManager.grey,
//       ),
//       child: Column(
//         children: [
//           AspectRatio(
//             aspectRatio: 1,
//             child: Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           const Height(8),
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   'asdasd',
//                   style: TextStyle(
//                     color: ColorManager.white,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   overflow: TextOverflow.fade,
//                   maxLines: 1,
//                   softWrap: false,
//                 ),
//               ),
//             ],
//           ),
//           const Height(4),
//         ],
//       ),
//     );
//   }
// }
