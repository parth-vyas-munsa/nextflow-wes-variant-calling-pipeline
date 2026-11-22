
process DOWNLOAD_REFERENCE {

    tag "GRCh38"

    publishDir "${params.ref_dir}", mode: 'copy'

    output:
    path "GRCh38.fa", emit: fasta
    path "GRCh38.fa.fai", emit: fai
    path "GRCh38.dict", emit: dict

    script:
    """
    set -euo pipefail

    wget -4 -c \
      https://ftp.ensembl.org/pub/release-${params.release}/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz \
      -O GRCh38.fa.gz

    gunzip GRCh38.fa.gz

    mv Homo_sapiens.GRCh38.dna.primary_assembly.fa GRCh38.fa

    samtools faidx GRCh38.fa

    gatk CreateSequenceDictionary \
        -R GRCh38.fa \
        -O GRCh38.dict
    """
}

