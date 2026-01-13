import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_card.dart';
import 'package:farm_vest/core/widgets/custom_dialog.dart';

import 'package:farm_vest/features/employee/new_supervisor/widgets/alert_dialog.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/left_strip_alert_card.dart';

import 'package:farm_vest/features/employee/new_supervisor/widgets/check_list.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/quick_actions_cards.dart';
import 'package:farm_vest/features/employee/presentation/widgets/employee_dashboard_card.dart';
import 'package:flutter/material.dart';
class NewSupervisorDashboard extends StatefulWidget {
  const NewSupervisorDashboard({super.key});

  @override
  State<NewSupervisorDashboard> createState() =>   _NewSupervisorDashboardState();
}

class _NewSupervisorDashboardState extends State<NewSupervisorDashboard> {
  
  bool morningFeed = true;
bool waterCleaning = true;
bool shedWash = false;
bool eveningMilking = false;

  @override
  Widget build(BuildContext context) {
     final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.width * 0.18,
        centerTitle: false,
       

title: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      "Hello, Supervisor",
      style: TextStyle(
        fontSize: screenWidth * 0.05, 
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height: screenWidth * 0.01),
    Text(
      "Farm: Kurnool Main",
      style: TextStyle(
        fontSize: screenWidth * 0.022,
        color: AppTheme.black,
      ),
    ),
  ],
),

        
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [  
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                CustomCard(
                  color: AppTheme.lightPrimary,
                  type: DashboardCardType.priority,  
                  onTap: () {},
                  child: _leftStripAlertCard(
                    icon: Icons.pets,stripColor: AppTheme.primary,subtitle: '142',title: 'Total Animals' ),
                ),
                 CustomCard(
                  color: AppTheme.errorRed,
                  type: DashboardCardType.priority,
                  onTap: () {},
                  child:_leftStripAlertCard(icon: Icons.water_drop,stripColor: AppTheme.errorRed,subtitle: '0',title: 'Milk Today')
                    ),
                 CustomCard(
                  color:AppTheme.errorRed ,
                  type: DashboardCardType.priority,                 
                  onTap: () {},
                  child: _leftStripAlertCard(icon: Icons.warning,stripColor: AppTheme.errorRed,subtitle: '5',title: 'Active Issues')
                  ),
                 CustomCard(
                  color: AppTheme.successGreen,
                  type: DashboardCardType.priority,                           
                  onTap: () {},        
                  child:_leftStripAlertCard(icon: Icons.move_down,stripColor: AppTheme.successGreen,subtitle: '1',title: 'Transfers')
                                 
                  ),
                   ],
            ),

            const SizedBox(height: 20),
Text(
  "Quick Actions",
  style: TextStyle(
    fontSize: MediaQuery.of(context).size.width * 0.045,
    fontWeight: FontWeight.bold,
  ),
),

            // const Text(
            //   "Quick Actions",
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
//             Text(
//   "Quick Actions",
//   style: TextStyle(
//     fontSize: rs(context, 0.045),
//     fontWeight: FontWeight.bold,
//   ),
// ),


            const SizedBox(height: 12),
           GridView.count(
           crossAxisCount: 2,
           crossAxisSpacing: 14,
           mainAxisSpacing: 12,
           childAspectRatio: 1.2,
           shrinkWrap: true,
           physics: const NeverScrollableScrollPhysics(),
           children: [
            CustomCard(
            type: DashboardCardType.stats,     
            onTap: () {
            showQuickActionDialog(
            context: context,
            type: QuickActionType.onboardAnimal,
           );
           },
          child: _QuickActionCard(icon: Icons.add, label: 'Onboard Animal', onTap: () {  }, iconColor: AppTheme.darkPrimary,),
           ),
          CustomCard(
          type: DashboardCardType.stats, 
         onTap: () {
            showQuickActionDialog(
          context: context,
          type: QuickActionType.milkEntry,
        );
         },
          child: _QuickActionCard(label: 'Milk Entry', icon:Icons.water_drop, onTap: () {  }, iconColor: AppTheme.darkSecondary),
          ),
          CustomCard(
       type: DashboardCardType.stats,
          onTap: () {
            showQuickActionDialog(
          context: context,
          type: QuickActionType.healthTicket,
        );
          },
         child:_QuickActionCard(label: 'Health ticket', icon: Icons.medical_services, onTap: () {  }, iconColor: AppTheme.darkSecondary) ,
           ),
          CustomCard(
           type: DashboardCardType.stats,   
           onTap: () {
           showQuickActionDialog(
          context: context,
          type: QuickActionType.transferRequest,
        );
              },
             child:_QuickActionCard(icon: Icons.compare_arrows, label: 'Transefer Tickets', onTap: () {  }, iconColor: AppTheme.slate) ,
                  ),
        CustomCard(
       type: DashboardCardType.stats,   
           onTap: () {
          showQuickActionDialog(
          context: context,
          type: QuickActionType.locateAnimal,
        );
          },
            child: _QuickActionCard(label: 'Locate Animal', icon: Icons.search, onTap: () {  }, iconColor: AppTheme.darkSecondary),
                  ),
        ],
       ),
            const SizedBox(height: 20),

            
           Container(
            padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
             color: Colors.white,
              borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Daily Checklist",
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.045, // 4.5% of width
          fontWeight: FontWeight.bold,
        ),),
      
   SizedBox(height: MediaQuery.of(context).size.width * 0.03),
      const SizedBox(height: 12),

      CustomCheckboxTile(
        title: 'Morning Feed Check',
        value: morningFeed,
        onChanged: (val) {
          setState(() => morningFeed = val!);
        },
      ),
      CustomCheckboxTile(
        title: 'Water Troughs Cleaning',
        value: waterCleaning,
        onChanged: (val) {
          setState(() => waterCleaning = val!);
        },
      ),
      CustomCheckboxTile(
        title: 'Afternoon Shed Wash',
        value: shedWash,
        onChanged: (val) {
          setState(() => shedWash = val!);
        },
      ),
      CustomCheckboxTile(
        title: 'Evening Milking Count',
        value: eveningMilking,
        onChanged: (val) {
          setState(() => eveningMilking = val!);
        },
      ),
    ],
  ),
)
          ],
        ),
      ),
    );

  }
  Widget _leftStripAlertCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required Color stripColor,
}) {
  final screenWidth = MediaQuery.of(context).size.width;


  final iconSize = screenWidth * 0.08; 
  final paddingSize = screenWidth * 0.03; 
  final subtitleFontSize = screenWidth * 0.040; 
  final titleFontSize = screenWidth * 0.035; 
  final spacing = screenWidth * 0.02; 

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    
    children: [
      Container(
        decoration: BoxDecoration(
          color: stripColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(paddingSize),
        child: Icon(icon, color: stripColor, size: iconSize),
      ),
      SizedBox(width: spacing * 2),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
       
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                fontSize: subtitleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing),
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                color: Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ],
  );
}

  

Widget _QuickActionCard({
 required String label,
 required IconData icon,
 required VoidCallback onTap,
 required Color iconColor

}){
   final screenWidth = MediaQuery.of(context).size.width;
  final iconSize = screenWidth * 0.08; 
  final textSize = screenWidth * 0.035;
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
     
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.2), 
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    
      const SizedBox(height: 12),
    
     
      Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize:textSize,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),


    ],
  );
}
}


