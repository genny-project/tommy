///
//  Generated code. Do not modify.
//  source: stream.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'stream.pb.dart' as $0;
export 'stream.pb.dart';

class StreamClient extends $grpc.Client {
  static final _$connect = $grpc.ClientMethod<$0.Item, $0.Item>(
      '/stream.Stream/Connect',
      ($0.Item value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Item.fromBuffer(value));
  static final _$sink = $grpc.ClientMethod<$0.Item, $0.Empty>(
      '/stream.Stream/sink',
      ($0.Item value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$heartbeat = $grpc.ClientMethod<$0.Item, $0.Empty>(
      '/stream.Stream/Heartbeat',
      ($0.Item value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));

  StreamClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseStream<$0.Item> connect($0.Item request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$connect, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.Empty> sink($0.Item request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sink, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> heartbeat($0.Item request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$heartbeat, request, options: options);
  }
}

abstract class StreamServiceBase extends $grpc.Service {
  $core.String get $name => 'stream.Stream';

  StreamServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Item, $0.Item>(
        'Connect',
        connect_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Item.fromBuffer(value),
        ($0.Item value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Item, $0.Empty>(
        'sink',
        sink_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Item.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Item, $0.Empty>(
        'Heartbeat',
        heartbeat_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Item.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
  }

  $async.Stream<$0.Item> connect_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Item> request) async* {
    yield* connect(call, await request);
  }

  $async.Future<$0.Empty> sink_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Item> request) async {
    return sink(call, await request);
  }

  $async.Future<$0.Empty> heartbeat_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Item> request) async {
    return heartbeat(call, await request);
  }

  $async.Stream<$0.Item> connect($grpc.ServiceCall call, $0.Item request);
  $async.Future<$0.Empty> sink($grpc.ServiceCall call, $0.Item request);
  $async.Future<$0.Empty> heartbeat($grpc.ServiceCall call, $0.Item request);
}
