#!/bin/bash

out_f="RBF.arff"
num_examples=100000
num_attributes=25
num_classes=2

while getopts "h" opt;
do
    case $opt in
        h) echo "usage: $0 [ -f OUTPUT_FILE ] [ -e NUMBER OF INSTANCES ] [ -a NUMBER OF ATTRIBUTES ] [ -c NUMBER OF CLASSES ]"
        exit 0
        ;;
    esac
done

while getopts "f:e:a:c" opt;
do
    case $opt in
        f) out_f="${OPTARG}"
        e) num_examples="${OPTARG}"
        ;;
        a) num_attributes="${OPTARG}"
        ;;
        c) num_classes="${OPTARG}"
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

./weka.sh -main weka.Run .RandomRBF -o $out_f -n $num_examples -a $num_attributes -c $num_classes