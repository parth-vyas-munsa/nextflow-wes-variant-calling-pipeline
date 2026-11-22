# Human Whole Exome Sequencing (WES) Variant Calling and Annotation Pipeline

**Automated WES Analysis Using Nextflow DSL2, GATK and Ensembl VEP**

## 1. Project Overview

This project implements an automated Whole Exome Sequencing (WES) analysis pipeline using **Nextflow DSL2** to process human sequencing data, identify genetic variants and perform functional variant annotation.

The pipeline starts by downloading raw sequencing data directly from the NCBI Sequence Read Archive (SRA) using accession IDs provided in `acc_id.txt`.

It automates sequencing quality control, read preprocessing, reference-based alignment, BAM processing, variant calling, SNP/INDEL filtering and functional annotation using Ensembl Variant Effect Predictor (VEP).

The workflow is designed using a modular architecture to improve reproducibility, maintainability and scalability.

## 2. Study and Dataset Information

The pipeline was tested using publicly available Whole Exome Sequencing data from an NCBI study.

| Information         | Details                                                                                                                                                    |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Study title         | Whole exome sequencing of a Noonan syndrome patient with a rare KRAS p.Val14Ile variant: integrative phenotypic analysis and molecular dynamics simulation |
| BioProject          | PRJNA1540175                                                                                                                                               |
| SRA Study           | SRP742867                                                                                                                                                  |
| BioSample           | SAMN64008568                                                                                                                                               |
| SRA Run             | SRR41031147                                                                                                                                                |
| Organism            | Homo sapiens                                                                                                                                               |
| Scientific name     | Human                                                                                                                                                      |
| Library name        | NS_proband_1_WES                                                                                                                                           |
| Sequencing platform | Illumina NovaSeq 6000                                                                                                                                      |
| Library strategy    | WXS (Whole Exome Sequencing)                                                                                                                               |
| Library source      | GENOMIC                                                                                                                                                    |
| Library selection   | Hybrid Selection                                                                                                                                           |
| Sequencing layout   | Paired-end                                                                                                                                                 |

**Data source:** NCBI Sequence Read Archive (SRA).

- [NCBI BioProject](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1540175)
- [NCBI SRA Study](https://trace.ncbi.nlm.nih.gov/Traces?study=SRP742867)
- [NCBI BioSample](https://www.ncbi.nlm.nih.gov/biosample/SAMN64008568)
- [NCBI SRA Run](https://www.ncbi.nlm.nih.gov/sra/?term=SRR41031147)

## 3. Workflow Architecture

The pipeline consists of the following major analytical stages.

### Stage 1: Raw Data Acquisition

- Download SRA sequencing data using SRA Toolkit.
- Read accession IDs from `acc_id.txt`.
- Convert SRA files into paired-end FASTQ files using `fasterq-dump`.

### Stage 2: Quality Control and Preprocessing

- FastQC: Assess raw FASTQ quality.
- fastp: Perform adapter trimming and quality filtering.
- MultiQC: Aggregate quality control reports.

### Stage 3: Reference Genome Preparation

- Download the human reference genome (GRCh38).
- Download the corresponding gene annotation file (GTF).
- Prepare the reference genome index using BWA.

### Stage 4: Read Alignment

- Align paired-end sequencing reads against the GRCh38 reference genome using BWA.
- Generate alignment files.
- Process and sort BAM files using SAMtools.

### Stage 5: BAM Processing and Recalibration

- Mark duplicate reads using GATK MarkDuplicates.
- Download known variant sites.
- Perform Base Quality Score Recalibration (BQSR).
- Generate alignment quality metrics.

### Stage 6: Variant Calling

- Identify genetic variants using GATK HaplotypeCaller.
- Generate genomic variant call format (GVCF) output.
- Extract SNPs and INDELs separately.

### Stage 7: Variant Filtering

- Apply variant quality filtering.
- Separate SNP and INDEL filtering workflows.
- Extract variants passing the filtering criteria.

### Stage 8: Functional Variant Annotation

- Annotate filtered SNPs using Ensembl VEP.
- Annotate filtered INDELs using Ensembl VEP.
- Merge annotated variant outputs.
- Extract relevant functional annotation fields for downstream interpretation.

## 4. Workflow Diagram

```text
          SRA ACCESSION LIST
              acc_id.txt
                  |
                  v
           SRA PREFETCH
                  |
                  v
           FASTQ GENERATION
                  |
                  v
               FASTQC
                  |
                  v
               FASTP
                  |
                  v
              MULTIQC
                  |
                  v
        REFERENCE PREPARATION
              GRCh38
                  |
                  v
             BWA INDEX
                  |
                  v
              ALIGNMENT
                  |
                  v
           BAM PROCESSING
                  |
                  v
           MARK DUPLICATES
                  |
                  v
                 BQSR
                  |
                  v
           COLLECT METRICS
                  |
                  v
          GATK HAPLOTYPECALLER
                  |
                  v
           SNP / INDEL EXTRACTION
                  |
                  v
           VARIANT FILTERING
                  |
                  v
            PASS SNP / INDEL
                  |
                  v
              VEP ANNOTATION
                  |
                  v
             MERGE ANNOTATION
                  |
                  v
          FINAL ANNOTATED VARIANTS
```

## 5. Technologies and Tools

| Tool          | Application                       |
| ------------- | --------------------------------- |
| Nextflow DSL2 | Workflow automation               |
| Linux         | Computing environment             |
| SRA Toolkit   | Downloading sequencing data       |
| FastQC        | Sequencing quality assessment     |
| fastp         | Read preprocessing                |
| MultiQC       | QC report aggregation             |
| BWA           | Reference-based alignment         |
| SAMtools      | BAM processing                    |
| GATK          | Variant calling and recalibration |
| Ensembl VEP   | Functional variant annotation     |

## 6. Project Directory Structure

```text
human-wes-variant-calling/
│
├── automate_pipeline.nf
├── nextflow.config
├── acc_id.txt
├── README.md
├── .gitignore
│
├── modules/
│   ├── 01_prefetch.nf
│   ├── 02_split.nf
│   ├── 03_quality.nf
│   ├── 04_fastp.nf
│   ├── 05_multiqc.nf
│   ├── 06_download_reference.nf
│   ├── 07_bwa_index.nf
│   ├── 08_download_annotation.nf
│   ├── 09_alignment.nf
│   ├── 10_bam_processing.nf
│   ├── 11_mark_duplicates.nf
│   ├── 12_download_known_sites.nf
│   ├── 13_bqsr.nf
│   ├── 14_collect_metrics.nf
│   ├── 15_haplotype_caller.nf
│   ├── 16_extract_snp.nf
│   ├── 17_extract_indel.nf
│   ├── 18_filter_snp.nf
│   ├── 19_filter_indel.nf
│   ├── 20_pass_snp.nf
│   ├── 21_pass_indel.nf
│   ├── 22_vep_snp.nf
│   ├── 23_vep_indel.nf
│   ├── 24_merge_vep.nf
│   └── 25_extract_vep_annotation.nf
│
├── results/
├── reports/
├── reference/
└── work/
```

*Note: The directory structure represents the logical project organization. Large reference files, raw FASTQ files, intermediate files and the Nextflow work directory are excluded from GitHub.*

## 7. Installation and Requirements

### Prerequisites

- Linux operating system
- Java 17 or compatible Nextflow-supported Java version
- Nextflow
- SRA Toolkit
- FastQC
- fastp
- MultiQC
- BWA
- SAMtools
- GATK
- Ensembl VEP and the appropriate GRCh38 cache

### Check Nextflow installation

```bash
nextflow -version
```

### Check Java

```bash
java -version
```

## 8. Running the Pipeline

### Step 1: Add accession IDs

Create a file named `acc_id.txt`.

Example:

```text
SRR41031147
```

Multiple accession IDs can also be supplied, one per line.

### Step 2: Execute the pipeline

```bash
nextflow run automate_pipeline.nf
```

### Step 3: Generate execution reports

Execution reports, trace files and timeline reports can be enabled through `nextflow.config`.

## 9. Expected Outputs

| Analysis stage    | Expected output                    |
| ----------------- | ---------------------------------- |
| SRA download      | SRA files                          |
| FASTQ generation  | Paired-end FASTQ files             |
| FastQC            | HTML and ZIP reports               |
| fastp             | Trimmed FASTQ files and QC reports |
| MultiQC           | Combined QC report                 |
| Alignment         | BAM files                          |
| BAM processing    | Processed BAM and index files      |
| BQSR              | Recalibrated BAM files             |
| HaplotypeCaller   | GVCF files                         |
| SNP extraction    | SNP VCF files                      |
| INDEL extraction  | INDEL VCF files                    |
| Variant filtering | Filtered SNP and INDEL VCF files   |
| PASS selection    | Passing variant VCF files          |
| VEP               | Annotated SNP and INDEL files      |
| Final annotation  | Merged annotated variant table     |

## 10. Reproducibility

This pipeline uses Nextflow DSL2 to organize the analysis into independent processes.

The modular structure allows individual processes to be maintained, debugged and reused.

Reference genome versions, annotation releases, tool versions and execution parameters should be documented to ensure reproducibility.

## 11. Scientific Scope and Limitations

This project demonstrates an automated computational WES analysis workflow using publicly available sequencing data.

The study title reports a rare KRAS p.Val14Ile variant. However, the presence of that variant in the original study does not establish that this pipeline independently detected or validated it.

Variant interpretation requires appropriate genomic coordinate verification, transcript selection, annotation review and clinical evidence assessment.

This computational workflow is intended for research and educational purposes and is not a substitute for clinical genetic testing or diagnostic interpretation.

## 12. Author

**Parth Vyas**

MSc Bioinformatics

Interests:

- NGS Data Analysis
- Whole Exome Sequencing
- Nextflow Workflow Development
- Variant Calling and Annotation
- Computational Genomics

---

**Project:** Human WES Variant Calling and Annotation Pipeline
**Workflow Engine:** Nextflow DSL2
**Reference Genome:** GRCh38
**Variant Annotation:** Ensembl VEP
