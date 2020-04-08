clc;
clear all;
close all;

%% Testing

%transfer fee polyfits
global pUSD
global pCAD
[pUSD, pCAD] = fees();

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
x0 = 100; %thousand
EXrates = [ 1       usd2cad eur2cad;
            cad2usd 1       eur2usd;
            cad2eur usd2eur 1];
%x = x(1,1) x(1,2) x(1,3) x(1,4) x(2,1) ... x(3,3)
%x(10-11) are the cad to other currency rates
%x = 0 usd2cad eur2cad yen2cad ... 0 in amounts
x = zeros(1,11);

Aeq = [];
beq = [];
A = [];
b = [];

%finds 0.0048 profit
xGuess = [0 10 10 10 0 10 10 10 0 0.713554 0.66];


nonlcon=@varyRates;
%trade bounds and rate bounds
%rate bounds based off 5year h/l for cad to usd / eur
lb = [0,0,0,0,0,0,0,0,0,0.68250,0.61961];
ub = [0,10,10,10,0,10,10,10,0,0.83642,0.76188];
[x, fval, exit, out] = fmincon(@optimize,xGuess,A,b,Aeq,beq,lb,ub,nonlcon);

fminconRates=EXrates
T = table(x','VariableNames',{'fminconOptima'})
profit = -fval-x0
gain = profit/x0


opts = optimoptions('ga');
opts.FunctionTolerance = 1E-6;
opts.ConstraintTolerance = 1E-6;
%ensures the losses at each other currency (usd or eur) is 10 cents max
[x2, fval2, exit2, out2] = ga(@optimize,11,A,b,Aeq,beq,lb,ub,nonlcon,opts);

gaRates=EXrates
T2 = table(x2','VariableNames',{'gaOptima'})
profit2 = -fval2-x0
gain2 = profit2/x0


function f = optimize(x)
    global EXrates x0
    %arbitrage formulation
    %initial amount + conversions from other currencies = final amount +
    %conversions to other currencies
    f = -(x0 + (EXrates(1,2)*x(2) + EXrates(1,3)*x(3)) - (x(4) + x(7)));
end

function f = prof(x)
    f = (x(1)-usdFee(x(1)))*x(3) + (x(2) - cadFee(x(2)))/x(4) - 2*x(1); %in USD
end

function [c,ceq]=varyRates(x)
   
    cad2usd = x(10);
    cad2eur = x(11);

    usd2cad = 1/cad2usd;
    eur2cad = 1/cad2eur;
    usd2eur = (1/cad2usd)*cad2eur;
    %is more realistic / practical to the market, since not all 3 rates can
    %vary independently?
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
