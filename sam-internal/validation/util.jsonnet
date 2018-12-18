{
    # Receives an array of patterns and the value must match at least one of these patterns
    # OPTIONAL: notAllowed flag to make sure values must NOT match any of the patterns
    MatchRegex(allowed, notAllowed=[]):: {
        allOf: [
            {
                anyOf: [ 
                    { pattern: allowedPattern } 
                    for allowedPattern in allowed
                ] 
            },
            
            if notAllowed == [] then {}
            else  { 
                not: {
                    anyOf: [
                        { pattern: notAllowedPatterns } 
                        for notAllowedPatterns in notAllowed
                    ] 
                } 
            }
           
        ]
    },

    # Receives an array of patterns that MUST NOT be matched
    DoNotMatchRegex(notAllowed):: {
        not: {
            anyOf: [
                { pattern: notAllowedPatterns } 
                for notAllowedPatterns in notAllowed
            ] 
        } 
    },

    # Receives an ARRAY OF OBJECTS and the value cannot match any of the rules defined in the objects
    ListNotAllowed(reserved):: {
        not: {
            anyOf: reserved
        }
    },

    # Receives an ARRAY OF VALUES (integer/string) and the value cannot match any of the values included
    ValuesNotAllowed(notAllowed):: {
        not: {
            enum: notAllowed
        }
    },

    # Receives an array of REQUIRED elements that MUST exist
    Required(reqList):: {
        required: reqList
    },

    # Receives an array of UNSUPPORTED elements that CANNOT exist
    NotAllowed(notAllowed):: {
        propertyNames: $.ValuesNotAllowed(notAllowed)
    },

    # Receives an array of 2 values 
    Range(range):: {
        minimum: range[0],
        maximum: range[1],
    },

    # Receives an array of values that restricts the field to a fixed set of values
    AllowedValues(values):: {
        enum: values,
    },

    # Receives 2 property values and ensures that exactly 1 of the 2 values exist
    ExactlyOneExists(value1, value2):: {
        anyOf: [
            {
                allOf: [
                    $.Required([ value1 ]), 
                    $.NotAllowed([ value2 ])
                ]
            },
            { 
                allOf: [
                    $.Required([ value2 ]), 
                    $.NotAllowed([ value1 ])
                ]
            }
        ]
    },

    # Field MAY ONLY exist for certain groups
    Whitelist(condition={}, regularResult={}, whitelistResult={}):: {
        "if": {
            properties: condition
        }, 
        "then": regularResult,
        "else": whitelistResult
    },

    # Field CANNOT exist for certain groups
    Blacklist(condition={}, regularResult={}, blacklistResult={}):: {
        "if": {
            properties: condition
        }, 
        "then": blacklistResult,
        "else": regularResult
    },
}