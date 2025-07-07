"""
   ___                          
  / __|___ _ __  _ __  ___ _ _  
 | (__/ _ \ '  \| '  \/ _ \ ' \ 
  \___\___/_|_|_|_|_|_\___/_||_|

"""

import pathlib
import scripts.common_functions as cf

samples_sheet = cf.load_tsv("../config/samples_sheet.tsv")

samples_sheet = cf.clean_samples_sheet(samples_sheet)

list_target = [
    "results/{sample}/report.yaml"
]
def get_pipeline_output():
    list_ouput = []
    for sample in samples_sheet["sample"]:
        for target in list_target:
            list_ouput.append(target.format(sample=sample))
    return list_ouput