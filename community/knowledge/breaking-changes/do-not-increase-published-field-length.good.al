// BEST PRACTICE: leave the published field's length untouched; add a new, larger field instead.
// New fields have no previous version to compare against, so they can be sized freely.

// Version 2.0 - the existing field keeps its length; a new field carries the longer value.
table 50100 SuperFund
{
    fields
    {
        field(7; "Electronic Service Address"; Text[50]) { }       // unchanged
        field(20; "ESA URL"; Text[250]) { }                        // new, sized correctly up front
    }
}

// Alternative when the same field number must grow: the two-version obsolete lifecycle.
// 1) Ship the field as ObsoleteState = Pending.
// 2) In a later version, remove the Pending state AND change the length together.
