#!/bin/bash

DEFAULT=$(echo "\033[m")
BOLD=$(echo "\033[1m")
WARNING=$(echo "\033[33m")
SUCCESS=$(echo "\033[32m")
DANGER=$(echo "\033[31m")
INFO=$(echo "\033[36m")
FGDANGER=$(echo "\033[41m")

function printInfo
{
    printf "\n${WARNING}$1${DEFAULT}\n"
}

function printSuccess
{
    printf "\n${SUCCESS}$1${DEFAULT}\n"
}

function printDefault
{
    printf "\n${DEFAULT}$1${DEFAULT}\n"
}

function printHelp
{
    printf "\nusage:
elasticsearch-document-cleaner [ -f | -h | -p | -d | -i ]

-d <number>, --days <number>
Defines days, default 14.

-p <number>, --port <number>
Port, default 9200.

-h <string>, --host <string>
Host name, default \"localhost\".

-i <string>, --index <string>
Index name. If empty get list all indices.

-f, --force
Don't ask for confirm to delete indexes.
"
}

function getQuery
{
    echo '{
	    "query":{
	        "range": {
	            "@timestamp": {
	                "lte": "'$1'"
	            }
	        }
	    }
	}'
}

function getCount
{
    curl -XGET ${HOST}:${PORT}/${INDEX}/_count -H 'Content-Type: application/json' -d"`getQuery ${DATE}`" 2>&1 | grep -oP 'count":(\d+)' | grep -oP '(\d+)'
}

function findIndices
{
    curl -XGET ${HOST}:${PORT}/_cat/indices 2>&1
}

function deleteDocuments
{
    count=$(getCount)

    if [ "$count" != "0" ] && [ "$count" != "" ]; then
        printf "\n"

        if [ "${FORCE}" -eq "0" ]; then
            printf "${FGDANGER}Are you sure you want to delete these ${BOLD}${count}${DEFAULT}${FGDANGER} documents${DEFAULT} [Y/n]: "
            read -r
        else 
            REPLY="y"
        fi

        if [ "$REPLY" == "y" ] || [ "$REPLY" == "Y" ]; then
            printInfo "Deleting documents..."
            deleted=$(curl -XPOST ${HOST}:${PORT}/${INDEX}/_delete_by_query -H 'Content-Type: application/json' -d"`getQuery ${DATE}`" 2>&1 | grep -oP 'deleted":(\d+)' | grep -oP '(\d+)')
            printSuccess "${deleted} documents are removed"
        else
            printDefault "Skip..."
        fi

    else
        printDefault "No documents find"
    fi
}

FORCE=0
DAYS=14
PORT=9200
HOST="localhost"
INDEX=""
while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -f|--force)
            FORCE=1
        ;;

        -h|--host)
            shift 
            HOST="$1"
        ;;

        -p|--port)
            shift 
            PORT="$1"
        ;;

        -d|--days)
            shift 
            DAYS="$1"
        ;;

        -i|--index)
            shift 
            INDEX="$1"
        ;;

        *)
            printInfo "ElasticSearch Document Cleaner"
            printHelp
            exit 0
        ;;
    esac
    shift
done

date --version > /dev/null 2>&1
if [ $? == 0 ]; then
    DATE="$(date +%Y-%m-%d -d "-${DAYS}days")"
else
    DATE="$(date -v-${DAYS}d +%Y-%m-%d)"
fi

printInfo "ElasticSearch Document Cleaner"

if [ "$INDEX" == "" ]; then
    printInfo "Finding indices..."
    findIndices
else

    printInfo "Finding documents..."
    deleteDocuments
fi

exit 0

