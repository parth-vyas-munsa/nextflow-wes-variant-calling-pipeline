process MARK_DUPLICATES {

    tag "$id"
    cpus 2

    publishDir "${params.markdup_dir}", mode: 'copy'

    input:
    tuple val(id), path(bam), path(bai)

    output:
    tuple val(id),
          path("${id}.marked.bam"),
          path("${id}.marked.bam.bai"),
          path("${id}.metrics.txt"),
          emit: marked_bam

    script:
    """
    set -euo pipefail

    gatk MarkDuplicates \
        -I ${bam} \
        -O ${id}.marked.bam \
        -M ${id}.metrics.txt

    samtools index \
        -@ ${task.cpus} \
        ${id}.marked.bam
    """
}

