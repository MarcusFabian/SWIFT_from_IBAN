codeunit 50202 "Get SWIFT from IBAN"
{
    internal procedure GetSWIFT(IBAN: Text; HideDialog: Boolean): Code[20]
    var
        Handled: Boolean;
        SWIFT: Code[20];
    begin
        OnBeforeGetSWIFT(IBAN, SWIFT, Handled);
        DoGetSWIFT(IBAN, SWIFT, HideDialog, Handled);
        OnAfterGetSWIFT(IBAN, SWIFT);
        //AcknowledgeGetSWIFT(IBAN, SWIFT, HideDialog);
        Exit(SWIFT);
    end;

    local procedure DoGetSWIFT(IBAN: Text; Var SWIFT: Code[20]; HideDialog: Boolean; Handled: Boolean)
    /// This is the heart and soul of the Codeunit:
    /// 
    /// Use the following URL to retrieve the BIC:
    /// https://openiban.com/validate/CH5604835012345678009?getBIC=true&validateBancCode=true
    /// replace CH....284 with the required IBAN
    /// 
    /// The answer will be a json record which looks like this:
    ///
    /*

   {
  "valid": true,
  "messages": [],
  "iban": "CH5604835012345678009",
  "bankData": {
    "bankCode": "04835",
    "name": "Credit Suisse (Schweiz) AG",
    "bic": "CRESCHZZ81G"
    },
  "checkResults": {}
  }
    

    */
    /// We need to extract $.bankdata.bic
    /// 

    var
        _HTTPClient: HttpClient;
        ResponseMessage: HttpResponseMessage;
        HttpURL: Text;
        JSonText: text;
        JSonObject: JsonObject;
        JSonToken: JsonToken;
        JSonValue: JsonValue;

    begin
        if Handled then
            exit;
        HttpURL := StrSubstNo('https://openiban.com/validate/%1?getBIC=true&validateBancCode=true', IBAN);
        _HTTPClient.DefaultRequestHeaders.Add('User-Agent', 'Dynamics 3650');
        if not _HTTPClient.Get(HttpURL, ResponseMessage) then begin
            if not HideDialog then
                error('HTTP Request to %1 failed.', HttpURL);
        end
        else begin
            if not ResponseMessage.IsSuccessStatusCode then begin
                if not HideDialog then
                    error('Http Request Eror message:\\Status Code: %1\Description: %2', ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase);
            end
            else begin
                ResponseMessage.Content.ReadAs(JSonText);
                if not JSonObject.ReadFrom(JSonText) then begin
                    if not HideDialog then
                        error('Invalid response, expected a JSON array as root object');
                end
                else begin
                    if not JSonObject.SelectToken('$.bankData.bic', JSonToken) then begin
                        if not HideDialog then
                            error('leider keine bic gefunden :-(');
                    end
                    else begin
                        JSonValue := JSonToken.AsValue();
                        SWIFT := JSonValue.AsCode();
                    end;
                end;
            end;
        end;
    end;


    local procedure AcknowledgeGetSWIFT(IBAN: text; SWIFT: Code[20]; HideDialog: Boolean)
    var
        AcknowledgeMsg: label 'The SWIFT Code of IBAN >%1< reads: >%2<';
    begin
        if Not GuiAllowed or HideDialog then exit;
        Message(AcknowledgeMsg, iban, swift);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetSWIFT(var IBAN: Text; Var SWIFT: Code[20]; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetSWIFT(var IBAN: Text; Var SWIFT: Code[20]);
    begin
    end;

}
