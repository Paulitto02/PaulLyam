nextflow.enable.dsl=2

process downloadFile {
publishDir "/root/PaulLyam/", mode: "copy", overwrite: true
output:
	path "batch1.fasta"
"""

wget https://tinyurl.com/cqbatch1 -O batch1.fasta
"""
}
process countSequence{
publishDir "/root/PaulLyam/", mode: "copy", overwrite: true
output:
	path "numseqs.txt"
"""
grep "^>" batch1.fasta | wc -l > numseqs.txt
"""
}

workflow {
	downloadFile()
	countSequence ()
}