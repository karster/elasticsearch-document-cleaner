#!/bin/bash

NORMAL=$(echo "\033[m")
BOLD=$(echo "\033[1m")
YELLOW=$(echo "\033[33m")
GREEN=$(echo "\033[32m")
FGRED=$(echo "\033[41m")

function printTitle
{
	printf "\n"
    printf "${YELLOW}$1${NORMAL}"
    printf "\n"
}

function printDone 
{
    printf "\n"
    printf "${GREEN}Done${NORMAL}"
    printf "\n"
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

function printHelp
{
    printf "\nusage:
elasticsearch-document-cleaner [ -f | -h | -p | -d | -i ]

-d <number>, --days <number>
Defines days, default 14.

-p <9200>, --port <9200>
Port, default 9200.

-h <localhost>, --host <localhost>
Host name, default \"localhost\".

-i <index>, --index <index>
Index name. If empty get list all indices.

-f, --force
Don't ask for confirm to delete indexes.
"
}

function deleteDocuments
{
    count=$(getCount)

    if [ "$count" != "0" ]; then
        printf "\n"

        if [ "${FORCE}" -eq "0" ]; then
            printf "${FGRED}Are you sure you want to delete these ${BOLD}${count}${NORMAL}${FGRED} documents${NORMAL} [Y/n]: "
            read -r
        else 
            REPLY="y"
        fi

        if [ "$REPLY" == "y" ] || [ "$REPLY" == "Y" ]; then
            printSubject "Deleting documents..."
            deleted=$(curl -XPOST ${HOST}:${PORT}/${INDEX}/_delete_by_query -H 'Content-Type: application/json' -d"`getQuery ${DATE}`" 2>&1 | grep -oP 'deleted":(\d+)' | grep -oP '(\d+)')
            printf "\n"
            printf "${GREEN}${deleted} documents are removed${NORMAL}"
        else
            printf "\n"
            printf "Skip..."
        fi

    else
        printf "No documents find"
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
            printTitle "ElasticSearch Document Cleaner"
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

printTitle "ElasticSearch Document Cleaner"

if [ "$INDEX" == "" ]; then
    printTitle "Finding indices..."
    findIndices
else

    printTitle "Finding documents..."
    deleteDocuments
fi

exit 0

