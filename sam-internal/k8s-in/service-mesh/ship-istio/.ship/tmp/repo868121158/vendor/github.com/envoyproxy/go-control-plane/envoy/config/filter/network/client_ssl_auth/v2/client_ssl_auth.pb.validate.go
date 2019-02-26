// Code generated by protoc-gen-validate
// source: envoy/config/filter/network/client_ssl_auth/v2/client_ssl_auth.proto
// DO NOT EDIT!!!

package v2

import (
	"bytes"
	"errors"
	"fmt"
	"net"
	"net/mail"
	"net/url"
	"regexp"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/gogo/protobuf/types"
)

// ensure the imports are used
var (
	_ = bytes.MinRead
	_ = errors.New("")
	_ = fmt.Print
	_ = utf8.UTFMax
	_ = (*regexp.Regexp)(nil)
	_ = (*strings.Reader)(nil)
	_ = net.IPv4len
	_ = time.Duration(0)
	_ = (*url.URL)(nil)
	_ = (*mail.Address)(nil)
	_ = types.DynamicAny{}
)

// Validate checks the field values on ClientSSLAuth with the rules defined in
// the proto definition for this message. If any rules are violated, an error
// is returned.
func (m *ClientSSLAuth) Validate() error {
	if m == nil {
		return nil
	}

	if len(m.GetAuthApiCluster()) < 1 {
		return ClientSSLAuthValidationError{
			Field:  "AuthApiCluster",
			Reason: "value length must be at least 1 bytes",
		}
	}

	if len(m.GetStatPrefix()) < 1 {
		return ClientSSLAuthValidationError{
			Field:  "StatPrefix",
			Reason: "value length must be at least 1 bytes",
		}
	}

	if v, ok := interface{}(m.GetRefreshDelay()).(interface{ Validate() error }); ok {
		if err := v.Validate(); err != nil {
			return ClientSSLAuthValidationError{
				Field:  "RefreshDelay",
				Reason: "embedded message failed validation",
				Cause:  err,
			}
		}
	}

	for idx, item := range m.GetIpWhiteList() {
		_, _ = idx, item

		if v, ok := interface{}(item).(interface{ Validate() error }); ok {
			if err := v.Validate(); err != nil {
				return ClientSSLAuthValidationError{
					Field:  fmt.Sprintf("IpWhiteList[%v]", idx),
					Reason: "embedded message failed validation",
					Cause:  err,
				}
			}
		}

	}

	return nil
}

// ClientSSLAuthValidationError is the validation error returned by
// ClientSSLAuth.Validate if the designated constraints aren't met.
type ClientSSLAuthValidationError struct {
	Field  string
	Reason string
	Cause  error
	Key    bool
}

// Error satisfies the builtin error interface
func (e ClientSSLAuthValidationError) Error() string {
	cause := ""
	if e.Cause != nil {
		cause = fmt.Sprintf(" | caused by: %v", e.Cause)
	}

	key := ""
	if e.Key {
		key = "key for "
	}

	return fmt.Sprintf(
		"invalid %sClientSSLAuth.%s: %s%s",
		key,
		e.Field,
		e.Reason,
		cause)
}

var _ error = ClientSSLAuthValidationError{}
