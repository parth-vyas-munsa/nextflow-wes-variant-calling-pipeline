process BQSR {

    tag "$id"
    cpus 2

    publishDir "${params.bqsr_dir}", mode: 'copy'

   input:
tuple val(id),
      path(bam),
      path(bai),
      path(markdup_metrics)

path reference

tuple path(dbsnp), path(dbsnp_idx),
      path(mills), path(mills_idx)

    output:
    tuple val(id),
          path("${id}.recalibrated.bam"),
          path("${id}.recalibrated.bam.bai"),
          path("${id}.recal.table"),
          emit: recalibrated

    script:
    """
    set -euo pipefail

    # Prepare reference indexes required by GATK
   

    

    # STEP 1: BaseRecalibrator
    gatk --java-options "-Xmx2g" BaseRecalibrator \
        -R ${reference} \
        -I ${bam} \
        --known-sites ${dbsnp} \
        --known-sites ${mills} \
        -O ${id}.recal.table

    # STEP 2: ApplyBQSR
    gatk --java-options "-Xmx2g" ApplyBQSR \
        -R ${reference} \
        -I ${bam} \
        --bqsr-recal-file ${id}.recal.table \
        -O ${id}.recalibrated.bam

samtools index \
    -@ ${task.cpus} \
    ${id}.recalibrated.bam

    
    """
}

