
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final Map<String, bool> tasks = {
    "Vaccination : Buffalo #A1": true,
    "Clean Shed": false,
    "Health": false,
  };
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'FARM VEST',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
        height: 1,
        color: AppTheme.black, 
        ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.black),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _sectionHeader('Alerts', actionText: 'See All'),

            const SizedBox(height: 12),

            
            _alertCard(
              color: Colors.orange,
              iconAsset: 'assets/icons/new_heat.png',
              //iconAsset: 'assets/icons/heat_cycle.png',
              //icon: Icons.calendar_today,
              title: 'Heat Cycle Today',
              subtitle: 'Buffalo #412 is in heat window',
              buttonText: 'View Buffalos',
              onTap: () {

              },
            ),

            const SizedBox(height: 12),

            /// Health Issue Alert
            _alertCard(
              color: Colors.redAccent,
              
              iconAsset: 'assets/icons/heart.png',
            
             // icon: Icons.favorite,
              title: 'Health Issue',
              subtitle: 'Buffalo #408 has fever',
              buttonText: 'Send to doctor',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            /// Doctor Updates
            _sectionHeader(
              'Doctor Updates',
              chipText: 'New',
            ),

            const SizedBox(height: 12),

            _doctorCard(),

            const SizedBox(height: 24),

          
            const Text(
              "Today's Summary",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _summaryCard('23L', 'Milk Units'),
                _summaryCard('60', 'Total Buffalos'),
                _summaryCard('9', 'Heat Today'),
              ],
            ),

            const SizedBox(height: 24),

          
            const Text(
              "Pending Tasks",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _pendingTasksSection(),

          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  

  Widget _sectionHeader(String title,
      {String? actionText, String? chipText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold,color: AppTheme.black),
        ),
        if (actionText != null)
          Text(
            actionText,
            style: const TextStyle(color: AppTheme.successGreen),
          ),
        if (chipText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              chipText,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
      ],
    );
  }
  Widget _alertCard({
  required Color color,
  
   IconData? icon,
   String? iconAsset,
  
  required String title,
  required String subtitle,
  required String buttonText,
  required VoidCallback onTap,
}) {
  return Container(
    decoration: BoxDecoration(
      color: AppTheme.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.25),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          Container(
            width: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
             child: iconAsset != null
              ? Padding(
             padding: const EdgeInsets.all(8), 
             child:
              Image.asset(
             iconAsset,
            
             color: AppTheme.white,  
             ),
               )
                  
                  : Icon(
                      icon,
                      color: AppTheme.white,
                      size: 20,
                    ),
 
                     ),

          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,                     
          overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                     maxLines: 2,                     
          overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: AppTheme.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _doctorCard() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.indigo,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        
        const CircleAvatar(
          radius: 40,
          backgroundColor: AppTheme.white,
          backgroundImage: AssetImage('assets/images/doctor.png'),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Text(
                'Dr. Varma',
                style: TextStyle(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(
  height: 26,
  child: OutlinedButton(
    onPressed: () {
      
    },
    style: OutlinedButton.styleFrom(
      backgroundColor: AppTheme.white,
      foregroundColor: Colors.indigo,
      side: const BorderSide(color: Colors.white70),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      textStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    child: const Text('Buffalo #45'),
  ),
),

              
              
              
              SizedBox(height: 8),
              Text(
                'Your prescription is ready',
                    maxLines: 2,                     
          overflow: TextOverflow.ellipsis, 
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              
              ),
            ],
          ),
        ),

        
        SizedBox(
          height: 32,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor:AppTheme.white,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () {},
            child: const Text('View prescription'),
          ),
        ),
      ],
    ),
  );
}

 Widget _summaryCard(String value, String label) {
  return Expanded(
    child: Column(
      children: [
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}

Widget _taskRow(String title, bool completed, ValueChanged<bool?> onChanged) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.black,
              ),
            ),
          ),

       
          Checkbox(
            value: completed,
            onChanged: onChanged, 
            activeColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),

     
      const SizedBox(height: 10),
      Container(
        height: 1.2,
        color: Colors.green,
      ),
      const SizedBox(height: 16),
    ],
  );
}
Widget _pendingTasksSection() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.green.shade300, width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pending Tasks",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 16),

      
        ...tasks.keys.map((taskTitle) {
          return _taskRow(
            taskTitle,
            tasks[taskTitle]!,
            (newValue) {
              setState(() {
                tasks[taskTitle] = newValue ?? false;
              });
            },
            
          );
        }).toList(),
      ],
    ),
     
  );
}
}
class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int selectedIndex = 0;

  final icons = [
    Icons.home,
    Icons.pets,
    Icons.notifications,
    Icons.bar_chart,
    Icons.more_horiz,
  ];

  final labels = [
    'Home',
    'Buffalo',
    'Alerts',
    'Stats',
    'More',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final isActive = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() => selectedIndex = index);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icons[index],
                  color: isActive ? Colors.blue : Colors.grey,
                ),
                const SizedBox(height: 4),
                Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive ? Colors.blue : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  width: isActive ? 18 : 0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
