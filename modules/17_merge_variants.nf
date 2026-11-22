
process MERGE_VEP {

    tag "$id"

    publishDir "${params.merge_ann_var_dir}", mode: 'copy'

    input:
    tuple val(id), path(snp_vcf), path(indel_vcf)

    output:
    tuple val(id),
          path("${id}.merged.vep.vcf"),
          emit: merge_annotated

    script:
    """
    set -euo pipefail

    bcftools concat \
        -a \
        -Ov \
        -o ${id}.merged.vep.vcf \
        ${snp_vcf} \
        ${indel_vcf}

bcftools view -h ${id}.merged.vep.vcf \
    | grep 'ID=CSQ' \
    > ${id}.CSQ_fields.txt
    """
}

