#!/bin/bash

for EACH in $(find . | grep kb-output)
do
echo $EACH
jq -r '.Controls[].tests[].results[] | select (.status == "FAIL")' < $EACH
done
