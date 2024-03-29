import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';

import '../map_utils.dart';

//Directions Api
List cars = [
  {'id': 0, 'name': 'Select a Ride', 'price': 0.0},
  {'id': 1, 'name': 'UberGo', 'price': 230.0},
  {'id': 2, 'name': 'Go Sedan', 'price': 300.0},
  {'id': 3, 'name': 'UberXL', 'price': 500.0},
  {'id': 4, 'name': 'UberAuto', 'price': 140.0},
];
class MapScreen extends StatefulWidget {
  final DetailsResult? startPosition;
  final DetailsResult? endPosition;

  const MapScreen({Key? key, this.startPosition, this.endPosition})
      : super(key: key);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  int selectedCarId = 1;
  bool backButtonVisible = true;
  @override
  void initState() {
    super.initState();
    _initialPosition = const CameraPosition(
      target: LatLng(28.582062, 77.310905),
      // target: LatLng(widget.startPosition!.geometry!.location!.lat!,
      //     widget.startPosition!.geometry!.location!.lng!),
      zoom: 12,
    );
  }

  late CameraPosition _initialPosition;
  // final Completer<GoogleMapController> _controller = Completer();

  // @override
  // void initState() {
  // TODO: implement initState
  //   super.initState();
  //   _initialPosition = CameraPosition(
  //     target: LatLng(widget.startPosition!.geometry!.location!.lat!,
  //         widget.startPosition!.geometry!.location!.lng!),
  //     zoom: 14.4746,
  //   );
  // }
  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 1);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyBQfRxGF_rIGjxf9-tzMSVT5m6i8xDZK_0',
        const PointLatLng(28.582062, 77.310905),
        const PointLatLng(29.969513, 76.878281),
        travelMode: TravelMode.driving);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> _markers = {
      const Marker(
          markerId: MarkerId('1'),
          position: LatLng(28.582062, 77.310905),
          infoWindow: InfoWindow(title: 'My position')),
      const Marker(
          markerId: MarkerId('1'),
          position: LatLng(29.969513, 76.878281),
          infoWindow: InfoWindow(title: 'India Gate'))
      // Marker(
      //     markerId: MarkerId('start'),
      //     position: LatLng(widget.startPosition!.geometry!.location!.lat!,
      //         widget.startPosition!.geometry!.location!.lng!)),
      // Marker(
      //     markerId: MarkerId('end'),
      //     position: LatLng(widget.endPosition!.geometry!.location!.lat!,
      //         widget.endPosition!.geometry!.location!.lng!))
    };

    return Scaffold(
      extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return SizedBox(
                height: constraints.maxHeight / 2,
                child: GoogleMap(
                  polylines: Set<Polyline>.of(polylines.values),
                  initialCameraPosition: _initialPosition,
                  markers: Set.from(_markers),
                  onMapCreated: (GoogleMapController controller) {
                    Future.delayed(const Duration(milliseconds: 2000), () {
                      controller.animateCamera(CameraUpdate.newLatLngBounds(
                          MapUtils.boundsFromLatLngList(
                              _markers.map((loc) => loc.position).toList()),
                          1));
                      _getPolyline();
                    });
                  },
                ),
              );
            }),
            DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.5,
                maxChildSize: 1,
                snapSizes: [0.5, 1],
                snap: true,
                builder: (BuildContext context, scrollSheetController) {
                  return Container(
                      color: Colors.white,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: ClampingScrollPhysics(),
                        controller: scrollSheetController,
                        itemCount: cars.length,
                        itemBuilder: (BuildContext context, int index) {
                          final car = cars[index];
                          if (index == 0) {
                            return Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      child: Divider(
                                        thickness: 5,
                                      ),
                                    ),
                                    Text('Choose a tripe or swipe up for more')
                                  ],
                                ));
                          }
                          return Card(
                            margin: EdgeInsets.zero,
                            elevation: 0,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(10),
                              onTap: () {
                                setState(() {
                                  selectedCarId = car['id'];
                                });
                              },
                              leading: Icon(Icons.car_rental),
                              title: Text(car['name']),
                              trailing: Text(
                                car['price'].toString(),
                              ),
                              selected: selectedCarId == car['id'],
                              selectedTileColor: Colors.grey[200],
                            ),
                          );
                        },
                      ));
                }),
          ]),
    );
  }
}