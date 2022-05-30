library empaticae4;

import 'dart:async';

import 'package:flutter/services.dart';

part 'empatica_status_events.dart';
part 'empatica_data_events.dart';

class EmpaticaPlugin {
  static const String methodChannelName = 'empatica.io/empatica_methodChannel';
  static const String statusEventSinkName =
      "empatica.io/empatica_statusEventSink";
  static const String dataEventSinkName = "empatica.io/empatica_dataEventSink";

  final MethodChannel _methodChannel = const MethodChannel(methodChannelName);
  final EventChannel _statusEventChannel =
      const EventChannel(statusEventSinkName);
  final EventChannel _dataEventChannel = const EventChannel(dataEventSinkName);

  Stream<EmpaticaStatusEvent>? _statusEventSink;
  Stream<EmpaticaDataEvent>? _dataEventSink;

  /// The [EmpaStatus] of the device. For example, ready, connected, disconnected, etc.
  EmpaStatus status = EmpaStatus.initial;
  // ------------    METHOD HANDLERS --------------------


  /// Initiates a connection to the Empatica backend using an API key given by Empatica.
  ///
  /// The [EmpaStatus.ready] status will be thrown on the [statusEventSink] when
  /// the authentication is accepted.
  Future<void> authenticateWithAPIKey(String key) async {
    await _methodChannel.invokeMethod('authenticateWithAPIKey', {'key': key});
  }

  /// Starts scanning for Empatica devices once the [EmpaStatus.ready] is thrown.
  ///
  /// Once a device is found, the [statusEventSink] will throw a
  /// [DiscoverDevice] event. This event contains the device's serial number,
  /// along with a label with the MAC address and the RSSI connection strength.
  Future<void> startScanning() async {
    await _methodChannel.invokeMethod('startScanning');
  }

  /// Connect with Empatica connect user. Unknown how this works exactly.
  Future<void> authenticateWithConnectUser() async {
    await _methodChannel.invokeMethod('authenticateWithConnectUser');
  }

  /// Stops the scanning for devices started by [startScanning]. Suitably call this whenever one has connected
  /// to the device using [connectDevice].
  Future<void> stopScanning() async {
    await _methodChannel.invokeMethod('stopScanning');
  }

  /// Connects to the device with the serial number. Suitably call this whenever
  /// one has found a device from [startScanning]
  Future<void> connectDevice(String serialNumber) async {
    await _methodChannel
        .invokeMethod('connectDevice', {'serialNumber': serialNumber});
  }

  Future<void> disconnect() async {
    await _methodChannel.invokeMethod('disconnect');
  }

  // ------------    STREAM HANDLERS --------------------

  Stream<EmpaticaStatusEvent>? get statusEventSink {
    _statusEventSink = _statusEventChannel
        .receiveBroadcastStream()
        .map((event) => EmpaticaStatusEvent.fromMap(event));

    _statusEventSink?.listen((event) {
      if (event.runtimeType == UpdateStatus) {
        status = (event as UpdateStatus).status;
      }
    });
    return _statusEventSink;
  }

  Stream<EmpaticaDataEvent>? get dataEventSink {
    _dataEventSink = _dataEventChannel
        .receiveBroadcastStream()
        .map((event) => EmpaticaDataEvent.fromMap(event));
    return _dataEventSink;
  }
}
