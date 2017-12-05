#!/bin/bash
set -e

# Run OSX ci tests if we're on darwin
if [[ `uname -s` == 'Darwin' ]];
then
    echo "== START OSX"
    version=$(./bin/cert-manage-osx-amd64 -version)
    echo "cert-manage ($version)"

    ./bin/cert-manage-osx-amd64 -list -count
    ./bin/cert-manage-osx-amd64 -backup
    # TODO(adam): Need to run -whitelist and -restore

    if [[ -d "/Applications/Firefox.app" ]];
    then
        echo "Firefox"
        set +e
        out=$(./bin/cert-manage-osx-amd64 -list -app firefox -count)
        count=$(echo "$out" | tail -n1)
        if [[ "$?" -ne "0" ]];
        then
            echo "Error: $count"
            exit 1
        fi
        set -e
        if [[ ! "$count" -gt "1" ]];
        then
            echo "Only found $count firefox certs"
            exit 1
        else
            echo "Found $count firefox certs"
        fi
        echo "Firefox Passed"
    fi

    if [[ -n "JAVA_HOME" ]];
    then
        echo "Java"
        set +e
        out=$(./bin/cert-manage-osx-amd64 -list -app java -count)
        count=$(echo "$out" | tail -n1)
        if [[ "$?" -ne "0" ]];
        then
            echo "Error: $count"
            exit 1
        fi
        set -e
        if [[ ! "$count" -gt "1" ]];
        then
            echo "Only found $count java certs"
            exit 1
        else
            echo "Found $count java certs"
        fi
        echo "Java Passed"
    fi

    echo "== END OSX"
fi
