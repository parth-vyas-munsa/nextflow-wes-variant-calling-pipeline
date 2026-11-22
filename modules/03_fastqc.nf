process QUALITY {

    tag "$id"
    cpus 8

    publishDir "${params.qc_dir}", mode: 'copy'

    input:
tuple val(id), path(read1), path(read2)

    output:
    path "${id}/*_fastqc.html", emit: html
    path "${id}/*_fastqc.zip", emit: zip

    script:
    """
    mkdir -p ${id}

    fastqc \
    --threads ${task.cpus} \
    --outdir ${id} \
    ${read1} ${read2}
    """
}
