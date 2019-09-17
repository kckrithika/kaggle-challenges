local flowsnake_images = import "flowsnake_images.jsonnet";
local enabled = std.objectHas(flowsnake_images.feature_flags, "v1beta1_original");

if enabled then
{
    "apiVersion": "v1",
    "kind": "List",
    "items": [
        {
            "apiVersion": "apiextensions.k8s.io/v1beta1",
            "kind": "CustomResourceDefinition",
            "metadata": {
                "name": "scheduledsparkapplications.sparkoperator.k8s.io",
                  "annotations": {
                      "manifestctl.sam.data.sfdc.net/swagger": "disable"
                  }
            },
            "spec": {
                "group": "sparkoperator.k8s.io",
                "names": {
                    "kind": "ScheduledSparkApplication",
                    "listKind": "ScheduledSparkApplicationList",
                    "plural": "scheduledsparkapplications",
                    "shortNames": [
                        "scheduledsparkapp"
                    ],
                    "singular": "scheduledsparkapplication"
                },
                "scope": "Namespaced",
                "validation": {
                    "openAPIV3Schema": {
                        "properties": {
                            "spec": {
                                "properties": {
                                    "concurrencyPolicy": {
                                        "enum": [
                                            "Allow",
                                            "Forbid",
                                            "Replace"
                                        ]
                                    },
                                    "failedRunHistoryLimit": {
                                        "minimum": 1,
                                        "type": "integer"
                                    },
                                    "schedule": {
                                        "type": "string"
                                    },
                                    "successfulRunHistoryLimit": {
                                        "minimum": 1,
                                        "type": "integer"
                                    },
                                    "template": {
                                        "properties": {
                                            "deps": {
                                                "properties": {
                                                    "downloadTimeout": {
                                                        "minimum": 1,
                                                        "type": "integer"
                                                    },
                                                    "maxSimultaneousDownloads": {
                                                        "minimum": 1,
                                                        "type": "integer"
                                                    }
                                                }
                                            },
                                            "driver": {
                                                "properties": {
                                                    "cores": {
                                                        "exclusiveMinimum": true,
                                                        "minimum": 0,
                                                        "type": "number"
                                                    },
                                                    "podName": {
                                                        "pattern": "[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*"
                                                    }
                                                }
                                            },
                                            "executor": {
                                                "properties": {
                                                    "cores": {
                                                        "exclusiveMinimum": true,
                                                        "minimum": 0,
                                                        "type": "number"
                                                    },
                                                    "instances": {
                                                        "minimum": 1,
                                                        "type": "integer"
                                                    }
                                                }
                                            },
                                            "mode": {
                                                "enum": [
                                                    "cluster",
                                                    "client"
                                                ]
                                            },
                                            "monitoring": {
                                                "properties": {
                                                    "prometheus": {
                                                        "properties": {
                                                            "port": {
                                                                "maximum": 49151,
                                                                "minimum": 1024,
                                                                "type": "integer"
                                                            }
                                                        }
                                                    }
                                                }
                                            },
                                            "pythonVersion": {
                                                "enum": [
                                                    "2",
                                                    "3"
                                                ]
                                            },
                                            "restartPolicy": {
                                                "properties": {
                                                    "onFailureRetries": {
                                                        "minimum": 0,
                                                        "type": "integer"
                                                    },
                                                    "onFailureRetryInterval": {
                                                        "minimum": 1,
                                                        "type": "integer"
                                                    },
                                                    "onSubmissionFailureRetries": {
                                                        "minimum": 0,
                                                        "type": "integer"
                                                    },
                                                    "onSubmissionFailureRetryInterval": {
                                                        "minimum": 1,
                                                        "type": "integer"
                                                    },
                                                    "type": {
                                                        "enum": [
                                                            "Never",
                                                            "OnFailure",
                                                            "Always"
                                                        ]
                                                    }
                                                }
                                            },
                                            "type": {
                                                "enum": [
                                                    "Java",
                                                    "Scala",
                                                    "Python",
                                                    "R"
                                                ]
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                },
                "version": "v1beta1",
                "versions": [
                    {
                        "name": "v1beta2",
                        "served": true,
                        "storage": false
                    },
                    {
                        "name": "v1beta1",
                        "served": true,
                        "storage": true
                    }
                ]
            },
        },
        {
            "apiVersion": "apiextensions.k8s.io/v1beta1",
            "kind": "CustomResourceDefinition",
            "metadata": {
                "name": "sparkapplications.sparkoperator.k8s.io",
                  "annotations": {
                      "manifestctl.sam.data.sfdc.net/swagger": "disable"
                  }
            },
            "spec": {
                "group": "sparkoperator.k8s.io",
                "names": {
                    "kind": "SparkApplication",
                    "listKind": "SparkApplicationList",
                    "plural": "sparkapplications",
                    "shortNames": [
                        "sparkapp"
                    ],
                    "singular": "sparkapplication"
                },
                "scope": "Namespaced",
                "validation": {
                    "openAPIV3Schema": {
                        "properties": {
                            "metadata": {
                                "properties": {
                                    "name": {
                                        "maxLength": 63,
                                        "minLength": 1,
                                        "type": "string"
                                    }
                                }
                            },
                            "spec": {
                                "properties": {
                                    "deps": {
                                        "properties": {
                                            "downloadTimeout": {
                                                "minimum": 1,
                                                "type": "integer"
                                            },
                                            "maxSimultaneousDownloads": {
                                                "minimum": 1,
                                                "type": "integer"
                                            }
                                        }
                                    },
                                    "driver": {
                                        "properties": {
                                            "cores": {
                                                "exclusiveMinimum": true,
                                                "minimum": 0,
                                                "type": "number"
                                            },
                                            "podName": {
                                                "pattern": "[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*"
                                            }
                                        }
                                    },
                                    "executor": {
                                        "properties": {
                                            "cores": {
                                                "exclusiveMinimum": true,
                                                "minimum": 0,
                                                "type": "number"
                                            },
                                            "instances": {
                                                "minimum": 1,
                                                "type": "integer"
                                            }
                                        }
                                    },
                                    "mode": {
                                        "enum": [
                                            "cluster",
                                            "client"
                                        ]
                                    },
                                    "monitoring": {
                                        "properties": {
                                            "prometheus": {
                                                "properties": {
                                                    "port": {
                                                        "maximum": 49151,
                                                        "minimum": 1024,
                                                        "type": "integer"
                                                    }
                                                }
                                            }
                                        }
                                    },
                                    "pythonVersion": {
                                        "enum": [
                                            "2",
                                            "3"
                                        ]
                                    },
                                    "restartPolicy": {
                                        "properties": {
                                            "onFailureRetries": {
                                                "minimum": 0,
                                                "type": "integer"
                                            },
                                            "onFailureRetryInterval": {
                                                "minimum": 1,
                                                "type": "integer"
                                            },
                                            "onSubmissionFailureRetries": {
                                                "minimum": 0,
                                                "type": "integer"
                                            },
                                            "onSubmissionFailureRetryInterval": {
                                                "minimum": 1,
                                                "type": "integer"
                                            },
                                            "type": {
                                                "enum": [
                                                    "Never",
                                                    "OnFailure",
                                                    "Always"
                                                ]
                                            }
                                        }
                                    },
                                    "type": {
                                        "enum": [
                                            "Java",
                                            "Scala",
                                            "Python",
                                            "R"
                                        ]
                                    }
                                }
                            }
                        }
                    }
                },
                "version": "v1beta1",
                "versions": [
                    {
                        "name": "v1beta2",
                        "served": true,
                        "storage": false
                    },
                    {
                        "name": "v1beta1",
                        "served": true,
                        "storage": true
                    }
                ]
            },
        }
    ]
} else "SKIP"
