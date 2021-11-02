import 'package:flutter/material.dart';
import 'package:jallaliefern_taking_orders_app/services/api_service.dart';
import 'package:jallaliefern_taking_orders_app/utils/service_locator.dart';
import 'package:jallaliefern_taking_orders_app/widgets/order_tile.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return List<Widget>.empty();
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return Container();
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
        future: locator<ApiService>().getSearchOrders(query),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData)
            return CircularProgressIndicator();
          else
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return OrderTile(
                    order: snapshot.data[index], parentRefresh: () async {});
              },
            );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return Container();
  }
}
