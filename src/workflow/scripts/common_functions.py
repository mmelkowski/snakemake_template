"""
   ___                             __              _   _          
  / __|___ _ __  _ __  ___ _ _    / _|_  _ _ _  __| |_(_)___ _ _  
 | (__/ _ \ '  \| '  \/ _ \ ' \  |  _| || | ' \/ _|  _| / _ \ ' \ 
  \___\___/_|_|_|_|_|_\___/_||_|_|_|  \_,_|_||_\__|\__|_\___/_||_|
                              |___|
"""

import pandas as pd

def load_tsv(myfile):
    """
    Load a tab-separated values (TSV) file into a pandas DataFrame.

    Args:
        myfile (str or file-like object): Path to the TSV file or a file-like object.

    Returns:
        pandas.DataFrame: DataFrame containing the data from the TSV file.
    """
    return pd.read_csv(myfile, sep='\t')


def determine_platform(row):
    has_ill = pd.notnull(row.get("fq1"))
    has_ont = pd.notnull(row.get("raw_ont")) or pd.notnull(row.get("ont"))
    if has_ill and has_ont:
        return "hybrid"
    elif has_ill:
        return "ill"
    elif has_ont:
        return "ont"
    else:
        return None


def clean_samples_sheet(samples_sheet):
    """
    Cleans the samples sheet by removing incomplete rows and determining the sequencing platform.

    Drops any rows from the input DataFrame where the "sample", "reference", or "out" columns contain missing values.
    Then, adds a new column "platform" by applying the `determine_platform` function to each row.

    Args:
        samples_sheet (pandas.DataFrame): Input DataFrame containing at least the columns "sample", "reference", and "out".

    Returns:
        pandas.DataFrame: Cleaned DataFrame with incomplete rows removed and a new "platform" column added.
    """
    samples_sheet = samples_sheet.dropna(subset=["sample", "reference", "out"])

    samples_sheet["platform"] = samples_sheet.apply(determine_platform, axis=1)

    return samples_sheet
