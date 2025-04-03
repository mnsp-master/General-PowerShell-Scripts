# GLPI REST API CONFIG :
$AppURL =     "http://server/apirest.php/"
$UserToken =  "xxxxxxxxx"
$AppToken =   "yyyyyyyyy"
$createUrl = "http://server/apirest.php/Ticket"

# session creation
$SessionToken = Invoke-RestMethod "$AppURL/initSession" -Method Get -Headers @{"Content-Type" = "application/json";"Authorization" = "user_token $UserToken";"App-Token"=$AppToken}

# Things to do
$data = @{
    "input" = @(
        @{
            "content" = "Ticket description"
            "name" = "Depart Salarie"
            "_groups_id_requester" = "1"
            "priority" = "4"
            "urgency" = "2"
            "status" = "1"
            "impact" = "3"
        }
    )
}
$json = $data | ConvertTo-Json
Invoke-RestMethod -Method POST -Uri $createUrl -Headers @{"session-token"=$SessionToken.session_token; "App-Token" = "$AppToken"} -Body $json -ContentType 'application/json'

# Kill of the session
Invoke-RestMethod "$AppURL/killSession" -Headers @{"session-token"=$SessionToken.session_token; "App-Token" = "$AppToken"}