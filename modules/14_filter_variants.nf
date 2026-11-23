process FILTER_SNP{


 tag "$id"

    publishDir "${params.variants_filter_dir}/SNP", mode: 'copy'



 input:
    tuple val(id), path(vcf)
    path reference

output:
 tuple val(id),
          path("${id}.snps.filtered.vcf.gz"),
          emit: snps_filtered

script:
    """
    set -euo pipefail

    gatk VariantFiltration \
        -R ${reference} \
        -V ${vcf} \
        --filter-name "SNP_FILTER" \
        --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || SOR > 3.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" \
        -O ${id}.snps.filtered.vcf.gz

    """
}

process FILTER_INDEL{


 tag "$id"

    publishDir "${params.variants_filter_dir}/INDEL", mode: 'copy'



 input:
    tuple val(id), path(vcf)
    path reference

output:
 tuple val(id),
          path("${id}.indel.filtered.vcf.gz"),
          emit: indel_filtered

script:
    """
    set -euo pipefail

    gatk  VariantFiltration \
        -R ${reference} \
        -V ${vcf} \
        --filter-name "INDEL_FILTER" \
         --filter-expression "QD < 2.0 || FS > 200.0 || SOR > 10.0 || ReadPosRankSum < -20.0"  \
        -O ${id}.indel.filtered.vcf.gz

    """
}
