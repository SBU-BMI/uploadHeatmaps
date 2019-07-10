#!/bin/bash
# bash uploadHeatmaps.sh <options>
# Authors: Alina Jasniewski, Joseph Balsamo

# Functions
# function: usage(brief)
function usage() {
    echo "Usage: $ ./uploadHeatmaps.sh [options] -h <host> -f <filename>"
    if [ $1 == false ]
    then
      echo "  Options:"
      echo "    -f <filename>: filename of the data to be loaded (this parameter required)"
      echo "    -h <host>: ip or hostname of database (this parameter required)"
      echo "    -d <database name> (default: quip)"
      echo "    -p <database port> (default: 27017)"
      echo ""
      echo "    --help Display full help usage."
      echo "  Notes: requires mongoDB client tools installed on running server"
      echo "  Notes: If '-f' parameter is *, it must be in quotes."
    fi
}
# end functions

# Set Default variables.
database="camic"
port="27017"
HOST="ca-mongo"
errcode=0
brief=true

while [ -n "$1" ]
# while loop starts
do
  # Process commandline flags
  case "$1" in
    -q) qhost="$2"
        shift;;
    -h) host="$2"
        shift;;
    -P) port="$2"
        shift ;;
    -p) passw="$2"
        shift ;;
    -c) collection="$2"
        shift ;;
    -u) uname="$2"
        shift ;;
    -i) in="$2"
        shift ;;
    -o) out=${2}
        shift;;
    -d) database=${2}
        shift;;
    --help)  
        usage false
        exit 0;;
    *) usage true;; 
  esac
  shift
done

if [ -z "${collection}" ] || [ -z "${passw}" ] || [ -z "${uname}" ] 
then
  echo "Missing required parameters"
  usage true
  exit 1
fi

# Set default values for unprovided options.
if [ -z "${host}" ]
then
  host="ca-mongo"
fi
if [ -z "${qhost}" ]
then
  qhost="quip-pathdb"
fi
if [ -z "${in}" ]
then
  in="/data/xfer/input"
fi
if [ -z "${out}" ]
then
  out="data/xfer/output"
fi
if [ -z "${port}" ]
then
  port="27017"
fi
if [ -z "${database}" ]
then
  database="camic"
fi

# Convert heatmap data in the 'in' folder into uploadable json in the 'out' folder.
node /usr/local/bin/convert_heatmaps.js -h ${qhost} -c ${collection} -i ${in} -o ${out} -u ${uname} -p ${passw}

# Import into the quip database
for filename in ${out}/*.json ; do
  mongoimport --port ${port} --host ${host} -d ${database} -c heatmap ${filename}
done

exit 0