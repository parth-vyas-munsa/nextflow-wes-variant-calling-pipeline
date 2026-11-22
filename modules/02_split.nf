// PROCESS 2: Convert SRA into FASTQ

process SPLIT {

    tag "${id}_1 ,${id}_2"
    cpus 8
    

    publishDir "${params.fastq_dir}", mode: 'copy'

    input:
    tuple val(id), path(sra)

   output:
tuple val(id),
      path("${id}/${id}_1.fastq"),
      path("${id}/${id}_2.fastq")

    script:
    """
    mkdir -p ${id}

    fasterq-dump ${sra} \
        --split-files \
        --threads ${task.cpus} \
        --outdir ${id}
    """
}
