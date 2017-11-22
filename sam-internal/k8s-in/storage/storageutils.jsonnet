// Public functions
{   
    string_replace(str, to_replace, replace_with):: (
        std.join("", std.map(function(x) if x == to_replace then replace_with else x, std.stringChars(str)))
    ),
}