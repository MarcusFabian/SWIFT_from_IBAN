pageextension 50204 "Vendor Bank Account Ext SWIFT" extends "Vendor Bank Account Card"
{
    layout
    {
        modify(IBAN)
        {
            trigger OnAfterValidate()
            var
                cuGetSWIFT: Codeunit "Get SWIFT from IBAN";
                _LocalSWIFT: code[20];
            begin
                _LocalSWIFT := cuGetSWIFT.GetSWIFT(rec.IBAN, true);  // true=ignore all error messages
                if (_LocalSWIFT <> '') and (_LocalSWIFT <> Rec."SWIFT Code") then begin
                    rec.Validate("SWIFT Code", _LocalSWIFT);
                end
            end;
        }
    }
}
