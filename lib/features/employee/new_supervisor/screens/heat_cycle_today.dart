import 'package:flutter/material.dart';
class BuffaloAlertScreen extends StatefulWidget {
  const BuffaloAlertScreen({super.key});

  @override
  State<BuffaloAlertScreen> createState() => _BuffaloAlertScreenState();
}

class _BuffaloAlertScreenState extends State<BuffaloAlertScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}



// import 'package:farm_vest/features/employee/new_supervisor/models/buffalo_aleart_model.dart';
// import 'package:farm_vest/features/employee/new_supervisor/widgets/textfileds.dart';
// import 'package:flutter/material.dart';

// class BuffaloAlertScreen extends StatefulWidget {
//   const BuffaloAlertScreen({super.key});

//   @override
//   State<BuffaloAlertScreen> createState() => _BuffaloAlertScreenState();
// }

// class _BuffaloAlertScreenState extends State<BuffaloAlertScreen> {
//   late BuffaloDataControllers controllers;

// @override
// void initState(){
//   super.initState();
//   controllers=BuffaloDataControllers();
// }
// @override
//   void dispose() {
//     controllers.dispose();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6FA),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _searchBar(),
//               const SizedBox(height: 12),
//               _actionButtons(),
//               const SizedBox(height: 16),
//             Column(
//               children: [
//                 _buffaloImage(),
//                 const SizedBox(height: 16),
              
            
//              infoRowWithColumns(
//              label: 'AGE',
//              controller: controllers.ageController,
//                rightLabel: 'SHED',
//                rightValue: '2',
//                ),

//             infoRowWithColumns(
//               label: 'WEIGHT',
//              controller: controllers.weightController,
//             rightLabel: 'ROW',
//               rightValue: '3',
//               ),

//             infoRowWithColumns(
//                label: 'LOCATION',
//             controller: controllers.locationController,
//            ),

//           infoRowWithColumns(
//            label: 'PREGNANCY',
//            controller: controllers.pregnancyController,
//            showEditButton: true,
//            editButtonColor: Colors.red,
//            editButtonText: 'Edit Info',
//             ),]),

//               const SizedBox(height: 16),
//               _milkProduction(context),
//               const SizedBox(height: 16),
//               _heatCycle(context),
//               const SizedBox(height: 16),
//               _doctorSection(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _searchBar() {
//     return Row(
//       children: [
//         Expanded(
//           child: 
//           commonTextField(
//             controller: controllers.searchBarController,
//             hintText: 'Enter Buffalo ID', onChanged: (String value) {  },
//           ),
          
//         ),
//         const SizedBox(width: 8),
//         Container(
//           height: 48,
//           width: 48,
//           decoration: BoxDecoration(
//            // color: Colors.green,
//            color: Color(0xFF4CAF50),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: IconButton(onPressed: (){}, icon: const Icon(Icons.search, color: Colors.white)),
//           // child: const Icon(Icons.search, color: Colors.white),
//         ),
//       ],
//     );
//   }

//   Widget _actionButtons() {
//     return 
//     Row(
//       children: [
//         Expanded(child: _smallButton( 'Mark Heat',Icons.local_fire_department, Colors.red)),
       
//         const SizedBox(width: 8),
//        Expanded(child: _smallButton('Add symptoms', Icons.favorite, Colors.black)),
     
//       ],
//     );
//   }

//   Widget _smallButton(String text, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: color),
//           const SizedBox(width: 4),
//           Text(text, style: const TextStyle(fontSize: 10)),
//         ],
//       ),
//     );
//   }

//   Widget infoRowWithColumns({
//   required String label,
//   required TextEditingController controller,
//   String rightLabel = '',
//   String rightValue = '',
//   bool showEditButton = false,
//   Color editButtonColor = Colors.green,
//   String editButtonText = 'Edit',
// }) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 6),
//     child:
//      Row(
//       children: [
        
  
//         SizedBox(
//           width: 80,
//           child: Text(
//             label,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
        
        
//         SizedBox(
//           width: 120,
//           child: commonTextField(
//             controller: controller,
//             hintText: 'Enter $label', onChanged: (String value) {  },
//           ),
//         ),
//         if (rightLabel.isNotEmpty) ...[
//           const SizedBox(width: 8),
//           Expanded(child: 
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
//             decoration: BoxDecoration(
//               color: Colors.green,
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Text(
//               '$rightLabel : $rightValue',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 11,
//               ),
//             ),
//           ),)
//         ],

//         SizedBox(width: 10,),
//         if (showEditButton) ...[
//           const SizedBox(width: 8),
//         Align(
//             alignment: Alignment.bottomRight,
//             child: _editButton(
//               buttonText: editButtonText,
//               color: editButtonColor,
//             ),
//           ),
//         ],
//       ],
//     ),
//   );
// }


//   Widget _editButton({ required String buttonText, required Color color }) {
    
//     return ElevatedButton(
//       onPressed: () {},
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//       ),
//       child: Text(
//         buttonText,
//         style: const TextStyle(color: Colors.white, fontSize: 12),
//       ),
//     );
    
//   }

//   Widget _milkProduction(context) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: MediaQuery.of(context).size.width,
            
//             padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.green,
//               //borderRadius: BorderRadius.circular(20),
//               borderRadius: BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12)),
//             ),
//             child: const Text(  'Milk Production',
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                
//           ),
//           SizedBox(height: 10,),
          

         
//           Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 12),
//   child: Column(
//     children: [
//       Row(
//         children: [
//           const SizedBox(
//             width: 110,
//             child: Text(
//               'Evening milk :',
//               style: TextStyle(fontSize: 14),
//             ),
//           ),
//           SizedBox(
//             width: 40,
//             child: commonTextField(
//               controller: controllers.eveningMilkController,
//               hintText: 'L',
//               onChanged: (_) => setState(() {
//                 controllers.calculateTotalMilk();
//               }),
//             ),
//           ),
//           const SizedBox(width: 6),
//           const Text('L'),
//           SizedBox(width: 5,),
//           const SizedBox(
//             width: 110,
//             child: Text(
//               'Morning milk :',
//               style: TextStyle(fontSize: 14),
//             ),
//           ),
//           SizedBox(
//             width: 40,
//             child: commonTextField(
//               controller: controllers.morningMilkController,
//               hintText: 'L',
//               onChanged: (_) => setState(() {
//                 controllers.calculateTotalMilk();
//               }),
//             ),
//           ),
//           const SizedBox(width: 6),
//         const Text('L'),
//         ],
//       ),

//       const SizedBox(height: 10),

      
//     ],
//   ),
// ),
//         const SizedBox(height: 10),
//         Row(
//         children: [
//           Padding(padding: EdgeInsets.only(left: 12,top: 12),child:
//           const SizedBox(
//             width: 110,
//             child: Text(
//               'Todays  milk :',
//               style: TextStyle(fontSize: 14),
//             ),
//           ),),
//           SizedBox(
//             width: 40,
//             child: commonTextField(
//               controller: controllers.totalMilkController,
//               hintText: 'L',
//               readOnly:true,
//               onChanged: (_) => setState(() {
//                 controllers.calculateTotalMilk();
//               }),
//             ),
//           ),
//           const SizedBox(width: 6),
//           const Text('L'),
//           SizedBox(width: 50,),        
//         ],
//       ),
//       Padding(padding: EdgeInsets.all(12),child: 
//         Align(
//           alignment: Alignment.centerRight,
//             child: _editButton(buttonText: 'Edit info', color: Colors.red),
//           ),),
//         ],
//       ),
//     );
//   }
//   Widget _heatCycle(context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child:
//     Column(
//       children: [
        
//         Container(
//           width: MediaQuery.of( context).size.width,
//           decoration: BoxDecoration(
//             color: Colors.orange,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(12),
//               topRight: Radius.circular(12),
//             ),
//           ),
//           child: const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             child: Text('Heat Cycle',
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//           ),
//         ),

//         const SizedBox(height: 10),
//         Row(          
//         children: [
//           Expanded(
//             child: Row(
//               children: [          
//           Padding(padding: EdgeInsets.all(12),
//           child:
//           const SizedBox(
//             width: 100,
//             child: Text(
//               'Last :',
//               style: TextStyle(fontSize: 14),
//             ),
//           ),),
//           SizedBox(
//             width: 40,
//             child: commonTextField(
//               controller: controllers.lastHeatController,
//               hintText: 'L',
//               onChanged: (_) => setState(() {}),
//             ),
//           ),
//           const SizedBox(width: 6),
//           const Text('L'),
        
//         ],))]
//       ),
//       SizedBox(height: 10,),
//       Padding(padding: EdgeInsets.all(12),child: 
//       Row(      
//         children: [        
//           Padding(padding: EdgeInsets.only(left: 4,top: 12),child:
//           const SizedBox(
//             width: 100,
//             child: Text(
//               'Cycle Count :',
//               style: TextStyle(fontSize: 14),
//             ),
//           ),),
//           SizedBox(
//             width: 40,
//             child: commonTextField(
//               controller: controllers.cycleCountController,
//               hintText: 'L',
//               onChanged: (_) => setState(() {}),
//             ),
//           ),
//           const SizedBox(width: 6),
//           const Text('L'),
//           SizedBox(width: 50,),
//           //_editButton(buttonText: 'Mark Heat', color: Colors.orange)
//           Align(
//             alignment: Alignment.bottomRight,
//             child: _editButton(
//               buttonText: 'Mark Heat', 
//               color: Colors.orange
//             ),
//           ),
//           ],
//           ))
//         ],
//       ),    
//     );
//   }

//   Widget _doctorSection(context) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children:  [  
//           Text('Doctor name :', style: TextStyle(fontWeight: FontWeight.bold)),
//           SizedBox(height: 12),
//           Row(
//             children: [
//               Container(
//                 height: 60,
//                 width: 60,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(12),
//                 )
//               ),
//               SizedBox(width: 16),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                    Text('Date :',),
//           Text('Time :'),
//           Text('Buffalo ID :'),
//                 ],
//               )    
//             ],
//           ),
//           Container(
//             width: MediaQuery.of(context).size.width,
//             alignment: Alignment.center,
//             margin: const EdgeInsets.only(top: 12),
//             //padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.green,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: const Text('Contact Doctor',
//                 style: TextStyle(color: Colors.white, fontSize: 20)),
//           )
//         ],
//       ),
//     );
//   }
//   Widget _buffaloImage() {
//   return ClipRRect(
//     borderRadius: BorderRadius.circular(16),
//     child: Image.asset(
//       'assets/images/buffalo.png',
//       height: 180,
//       width: double.infinity,
//       fit: BoxFit.cover,
//     ),
//   );
// }

// }
