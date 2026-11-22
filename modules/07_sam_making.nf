process ALIGNMENT {

    tag "${id}.sam"
    cpus 2

    publishDir "${params.alignment_dir}", mode: 'copy'

    input:
tuple val(id), path(read1), path(read2)
path index_dir

    output:
    tuple val(id), path("aligned/${id}.sam"), emit: sam

    script:
    """
    set -euo pipefail
mkdir -p aligned

    bwa-mem2 mem \
    -t ${task.cpus} \
    -R '@RG\\tID:${id}\\tSM:${id}\\tPL:ILLUMINA' \
    ${index_dir}/GRCh38.fa \
    ${read1} \
    ${read2} \
    >aligned/${id}.sam
    """
}

