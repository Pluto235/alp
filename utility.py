import numpy as np


# 定义生成EGeV的函数
def generate_EGeV(Eexp, Elow, Ehigh):
    """
    用此函数，根据实验数据生成模拟用到的EGeV数据
    """
    # Eexp is data from experiment
    # Eerr is the error of the experimental data
    # Elow is the low bar of the experimental data
    # Ehigh is the high bar of the experimental data

    # Return EGeV
    
    assert len(Eexp) == len(Elow) == len(Ehigh), "Lengths of Eexp, Elow, and Ehigh should be the same"

    EGeV = np.array([])
    for i in range(len(Eexp)):
        new_E = np.geomspace(Elow[i], Ehigh[i], 10)
        EGeV =  np.concatenate([EGeV, new_E]) #连接数组
    return EGeV