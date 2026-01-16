import 'package:flutter/material.dart';

import 'compose_mail_screen.dart';
import 'entity/drawer_item_model.dart';
import 'entity/mail_model.dart';
import 'mail_detail_screen.dart';
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final List<DrawerItemModel> drawerItems = [
    DrawerItemModel(icon: Icons.inbox, title: "Primary", badge: "256", selected: true),
    DrawerItemModel(icon: Icons.local_offer_outlined, title: "Promotions", badge: "22 new", badgeColor: Colors.green),
    DrawerItemModel(icon: Icons.people_outline, title: "Social", badge: "1 new", badgeColor: Colors.blue),
    DrawerItemModel(icon: Icons.info_outline, title: "Updates", badge: "14 new", badgeColor: Colors.orange),

    DrawerItemModel(title: "ALL LABELS", isHeader: true),

    DrawerItemModel(icon: Icons.star_border, title: "Starred"),
    DrawerItemModel(icon: Icons.snooze, title: "Snoozed"),
    DrawerItemModel(icon: Icons.label_important_outline, title: "Important", badge: "17"),
    DrawerItemModel(icon: Icons.shopping_bag_outlined, title: "Purchases", badge: "4"),
    DrawerItemModel(icon: Icons.send_outlined, title: "Sent", badge: "2"),
    DrawerItemModel(icon: Icons.schedule_outlined, title: "Scheduled"),
    DrawerItemModel(icon: Icons.outbox_outlined, title: "Outbox"),
    DrawerItemModel(icon: Icons.drafts_outlined, title: "Drafts", badge: "3"),
    DrawerItemModel(icon: Icons.mail_outline, title: "All mail", badge: "509"),
  ];

  List<MailModel> allMails = [];
  List<MailModel> filteredMails = [];

  @override
  void initState() {
    super.initState();

    allMails = [
      MailModel(sender: "Paytm", subject: "Thank you for your application", time: "9:54 PM", unread: true),
      MailModel(sender: "Neil Patel", subject: "New marketing workflows", time: "Jan 15"),
      MailModel(sender: "Daten Technology", subject: "Job | Associate Android Developer", time: "Jan 15"),
      MailModel(sender: "VistaCreate", subject: "Welcome to VistaCreate Colors", time: "Jan 15"),
    ];

    filteredMails = allMails;
  }

  /// -------------------- SEARCH --------------------

  void onSearch(String value) {
    setState(() {
      filteredMails = allMails.where((mail) {
        return mail.sender.toLowerCase().contains(value.toLowerCase()) ||
            mail.subject.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  /// -------------------- DRAWER --------------------

  Drawer buildGmailDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Gmail",
                style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.all_inbox),
              title: Text("All inboxes"),
            ),
            const Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: drawerItems.length,
                itemBuilder: (context, index) {
                  final item = drawerItems[index];

                  if (item.isHeader) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        item.title,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    );
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.selected ? Colors.grey.shade300 : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      trailing: item.badge != null
                          ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.badgeColor?.withOpacity(0.2) ?? Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.badge!,
                          style: TextStyle(fontSize: 12, color: item.badgeColor ?? Colors.black),
                        ),
                      )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildGmailDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: onSearch,
                  decoration: const InputDecoration(
                    hintText: "Search in mail",
                    border: InputBorder.none,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => showAccountBottomSheet(context),
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.teal,
                  child: Text("A", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.edit),
        label: const Text("Compose"),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ComposeMailScreen(),
            ),
          );
        },
      ),

      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filteredMails.length,
        itemBuilder: (context, index) {
          final mail = filteredMails[index];
          return ListTile(
            leading: CircleAvatar(child: Text(mail.sender[0])),
            title: Text(mail.sender, style: TextStyle(fontWeight: mail.unread ? FontWeight.bold : FontWeight.normal)),
            subtitle: Text(mail.subject, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(mail.time, style: const TextStyle(fontSize: 12)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MailDetailScreen(mail: mail)),
              );
            },
          );
        },
      ),
    );
  }

  /// -------------------- ACCOUNT SHEET --------------------

  void showAccountBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircleAvatar(radius: 30, backgroundColor: Colors.teal, child: Text("A", style: TextStyle(fontSize: 24, color: Colors.white))),
            SizedBox(height: 10),
            Text("Akash Singh", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("akash.tsscommunity@gmail.com"),
            Divider(height: 30),
            ListTile(leading: Icon(Icons.person_add), title: Text("Add another account")),
            ListTile(leading: Icon(Icons.logout), title: Text("Manage accounts")),
          ],
        ),
      ),
    );
  }
}

