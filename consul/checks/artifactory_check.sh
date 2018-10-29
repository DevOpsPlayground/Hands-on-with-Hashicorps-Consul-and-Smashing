#!/bin/bash

CONSUL_URL="http://localhost:8500/v1/health/checks/artifactory"
SMASHING_URL="http://localhost:9292"


function postFailingResults() {
  curl -d "{ \"auth_token\": \"playground\", \"status\": \"down\", \"moreinfo\": \"Artifactory Service Is Experiencing Issues\", \"items\": [  $1 ] }" $SMASHING_URL/widgets/repo
}

function postPassingResults() {
  curl -d "{ \"auth_token\": \"playground\", \"status\": \"up\", \"moreinfo\": \"No Issues Currently Reported\", \"items\": [  $1 ] }" $SMASHING_URL/widgets/repo
}

#Get the service status from Consul
OUTPUT=$(curl -f -w '%{http_code}' -L -k "$CONSUL_URL" -o /tmp/artifactory_checks 2>&1)
RESPONSE_CODE=${OUTPUT: -3}
STATUS=$(jq --raw-output .[].Status   /tmp/artifactory_checks)

# Send relevant update to the Smashing board
if [[ "$STATUS" == "passing" ]]; then
  postPassingResults
else
  postFailingResults "{\"label\": \"Artifactory\", \"value\": \"Failing\"}"
fi