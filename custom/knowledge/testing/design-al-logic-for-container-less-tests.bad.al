// BAD: the business logic lives inside the subscriber body and calls a dependency
// codeunit directly. A container-less runner cannot fire the base-app event and
// auto-stubs the dependency, so none of this logic can be unit-tested.

codeunit 50120 "Order Release Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterModifySalesHeader(var Rec: Record "Sales Header")
    var
        InventoryMgt: Codeunit "Inventory Mgt."; // from another app: auto-stubbed, returns false
    begin
        if Rec.IsTemporary() then
            exit;

        // Branching, validation and a cross-app call are all trapped inside the
        // subscriber. There is no procedure a test could call, and the event
        // never fires under the runner — so this path is unreachable from a unit test.
        if Rec."No." <> '' then
            if InventoryMgt.HasStock(Rec."No.") then
                Rec.Status := Rec.Status::Released;
    end;
}
