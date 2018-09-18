"""Loads the benchmark dataset and obtains TP and FP counts for CRH predictions on a PDB based benchmark dataset
Publication available online:

"""


from collections import defaultdict
import pandas as pd
import csv
import networkx as nx
import gzip


crosshits_g = nx.read_gpickle( "cross_hits_fam_fam_70.pkl") #superfamilies that have crosshits as discussed in supplementary data

def getNumberOfMatchingDoms(known_regs,pdoms,crosshits):
    
   
    tp_dom = 0.0
    fp_dom = 0.0
    tot_dom = 0.0
    
    known_out=["known",filter_identity, uacc]
    pred_out=["predicted", method,uacc]
   

    for k_sfam, dom_regs in known_regs:
       
        aas1=set()
        tot_dom +=1
        for start,stop in dom_regs: 
            aas1 |= set(range(start, stop+1))

        for p_sfam,  p_mda_regs in pdoms:
            aas2 = set()
            for start,stop in p_mda_regs: aas2 |= set(range(start, stop+1))
            
            if p_sfam == k_sfam: 
               
                if (len(aas1 &aas2) / float(len(aas1 | aas2))) > 0.5:tp_dom +=1
               
                
            elif p_sfam != k_sfam:
                 
                if crosshits.has_edge(p_sfam, k_sfam) is False: 
                    if (len(aas1 &aas2) / float(len(aas1 | aas2))) > 0.5:
                        fp_dom +=1
                        
                else:
                    """Ignore altogther if its a potential CATH Superfamily cross-hit issue"""
                    if (len(aas1 &aas2) / float(len(aas1 | aas2))) > 0.5:return 0,0,0

     
    tps = tp_dom  / float(tot_dom)
    fps = fp_dom / float(tot_dom)
  
    return tps,fps,tot_dom

def getSfamRegs(doms):
    res=[]
    for sfam_regs in doms:
        
        sfam, regs = sfam_regs.split("_")
        regs_as_ints = []
        for start_stop in regs.split(","):
         
            start,stop = start_stop.split("-")
            regs_as_ints.append([int(start), int(stop)])
        res.append([sfam, regs_as_ints])
    return res

method = filter_identity = None

bench_res=defaultdict(list)
for line in csv.reader(gzip.open("preds_for_bench.txt.gz","r")):
   
    pred_or_known = line[0]
    if pred_or_known =="known":
        known_regs=getSfamRegs(line[3:])
        filter_identity = float(line[1])
        uacc = line[2]
        
        
          
    else:
        method = line[1]
        
        if line[2] != uacc:
            
            exit(1)
        
        pred_regs=getSfamRegs(line[3:])
       
      

 
        tps,fps,tot_dom= getNumberOfMatchingDoms(known_regs, pred_regs,crosshits_g)

        if tot_dom > 0:
            bench_res["filt-ident"].append(filter_identity)
            bench_res["res-tps"].append(tps)
            bench_res["res-fps"].append(fps)
            bench_res["res-tot"].append(tot_dom)
            bench_res["uacc"].append(uacc)
            bench_res["name"].append(method)

df = pd.DataFrame.from_dict(bench_res)
df.to_hdf("preds_for_bench.hdf","df", mode="w")  

df = df.drop(['res-tot'], axis=1)
df = df.groupby(["name", "filt-ident"]).mean()
df.to_csv("preds_for_bench.csv")


