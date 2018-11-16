{
    # Receives an array of patterns and the value must match at least one of these patterns
    # OPTIONAL: notAllowed flag to make sure values must NOT match any of the patterns
    MatchPatterns(allowed, notAllowed=[]):: {
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
    Unsupported(unsupported):: {
        not: {
            anyOf: [
                { required: [ unsupportedElement ] }
                for unsupportedElement in unsupported
            ]
        }
    },

    # Receives an array of 2 values 
    Range(range):: {
        # Add error checking here later
        minimum: range[0],
        maximum: range[1],
    },

    # Receives an array of values that restricts the field to a fixed set of values
    AllowedValues(values):: {
        enum: values,
    },
}