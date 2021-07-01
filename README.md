# SWIFT_from_IBAN

For Business Central (all Versions)

The purpose of this APP is to extend the Vendor Bank Account in a way that OnValidate() of the IBAN Number, the SWIFT Code is automatically
determined and filled.

For this purpose we use a Web-Service from https://openiban.com/

Example:
In order to find the SWIFT Code for IBAN: CH5604835012345678009

We could manually enter the following Link:
https://openiban.com/validate/CH5604835012345678009?getBIC=true&validateBancCode=true

The result is a JSON-Object in the Form:

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

We can now extract the SWIFT Code from $.bankData.bic

