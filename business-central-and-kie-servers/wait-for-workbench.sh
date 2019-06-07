#!/bin/bash
# Script to keep testing business central API availability before
# starting up KIE execution server
for i in {1..10}
do
  echo "Checking for Business Central availability..."
  # -f (--fail) Fail silently on HTTP errors
  # -s (--silent) Don't show progress meter or error messages
  # -m (--max-time n) exit after n seconds prevent curl waiting indefinitely
  # -u (--user user:pass) set basic auth base64-encoded credentials
  curl -f -s -m 2 -u ${KIE_SERVER_USER}:${KIE_SERVER_PWD} \
    http://drools-workbench:8080/business-central/rest/spaces
  if [ $? = 0 ]
  then
    # Endpoint is ready to execute KIE Server boot up
    echo "Business Central is ready. Starting KIE Execution Server."
    sleep 5
    ./start_kie-server.sh
    exit 0
  else
    # cURL error most likely means endpoint is not ready
    printf "Business Central not ready, retrying in 10 seconds...\n"
  fi
  sleep 20
done

printf "Failed to wait for Business Central after $i attempts.\n" 1>&2
exit 1
