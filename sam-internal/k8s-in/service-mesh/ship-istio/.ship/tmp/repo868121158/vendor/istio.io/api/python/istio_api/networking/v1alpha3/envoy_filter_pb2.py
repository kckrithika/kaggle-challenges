# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: networking/v1alpha3/envoy_filter.proto

import sys
_b=sys.version_info[0]<3 and (lambda x:x) or (lambda x:x.encode('latin1'))
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from google.protobuf import reflection as _reflection
from google.protobuf import symbol_database as _symbol_database
from google.protobuf import descriptor_pb2
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()


from google.protobuf import struct_pb2 as google_dot_protobuf_dot_struct__pb2


DESCRIPTOR = _descriptor.FileDescriptor(
  name='networking/v1alpha3/envoy_filter.proto',
  package='istio.networking.v1alpha3',
  syntax='proto3',
  serialized_pb=_b('\n&networking/v1alpha3/envoy_filter.proto\x12\x19istio.networking.v1alpha3\x1a\x1cgoogle/protobuf/struct.proto\"\x80\t\n\x0b\x45nvoyFilter\x12S\n\x0fworkload_labels\x18\x01 \x03(\x0b\x32:.istio.networking.v1alpha3.EnvoyFilter.WorkloadLabelsEntry\x12>\n\x07\x66ilters\x18\x02 \x03(\x0b\x32-.istio.networking.v1alpha3.EnvoyFilter.Filter\x1a\x35\n\x13WorkloadLabelsEntry\x12\x0b\n\x03key\x18\x01 \x01(\t\x12\r\n\x05value\x18\x02 \x01(\t:\x02\x38\x01\x1a\x8c\x03\n\rListenerMatch\x12\x13\n\x0bport_number\x18\x01 \x01(\r\x12\x18\n\x10port_name_prefix\x18\x02 \x01(\t\x12X\n\rlistener_type\x18\x03 \x01(\x0e\x32\x41.istio.networking.v1alpha3.EnvoyFilter.ListenerMatch.ListenerType\x12`\n\x11listener_protocol\x18\x04 \x01(\x0e\x32\x45.istio.networking.v1alpha3.EnvoyFilter.ListenerMatch.ListenerProtocol\x12\x0f\n\x07\x61\x64\x64ress\x18\x05 \x03(\t\"O\n\x0cListenerType\x12\x07\n\x03\x41NY\x10\x00\x12\x13\n\x0fSIDECAR_INBOUND\x10\x01\x12\x14\n\x10SIDECAR_OUTBOUND\x10\x02\x12\x0b\n\x07GATEWAY\x10\x03\".\n\x10ListenerProtocol\x12\x07\n\x03\x41LL\x10\x00\x12\x08\n\x04HTTP\x10\x01\x12\x07\n\x03TCP\x10\x02\x1a\xa6\x01\n\x0eInsertPosition\x12J\n\x05index\x18\x01 \x01(\x0e\x32;.istio.networking.v1alpha3.EnvoyFilter.InsertPosition.Index\x12\x13\n\x0brelative_to\x18\x02 \x01(\t\"3\n\x05Index\x12\t\n\x05\x46IRST\x10\x00\x12\x08\n\x04LAST\x10\x01\x12\n\n\x06\x42\x45\x46ORE\x10\x02\x12\t\n\x05\x41\x46TER\x10\x03\x1a\xec\x02\n\x06\x46ilter\x12L\n\x0elistener_match\x18\x01 \x01(\x0b\x32\x34.istio.networking.v1alpha3.EnvoyFilter.ListenerMatch\x12N\n\x0finsert_position\x18\x02 \x01(\x0b\x32\x35.istio.networking.v1alpha3.EnvoyFilter.InsertPosition\x12M\n\x0b\x66ilter_type\x18\x03 \x01(\x0e\x32\x38.istio.networking.v1alpha3.EnvoyFilter.Filter.FilterType\x12\x13\n\x0b\x66ilter_name\x18\x04 \x01(\t\x12.\n\rfilter_config\x18\x05 \x01(\x0b\x32\x17.google.protobuf.Struct\"0\n\nFilterType\x12\x0b\n\x07INVALID\x10\x00\x12\x08\n\x04HTTP\x10\x01\x12\x0b\n\x07NETWORK\x10\x02\x42\"Z istio.io/api/networking/v1alpha3b\x06proto3')
  ,
  dependencies=[google_dot_protobuf_dot_struct__pb2.DESCRIPTOR,])



_ENVOYFILTER_LISTENERMATCH_LISTENERTYPE = _descriptor.EnumDescriptor(
  name='ListenerType',
  full_name='istio.networking.v1alpha3.EnvoyFilter.ListenerMatch.ListenerType',
  filename=None,
  file=DESCRIPTOR,
  values=[
    _descriptor.EnumValueDescriptor(
      name='ANY', index=0, number=0,
      options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='SIDECAR_INBOUND', index=1, number=1,
      options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='SIDECAR_OUTBOUND', index=2, number=2,
      options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='GATEWAY', index=3, number=3,
      options=None,
      type=None),
  ],
  containing_type=None,
  options=None,
  serialized_start=589,
  serialized_end=668,
)
_sym_db.RegisterEnumDescriptor(_ENVOYFILTER_LISTENERMATCH_LISTENERTYPE)

_ENVOYFILTER_LISTENERMATCH_LISTENERPROTOCOL = _descriptor.EnumDescriptor(
  name='ListenerProtocol',
  full_name='istio.networking.v1alpha3.EnvoyFilter.ListenerMatch.ListenerProtocol',
  filename=None,
  file=DESCRIPTOR,
  values=[
    _descriptor.EnumValueDescriptor(
      name='ALL', index=0, number=0,
      options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='HTTP', index=1, number=1,
      options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='TCP', index=2, number=2,
      options=None,
      type=None),
  ],
  containing_type=None,
  options=None,
  serialized_start=670,
  serialized_end=716,
)
_sym_db.RegisterEnumDescriptor(_ENVOYFILTER_LISTENERMATCH_LISTENERPROTOCOL)

_ENVOYFILTER_INSERTPOSITION_INDEX = _descriptor.EnumDescriptor(
  name='Index',
  full_name='istio.networking.v1alpha3.EnvoyFilter.InsertPosition.Index',
  filename=None,
  file=DESCRIPTOR,
  values=[
    _descriptor.EnumValueDescriptor(
      name='FIRST', index=0, number=0,
      options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='LAST', index=1, number=1,
      options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='BEFORE', index=2, number=2,
      options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='AFTER', index=3, number=3,
      options=None,
      type=None),
  ],
  containing_type=None,
  options=None,
  serialized_start=834,
  serialized_end=885,
)
_sym_db.RegisterEnumDescriptor(_ENVOYFILTER_INSERTPOSITION_INDEX)

_ENVOYFILTER_FILTER_FILTERTYPE = _descriptor.EnumDescriptor(
  name='FilterType',
  full_name='istio.networking.v1alpha3.EnvoyFilter.Filter.FilterType',
  filename=None,
  file=DESCRIPTOR,
  values=[
    _descriptor.EnumValueDescriptor(
      name='INVALID', index=0, number=0,
      options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='HTTP', index=1, number=1,
      options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='NETWORK', index=2, number=2,
      options=None,
      type=None),
  ],
  containing_type=None,
  options=None,
  serialized_start=1204,
  serialized_end=1252,
)
_sym_db.RegisterEnumDescriptor(_ENVOYFILTER_FILTER_FILTERTYPE)


_ENVOYFILTER_WORKLOADLABELSENTRY = _descriptor.Descriptor(
  name='WorkloadLabelsEntry',
  full_name='istio.networking.v1alpha3.EnvoyFilter.WorkloadLabelsEntry',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='key', full_name='istio.networking.v1alpha3.EnvoyFilter.WorkloadLabelsEntry.key', index=0,
      number=1, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='value', full_name='istio.networking.v1alpha3.EnvoyFilter.WorkloadLabelsEntry.value', index=1,
      number=2, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  options=_descriptor._ParseOptions(descriptor_pb2.MessageOptions(), _b('8\001')),
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=264,
  serialized_end=317,
)

_ENVOYFILTER_LISTENERMATCH = _descriptor.Descriptor(
  name='ListenerMatch',
  full_name='istio.networking.v1alpha3.EnvoyFilter.ListenerMatch',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='port_number', full_name='istio.networking.v1alpha3.EnvoyFilter.ListenerMatch.port_number', index=0,
      number=1, type=13, cpp_type=3, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='port_name_prefix', full_name='istio.networking.v1alpha3.EnvoyFilter.ListenerMatch.port_name_prefix', index=1,
      number=2, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='listener_type', full_name='istio.networking.v1alpha3.EnvoyFilter.ListenerMatch.listener_type', index=2,
      number=3, type=14, cpp_type=8, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='listener_protocol', full_name='istio.networking.v1alpha3.EnvoyFilter.ListenerMatch.listener_protocol', index=3,
      number=4, type=14, cpp_type=8, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='address', full_name='istio.networking.v1alpha3.EnvoyFilter.ListenerMatch.address', index=4,
      number=5, type=9, cpp_type=9, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
    _ENVOYFILTER_LISTENERMATCH_LISTENERTYPE,
    _ENVOYFILTER_LISTENERMATCH_LISTENERPROTOCOL,
  ],
  options=None,
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=320,
  serialized_end=716,
)

_ENVOYFILTER_INSERTPOSITION = _descriptor.Descriptor(
  name='InsertPosition',
  full_name='istio.networking.v1alpha3.EnvoyFilter.InsertPosition',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='index', full_name='istio.networking.v1alpha3.EnvoyFilter.InsertPosition.index', index=0,
      number=1, type=14, cpp_type=8, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='relative_to', full_name='istio.networking.v1alpha3.EnvoyFilter.InsertPosition.relative_to', index=1,
      number=2, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
    _ENVOYFILTER_INSERTPOSITION_INDEX,
  ],
  options=None,
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=719,
  serialized_end=885,
)

_ENVOYFILTER_FILTER = _descriptor.Descriptor(
  name='Filter',
  full_name='istio.networking.v1alpha3.EnvoyFilter.Filter',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='listener_match', full_name='istio.networking.v1alpha3.EnvoyFilter.Filter.listener_match', index=0,
      number=1, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='insert_position', full_name='istio.networking.v1alpha3.EnvoyFilter.Filter.insert_position', index=1,
      number=2, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='filter_type', full_name='istio.networking.v1alpha3.EnvoyFilter.Filter.filter_type', index=2,
      number=3, type=14, cpp_type=8, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='filter_name', full_name='istio.networking.v1alpha3.EnvoyFilter.Filter.filter_name', index=3,
      number=4, type=9, cpp_type=9, label=1,
      has_default_value=False, default_value=_b("").decode('utf-8'),
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='filter_config', full_name='istio.networking.v1alpha3.EnvoyFilter.Filter.filter_config', index=4,
      number=5, type=11, cpp_type=10, label=1,
      has_default_value=False, default_value=None,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
    _ENVOYFILTER_FILTER_FILTERTYPE,
  ],
  options=None,
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=888,
  serialized_end=1252,
)

_ENVOYFILTER = _descriptor.Descriptor(
  name='EnvoyFilter',
  full_name='istio.networking.v1alpha3.EnvoyFilter',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='workload_labels', full_name='istio.networking.v1alpha3.EnvoyFilter.workload_labels', index=0,
      number=1, type=11, cpp_type=10, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
    _descriptor.FieldDescriptor(
      name='filters', full_name='istio.networking.v1alpha3.EnvoyFilter.filters', index=1,
      number=2, type=11, cpp_type=10, label=3,
      has_default_value=False, default_value=[],
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None, file=DESCRIPTOR),
  ],
  extensions=[
  ],
  nested_types=[_ENVOYFILTER_WORKLOADLABELSENTRY, _ENVOYFILTER_LISTENERMATCH, _ENVOYFILTER_INSERTPOSITION, _ENVOYFILTER_FILTER, ],
  enum_types=[
  ],
  options=None,
  is_extendable=False,
  syntax='proto3',
  extension_ranges=[],
  oneofs=[
  ],
  serialized_start=100,
  serialized_end=1252,
)

_ENVOYFILTER_WORKLOADLABELSENTRY.containing_type = _ENVOYFILTER
_ENVOYFILTER_LISTENERMATCH.fields_by_name['listener_type'].enum_type = _ENVOYFILTER_LISTENERMATCH_LISTENERTYPE
_ENVOYFILTER_LISTENERMATCH.fields_by_name['listener_protocol'].enum_type = _ENVOYFILTER_LISTENERMATCH_LISTENERPROTOCOL
_ENVOYFILTER_LISTENERMATCH.containing_type = _ENVOYFILTER
_ENVOYFILTER_LISTENERMATCH_LISTENERTYPE.containing_type = _ENVOYFILTER_LISTENERMATCH
_ENVOYFILTER_LISTENERMATCH_LISTENERPROTOCOL.containing_type = _ENVOYFILTER_LISTENERMATCH
_ENVOYFILTER_INSERTPOSITION.fields_by_name['index'].enum_type = _ENVOYFILTER_INSERTPOSITION_INDEX
_ENVOYFILTER_INSERTPOSITION.containing_type = _ENVOYFILTER
_ENVOYFILTER_INSERTPOSITION_INDEX.containing_type = _ENVOYFILTER_INSERTPOSITION
_ENVOYFILTER_FILTER.fields_by_name['listener_match'].message_type = _ENVOYFILTER_LISTENERMATCH
_ENVOYFILTER_FILTER.fields_by_name['insert_position'].message_type = _ENVOYFILTER_INSERTPOSITION
_ENVOYFILTER_FILTER.fields_by_name['filter_type'].enum_type = _ENVOYFILTER_FILTER_FILTERTYPE
_ENVOYFILTER_FILTER.fields_by_name['filter_config'].message_type = google_dot_protobuf_dot_struct__pb2._STRUCT
_ENVOYFILTER_FILTER.containing_type = _ENVOYFILTER
_ENVOYFILTER_FILTER_FILTERTYPE.containing_type = _ENVOYFILTER_FILTER
_ENVOYFILTER.fields_by_name['workload_labels'].message_type = _ENVOYFILTER_WORKLOADLABELSENTRY
_ENVOYFILTER.fields_by_name['filters'].message_type = _ENVOYFILTER_FILTER
DESCRIPTOR.message_types_by_name['EnvoyFilter'] = _ENVOYFILTER
_sym_db.RegisterFileDescriptor(DESCRIPTOR)

EnvoyFilter = _reflection.GeneratedProtocolMessageType('EnvoyFilter', (_message.Message,), dict(

  WorkloadLabelsEntry = _reflection.GeneratedProtocolMessageType('WorkloadLabelsEntry', (_message.Message,), dict(
    DESCRIPTOR = _ENVOYFILTER_WORKLOADLABELSENTRY,
    __module__ = 'networking.v1alpha3.envoy_filter_pb2'
    # @@protoc_insertion_point(class_scope:istio.networking.v1alpha3.EnvoyFilter.WorkloadLabelsEntry)
    ))
  ,

  ListenerMatch = _reflection.GeneratedProtocolMessageType('ListenerMatch', (_message.Message,), dict(
    DESCRIPTOR = _ENVOYFILTER_LISTENERMATCH,
    __module__ = 'networking.v1alpha3.envoy_filter_pb2'
    # @@protoc_insertion_point(class_scope:istio.networking.v1alpha3.EnvoyFilter.ListenerMatch)
    ))
  ,

  InsertPosition = _reflection.GeneratedProtocolMessageType('InsertPosition', (_message.Message,), dict(
    DESCRIPTOR = _ENVOYFILTER_INSERTPOSITION,
    __module__ = 'networking.v1alpha3.envoy_filter_pb2'
    # @@protoc_insertion_point(class_scope:istio.networking.v1alpha3.EnvoyFilter.InsertPosition)
    ))
  ,

  Filter = _reflection.GeneratedProtocolMessageType('Filter', (_message.Message,), dict(
    DESCRIPTOR = _ENVOYFILTER_FILTER,
    __module__ = 'networking.v1alpha3.envoy_filter_pb2'
    # @@protoc_insertion_point(class_scope:istio.networking.v1alpha3.EnvoyFilter.Filter)
    ))
  ,
  DESCRIPTOR = _ENVOYFILTER,
  __module__ = 'networking.v1alpha3.envoy_filter_pb2'
  # @@protoc_insertion_point(class_scope:istio.networking.v1alpha3.EnvoyFilter)
  ))
_sym_db.RegisterMessage(EnvoyFilter)
_sym_db.RegisterMessage(EnvoyFilter.WorkloadLabelsEntry)
_sym_db.RegisterMessage(EnvoyFilter.ListenerMatch)
_sym_db.RegisterMessage(EnvoyFilter.InsertPosition)
_sym_db.RegisterMessage(EnvoyFilter.Filter)


DESCRIPTOR.has_options = True
DESCRIPTOR._options = _descriptor._ParseOptions(descriptor_pb2.FileOptions(), _b('Z istio.io/api/networking/v1alpha3'))
_ENVOYFILTER_WORKLOADLABELSENTRY.has_options = True
_ENVOYFILTER_WORKLOADLABELSENTRY._options = _descriptor._ParseOptions(descriptor_pb2.MessageOptions(), _b('8\001'))
# @@protoc_insertion_point(module_scope)
