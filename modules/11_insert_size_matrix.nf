process COLLECT_METRICS {

    tag "$id"
    cpus 2

    publishDir "${params.metrics_dir}", mode: 'copy'

    input:
tuple val(id),
      path(recalibrated_bam),
      path(bam_bai),
      path(recal_table)

path reference

    output:
    tuple val(id),
          path("${id}.alignment_metrics.txt"),
          path("${id}.insert_size_metrics.txt"),
          path("${id}.insert_size_histogram.pdf"),
          emit: metrics

    script:
    """
    set -euo pipefail

    gatk CollectAlignmentSummaryMetrics \
        -R ${reference} \
        -I ${recalibrated_bam} \
        -O ${id}.alignment_metrics.txt

    gatk CollectInsertSizeMetrics \
        -I ${recalibrated_bam} \
        -O ${id}.insert_size_metrics.txt \
        -H ${id}.insert_size_histogram.pdf
    """
}
