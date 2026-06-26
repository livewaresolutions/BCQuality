// BEST PRACTICE: build the wildcard filter with StrSubstNo first, then apply it.
// StrSubstNo always substitutes %1, so the applied filter is '@*<value>*' with wildcards intact.
codeunit 50101 FundLookupGood
{
    procedure FindByName(SearchText: Text; var SuperFund: Record "Super Fund")
    begin
        SuperFund.SetFilter(Name, StrSubstNo('@*%1*', SearchText));
        if SuperFund.FindSet() then;
    end;

    // For an exact, full-value lookup, SetRange needs no wildcards or placeholders at all.
    procedure FindByUsi(Usi: Code[20]; var SuperFund: Record "Super Fund")
    begin
        SuperFund.SetRange(USI, Usi);
        if SuperFund.FindSet() then;
    end;
}
