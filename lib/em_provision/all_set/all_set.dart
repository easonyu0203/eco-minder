import 'package:eco_minder_flutter_app/em_provision/em_provision_state.dart';
import 'package:eco_minder_flutter_app/services/FireAuth.dart';
import 'package:eco_minder_flutter_app/services/FireStore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllSetPage extends StatefulWidget {
  final Function(BuildContext context) toNext;
  const AllSetPage({super.key, required this.toNext});

  @override
  State<AllSetPage> createState() => _AllSetPageState();
}

class _AllSetPageState extends State<AllSetPage> {
  @override
  void initState() {
    super.initState();

    EMProvisionState state = context.read<EMProvisionState>();
    state.sendViaBluetooth("done");

    // add EcoMinder for user
    FireStoreService().addEcoMinder(FireAuthService().user!.uid,
        context.read<EMProvisionState>().eco_minder_id!);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("All Set!"),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.toNext(context);
            },
            child: Text("Start your journey with EcoMinder!"),
          ),
        ],
      ),
    );
  }
}
