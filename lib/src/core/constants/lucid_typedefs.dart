import 'package:flutter/material.dart';

typedef LucidVoidCallBack = void Function();

typedef LucidValueCallBack<T> = void Function(T value);

typedef LucidBiValueCallBack<S, T> = void Function(S first, T second);

typedef LucidTriValueCallBack<S, T, U> = void Function(S first, T second, U third);

typedef LucidListCallBack<T> = void Function(List<T> value);

typedef LucidMapCallBack<S, T> = void Function(Map<S, T> value);

typedef LucidAsyncValueCallBack<T> = Future<T> Function();

typedef LucidDataWidgetBuilder<T> = Widget Function(BuildContext context, T value);

typedef LucidBiDataWidgetBuilder<S, T> = Widget Function(BuildContext context, S first, T second);

typedef LucidFormFieldValidator = String? Function(String? value);

typedef LucidTransformer<Input, Output> = Output Function(Input input);

typedef LucidStreamMapper<Input, Output> = Stream<Output> Function(Stream<Input> input);

typedef LucidErrorHandler = void Function(Object error, StackTrace stackTrace);

typedef LucidPredicate<T> = bool Function(T value);

typedef LucidComparator<S, T> = int Function(S first, T second);

typedef LucidAuthToken = String;

typedef LucidUserId = String;

typedef LucidTimestamp = int;

typedef LucidData<T> = T;

typedef LucidDataList<T> = List<LucidData<T>>;

typedef LucidEntriesMap<T> = Map<String, LucidData<T>>;

typedef LucidEntriesList<T> = List<LucidEntriesMap<T>>;

typedef LucidJsonMap = Map<String, dynamic>;

typedef LucidJsonList = List<LucidJsonMap>;

typedef LucidQueryParams = Map<String, String>;

typedef LucidHttpHeaders = Map<String, String>;

typedef LucidEnvConfig = LucidJsonMap;
