#!/bin/bash

out_f="RDG.arff"
num_examples=100000
num_attributes=25
num_classes=2
minimum_size=3
numeric_attributes=2

while getopts "h" opt;
do
    case $opt in
        h) echo "usage: $0 [ -f OUTPUT_FILE ] [ -e NUMBER OF INSTANCES ] [ -a NUMBER OF ATTRIBUTES ] [ -c NUMBER OF CLASSES ] [ -m MINIMUM RULE SIZE ] [ -n NUMBER OF NUMERIC ATTRIBUTES ]"
        exit 0
        ;;
    esac
done

while getopts "f:e:a:c:m:n" opt;
do
    case $opt in
        f) out_f="${OPTARG}"
        ;;
        e) num_examples="${OPTARG}"
        ;;
        a) num_attributes="${OPTARG}"
        ;;
        c) num_classes="${OPTARG}"
        ;;
        m) minimum_size="${OPTARG}"
        ;;
        n) numeric_attributes="${OPTARG}"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
        exit 1
        ;;
    esac

    case $OPTARG in
        -*) echo "Option $opt needs a valid argument"
        exit 1
        ;;
    esac
done

$WEKA_HOME/weka.sh -main weka.Run .RandomRBF -o $out_f -n $num_examples -a $num_attributes -c $num_classes -M $minimum_size -N $numeric_attributes