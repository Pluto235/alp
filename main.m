clear();
global chi_origin critical_value
chi_origin = 0;
critical_value =0;
AidDir = uigetdir('path of probability'); 	% 通过交互的方式选择一个文件夹
if AidDir == 0 			% 用户取消选择
    fprintf('Please Select a New Folder!\n');
else
	cd(AidDir)
	RawFile = dir('**/*.*'); %主要是这个结构，可以提取所有文件
	AllFile = RawFile([RawFile.isdir]==0);
    if isempty(fieldnames(AllFile))
    	fprintf('There are no files in this folder!\n');
    else	% 当前文件夹下有文件，反馈文件数量
    	fprintf('Number of Files: %i \n',size(AllFile,1));
    end
end
cd ../
fileNames=[];
Folder = {AllFile.folder};
Name = {AllFile.name};                                                                                                          
cdata=readtable("C:\Users\Pluto\Desktop\ALP\data\GRB221009A\Le\celestial_data.xlsx");%需要更换！！！！！
for i=1:length(AllFile)
    fileNames = [Folder{i},'\',Name{i}];%每个文件对应路径
    pd=readtable(fileNames);
    chisquare(i,:)=probability(cdata,pd); %用下面的probability函数计算对应的chisquare
end

% 设置g和m的数值
malp = logspace(log10(1e-7), log10(10), 100); % neV
galp = logspace(log10(0.1), log10(10), 100); %1e-11 GeV-1
% g=[0.1,1,2,3,4,5,6,7,8,9,10] * 1e-11;%单位GeV-1
% m=[1e-7, 1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 0.1, 1.0, 10];%单位neV    ????????
% g=g*1e-11;

fprintf('拟合得到的chisquare为：%f, 拟合百分之95要求的chisquare为%f ',chi_origin, critical_value);
% 比较卡方值和临界值
if chi_origin > critical_value
    disp('观察值与理论值之间的拟合不好\n');
else
    disp('观察值与理论值之间的拟合良好\n');
end
chisquare = chisquare(:, 2:end); %删除多余的第一列
min_chisquare =min(chisquare(:));
[row,column]=find(chisquare==min_chisquare);
fprintf('chisquare中最小的数为%f, 对应位置：[%d,%d], 对应galp=%f *1e-11 GeV-1,malp=%f neV\n',min_chisquare,row,column,galp(row),malp(column));
if min_chisquare<=chi_origin
    fprintf('所有chisquare中最小值为：%f , 是考虑alp转化的chisquare',min_chisquare);
else
    fprintf('所有chisquare中最小值为：%f , 是实验拟合的chisquare',chi_origin);
end
min_chisquare = min(min_chisquare, chi_origin);
chisquare1 = chisquare - min_chisquare; % 减去最小值（带入拟合的chisquare的最小值）

% 创建一个result表格，让chisquare >6 的为零，否则为1
result = chisquare1; %  i->g;    j->m
plt_m = [];
plt_g = [];
for i=1:size(chisquare1,1)
    for j=1:size(chisquare1,2)
        if (result(i,j)>6 || result(i,j)<1) 
            result(i,j) = 0;
        else
            result(i,j) = 1;
            plt_m = [plt_m, malp(j)];
            plt_g = [plt_g, galp(i)];
        end
    end
end

% 画图
scatter(plt_g, log10(plt_m), 'r', 'Marker', 'x'); % 在自定义坐标上绘制值为1的点
title('卡方小于6的散点');
ylabel('对数坐标 m / 单位log(neV)');
xlabel('g / 单位(1e-11 GeV-1)');

function [chi]=probability(celestial_data, probability_data)
global chi_origin critical_value
% probability函数
X = [celestial_data(:,1)];
X = X.Variables; 
Y = [celestial_data(:,2)];
Y = Y.Variables; 
Y_err = [celestial_data(:,3)];
Y_err = Y_err.Variables;
X_err = [celestial_data(:,4)];
X_err = X_err.Variables;
Y_err=((Y_err./Y).^2+(2*X_err./X).^2).^0.5;    %？？？？？
Xl=X-X_err/2;
Xh=X+X_err/2;
lnx = log(X);
lny = log(Y);

[fittedmodel1] = createFit(lnx,lny,Y_err);
observed = lny;
expected = feval(fittedmodel1,lnx);
uncertaintie=Y_err;
chi_origin = chicalculate(observed,expected,uncertaintie);
degrees_of_freedom = length(observed) - 5;
critical_value = chi2inv(0.95, degrees_of_freedom);


pxyx=table2array(probability_data(:,1:1)); % pxyx模拟的能量点，probability数据每一列对应一个malp；

n=size(probability_data,2);
chi=[];
for j=2:1:n % 对每一列（每个malp）遍历 % 因为这里从2开始索引，所以最好chisquare第一列全是0
    pxyy=table2array(probability_data(:,j:j)); %每一列对应的是一个malp
    %拟合离散的原始数据，并做卡方检验19-23
    b=averageprobability(X,Xl,Xh,pxyx,pxyy);
    %拟合考虑存活概率的曲线，并做卡方40-45
    b=b'; % matlab有broadcasting
    theory_lny=lny+b;   % 转化率在这里累加了？？？？！！！
    [fittedmodel2] = createFit(lnx,theory_lny,Y_err);  % weight是Y_err吗？？？？-
    %%这种方式调用拟合函数是合理的吗？
    observed = lny;
    expected= feval(fittedmodel2, lnx); 
    uncertaintie=Y_err;
%disp('考虑转化率')
    chi(j)=chicalculate(observed,expected,uncertaintie);
end
end


function [a] = chicalculate(observed,expected,uncertaintie)
residuals = observed - expected;
chi_square_bin=residuals.^2./uncertaintie.^2;
chi_square = sum(chi_square_bin);
a=chi_square;
 %{
degrees_of_freedom = length(observed) - 3;
critical_value = chi2inv(0.95, degrees_of_freedom);
% 比较卡方值和临界值
if chi_square > critical_value
    disp('观察值与理论值之间的拟合不好');
else
    disp('观察值与理论值之间的拟合良好');
end
chi_square 
critical_value
%}
end
function [fitresult] = createFit(x,y,y_err)

%CREATEFIT(LNX,LNY,YBLUE_ERR)
%  创建一个拟合。
%  要进行 '无标题拟合 1' 拟合的数据:
%      X 输入: lnX
%      Y 输出: lnY
%      权重: Yblue_err
%  输出:
%      fitresult: 表示拟合的拟合对象。
%      gof: 带有拟合优度信息的结构体。
%  另请参阅 FIT, CFIT, SFIT.
%  由 MATLAB 于 05-Oct-2023 19:22:58 自动生成
%% 拟合: '无标题拟合 1'。
[xData, yData, weights] = prepareCurveData(x, y, y_err );

% 设置 fittype 和选项。
ft = fittype( 'poly2' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Weights = weights;

% 对数据进行模型拟合。
[fitresult] = fit( xData, yData, ft, opts );

end


function [b]=averageprobability(X,Xl,Xh,pxyx,pxyy)
pxyx = pxyx * 1e6; % pxyx 是GeV量级，换成KeV量级（实验数据数量级）
b = []; % 储存平均转换率
for i =1:1:length(X)
    temp_prop = [];
    for j =1:1:length(pxyx)
        if Xl(i) <= pxyx(j)  && Xh(i) >= pxyx(j)
            temp_prop = [temp_prop, pxyy(j)];
        end
    end
    b = [b, mean(temp_prop)];
end
b = log(b); %得到转化率的对数值（方便相加）
end





