#!/bin/bash

echo 'Hello! This is a friendly script ready to query the NCBI dbSNP database for you :)'

# read input file name
read -p 'Please enter the name of the input file including extension (default: input.txt): ' input_file
[[ -z "${input_file// }" ]] && input_file="input.txt"

# read output file name
read -p 'Please enter the file name of the file you want the data to be written to (default: output): ' output_file
[[ -z "${output_file// }" ]] && output_file="output"

# read path to jq executable
read -p 'Please enter the path to the jq executable (default: ./jq-win64.exe): ' jq_exe
[[ -z "${jq_exe// }" ]] && jq_exe="./jq-win64.exe"

# append json file extension to output file
output_file="output/${output_file}.json"

# create temporary query files
tmp_query_file="tmp_query.txt"
query_file="query.txt"

# replace newlines with commas (delete carriage return characters in case of windows)
tr -d '\r' < $input_file > $tmp_query_file
# tr --delete '\r' < $input_file > $tmp_query_file
tr '\n' ',' < $tmp_query_file > $query_file

# create query string
query=$(cat ${query_file})

# create query url
url="https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=snp&id="${query}"&rettype=json&retmode=text"

# query database
echo "Querying database and writing to ${output_file}..."
echo $(curl -H "Accept: application/json" -H "Content-Type: application/json" -X GET ${url}) >> $output_file

# create files to store parsed results
frequency_output_file="output/frequency_output_file.txt"
cdna_output_file="output/cdna_output_file.txt"

# parse frequency and cdna position from result
cat $output_file | $jq_exe '.refsnp_id,(.primary_snapshot_data.allele_annotations | .[].frequency)' > $frequency_output_file
cat $output_file | $jq_exe '.refsnp_id,(.primary_snapshot_data.placements_with_allele | .[].alleles | .[] | select(.hgvs | startswith("NM_")))' > $cdna_output_file

# delete temporary query files
rm $tmp_query_file
rm $query_file

echo "Query complete! Please open ${output_file} to see the full results, ${frequency_output_file} to see the frequencies, and ${cdna_output_file} to see the cDNA positions :)"
