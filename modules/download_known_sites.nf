
process DOWNLOAD_KNOWN_SITES {

    tag "GRCh38_known_sites"
    cpus 2

    publishDir "${params.known_sites_dir}", mode: 'copy'

    output:
    tuple path("Homo_sapiens_assembly38.dbsnp138.vcf"),
          path("Homo_sapiens_assembly38.dbsnp138.vcf.idx"),
          path("Mills_and_1000G_gold_standard.indels.hg38.vcf.gz"),
          path("Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi"),
          emit: known_sites

    script:
    """
    set -euo pipefail

    # Download dbSNP GRCh38
    wget -c \
      https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf \
      -O Homo_sapiens_assembly38.dbsnp138.vcf

    # Download Mills known indels GRCh38
    wget -c \
      https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz \
      -O Mills_and_1000G_gold_standard.indels.hg38.vcf.gz

    # Create GATK-compatible indexes
    gatk IndexFeatureFile \
      -I Homo_sapiens_assembly38.dbsnp138.vcf

    gatk IndexFeatureFile \
      -I Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
    """
}
