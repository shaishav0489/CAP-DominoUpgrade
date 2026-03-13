*** Settings ***
Resource  ../resources/GlobalVariables.robot
Documentation    To get Authorization token.
Suite Setup  Create Session  authtokenURL  ${authtokenURL}

*** Variable ***

${URI}  /sso-api/v1/token
${URI1}  /sso-api/auth/renewtoken
${grantType}  password
${scope}  openid
#${authtokenURL}  https://qa-api.sso.moodysanalytics.net
${clientId}  _DkGikdVhgTof8vSZNOdIfF9JZEa
${clientSecret}  AjniSzQVn2N6KgIfUg_j0oAug5ca

*** Test Cases ***
Get auth token from user login flow with all value( username , password , granttype, scope , client id, client secret)
   [Tags]  Critical  Smoke
   [Documentation]  - to login user and get auth token
   Wait Until Keyword Succeeds  2 min  4 seconds  Get token with v1  ${user}  ${password}
