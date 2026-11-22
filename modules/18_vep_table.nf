
process EXTRACT_VEP_ANNOTATION {

    tag "$id"

    publishDir "${params.vep_table_dir}", mode: 'copy'

    input:
    tuple val(id), path(vcf)

    output:
    tuple val(id),
          path("${id}.vep_annotation.tsv"),
          emit: vep_table

    script:
    """
    set -euo pipefail

    bcftools +split-vep \
        ${vcf} \
        -d \
        -f '%CHROM\\t%POS\\t%REF\\t%ALT\\t%SYMBOL\\t%Consequence\\t%IMPACT\\t%Gene\\t%Feature\\t%BIOTYPE\\t%HGVSc\\t%HGVSp\\n' \
        > ${id}.vep_annotation.tsv
    """
}
