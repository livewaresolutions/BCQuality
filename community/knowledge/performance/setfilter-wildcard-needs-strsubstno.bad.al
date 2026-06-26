// ANTI-PATTERN: %1 is not substituted when the SetFilter format string also contains wildcards.
// The applied filter becomes the literal '@*%1*', so the lookup silently matches nothing.
codeunit 50100 FundLookupBad
{
    procedure FindByName(SearchText: Text; var SuperFund: Record "Super Fund")
    begin
        // Debugger shows: Filters = Name: @*%1*  (the value was never inserted)
        SuperFund.SetFilter(Name, '@*%1*', SearchText);
        if SuperFund.FindSet() then;
    end;
}
