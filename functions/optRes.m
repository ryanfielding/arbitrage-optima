function optRes(opt, profit, gain, iters, funcVals, name)
    Res.Optimum = opt;
    Res.Profit = profit;
    Res.Gain = gain;
    Res.Iterations = iters.';
    Res.FuncEvals = funcVals.';
    Res = struct2table(Res);
    table2latex(Res,name);
end