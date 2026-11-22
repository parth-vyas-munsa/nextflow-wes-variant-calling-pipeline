
import pandas as pd
import requests
import time
from pathlib import Path

.
# 1. Project directories
.

PROJECT = Path(__file__).resolve().parent.parent

INPUT = (
    PROJECT / "final_results" /
    "filtered_variants" / "filtered_variants.csv"
)

OUT_DIR = PROJECT / "final_results" / "clinvar"

OUTPUT = OUT_DIR / "clinvar_annotated.csv"

OUT_DIR.mkdir(parents=True, exist_ok=True)

.
# 2. NCBI API settings
.

BASE_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils"

HEADERS = {
    "User-Agent": "WES-Variant-Annotation/1.0"
}

.
# 3. Read input CSV
.

df = pd.read_csv(INPUT, dtype=str)

required = ["CHROM", "POS", "REF", "ALT"]

for col in required:
    if col not in df.columns:
        raise ValueError(f"Missing column: {col}")

print("Total variants:", len(df))

.
# 4. Function to search ClinVar
.

def search_clinvar(chrom, pos, ref, alt):

    chrom = str(chrom).replace("chr", "")
    pos = str(pos)
    ref = str(ref)
    alt = str(alt)

    # Exact genomic allele query on GRCh38
    query = f"{chrom}-{pos}-{ref}-{alt}(GRCh38)"

    search_url = f"{BASE_URL}/esearch.fcgi"

    search_params = {
        "db": "clinvar",
        "term": query,
        "retmode": "json",
        "retmax": 20
    }

    try:

        response = requests.get(
            search_url,
            params=search_params,
            headers=HEADERS,
            timeout=30
        )

        response.raise_for_status()

        search_data = response.json()

        ids = search_data.get(
            "esearchresult", {}
        ).get("idlist", [])

        if not ids:
            return {
                "ClinVar_UID": "",
                "ClinVar_Classification": "No exact match found",
                "ClinVar_Review_Status": "",
                "ClinVar_Title": ""
            }

        # --------------------------------
        # 5. Retrieve ClinVar summaries
        # --------------------------------

        summary_url = f"{BASE_URL}/esummary.fcgi"

        summary_params = {
            "db": "clinvar",
            "id": ",".join(ids),
            "retmode": "json"
        }

        response = requests.get(
            summary_url,
            params=summary_params,
            headers=HEADERS,
            timeout=30
        )

        response.raise_for_status()

        summary = response.json().get("result", {})

        classifications = []
        review_statuses = []
        titles = []

        for uid in ids:

            record = summary.get(uid, {})

            title = record.get("title", "")
            if title:
                titles.append(title)

            clinical = record.get(
                "clinical_significance", {}
            )

            if isinstance(clinical, dict):

                classification = clinical.get(
                    "description", ""
                )

                review = clinical.get(
                    "review_status", ""
                )

                if classification:
                    classifications.append(classification)

                if review:
                    review_statuses.append(review)

        return {
            "ClinVar_UID": ";".join(ids),
            "ClinVar_Classification": ";".join(
                sorted(set(classifications))
            ) or "Classification unavailable",
            "ClinVar_Review_Status": ";".join(
                sorted(set(review_statuses))
            ),
            "ClinVar_Title": ";".join(titles),
        }

    except requests.RequestException as error:

        print("API error:", error)

        return {
            "ClinVar_UID": "",
            "ClinVar_Classification": "API error",
            "ClinVar_Review_Status": "",
            "ClinVar_Title": ""
        }

.
# 6. Query ClinVar for every variant
.

results = []

for index, row in df.iterrows():

    print(
        f"Searching variant {index + 1}/{len(df)}"
    )

    result = search_clinvar(
        row["CHROM"],
        row["POS"],
        row["REF"],
        row["ALT"]
    )

    results.append(result)

    # Avoid sending requests too quickly
    time.sleep(0.4)

.
# 7. Combine original and ClinVar data
.

clinvar_df = pd.DataFrame(results)

final_df = pd.concat(
    [
        df.reset_index(drop=True),
        clinvar_df
    ],
    axis=1
)

.
# 8. Save annotated CSV
.

final_df.to_csv(OUTPUT, index=False)

.
# 9. Summary
.

print("\n========== CLINVAR SUMMARY ==========")

print(
    final_df["ClinVar_Classification"].value_counts()
)

print("\nTotal variants:", len(final_df))

print("\nOutput saved:", OUTPUT)
