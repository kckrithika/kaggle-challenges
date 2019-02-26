// Code generated by protoc-gen-go. DO NOT EDIT.
// source: google/monitoring/v3/metric.proto

package monitoring

import proto "github.com/golang/protobuf/proto"
import fmt "fmt"
import math "math"
import google_api5 "google.golang.org/genproto/googleapis/api/metric"
import google_api4 "google.golang.org/genproto/googleapis/api/monitoredres"

// Reference imports to suppress errors if they are not otherwise used.
var _ = proto.Marshal
var _ = fmt.Errorf
var _ = math.Inf

// A single data point in a time series.
type Point struct {
	// The time interval to which the data point applies.  For GAUGE metrics, only
	// the end time of the interval is used.  For DELTA metrics, the start and end
	// time should specify a non-zero interval, with subsequent points specifying
	// contiguous and non-overlapping intervals.  For CUMULATIVE metrics, the
	// start and end time should specify a non-zero interval, with subsequent
	// points specifying the same start time and increasing end times, until an
	// event resets the cumulative value to zero and sets a new start time for the
	// following points.
	Interval *TimeInterval `protobuf:"bytes,1,opt,name=interval" json:"interval,omitempty"`
	// The value of the data point.
	Value *TypedValue `protobuf:"bytes,2,opt,name=value" json:"value,omitempty"`
}

func (m *Point) Reset()                    { *m = Point{} }
func (m *Point) String() string            { return proto.CompactTextString(m) }
func (*Point) ProtoMessage()               {}
func (*Point) Descriptor() ([]byte, []int) { return fileDescriptor5, []int{0} }

func (m *Point) GetInterval() *TimeInterval {
	if m != nil {
		return m.Interval
	}
	return nil
}

func (m *Point) GetValue() *TypedValue {
	if m != nil {
		return m.Value
	}
	return nil
}

// A collection of data points that describes the time-varying values
// of a metric. A time series is identified by a combination of a
// fully-specified monitored resource and a fully-specified metric.
// This type is used for both listing and creating time series.
type TimeSeries struct {
	// The associated metric. A fully-specified metric used to identify the time
	// series.
	Metric *google_api5.Metric `protobuf:"bytes,1,opt,name=metric" json:"metric,omitempty"`
	// The associated resource. A fully-specified monitored resource used to
	// identify the time series.
	Resource *google_api4.MonitoredResource `protobuf:"bytes,2,opt,name=resource" json:"resource,omitempty"`
	// The metric kind of the time series. When listing time series, this metric
	// kind might be different from the metric kind of the associated metric if
	// this time series is an alignment or reduction of other time series.
	//
	// When creating a time series, this field is optional. If present, it must be
	// the same as the metric kind of the associated metric. If the associated
	// metric's descriptor must be auto-created, then this field specifies the
	// metric kind of the new descriptor and must be either `GAUGE` (the default)
	// or `CUMULATIVE`.
	MetricKind google_api5.MetricDescriptor_MetricKind `protobuf:"varint,3,opt,name=metric_kind,json=metricKind,enum=google.api.MetricDescriptor_MetricKind" json:"metric_kind,omitempty"`
	// The value type of the time series. When listing time series, this value
	// type might be different from the value type of the associated metric if
	// this time series is an alignment or reduction of other time series.
	//
	// When creating a time series, this field is optional. If present, it must be
	// the same as the type of the data in the `points` field.
	ValueType google_api5.MetricDescriptor_ValueType `protobuf:"varint,4,opt,name=value_type,json=valueType,enum=google.api.MetricDescriptor_ValueType" json:"value_type,omitempty"`
	// The data points of this time series. When listing time series, the order of
	// the points is specified by the list method.
	//
	// When creating a time series, this field must contain exactly one point and
	// the point's type must be the same as the value type of the associated
	// metric. If the associated metric's descriptor must be auto-created, then
	// the value type of the descriptor is determined by the point's type, which
	// must be `BOOL`, `INT64`, `DOUBLE`, or `DISTRIBUTION`.
	Points []*Point `protobuf:"bytes,5,rep,name=points" json:"points,omitempty"`
}

func (m *TimeSeries) Reset()                    { *m = TimeSeries{} }
func (m *TimeSeries) String() string            { return proto.CompactTextString(m) }
func (*TimeSeries) ProtoMessage()               {}
func (*TimeSeries) Descriptor() ([]byte, []int) { return fileDescriptor5, []int{1} }

func (m *TimeSeries) GetMetric() *google_api5.Metric {
	if m != nil {
		return m.Metric
	}
	return nil
}

func (m *TimeSeries) GetResource() *google_api4.MonitoredResource {
	if m != nil {
		return m.Resource
	}
	return nil
}

func (m *TimeSeries) GetMetricKind() google_api5.MetricDescriptor_MetricKind {
	if m != nil {
		return m.MetricKind
	}
	return google_api5.MetricDescriptor_METRIC_KIND_UNSPECIFIED
}

func (m *TimeSeries) GetValueType() google_api5.MetricDescriptor_ValueType {
	if m != nil {
		return m.ValueType
	}
	return google_api5.MetricDescriptor_VALUE_TYPE_UNSPECIFIED
}

func (m *TimeSeries) GetPoints() []*Point {
	if m != nil {
		return m.Points
	}
	return nil
}

func init() {
	proto.RegisterType((*Point)(nil), "google.monitoring.v3.Point")
	proto.RegisterType((*TimeSeries)(nil), "google.monitoring.v3.TimeSeries")
}

func init() { proto.RegisterFile("google/monitoring/v3/metric.proto", fileDescriptor5) }

var fileDescriptor5 = []byte{
	// 396 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xff, 0x7c, 0x92, 0xc1, 0x4a, 0xeb, 0x40,
	0x14, 0x86, 0x49, 0x7b, 0x5b, 0x7a, 0x27, 0x70, 0x17, 0xc3, 0x05, 0x43, 0x45, 0x88, 0x15, 0xb4,
	0xb8, 0x48, 0xa0, 0x01, 0x41, 0x84, 0x2e, 0xaa, 0xa2, 0x22, 0x42, 0x19, 0xa5, 0x0b, 0x29, 0x94,
	0x98, 0x0c, 0x61, 0x30, 0x99, 0x33, 0x4c, 0xd2, 0x40, 0x57, 0x3e, 0x8c, 0x3b, 0xdf, 0xc0, 0x57,
	0xf0, 0xa9, 0x24, 0x33, 0x93, 0xd6, 0x62, 0x74, 0x37, 0xc9, 0xff, 0x9d, 0xff, 0x9f, 0x73, 0xce,
	0xa0, 0xfd, 0x04, 0x20, 0x49, 0xa9, 0x9f, 0x01, 0x67, 0x05, 0x48, 0xc6, 0x13, 0xbf, 0x0c, 0xfc,
	0x8c, 0x16, 0x92, 0x45, 0x9e, 0x90, 0x50, 0x00, 0xfe, 0xaf, 0x11, 0x6f, 0x83, 0x78, 0x65, 0xd0,
	0xdf, 0x31, 0x85, 0xa1, 0x60, 0x5b, 0x78, 0xff, 0xe0, 0xab, 0xa0, 0x4b, 0x68, 0xbc, 0x90, 0x34,
	0x87, 0xa5, 0x8c, 0xa8, 0x81, 0x9a, 0x63, 0x23, 0xc8, 0x32, 0xe0, 0x1a, 0x19, 0xbc, 0xa0, 0xce,
	0x14, 0x18, 0x2f, 0xf0, 0x18, 0xf5, 0x18, 0x2f, 0xa8, 0x2c, 0xc3, 0xd4, 0xb1, 0x5c, 0x6b, 0x68,
	0x8f, 0x06, 0x5e, 0xd3, 0x95, 0xbc, 0x07, 0x96, 0xd1, 0x1b, 0x43, 0x92, 0x75, 0x0d, 0x3e, 0x41,
	0x9d, 0x32, 0x4c, 0x97, 0xd4, 0x69, 0xa9, 0x62, 0xf7, 0x87, 0xe2, 0x95, 0xa0, 0xf1, 0xac, 0xe2,
	0x88, 0xc6, 0x07, 0xef, 0x2d, 0x84, 0x2a, 0xcb, 0x7b, 0x2a, 0x19, 0xcd, 0xf1, 0x31, 0xea, 0xea,
	0x3e, 0xcd, 0x25, 0x70, 0xed, 0x13, 0x0a, 0xe6, 0xdd, 0x29, 0x85, 0x18, 0x02, 0x9f, 0xa2, 0x5e,
	0xdd, 0xb0, 0x49, 0xdd, 0xdb, 0xa2, 0xeb, 0xb1, 0x10, 0x03, 0x91, 0x35, 0x8e, 0xaf, 0x91, 0xad,
	0x4d, 0x16, 0xcf, 0x8c, 0xc7, 0x4e, 0xdb, 0xb5, 0x86, 0xff, 0x46, 0x47, 0xdf, 0xb3, 0x2e, 0x68,
	0x1e, 0x49, 0x26, 0x0a, 0x90, 0xe6, 0xc7, 0x2d, 0xe3, 0x31, 0x41, 0xd9, 0xfa, 0x8c, 0x2f, 0x11,
	0x52, 0x8d, 0x2c, 0x8a, 0x95, 0xa0, 0xce, 0x1f, 0x65, 0x74, 0xf8, 0xab, 0x91, 0x6a, 0xbf, 0x1a,
	0x04, 0xf9, 0x5b, 0xd6, 0x47, 0x1c, 0xa0, 0xae, 0xa8, 0xf6, 0x90, 0x3b, 0x1d, 0xb7, 0x3d, 0xb4,
	0x47, 0xbb, 0xcd, 0xf3, 0x53, 0xbb, 0x22, 0x06, 0x9d, 0xbc, 0x5a, 0xc8, 0x89, 0x20, 0x6b, 0x44,
	0x27, 0xb6, 0x0e, 0x9e, 0x56, 0x6b, 0x9e, 0x5a, 0x8f, 0x63, 0x03, 0x25, 0x90, 0x86, 0x3c, 0xf1,
	0x40, 0x26, 0x7e, 0x42, 0xb9, 0x7a, 0x04, 0xbe, 0x96, 0x42, 0xc1, 0xf2, 0xed, 0xa7, 0x72, 0xb6,
	0xf9, 0x7a, 0x6b, 0xf5, 0xaf, 0xb4, 0xc1, 0x79, 0x0a, 0xcb, 0xb8, 0x1e, 0x6e, 0x95, 0x35, 0x0b,
	0x3e, 0x6a, 0x71, 0xae, 0xc4, 0xf9, 0x46, 0x9c, 0xcf, 0x82, 0xa7, 0xae, 0x0a, 0x09, 0x3e, 0x03,
	0x00, 0x00, 0xff, 0xff, 0x28, 0x45, 0x7a, 0x13, 0x05, 0x03, 0x00, 0x00,
}
