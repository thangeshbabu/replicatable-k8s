#!/bin/bash

set -e

export name group ca ca_key

function parse () {

    while [[ "$1" ]]; do 
        case "$1" in
        -name|-n) shift; name="$1";;
        -group|-g) shift; group="$1";;
        --ca) shift; ca="$1";;
        --ca-key) shift; ca_key="$1";;
        esac
        shift
    done

}


function main () {
    parse "$@"
    base_folder="users/$name"
    [[ ! -d "$base_folder" ]] && mkdir -p $base_folder

    echo "Creating private key"
    private_key="$base_folder/$name.key"
    openssl genrsa -out "$private_key" 2048

    echo "Creating CSR "
    subject="/CN=$name"
    [[ ! -z "$group" ]] && subject="$subject/O=$group"
    csr_file="$base_folder/$name.csr"
    openssl req -new -key "$private_key" -subj "$subject" -out "$csr_file"

 
    echo "Creating client Certificate using CA and CA.key"
    [[ ! -f "$ca" ]] && echo "ca path does not exist or empty <$ca>" && exit 1
    [[ ! -f "$ca_key" ]] && echo "ca_key path does not exist or empty <$ca_key>" && exit 1

    openssl x509 -req -in "$csr_file" -CA "$ca" -CAkey "$ca_key" -out "$base_folder/$name.crt" 

}

main "$@"
