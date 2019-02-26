// Code generated by counterfeiter. DO NOT EDIT.
package fakes

import (
	"sync"

	"istio.io/istio/pilot/pkg/model"
)

type ServiceAccounts struct {
	GetIstioServiceAccountsStub        func(hostname model.Hostname, ports []string) []string
	getIstioServiceAccountsMutex       sync.RWMutex
	getIstioServiceAccountsArgsForCall []struct {
		hostname model.Hostname
		ports    []string
	}
	getIstioServiceAccountsReturns struct {
		result1 []string
	}
	getIstioServiceAccountsReturnsOnCall map[int]struct {
		result1 []string
	}
	invocations      map[string][][]interface{}
	invocationsMutex sync.RWMutex
}

func (fake *ServiceAccounts) GetIstioServiceAccounts(hostname model.Hostname, ports []string) []string {
	var portsCopy []string
	if ports != nil {
		portsCopy = make([]string, len(ports))
		copy(portsCopy, ports)
	}
	fake.getIstioServiceAccountsMutex.Lock()
	ret, specificReturn := fake.getIstioServiceAccountsReturnsOnCall[len(fake.getIstioServiceAccountsArgsForCall)]
	fake.getIstioServiceAccountsArgsForCall = append(fake.getIstioServiceAccountsArgsForCall, struct {
		hostname model.Hostname
		ports    []string
	}{hostname, portsCopy})
	fake.recordInvocation("GetIstioServiceAccounts", []interface{}{hostname, portsCopy})
	fake.getIstioServiceAccountsMutex.Unlock()
	if fake.GetIstioServiceAccountsStub != nil {
		return fake.GetIstioServiceAccountsStub(hostname, ports)
	}
	if specificReturn {
		return ret.result1
	}
	return fake.getIstioServiceAccountsReturns.result1
}

func (fake *ServiceAccounts) GetIstioServiceAccountsCallCount() int {
	fake.getIstioServiceAccountsMutex.RLock()
	defer fake.getIstioServiceAccountsMutex.RUnlock()
	return len(fake.getIstioServiceAccountsArgsForCall)
}

func (fake *ServiceAccounts) GetIstioServiceAccountsArgsForCall(i int) (model.Hostname, []string) {
	fake.getIstioServiceAccountsMutex.RLock()
	defer fake.getIstioServiceAccountsMutex.RUnlock()
	return fake.getIstioServiceAccountsArgsForCall[i].hostname, fake.getIstioServiceAccountsArgsForCall[i].ports
}

func (fake *ServiceAccounts) GetIstioServiceAccountsReturns(result1 []string) {
	fake.GetIstioServiceAccountsStub = nil
	fake.getIstioServiceAccountsReturns = struct {
		result1 []string
	}{result1}
}

func (fake *ServiceAccounts) GetIstioServiceAccountsReturnsOnCall(i int, result1 []string) {
	fake.GetIstioServiceAccountsStub = nil
	if fake.getIstioServiceAccountsReturnsOnCall == nil {
		fake.getIstioServiceAccountsReturnsOnCall = make(map[int]struct {
			result1 []string
		})
	}
	fake.getIstioServiceAccountsReturnsOnCall[i] = struct {
		result1 []string
	}{result1}
}

func (fake *ServiceAccounts) Invocations() map[string][][]interface{} {
	fake.invocationsMutex.RLock()
	defer fake.invocationsMutex.RUnlock()
	fake.getIstioServiceAccountsMutex.RLock()
	defer fake.getIstioServiceAccountsMutex.RUnlock()
	copiedInvocations := map[string][][]interface{}{}
	for key, value := range fake.invocations {
		copiedInvocations[key] = value
	}
	return copiedInvocations
}

func (fake *ServiceAccounts) recordInvocation(key string, args []interface{}) {
	fake.invocationsMutex.Lock()
	defer fake.invocationsMutex.Unlock()
	if fake.invocations == nil {
		fake.invocations = map[string][][]interface{}{}
	}
	if fake.invocations[key] == nil {
		fake.invocations[key] = [][]interface{}{}
	}
	fake.invocations[key] = append(fake.invocations[key], args)
}

var _ model.ServiceAccounts = new(ServiceAccounts)
