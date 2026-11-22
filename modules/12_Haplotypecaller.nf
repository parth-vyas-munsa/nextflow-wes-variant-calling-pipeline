process HAPLOTYPE_CALLER {

    tag "$id"

    cpus 2

    publishDir "${params.vcf_dir}", mode: 'copy'

    input:
    tuple val(id), path(recalibrated_bam), path(bam_bai)
    path reference
    path reference_fai
    path reference_dict

    output:
    tuple val(id),
          path("${id}.g.vcf.gz"),
          path("${id}.g.vcf.gz.tbi"),
          emit: gvcf

    script:
    """
    set -euo pipefail

    gatk --java-options "-Xmx2g" HaplotypeCaller \
        -R ${reference} \
        -I ${recalibrated_bam} \
        -O ${id}.g.vcf.gz \
        -ERC GVCF \
        --native-pair-hmm-threads ${task.cpus}
    """
}
