simple script to query the NCBI (National Center for Biotechnology Information) dbSNP database and parse the results for cDNA position and frequency data.

the script takes in list of Reference SNP IDs and outputs three files:
1. output.json: the raw output from querying the dbSNP database, contains all the information related to each ID
2. cdna_output_file.txt: cDNA-related info
3. frequency_output_file.txt: frequency-related info
