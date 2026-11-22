process PREFETCH {

  tag "${id}"
publishDir "${params.outdir}", mode: 'copy'

    input:
    val id

    output:
    tuple val(id), path("${id}/${id}.sra"), emit: sra

    script:
    """
    set -euo pipefail
    prefetch ${id} --output-directory .
    """
}