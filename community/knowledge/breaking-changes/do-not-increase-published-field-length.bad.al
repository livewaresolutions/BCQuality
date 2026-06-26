// ANTI-PATTERN: widening a field that already shipped in a previous version.
// Triggers AppSourceCop AS0086 and can break dependent extensions that read the field
// into a shorter variable.

// Version 1.0 (already published):
table 50100 SuperFund
{
    fields
    {
        field(7; "Electronic Service Address"; Text[50]) { }
    }
}

// Version 2.0 (BREAKING - AS0086):
table 50100 SuperFund
{
    fields
    {
        field(7; "Electronic Service Address"; Text[100]) { }
    }
}
