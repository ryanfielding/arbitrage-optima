clc;
clear all;
close all;

%% 2-way Currency Arbitrage Optimization
%With transfer fees

%transfer fee polyfits from TransferWise fees
global pUSD
global pCAD
[pUSD, pCAD] = fees();

%initial $10k USD
x0=10000;

A = [];
b = [];
Aeq = [];
beq = [];
lb = [0,0,1.2,1.2];
ub = [x0,60000,1.5,1.5];
nonlcon=@trade2MAX;
xStart = [1000 1000 1.4 1.4];

%min are the optimum
% min(1) = amount to send to CAD
% min(2) = amount to send back to USD
% min(3) = rate for transfer 1
% min(4) = rate for transfer 2

[min, fval, exit, out] = fmincon(@optimize,xStart,A,b,Aeq,beq,lb,ub,nonlcon);
profit = -fval-x0
T = table(min','VariableNames',{'fminconOptima'})

[min2,fval2,exitflag,output,population,scores] = ga(@optimize, 4, [],[],[],[],lb,ub,nonlcon);
profit2 = -fval2-x0
T2 = table(min2','VariableNames',{'gaOptima'})

%% Functions

function f = optimize(x)
    %x(1) is amount sent USD to CAD
    %x(2) is amount sent back - CAD to USD
    %x(3) is usd2cad rate for 1st transfer
    %x(4) is usd2cad rate for 2nd transfer
    f = -( (x(1)-usdFee(x(1)))*x(3) + (x(2) - cadFee(x(2)))/x(4) - x(1)); %in USD
end

function [c,ceq]=trade2MAX(x)
    %this constraint implies that one cannot send back to USD more than they
    %receive from USD from first exchange
    c(1)=(x(1)-usdFee(x(1)))*x(3) - x(2);
    ceq=[];
end

function fee = usdFee(val)
    %Fee to send USD to CAD
    global pUSD
    fee = polyval(pUSD,val);
end

function fee = cadFee(val)
    %Fee to send USD to CAD
    global pCAD
    fee = polyval(pCAD,val);
end

function [p1, p2] = fees()
    %% Poly fit fee data
    x = [100 500 1000 5000 10000 15000]';
    yUSD = [1.99 5.48 9.86 44.82 88.53 132.24]';
    yCAD = [3.22 6.95 11.61 48.92 78.84 114.58]';

    p1 = polyfit(x,yUSD,4);
    
    p2 = polyfit(x,yCAD,4);
    
    feeUSD = polyval(p1,x);
    feeCAD = polyval(p2,x);
    
  
%     figure
%     plot(x,yCAD,'o')
%     hold on
%     plot(x,yUSD,'r*')
%     plot(x,feeUSD,'r-')
%     plot(x,feeCAD,'b-')
%     axis([0  15000  0  150])
%     hold off
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
% profit =
% 
%    2.3394e+04
% 
% 
% T =
% 
%   table
% 
%              fminconOptima          
%     ________________________________
% 
%     10000    43552      1.5      1.2
% 
% Optimization terminated: average change in the fitness value less than options.FunctionTolerance
%  and constraint violation is less than options.ConstraintTolerance.
% 
% profit2 =
% 
%    2.2694e+04
% 
% 
% T2 =
% 
%   table
% 
%                   gaOptima              
%     ____________________________________
% 
%     9861.4     42386    1.4901     1.221