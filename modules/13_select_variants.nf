
process EXTRACT_SNP {

    tag "$id"

    publishDir "${params.variant_dir}/SNP", mode: 'copy'

    input:
    tuple val(id), path(vcf)
    path reference

    output:
    tuple val(id),
          path("${id}.snps.vcf.gz"),
          emit: snps

    script:
    """
    set -euo pipefail

    gatk SelectVariants \
        -R ${reference} \
        -V ${vcf} \
        --select-type-to-include SNP \
        -O ${id}.snps.vcf.gz
    """
}


process EXTRACT_INDEL {

    tag "$id"

    publishDir "${params.variant_dir}/INDEL", mode: 'copy'

    input:
    tuple val(id), path(vcf)
    path reference

    output:
    tuple val(id),
          path("${id}.indels.vcf.gz"),
          emit: indels

    script:
    """
    set -euo pipefail

    gatk SelectVariants \
        -R ${reference} \
        -V ${vcf} \
        --select-type-to-include INDEL \
        -O ${id}.indels.vcf.gz
    """
}
