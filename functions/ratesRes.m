function ratesRes(rates,name)
    Res.CAD = rates(:,1);
    Res.USD = rates(:,2);
    Res.EUR = rates(:,3);
    Res = struct2table(Res);
    Res.Properties.RowNames =  {'CAD' 'USD' 'EUR'};
    table2latex(Res,name);
end