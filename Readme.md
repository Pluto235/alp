README
1. 这是计算alp的python code and matlab code
2. cal_prop 是主计算转换率的文件，而main.ipynb是原来测试的python文件，可以忽略
3. main.m是matlab计算chisquare的主文件
4. utility是给主程序写的一个python函数应用包
5. man_multi是调用多进程计算的程序

说明：
1. 选取能量区间为慧眼全能区，即10^-6-0(GeV)
2. 选取源为GRB 221009A src = Source(z=0.151, ra='19h13m3.48s', dec='+19d46m24.6s')
3. 能量取点在-6~0四个量级区间为20000个 EGeV = np.logspace(-6, 0,20000)
4. 耦合强度暂时取了0.1-10（10^-11 GeV^-1）几个点 galp= np.array([0.1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])  #1e-11 GeV-1
5. 轴子质量暂时为以下几点： malp = np.array([1e-7, 1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 0.1, 1., 10.]) # neV

% revision in 2023.11.03
1. matlab line 94 "lny = lny + b" 转化率在循环里累加了，已修改!
2. chisquare比chisquare1矩阵多一列，且第一列全为0， 因为matlab line88，这里从2开始索引，所以最后chisquare第一列全是0，不影响结果，已经修改！
3. matlab出现“索引超出数组元素的数目(9)。”错误，因为原先galp和malp都只取了10个，但是后面取了一百个没有改！
4. ![Alt text](image.png) Thats may be something wrong!![Alt text](image-1.png)
5. 根据上图得到的结果，chisquare=6的边界值大约为g=0.37左右
6. 单独测试g=1，m=1E-7时候的chisquare看看下限压在哪里，%%读取g=1,m=1e-7时候的转化率单独看看b和chisquare=[227.782249322207]
7. 单独测试g=4，m=1E-7时候的chisquare看看下限压在哪里，%%读取g=4,m=1e-7时候的转化率单独看看b和chisquare=[5.044610679392968e+03]
8. 在100*100数据下（未优化），chisquare中最小的数为38.513324, 对应位置：[44,65], 对应**galp=0.739072** *1e-11 GeV-1,**malp=0.014850** neV>> 
9. 在g=0即没有耦合的情况下，chisquare=38.847342>> 比min_chisquare大！！
10. 测试result/pure_ALP_testg=10.txt，得到在m=1e-8,m=1e-7,m=1e-3下分别的chi： 4368.74166880683	4368.74168884263	1163.52272995760，转化的图像![Alt text](g=10.jpg),在g很大(10)，m很小的时候转化很剧烈，几乎接近0.5，但是在g=6时候就没有那么剧烈![Alt text](g=6.jpg)
11. python中减去ELB的值得到纯粹的ALP转化率： print(px[j,b,a]+py[j,b,a]-(1-np.exp(-tau[a])),file=datapxy,end=" ")
12. ![Alt text](g=0.jpg) g = 0的时候没有转化，意料之中！
13. 尝试m很大的情况,![Alt text](g=1.jpg),![Alt text](g=6-1.jpg),![Alt text](g=10-1.jpg),看到在m比较大时，虽然g越大，耦合越强，但总的在慧眼的能区（TeV）都没有太大的耦合。因此，在图上chisquare小于6也是合理的。
    
% Queations in 2023.11.07
14. lhaaso数据没有xerr???几何平均！对数坐标的算数平均值

%%%%    
work in next week
    1. 慧眼低能区！！！
    2. lhaaso能区
    3. SGR

% Revison in 2023.11.16
1. 使用新数据报错，原因是数据输出的转化率怎么是负的呀？？？
   原因在于读取数据时，实验数据是KeV量级，直接带入了python计算，导致输出的转化率是在EGeV大6个数量级下产生的，因此ELB很大，在python里修改即可！
2. ![Alt text](image-2.png) 跑出来在high gain 区间的图像
3. matlab里修改了chisquare的输出，能直接打印最小的chisquare，并且与拟合的chisquare比较
4. 慧眼低能区结果：chisquare中最小的数为137.258641, 对应位置：[1,100], 对应galp=0.100000 *1e-11 GeV-1,malp=10.000000 neV>> \![Alt text](image-3.png)
   拟合得到的chisquare为：137.258437, 拟合百分之95要求的chisquare为105.267177 观察值与理论值之间的拟合不好\n
chisquare中最小的数为137.258641, 对应位置：[1,100], 对应galp=0.100000 *1e-11 GeV-1,malp=10.000000 neV
所有chisquare中最小值为：137.258437 , 是实验拟合的chisquare>> 3
5. ![Alt text](image-4.png)，限制的galp=0.2656