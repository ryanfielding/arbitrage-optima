clc;
clear all;
close all;

%% 3-way Currency Arbitrage Optimization
addpath('functions');

%cad, usd, eur
%col by row means currency 1 to currency 2
%eg. element (2,1) is cad to usd exchange rate
cad2usd = 0.7085;
cad2eur = 0.6559;
usd2cad = 1.4113;
usd2eur = 0.9260;
eur2cad = 1.52448;
eur2usd = 1.0799;

global EXrates x0
%initial amount 10000 CAD
x0 = 10; %thousand
EXrates = [ 1       usd2cad eur2cad;
            cad2usd 1       eur2usd;
            cad2eur usd2eur 1];
%x = x(1,1) x(1,2) x(1,3) x(1,4) x(2,1) ... x(4,4)
%x = 0 usd2cad eur2cad yen2cad ... 0 in amounts
x = zeros(1,9);

Aeq = [0 1 0 -EXrates(2,1) 0 -EXrates(2,3) 0 1 0;
    0 0 1 0 0 1 -EXrates(3,1) -EXrates(3,2) 0];
beq = [0; 0];
A = [];
b = [];

xGuess = [0 10 10 10 0 10 10 10 0];

lb = [0,0,0,0,0,0,0,0,0];
ub = [0,10,10,10,0,10,10,10,0];
[x, fval, exit, out] = fmincon(@optimize,xGuess,A,b,Aeq,beq,lb,ub);

fminconRates=EXrates
profit = -fval-x0
gain = profit/x0

optRes(fval, profit, gain, out.iterations, out.funcCount,'aFMResults');

opts = optimoptions('ga');
opts.FunctionTolerance = 1E-6;
lb = [0,0,0,1,0,0,0,0,0];
ub = [0,10,10,15,0,10,15,10,0];
[x2, fval2, exit2, out2] = ga(@optimize,9,A,b,Aeq,beq,lb,ub,[],opts);

gaRates=EXrates
profit2 = -fval2-x0
gain2 = profit2/x0

optRes(fval2, profit2, gain2, out2.generations, out2.funccount,'aGAResults');

xTable(x,x2,'aX_Results');

%%Move Latex files to folder
movefile *.tex Report/latex/tables

%% Functions

function f = optimize(x)
    global EXrates x0
    %arbitrage formulation
    %initial amount + conversions from other currencies = final amount +
    %conversions to other currencies
    f = -(x0 + (EXrates(1,2)*x(2) + EXrates(1,3)*x(3)) - (x(4) + x(7)));
end

function xTable(x1,x2,name)
    
    X_Opt.X = { '\$CAD2CAD' '\$USD2CAD' '\$EUR2CAD'...
        '\$CAD2USD' '\$USD2USD' '\$EUR2USD' '\$CAD2EUR' '\$USD2EUR' '\$EUR2EUR'}';
    X_Opt.FMOptima = x1';
    X_Opt.GAOptima = x2';
    X_Opt=struct2table(X_Opt);
    table2latex(X_Opt,name);

end


%% Results
% Local minimum found that satisfies the constraints.
% 
% Optimization completed because the objective function is non-decreasing in 
% feasible directions, to within the value of the optimality tolerance,
% and constraints are satisfied to within the value of the constraint tolerance.
% 
% <stopping criteria details>
% 
% fminconRates =
% 
%     1.0000    1.4113    1.5245
%     0.7085    1.0000    1.0799
%     0.6559    0.9260    1.0000
% 
% 
% T =
% 
%   table
% 
%     fminconOptima
%     _____________
% 
%     [1×9 double] 
% 
% 
% profit =
% 
%     0.0017
% 
% 
% gain =
% 
%    1.6696e-04
% 
% Optimization terminated: average change in the fitness value less than options.FunctionTolerance.
% 
% gaRates =
% 
%     1.0000    1.4113    1.5245
%     0.7085    1.0000    1.0799
%     0.6559    0.9260    1.0000
% 
% 
% T2 =
% 
%   table
% 
%       gaOptima  
%     ____________
% 
%     [1×9 double]
% 
% 
% profit2 =
% 
%    -0.0016
% 
% 
% gain2 =
% 
%   -1.6003e-04
