{
    // Available Error Types for $expected field
    
    // For when the test should pass with no errors
    none: "pass",

    // For the 'not' keyword, when a not allowed value, property, pattern is used
    notAllowedValuesUsed: "number_not",

    // For the 'required' keyword, when for when a required field doesn't exist
    requiredPropertyDoesntExist: "required",

    // For the 'enum' keyword, when a value that was not the specific set of values allowed is used
    allowedValuesNotUsed: "enum",

    // For the 'pattern' keyword, when a value that does not match the regex defined is used
    doesNotMatchPattern: "pattern",

    // For the 'additionalProperty' keyword, when properties that are not defined in the schema are used
    additionalPropertyNotAllowed: "additional_property_not_allowed",

    // For the 'minLength' keyword for string, when a string reaches or is less than the minLength defined
    stringBelowMin: "string_gte",

    // For the 'maxLength' keyword for string, when a string reaches or exceeds the maxLength defined
    stringExceedsMax: "string_lte",

    // For the 'minimum' keyword for numbers, when a number reaches or is less than the min defined
    numberBelowMin: "number_gte",

    // For the 'maximum' keyword for numbers, when a number reaches or exceeds the max defined
    numberExceedsMax: "number_lte",

    // For the 'minItems' keyword for arrays, when an array reaches or has less elements than the min defined    
    arrayBelowMin: "array_max_items",

    // For the 'maxItems' keyword for arrays, when an array reaches or has more elements than the max defined
    arrayExceedsMax: "array_min_items",


    // Below are for errors types that we are currently not using, please update them if they ever get used
    array_no_additional_items: "array_no_additional_items",
    invalid_property_pattern: "invalid_property_pattern",
    invalid_property_name: "invalid_property_name",
    array_min_properties: "array_min_properties",
    array_max_properties: "array_max_properties",
    missing_dependency: "missing_dependency",
    invalid_type: "invalid_type",
    multiple_of: "multiple_of",
    internal: "internal",
    contains: "contains",
    unique: "unique",
}