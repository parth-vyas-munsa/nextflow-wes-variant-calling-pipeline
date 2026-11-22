


process VEP_SNP {

    tag "$id"

    publishDir "${params.variants_annotation_dir}/SNP", mode: 'copy'

    input:
    tuple val(id), path(vcf)

    output:
    tuple val(id),
          path("${id}.snps.vep.vcf"),
          emit: snps_annotated

    script:
    """
    set -euo pipefail

    vep \
        --input_file ${vcf} \
        --output_file ${id}.snps.vep.vcf \
        --vcf \
        --assembly GRCh38 \
        --species homo_sapiens \
        --everything
    """
}



process VEP_INDEL {

    tag "$id"

    publishDir "${params.variants_annotation_dir}/INDEL", mode: 'copy'

    input:
    tuple val(id), path(vcf)

    output:
    tuple val(id),
          path("${id}.indel.vep.vcf"),
          emit: indel_annotated

    script:
    """
    set -euo pipefail

    vep \
        --input_file ${vcf} \
        --output_file ${id}.indel.vep.vcf \
        --vcf \
        --assembly GRCh38 \
        --species homo_sapiens \
        --everything
    """
}

