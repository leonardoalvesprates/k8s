#!/bin/bash

green=$(tput setaf 2)
normal=$(tput sgr0)

for EACH in $(find . | grep kb-output)
do
printf "${green}$EACH ${normal}\n"
jq -r '.Controls[].tests[].results[] | select (.status == "FAIL") |.test_number, .test_desc,.remediation' < $EACH
done
