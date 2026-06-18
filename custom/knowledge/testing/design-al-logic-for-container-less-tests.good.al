// GOOD: thin subscriber delegates to a public procedure; the external collaborator
// is injected through an interface, so both are unit-testable without a container.

interface "IStock Check"
{
    procedure HasStock(ItemNo: Code[20]): Boolean;
}

codeunit 50110 "Order Processor"
{
    // Pure, directly callable logic — a container-less runner can invoke this as-is.
    procedure CanRelease(ItemNo: Code[20]; Checker: Interface "IStock Check"): Boolean
    begin
        exit((ItemNo <> '') and Checker.HasStock(ItemNo));
    end;
}

codeunit 50111 "Order Release Subscriber"
{
    // The subscriber stays thin: it only wires the event to the testable procedure.
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterModifySalesHeader(var Rec: Record "Sales Header")
    var
        OrderProcessor: Codeunit "Order Processor";
        StockCheck: Codeunit "Default Stock Check"; // implements "IStock Check"
    begin
        if Rec.IsTemporary() then
            exit;
        if OrderProcessor.CanRelease(Rec."No.", StockCheck) then
            Rec.Status := Rec.Status::Released;
    end;
}
