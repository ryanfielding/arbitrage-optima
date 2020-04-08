clc;
clear all;
close all;

%% Testing
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
%x = x(1,1) x(1,2) x(1,3) x(1,4) x(2,1) ... x(3,3)
%x(10-12) are the rates
%x = 0 usd2cad eur2cad yen2cad ... 0 in amounts
x = zeros(1,12);

Aeq = [];
beq = [];
A = [];
b = [];

%finds 0.0048 profit
%xGuess = [0 10 10 10 0 10 10 10 0 0.713554 0.66 .9];
%finds 1.56 profit
%xGuess=[0,1.45956047181335,4.36166553397463,7.27194070618012,0,5.64212289465898,0.00552664825793103,9.99999998644946,0,0.799999995962151,0.600000004715667,0.999999986584457];
%finds 1.147
%xGuess=[0,9.99242501921721,1.60319216391258e-06,1.79994172185933,0,8.85986264219077,9.99999984985734,1.60089391853419,0,0.650000000000000,0.749999981783946,0.850000000000000];
%finds 0.3145
xGuess=[0,8.75266172520550,2.32746313743225,8.64661087348664,0,6.68752910409166,7.12717579347866,4.84865467546798,0,0.680176110219948,0.675591051281899,0.866237297766703];

nonlcon=@varyRates;
lb = [0,0,0,0,0,0,0,0,0, 0.65, 0.60, 0.85];
ub = [0,10,10,10,0,10,10,10,0,0.8,0.75,1.0];
[x, fval, exit, out] = fmincon(@optimize,xGuess,A,b,Aeq,beq,lb,ub,nonlcon);

fminconRates=EXrates
profit = -fval-x0
gain = profit/x0

optRes(fval, profit, gain, out.iterations, out.funcCount,'FMResults');
ratesRes(fminconRates,'fminconRates');

opts = optimoptions('ga');
opts.FunctionTolerance = 1E-6;
opts.ConstraintTolerance = 1E-6;
%ensures the losses at each other currency (usd or eur) is 10 cents max
[x2, fval2, exit2, out2] = ga(@optimize,12,A,b,Aeq,beq,lb,ub,nonlcon,opts);

gaRates=EXrates
profit2 = -fval2-x0
gain2 = profit2/x0

optRes(fval2, profit2, gain2, out2.generations, out2.funccount,'GAResults');
ratesRes(gaRates,'gaRates');

xTable(x,x2);

%%Copy Latex files to folder then delete
movefile *.tex Report/latex/tables

%% Functions

function f = optimize(x)
    global EXrates x0
    %arbitrage formulation
    %initial amount + conversions from other currencies = final amount +
    %conversions to other currencies
    f = -(x0 + (EXrates(1,2)*x(2) + EXrates(1,3)*x(3)) - (x(4) + x(7)));
end

function [c,ceq]=varyRates(x)
   
    cad2usd = x(10);
    cad2eur = x(11);
    usd2eur = x(12);
    %usd2eur = (1/cad2usd)*cad2eur is more realistic / practical to the
    %market

    usd2cad = 1/cad2usd;
    eur2cad = 1/cad2eur;
    eur2usd = 1/usd2eur;
    
    global EXrates
    EXrates = [ 1       usd2cad eur2cad;
            cad2usd 1       eur2usd;
            cad2eur usd2eur 1];
            
    %old linear constraint is now non linear since vary 3 exch rates
    % Aeq = [0 1 0 -EXrates(2,1) 0 -EXrates(2,3) 0 1 0;
    %     0 0 1 0 0 1 -EXrates(3,1) -EXrates(3,2) 0];
    % beq = [0; 0];

    ceq(1) = x(2) + x(8) - EXrates(2,1)*x(4) - EXrates(2,3)*x(6);
    ceq(2) = x(3) + x(6) - EXrates(3,1)*x(7) - EXrates(3,2)*x(8);
    %ceq(3) = x(4) + x(8) + x(12) - EXrates(4,1)*x(13) - EXrates(4,2)*x(14) - EXrates(4,3)*x(15);
    %cad to eur
    
    %f <= -x0 to ensure gains are the only found optima
    %f = -(x0 + (EXrates(1,2)*x(2) + EXrates(1,3)*x(3)) - (x(4) + x(7)));
    c(1) = -((EXrates(1,2)*x(2) + EXrates(1,3)*x(3)) - (x(4) + x(7)));
end

function xTable(x1,x2)
    
    X_Opt.X = { '$CAD2CAD' '$USD2CAD' '$EUR2CAD'...
        '$CAD2USD' '$USD2USD' '$EUR2USD' '$CAD2EUR' '$USD2EUR' '$EUR2EUR'...
        'Rate CAD2USD' 'Rate CAD2EUR' 'Rate USD2EUR' }';
    X_Opt.FMOptima = x1';
    X_Opt.GAOptima = x2';
    X_Opt=struct2table(X_Opt);
    table2latex(X_Opt,'X_Optima');

end
