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
