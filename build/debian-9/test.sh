#!/bin/bash
set -e

total=166
after=5

# Verify we're starting with the correct number of certs
/bin/cert-manage -list -count | grep $total

# Make a backup
/bin/cert-manage -backup

# Quick check
ls -1 /usr/share/ca-certificates/* | wc -l | grep $total
ls -1 /usr/share/ca-certificates.backup/* | wc -l | grep $total

# Whitelist and verify
/bin/cert-manage -whitelist -file /whitelist.json
/bin/cert-manage -list -count | grep $after

# Restore
/bin/cert-manage -restore
/bin/cert-manage -list -count | grep $total

# Java tests
echo "Java"

# Take a backup and verify
/bin/cert-manage -list -app java -count | grep 166
/bin/cert-manage -backup -app java
ls -1 ~/.cert-manage/java | wc -l | grep 1

# verify things are ok
java Download

# Break the keystore
echo a > /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts

# Restore
/bin/cert-manage -restore -app java
/bin/cert-manage -list -app java -count | grep 166

# Verify restore
size=$(stat --printf="%s" /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts)
if [ ! "$size" -gt "2" ];
then
    echo "failed to restore java cacerts properly"
    exit 1
fi

/bin/cert-manage -whitelist -file /whitelist.json -app java
/bin/cert-manage -list -app java -count | grep 12

# Verify google.com request fails now that it should
set +e
out=$(java Download 2>&1)
set -e
if ! echo "$out" | grep 'PKIX path building failed';
then
    echo "Expected http response failure, but got something else, response:"
    echo "$out"
    exit 1
fi

echo "Debian 9 Passed"
