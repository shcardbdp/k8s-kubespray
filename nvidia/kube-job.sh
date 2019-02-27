#!/bin/bash

set -e

parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}


usage() { echo "Usage: $0 [-f job yml file] [-t sleep time (default: 30s)] [-d work day(default D-1)]" 1>&2; exit 1; }

t=1m
while getopts ":f:t:" flag; do
    case "${flag}" in
        f)
            f=${OPTARG}
            ;;
        t)
            t=${OPTARG}
            ;;
        d)
            d=${OPTARG}
            ;;                   
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${f}" ]; then
    usage
fi

eval $(parse_yaml ${f} "config_")

n=$config_metadata_name



echo "f = ${f}"
echo "n = ${n}"
echo "i = ${i}"
echo "d = ${d}"

# change JOBMIND_K8S_DATE_VAR_01  in YAML
cat $f |sed -e "s/JOBMIND_K8S_DATE_VAR_01/${d}/g" > tmp_$n

kubectl delete -f tmp_$n
kubectl apply -f tmp_$n
#kubectl apply -f ${f}

while :; do
  if  kubectl get jobs ${n} -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}' | grep -q 'True'
  then
    echo "the job is done."
    exit 0
  elif kubectl get jobs ${n} -o jsonpath='{.status.conditions[?(@.type=="Failed")].status}'  | grep -q 'True'
  then
    echo "the job failed"
    exit 1
  else 
    echo -e ".\c"
    sleep ${t}
  fi
done 