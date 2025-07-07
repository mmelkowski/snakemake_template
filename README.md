# Snakemake Template
A snakemake template showcasing many snakemake functionalities.

## Pipeline usage

The bash script `launch.sh` should be executed to trigger the snakemake pipeline

## Modules

The pipelines use the snakemake module features to make components easier to use between project.

It is found in the folder `src/workflow/modules/smk_modules` which could be a git submodule instead to a separate repository.

## Unit testing

Once you have a pipeline fully fonctionning which run once you can use the option `--generate-unit-test` to ask snakemake to produce a pytest unit test case for each rule called.

This feature is not perfect, the test created are under the format:

```shell
.tests/
`-- unit
    |-- common.py
    |-- {rule_name}
    |   |-- data
    |   |   `-- local_data
    |   |       `-- reads_R1.fastq.gz
    |   `-- expected
    |       `-- results
    |           `-- processed.R1.fastq.gz
    `-- test_{rule_name}.py
```

`test_{rule_name}.py` is the python file recognize by pytest to test the rule.

Depending on the snakemake version used and the command called in the pipeline this file can sometime be incomplete or incorrect [see snakemake issue #3137](https://github.com/snakemake/snakemake/issues/3137).