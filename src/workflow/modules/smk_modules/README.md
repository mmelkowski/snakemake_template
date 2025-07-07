# `smk_modules`

This folder is intended to simulate a `git submodule` for a Snakemake workflow modules. Each subfolder represents a reusable module. This approach helps organize and share workflow components across projects.

## Available Modules

Below is a list of available modules:

<!-- Update this list as you add new modules -->

- **Preprocessing/**
    - fastp
    - chopper
- **QC/**
    - fastqc
    - nanoplot
    - multiqc
- **Mapping/**
    - bwa-mem2
    - bowtie2
    - minimap2
- **Variant Calling/**
    - freebayes
    - lofreq
    - medaka

---

**How to add a new module:**  
Create a new subfolder and add your Snakemake rules. Update this README to include your module and its main tools.
