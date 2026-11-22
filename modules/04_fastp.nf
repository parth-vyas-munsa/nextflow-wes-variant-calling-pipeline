
process FASTP {

    tag "${id}_trimmed"
    cpus 2

    publishDir "${params.trimmed_dir}", mode: 'copy'

    input:
    tuple val(id), path(read1), path(read2)

    output:
    tuple val(id),
          path("${id}_1.trimmed.fastq.gz"),
          path("${id}_2.trimmed.fastq.gz"),
          path("${id}_fastp.html"),
          path("${id}_fastp.json"),
          emit: trimmed

    script:
    """
    set -euo pipefail

    fastp \
        --in1 ${read1} \
        --in2 ${read2} \
        --out1 ${id}_1.trimmed.fastq.gz \
        --out2 ${id}_2.trimmed.fastq.gz \
        --html ${id}_fastp.html \
        --json ${id}_fastp.json \
        --thread ${task.cpus}
    """
}

