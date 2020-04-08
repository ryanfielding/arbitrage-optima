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
cad2usd = 0.75;
cad2eur = 0.68;
cad2yen = 82;

usd2cad = 1/cad2usd;
usd2eur = usd2cad*cad2eur;
usd2yen = usd2cad*cad2yen;
eur2cad = 1/cad2eur;
eur2usd = eur2cad*cad2usd;
eur2yen = eur2cad*cad2yen;
yen2cad = 1/cad2yen;
yen2usd = yen2cad*cad2usd;
yen2eur = yen2cad*cad2eur;


global EXrates x0
%initial amount 10000 CAD
x0 = 10; %thousand
EXrates = [ 1       usd2cad eur2cad yen2cad;
            cad2usd 1       eur2usd yen2usd;
            cad2eur usd2eur 1       yen2eur;
            cad2yen usd2yen eur2yen 1];
%x = x(1,1) x(1,2) x(1,3) x(1,4) x(2,1) ... x(4,4)
%x = 0 usd2cad eur2cad yen2cad ... 0 in amounts
%x(17-19) are exchange rates cad2usd, eur, yen
x = zeros(1,19);

Aeq = [];
beq = [];

A = [];
b = [];

%lb = [0,0,1.2,1.2];
%ub = [20000,40000,1.5,1.5];

xGuess = [0 10 10 10 10 0 10 10 10 10 0 10 10 10 10 0 0.6 0.6 80];
%xGuess = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% 
% A = [];
% b = [];
% Aeq = [];
% beq = [];
lb = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.6,0.6,80];
ub = [0,10,10,10,10,0,10,10,10,10,0,10,10,10,10,0,0.75,0.75,95];
nonlcon=@tradeMax;
% x0 = [1000 1000 1.4 1.4];
% 
options = optimoptions('fmincon');
options.FunctionTolerance = 1E-12;
options.OptimalityTolerance = 1E-12;
options.ConstraintTolerance = 1E-12;
[x, fval, exit, out] = fmincon(@optimize,xGuess,A,b,Aeq,beq,lb,ub,nonlcon,options);
% profit = prof(min)
% T = table(min,'VariableNames',{'X'})
% 
profit = -fval-x0
gain = profit/x0

lb = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.6,0.6,80];
ub = [0,10,10,10,10,0,10,10,10,10,0,10,10,10,10,0,0.75,0.75,95];
[x2,fval2,exitflag,output,population,scores] = gamultiobj(@optimize,19,A,b,Aeq,beq,lb,ub,nonlcon);
%Results1(x,fval,'Prob1', output.generations, output.funccount)
profit2 = -fval2-x0
gain2 = profit2/x0

%% Practicality by reading historical exchange rate data
%USDCADHistoricalData = importfile('USD_CAD Historical Data.csv', [2, 59])

function f = optimize(x)
    global EXrates x0
    %arbitrage formulation
    %initial amount + conversions from other currencies = final amount +
    %conversions to other currencies
    f = -(x0 + (EXrates(1,2)*x(2) + EXrates(1,3)*x(3) + EXrates(1,4)*x(4)) - (x(5) + x(9) + x(13)));
end

function f = prof(x)
    f = (x(1)-usdFee(x(1)))*x(3) + (x(2) - cadFee(x(2)))/x(4) - 2*x(1); %in USD
end

function [c,ceq]=tradeMax(x)
    %this constraint implies that one cannot trade more than initial amount
    %x0 has given
    %varying rates through x(17-19)
    
    cad2usd = x(17);
    cad2eur = x(18);
    cad2yen = x(19);

    usd2cad = 1/cad2usd;
    usd2eur = usd2cad*cad2eur;
    usd2yen = usd2cad*cad2yen;
    eur2cad = 1/cad2eur;
    eur2usd = eur2cad*cad2usd;
    eur2yen = eur2cad*cad2yen;
    yen2cad = 1/cad2yen;
    yen2usd = yen2cad*cad2usd;
    yen2eur = yen2cad*cad2eur;


    global EXrates
    EXrates = [ 1       usd2cad eur2cad yen2cad;
                cad2usd 1       eur2usd yen2usd;
                cad2eur usd2eur 1       yen2eur;
                cad2yen usd2yen eur2yen 1];
            
    %old linear constraint is now non linear
%     Aeq = [0 1 0 0 -EXrates(2,1) 0 -EXrates(2,3) -EXrates(2,4) 0 1 0 0 0 1 0 0;
%     0 0 1 0 0 0 1 0 -EXrates(3,1) -EXrates(3,2) 0 -EXrates(3,4) 0 0 1 0;
%     0 0 0 1 0 0 0 1 0 0 0 1 -EXrates(4,1) -EXrates(4,2) -EXrates(4,3) 0];



    ceq(1) = x(2) + x(10) + x(14) - EXrates(2,1)*x(5) - EXrates(2,3)*x(7) - EXrates(2,4)*x(8);
    ceq(2) = x(3) + x(7) + x(15) - EXrates(3,1)*x(9) - EXrates(3,2)*x(10) - EXrates(3,4)*x(12);
    ceq(3) = x(4) + x(8) + x(12) - EXrates(4,1)*x(13) - EXrates(4,2)*x(14) - EXrates(4,3)*x(15);
    %cad to eur
    
    c=[];
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

function USDCADHistoricalData = importfile(filename, dataLines)
%IMPORTFILE Import data from a text file
%  USDCADHISTORICALDATA = IMPORTFILE(FILENAME) reads data from text file
%  FILENAME for the default selection.  Returns the data as a table.
%
%  USDCADHISTORICALDATA = IMPORTFILE(FILE, DATALINES) reads data for the
%  specified row interval(s) of text file FILENAME. Specify DATALINES as
%  a positive scalar integer or a N-by-2 array of positive scalar
%  integers for dis-contiguous row intervals.
%
%  Example:
%  USDCADHistoricalData = importfile("/Users/Ryan/Repos/optimization/USD_CAD Historical Data.csv", [2, 56]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 20-Mar-2020 21:57:07

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 6);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Date", "Price", "Open", "High", "Low", "Change"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "Date", "InputFormat", "dd-MMM-yy");
opts = setvaropts(opts, "Change", "TrimNonNumeric", true);
opts = setvaropts(opts, "Change", "ThousandsSeparator", ",");

% Import the data
USDCADHistoricalData = readtable(filename, opts);

end