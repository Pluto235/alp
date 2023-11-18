# run in environment "py37"
from gammaALPs.core import Source, ALP, ModuleList
from gammaALPs.base import environs, transfer
import numpy as np
import matplotlib.pyplot as plt
from ebltable.tau_from_model import OptDepth
from astropy import constants as c
import pandas as pd
from multiprocessing import Process


def main_run(gmalp_l):
    # GRB 221009A
    # src = Source(z=0.151, ra=288.2643, dec=19.7712)
    src = Source(z=0.151, ra='19h13m3.48s', dec='+19d46m24.6s')
    numberofengergy = 20000
    # Insight-HXMT : -6~0,
    EGeV = np.logspace(-6, 0., numberofengergy)
    pin = np.diag((1., 1., 0.)) * 0.5

    # g = 6.0
    ml = ModuleList(ALP(m=1., g=6.0), src, pin=pin, EGeV=EGeV, seed=0)

    ml.add_propagation("IGMF",
                       0,  # position of module counted from the source.
                       nsim=1,  # number of random B-field realizations
                       B0=1e-3,  # B field strength in micro Gauss at z = 0
                       n0=1e-7,  # normalization of electron density in cm^-3 at z = 0
                       L0=1e3,  # coherence (cell) length in kpc at z = 0
                       eblmodel='dominguez'  # EBL model
                       )
    ml.add_propagation("GMF", 0, model='jansson12')

    malp = np.logspace(-7, 1., 100)  # nGeV
    # malp = np.array([1e-7, 1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 0.1, 1., 10.]) # nGeV
    # gmalp= np.array([0.1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])  #1e-11 GeV-1

    px = np.zeros((gmalp_l.shape[0], malp.shape[0], EGeV.shape[0]))
    py = np.zeros((gmalp_l.shape[0], malp.shape[0], EGeV.shape[0]))
    pa = np.zeros((gmalp_l.shape[0], malp.shape[0], EGeV.shape[0]))

    tau = ml.modules["IGMFCell"].t.opt_depth(ml.source.z, ml.EGeV / 1e3)

    for j, gj in enumerate(gmalp_l):
        for i, mi in enumerate(malp):
            print("evulating i:", i, " j:", j, " mi:", mi, "gj:", gj)
            ml.alp.g = gj
            ml.alp.m = mi
            px[j, i], py[j, i], pa[j, i] = ml.run()

        # 转化率写入
        filename = "result/" + \
            "g="+str(gj)+".txt"
        datapxy = open(filename, 'w')
        str_malp = list(map(lambda x: str(x), malp))
        str_malp = ' '.join(str_malp)
        print("EGeV "+str_malp, file=datapxy)  # print first line
        for a in range(numberofengergy):
            print(EGeV[a], file=datapxy, end=' ')
            for b in range(len(malp)-1):
                print(px[j, b, a]+py[j, b, a], file=datapxy, end=" ")
            print(px[j, len(malp)-1, a]+py[j, len(malp)-1, a], file=datapxy)
        datapxy.close()


if __name__ == "__main__":
    gmalp = np.logspace(-1, 1, 10)  # 1e-11 GeV-1
    process = []
    process_num = 3
    num = (int)(gmalp.shape[0]/process_num)
    for i in range(process_num):
        if(i == process_num-1):
            gmalp_l = gmalp[i*num:]
        else:
            gmalp_l = gmalp[i*num:(i+1)*num]
        process.append(Process(target=main_run, args=(gmalp_l,)))
    [p.start() for p in process]
    [p.join() for p in process]
