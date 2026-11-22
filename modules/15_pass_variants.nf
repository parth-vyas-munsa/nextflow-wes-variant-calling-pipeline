
process PASS_SNP {

    tag "$id"

    publishDir "${params.variants_pass_dir}/SNP", mode: 'copy'

    input:
    tuple val(id), path(vcf)

    output:
    tuple val(id),
          path("${id}.snps.pass.vcf.gz"),
          emit: snps_pass

    script:
    """
    set -euo pipefail

    gatk SelectVariants \
        -V ${vcf} \
        --exclude-filtered true \
        -O ${id}.snps.pass.vcf.gz



gunzip -c ${id}.snps.pass.vcf.gz | \
awk 'BEGIN {FS=OFS="\t"}
     /^#/ {print; next}
     $7 !~ /(^|;)(DP_filter|GO_filter)(;|$)/ {print}' \
> ${id}_analysisready_snp_filtered.vcf    
"""
}


process PASS_INDEL {

    tag "$id"

    publishDir "${params.variants_pass_dir}/INDEL", mode: 'copy'

    input:
    tuple val(id), path(vcf)

    output:
    tuple val(id),
          path("${id}.indel.pass.vcf.gz"),
          emit: indel_pass

    script:
    """
    set -euo pipefail

    gatk SelectVariants \
        -V ${vcf} \
        --exclude-filtered true \
        -O ${id}.indel.pass.vcf.gz


gunzip -c ${id}.indel.pass.vcf.gz | \
awk 'BEGIN {FS=OFS="\t"}
     /^#/ {print; next}
     $7 !~ /(^|;)(DP_filter|GO_filter)(;|$)/ {print}' \
> ${id}_analysisready_indel_filtered.vcf    
 

    """
}
