

import 'package:farm_vest/core/widgets/custom_Textfield.dart';
import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/core/widgets/custom_dialog.dart';
import 'package:farm_vest/features/employee/new_supervisor/screens/new_supervisor_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

enum QuickActionType {
  onboardAnimal,
  milkEntry,
  healthTicket,
  transferRequest,
  locateAnimal,
 }
 const Map<QuickActionType, String> buttonLabels = {
  QuickActionType.onboardAnimal: 'Submit',
  QuickActionType.milkEntry: 'Submit Entry',
  QuickActionType.healthTicket: 'Raise Critical Ticket',
  QuickActionType.transferRequest: 'Submit',
  QuickActionType.locateAnimal: 'Search',
};
const Map<QuickActionType, Color> buttonBackgroundColors = {
  QuickActionType.onboardAnimal: AppTheme.lightPrimary,
  QuickActionType.milkEntry: AppTheme.lightPrimary,
  QuickActionType.healthTicket: Color.fromARGB(255, 244, 81, 69),
  QuickActionType.transferRequest: AppTheme.slate,
  QuickActionType.locateAnimal: AppTheme.lightPrimary,
};
 Future<void> showQuickActionDialog({
  required BuildContext context,
  required QuickActionType type,
}) async {
  String selectedShed = '';
  Map<String, dynamic>? locateResult;
  String selectedPriority = 'Critical';
  int selectedSlot=5;

  
final rfidController = TextEditingController();
final shedController = TextEditingController();
final breedController = TextEditingController();
final quantityController = TextEditingController();
final buffaloIdController = TextEditingController();
final reasonController = TextEditingController();
final idController=TextEditingController();
final requestController=TextEditingController();
final rowController=TextEditingController();


  

  final Map<String, Map<String, String>> animalData = {
    'R': {
      'shed': 'Shed C',
      'row': 'Row-04',
      'slot': 'Slot-12',
      'health': 'Healthy',
      'investor':'aparna'
    },
    'A': {
      'shed': 'Shed B',
      'row': 'Row-01',
      'slot': 'Slot-03',
      'health': 'Sick',
      'investor':'pradeep'
    },
  };

  String dialogTitle = '';
  bool showShedButtons = false;
  bool showImagePicker = false;
  String successMessage = '';
  //List<CustomTextField> fields = [];
  List<Widget> fields = [];
  List<TextEditingController> controllers=[];



  switch (type) {
    case QuickActionType.onboardAnimal:
      dialogTitle ='Onboard Animal';
      showImagePicker = true;
      successMessage = 'Animal onboarded successfully!';
     
      controllers = [
    shedController,
    breedController,
    rowController,
  ];
      fields = [
  helperTextField(
    helperText: 'Please enter shed number',
    field: CustomTextField(
      hint: 'Enter shed',
      controller: shedController,
    ),
  ),
  helperTextField(
    helperText: 'Please enter breed & age',
    field: CustomTextField(
      hint: 'Enter breed & age',
      controller: breedController,
    ),
  ),
  helperTextField(
    helperText: 'Please enter row number',
    field: CustomTextField(
      hint: 'Enter Row No',
      controller: rowController,
    ),
  ),
];

      
      break;

    case QuickActionType.milkEntry:
      dialogTitle = 'Milk Entry';
      showShedButtons = true;
      successMessage = 'Milk data recorded successfully!';
      controllers=[quantityController];
         fields = [
  helperTextField(
    helperText: 'Please enter quantity in liters',
    field: CustomTextField(
      hint: 'Enter quantity',
      controller: quantityController,
    ),
  ),
];
      
      
      break;

  
  case QuickActionType.healthTicket:
  dialogTitle = 'Report Health Ticket';
  successMessage = 'Health ticket raised successfully!';

  controllers = [
    reasonController,
    buffaloIdController,
  ];

  fields = [
    helperTextField(
      helperText: 'Please enter Buffalo ID / RFID',
      field: CustomTextField(
        hint: 'Buffalo ID / RFID',
        controller: reasonController,
      ),
    ),

    helperTextField(
      helperText: 'Please describe the issue',
      field: CustomTextField(
        hint: 'Enter issue',
        controller: buffaloIdController,
      ),
    ),

    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Priority',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.grey1,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedPriority,
          items: const [
            DropdownMenuItem(value: 'Critical', child: Text('Critical')),
            DropdownMenuItem(value: 'High', child: Text('High')),
            DropdownMenuItem(value: 'Medium', child: Text('Medium')),
            DropdownMenuItem(value: 'Low', child: Text('Low')),
          ],
          onChanged: (value) {
            if (value != null) {
              selectedPriority = value;
            }
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    ),
  ];
  break;

     
      
      

    case QuickActionType.transferRequest:
      dialogTitle = 'Transfer Request';
      showShedButtons = true;
      successMessage = 'Transfer request submitted!';
      
     
      controllers=[
        idController,
        requestController
      ];
      fields = [
  helperTextField(
    helperText: 'Please enter ID',
    field: CustomTextField(
      hint: 'Enter buffalo ID/RFID',
      controller: idController,
    ),
  ),
  helperTextField(
    helperText: 'Please enter reason ',
    field: CustomTextField(
      hint: 'Enter reason',
      controller: requestController,
    ),
  ),];
      break;

    case QuickActionType.locateAnimal:
      dialogTitle = 'Locate Buffalo Position';
      break;
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
          return CustomDialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dialogTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

              

                SingleChildScrollView(
                  child: Column(
                    children: [
                      if (type != QuickActionType.locateAnimal)
                        ...fields.map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: f,
                          ),
                        ),

                      if (showImagePicker)
                        DottedBorder(
                          radius: const Radius.circular(8),
                          color: AppTheme.lightPrimary,
                          dashPattern: const [6, 4],
                          child: const SizedBox(
                            height: 60,
                            child: Center(

                               child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                Icon(Icons.upload_file, color: AppTheme.lightPrimary),
                                SizedBox(width: 8),
                               Text(
                               'Upload Buffalo Image',
                                 style: TextStyle(color:AppTheme.lightPrimary, fontSize: 14),
                                ),
                              ],
                            ),
                            ),
                          ),
                        ),

       

                     
                           if (showShedButtons) ...[
                            const SizedBox(height: 12),
 
                            Text(
                             'Select Target Shed:',
                              style: TextStyle(
                              fontSize: screenWidth * 0.04, 
                              fontWeight: FontWeight.w600,
                              color: AppTheme.grey1
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                              children: ['Shed A', 'Shed B', 'Shed C'].map((shed) {
                                final selected = selectedShed == shed;
                                return Expanded(
                                child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: CustomActionButton(
                                  child: Text(shed),
                                   height: 40,
                                     variant: selected ? ButtonVariant.filled : ButtonVariant.outlined,
                                    color: AppTheme.darkSecondary,
                                     onPressed: () => setStateDialog(() => selectedShed = shed),
                                       ),
                                     ),
                                    );
                                    }).toList(),
                                  ),
                                 ],


                    
                      

if (type == QuickActionType.locateAnimal) ...[
  const SizedBox(height: 12),

  Row(
    children: [
      Expanded(
        child: CustomTextField(
          hint: 'Search Animal',
          controller: idController,
        ),
      ),
      const SizedBox(width: 8),
     
      CustomActionButton(
  width: 48,
  height: 48,
  color: AppTheme.lightPrimary,
  onPressed: () {
    final key = idController.text.trim();
    if (key.isEmpty || !animalData.containsKey(key)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buffalo not found')),
      );
      return;
    }
    setStateDialog(() {
      locateResult = animalData[key];
      
      selectedSlot = int.parse(
        locateResult!['row'].toString().replaceAll('Row-', ''),
      );
    });
  },
  
  child: Center(
    child: const Icon(
      Icons.search,
      color: AppTheme.white,
    ),
  ),
)

    ],
  ),

  const SizedBox(height: 16),

  
  if (locateResult != null)
  Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 12),
    color: AppTheme.white,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon, ID, Investor
          Row(
            children: [
              const CircleAvatar(
                backgroundColor:AppTheme.lightPrimary,
                child: Icon(Icons.pets, color:AppTheme.white),
              ),
              const SizedBox(width: 8),
              Text(
                '#BUF-889',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Investor',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.grey1),
                  ),
                  Text(
                    locateResult!['investor'] ?? '',
                    style: const TextStyle(
                        fontSize: 14, color: AppTheme.grey1),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            'Current Location: ${locateResult!['shed']}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          // Visual Parking Map Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.grey1),
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.white,
            ),
            child: Column(
              children: [
                Text(
                  locateResult!['row'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(6, (index) {
                    final boxNumber = index + 1;
                    final isRowBox = boxNumber ==
                        selectedSlot; // highlight selected

                    return Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isRowBox
                            ? AppTheme.lightPrimary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.grey1),
                      ),
                      child: Text(
                        '$boxNumber',
                        style: TextStyle(
                          color: isRowBox
                              ? AppTheme.white
                              : AppTheme.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Visual Parking Map',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.grey1),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),

],




                    
                     
                      //  if (type != QuickActionType.locateAnimal)
                        Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: CustomActionButton(
                       
                        child:Text(buttonLabels[type]!,style: TextStyle(color: AppTheme.white),),
                        
                       height: 48,
                       color: buttonBackgroundColors[type]!,
                       
                       onPressed: () async {
                       if (showShedButtons && selectedShed.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select a shed')),
                       );
                      return;
                      }
                     
                      for (final controller in controllers) {
  if (controller.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all fields')),
    );
    return;
  }
}



                           Navigator.of(context).pop();
        


                          showSuccessDialog(context, successMessage);
                           },
                           ),
                        ),

                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  
}
Widget helperTextField({
  required String helperText,
  required CustomTextField field,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        helperText,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppTheme.grey1,
        ),
      ),
      const SizedBox(height: 6),
      field,
    ],
  );
}








