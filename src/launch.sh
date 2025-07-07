# Go into main folder
cd workflow

# Load conda env
conda activate /path/to/envs/conda

# Launch pipeline
snakemake --profile ../profiles/default.yaml
