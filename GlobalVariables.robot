*** Settings ***
Resource   ../resources/GlobalVariables.robot
Documentation    To get Authorization token.
Suite Setup  Create Session  authtokenURL  ${authtokenURL}
${tokenURL}  /sso-api/auth/token
${URI}  /sso-api/v1/token
*** Variables ***

${URI}  /sso-api/v1/token
${URI1}  /sso-api/auth/renewtoken
${URI2}  /modelregistry/v1/ping
${grantType}  password
${scope}  openid
${authtokenURL}  https://qa-api.sso.moodysanalytics.net
${CAP_URL}  https://qa-api.cap.moodysanalytics.net
${clientId}  _DkGikdVhgTof8vSZNOdIfF9JZEa
${clientSecret}  AjniSzQVn2N6KgIfUg_j0oAug5ca
@{VERSIONS}=       0  1  2  3  4  5  6  7  8  9
${versionName}  v1
${name1}  Cross tenant model
${name2}  Model Hello World 7
${name 3}  Model Hello World 5
${name 4}  Model Hello World Interactive
${name 5}  Commercial Mortgage Metrics REIS
${name 6}  batchRunStatus
${runID}  1141658
${user}  demo_deployer@moodys.com
${password}  Password123!

*** Test Cases ***

Anna can get all the models for a particular tenant
  [Tags]  Critical
  [Documentation]  - Get job status by ID
  Create Session      cap    ${CAP_URL}
  ${token}=  Get Token Bank1
  ${headers1}=  Create Dictionary   Authorization   ${token}
  ${resp}=  Get Request  cap  /modelregistry/v1/models  headers=${headers1}
  Should Be Equal As Strings  ${resp.status_code}  200
  Log    ${resp.content}

*** Test Cases ***

Alex can Create a New Model for same tenant user
  [Tags]   POST
  Create Session      cap    ${CAP_URL}
  ${json_string} =  Get File  ${dataPath}/ModelVersion/create_model.json
  ${token}=  Get Token Bank1
  ${headers1}=  Create Dictionary   Content-Type    application/json   Authorization   ${token}

  ${resp}=  Post Request        cap    /modelregistry/v1/models   data=${json_string}  headers=${headers1}
  Should Be Equal As Strings  ${resp.status_code}  201
  Dictionary Should Contain Key
           ...                ${resp.json()}       _id
         Log                  ${resp.json()["name"]}
         ${name}    set variable    ${resp.json()["name"]}
         Set Global Variable      ${name}


*** Settings ***
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary

*** Variables ***
${CAP_URL}        http://your-cap-service-url
${CSV_FILE}       models.csv        # Path to your CSV file

*** Test Cases ***
Run Batch Test for Multiple Models
    [Documentation]    Run batch tests for multiple models using data from a CSV file
    ${models}=         Read CSV File    ${CSV_FILE}
    FOR    ${model}    IN    @{models}
        ${name}=       Get From Dictionary    ${model}    name
        ${version}=    Get From Dictionary    ${model}    versionName
        Log            Running test for model: ${name}, version: ${version}
        Run Batch Test    ${name}    ${version}
    END

Run Batch Test
    [Arguments]    ${name}    ${version}
    ${token}=      Get Token NoCAPAccess
    ${headers1}=   Create Dictionary   Content-Type=application/json   Authorization=${token}
    ${resp}=       Post Request    cap    /modelregistry/v1/batch-runs/models/${name}/versions/${version}    headers=${headers1}
    Should Be Equal As Strings    ${resp.status_code}    403
    Log            ${resp.json()}

*** Keywords ***
Read CSV File
    [Arguments]    ${file_path}
    @{lines}=      Get File Lines    ${file_path}
    ${header}=     Split String      ${lines[0]}    ,
    ${data}=       Create List
    FOR    ${line}    IN    @{lines[1:]}
        ${values}=   Split String    ${line}    ,
        ${row}=      Create Dictionary    ${header[0]}=${values[0]}    ${header[1]}=${values[1]}
        Append To List    ${data}    ${row}
    END
    [Return]       ${data}
