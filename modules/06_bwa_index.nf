process BWA_INDEX {

    tag "GRCh38_BWA_INDEX"
    cpus 2

    publishDir "${params.ref_index_dir}", mode: 'copy'

    input:
    path reference

    output:
    path "bwa_index", emit: bwa_index

    script:
    """
    set -euo pipefail

    mkdir -p bwa_index

    cp ${reference} bwa_index/GRCh38.fa

    bwa-mem2 index bwa_index/GRCh38.fa
    """
}

