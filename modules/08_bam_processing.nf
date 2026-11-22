process BAM_PROCESSING {

    tag "${id}.bam"
    cpus 8

    publishDir "${params.bam_dir}", mode: 'copy'

    input:
    tuple val(id), path(sam)

    output:
tuple val(id),
      path("${id}.sorted.bam"),
      path("${id}.sorted.bam.bai"),
      emit: bam
    
script:
"""
set -euo pipefail

mkdir -p bam

samtools view -@ ${task.cpus} -u ${sam} | \
    samtools sort \
        -@ ${task.cpus} \
        -T ${id}.tmp \
        -o ${id}.sorted.bam

samtools index \
    -@ ${task.cpus} \
    ${id}.sorted.bam
"""
}
