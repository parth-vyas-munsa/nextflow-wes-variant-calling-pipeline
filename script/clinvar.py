
import time
import requests
import pandas as pd

from pathlib import Path
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

.
# PROJECT PATHS
.

PROJECT = Path(__file__).resolve().parent.parent

INPUT = (
    PROJECT / "results" /
     "filtered_variants.csv"
)

OUT_DIR = PROJECT / "results" / "clinvar"
OUT_DIR.mkdir(parents=True, exist_ok=True)

OUTPUT = OUT_DIR / "clinvar_annotated.csv"

.
# NCBI API CONFIGURATION
.

BASE_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils"

session = requests.Session()

retry_strategy = Retry(
    total=3,
    backoff_factor=1,
    status_forcelist=[429, 500, 502, 503, 504],
    allowed_methods=["GET"]
)

adapter = HTTPAdapter(max_retries=retry_strategy)
session.mount("https://", adapter)

session.headers.update({
    "User-Agent": "WES-ClinVar-Annotation/1.0"
})


.
# SEARCH CLINVAR
.

def search_clinvar(chrom, pos, ref, alt):

    chrom = str(chrom).strip()
    chrom = chrom.removeprefix("chr")

    # Avoid searching malformed or missing values
    if not all([chrom, str(pos).strip(), ref, alt]):
        return {
            "ClinVar_Status": "Invalid variant fields"
        }

    query = f"{chrom}-{pos}-{ref}-{alt}(GRCh38)"

    search_url = f"{BASE_URL}/esearch.fcgi"

    search_params = {
        "db": "clinvar",
        "term": query,
        "retmode": "json",
        "retmax": 20
    }

    try:

        response = session.get(
            search_url,
            params=search_params,
            timeout=30
        )

        response.raise_for_status()

        search_data = response.json()

        ids = search_data.get(
            "esearchresult", {}
        ).get("idlist", [])

        if not ids:
            return {
                "ClinVar_Status": "No exact match found",
                "ClinVar_UID": "",
                "ClinVar_Classification": "",
                "ClinVar_Review_Status": "",
                "ClinVar_Title": ""
            }

        .
        # GET CLINVAR SUMMARY
        .

        summary_url = f"{BASE_URL}/esummary.fcgi"

        summary_params = {
            "db": "clinvar",
            "id": ",".join(ids),
            "retmode": "json",
            "version": "2.0"
        }

        response = session.get(
            summary_url,
            params=summary_params,
            timeout=30
        )

        response.raise_for_status()

        summary_data = response.json().get("result", {})

        classifications = []
        review_statuses = []
        titles = []

        for uid in ids:

            record = summary_data.get(uid, {})

            title = record.get("title", "")
            if title:
                titles.append(str(title))

            clinical = record.get(
                "clinical_significance", {}
            )

            if isinstance(clinical, dict):

                classification = clinical.get(
                    "description", ""
                )

                review_status = clinical.get(
                    "review_status", ""
                )

                if classification:
                    classifications.append(
                        str(classification)
                    )

                if review_status:
                    review_statuses.append(
                        str(review_status)
                    )

        return {
            "ClinVar_Status": "Match found",
            "ClinVar_UID": ";".join(ids),
            "ClinVar_Classification": ";".join(
                sorted(set(classifications))
            ),
            "ClinVar_Review_Status": ";".join(
                sorted(set(review_statuses))
            ),
            "ClinVar_Title": ";".join(
                sorted(set(titles))
            )
        }

    except (requests.RequestException, ValueError, KeyError) as error:

        print("API error:", error)

        return {
            "ClinVar_Status": "API error",
            "ClinVar_UID": "",
            "ClinVar_Classification": "",
            "ClinVar_Review_Status": "",
            "ClinVar_Title": ""
        }


.
# LOAD FILTERED VARIANTS
.

if not INPUT.exists():
    raise FileNotFoundError(
        f"Input file not found: {INPUT}"
    )

df = pd.read_csv(INPUT, dtype=str)

# Normalize column names
df.columns = df.columns.str.strip().str.upper()

required_columns = ["CHROM", "POS", "REF", "ALT"]

for column in required_columns:
    if column not in df.columns:
        raise ValueError(
            f"Missing required column: {column}"
        )

print("Total variants:", len(df))

.
# QUERY EACH VARIANT
.

results = []

for index, row in df.iterrows():

    print(
        f"Searching ClinVar: "
        f"{index + 1}/{len(df)}"
    )

    result = search_clinvar(
        row["CHROM"],
        row["POS"],
        row["REF"],
        row["ALT"]
    )

    results.append(result)

    # Stay below NCBI's usual unauthenticated
    # request-rate limit.
    time.sleep(0.4)


.
# MERGE RESULTS
.

clinvar_df = pd.DataFrame(results)

final_df = pd.concat(
    [
        df.reset_index(drop=True),
        clinvar_df.reset_index(drop=True)
    ],
    axis=1
)

final_df.to_csv(
    OUTPUT,
    index=False
)


.
# SUMMARY
.

print("\n========== CLINVAR SUMMARY ==========")

print(
    final_df["ClinVar_Status"].value_counts(
        dropna=False
    )
)

print("\nClinical classifications:")

print(
    final_df["ClinVar_Classification"].value_counts(
        dropna=False
    )
)

print("\nOutput saved at:")
print(OUTPUT)
