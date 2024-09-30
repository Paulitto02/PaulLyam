nextflow.enable.dsl = 2

// Define parameters
params.accession = "M21012" 
params.out = "${launchDir}/results_${params.accession}"
params.in = "${launchDir}/input_fasta"

process DownloadRef {
  publishDir "${params.out}", mode: 'copy', overwrite: true
  input:
    val params.accession

  output:
    path "${params.accession}.fasta"

  script:
    """
    wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${params.accession}&rettype=fasta&retmode=text" -O ${params.accession}.fasta 
    """
}

process CombinedFastaFil {
  publishDir "${params.out}", mode: 'copy', overwrite: true
  input:
    path infiles

  output:
    path "combined.fasta"

  script:
    """
    cat ${infiles} > combined.fasta
    """
}

process AlignGenomes_Mafft {
  container "https://depot.galaxyproject.org/singularity/mafft%3A7.525--h031d066_1"
  publishDir "${params.out}", mode: 'copy', overwrite: true
  input:
    path infile

  output:
    path "aligned.fasta"
	
  script:
    """
    mafft --auto ${infile} > aligned.fasta
    """
}

process trimAlignment {
  publishDir "${params.out}", mode: 'copy', overwrite: true
  container "https://depot.galaxyproject.org/singularity/trimal%3A1.5.0--h4ac6f70_0"
  input:
    path infile
  
  output:
    path "trim_seq_${params.accession}.fasta"
    path "report_trim_seq_${params.accession}.html"
    
  script:
    """
    trimal -automated1 -in ${infile} -out trimmed.fasta -htmlout trim_report.html
    """
}



workflow {
   
    download_channel = DownloadRef(params.accession)

    input_channel = Channel.fromPath("${params.in}/*.fasta")
	
    combined_channel = download_channel.concat(input_channel)
	
    CombinedFastaFil(combined_channel) | AlignGenomes_Mafft | trimAlignment

}
