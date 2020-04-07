function [rates,currencies,rates_struct] = exchangerate(base,curr,date)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function returns exchange rates obtained from openexchangerates.org
% using their API. To work correctly, one must be connected to the
% Internet. The default app_id is from a free account to
% openexchangerates.org, which has a limit of 1000 API requests/month. For
% more flexibility, sign up for your own free or paid account and replace 
% the app_id value with your own id number. 

% Inputs:
% 1) base: a string denoting the base currency, which is set to have a 
% value of 1. If an empty string '' is provided, the default 'USD' is used.
% See list of valid currency abbreviations below.
% 2) curr: a string or cell array of strings denoting the currency
% abbreviation to compare with the base currency. If 'all' or '' is
% provided as input, then all available currencies are returned. See list
% of valid currency abbreviations below.
% 3) date: an optional string containing the date desired for the exchange
% rate (historical data may not always be available). The input should be
% in the form 'YYYY-MM-DD'. To get the latest exchange rate data, use date
% = 'latest' or '', which is the default value. Historical data from 1999
% and onward

% Outputs:
% 1) rates: a number or vector indicating the exchange rate(s) between the
% desired currency (currencies), curr, and the base currency, base.
% 2) currencies: a cell array of the corresponding currency abbreviations
% in rates. 
% 3) rate_struct: a structure with field names equal to the currency
% abbreviations and associated values being the rates. This output just
% combines rates and currencies for convenience.

% Examples:
% 1) Get the latest exchange rate between Bitcoin and the US Dollar
% [rates,currencies,rates_struct] = exchangerate('USD','BTC');
% >> rates = 1.614e-3
% >> currencies = 'BTC'
% >> rates_struct = 
%        BTC: 1.614e-3
% 
% 2) gets latest exchange rates for all available currencies
% [rates,currencies,rates_struct] = exchangerate(); 
%
% 3) Obtain exchange rates for Bitcoin, Indian rupee, and Euro using the US
% Dollar as base currency on June 5, 2013
% [rates,currencies,rates_struct] = exchangerate('USD',{'BTC','INR','EUR'},'2013-06-05');
% >> rates = [8.246e-3; 5.672e1; 7.642e-1]
% >> currencies = {'BTC';'INR';'EUR'}
% >> rates_struct = 
%       BTC: 8.246e-3
%       INR: 5.672e1
%       EUR: 7.642e-1
%
% 4) Obtain exchange rates for all available currencies on June 14, 2014
% [rates,currencies,rates_struct] = exchangerate('USD','all','2014-07-14');
% 
%
% List of Currency Abbreviations (as of 7-16-2014)
%   "AED": "United Arab Emirates Dirham",
% 	"AFN": "Afghan Afghani",
% 	"ALL": "Albanian Lek",
% 	"AMD": "Armenian Dram",
% 	"ANG": "Netherlands Antillean Guilder",
% 	"AOA": "Angolan Kwanza",
% 	"ARS": "Argentine Peso",
% 	"AUD": "Australian Dollar",
% 	"AWG": "Aruban Florin", 
% 	"AZN": "Azerbaijani Manat",
% 	"BAM": "Bosnia-Herzegovina Convertible Mark",
% 	"BBD": "Barbadian Dollar",
% 	"BDT": "Bangladeshi Taka",
% 	"BGN": "Bulgarian Lev",
% 	"BHD": "Bahraini Dinar",
% 	"BIF": "Burundian Franc",
% 	"BMD": "Bermudan Dollar",
% 	"BND": "Brunei Dollar",
% 	"BOB": "Bolivian Boliviano",
% 	"BRL": "Brazilian Real",
% 	"BSD": "Bahamian Dollar",
% 	"BTC": "Bitcoin",
% 	"BTN": "Bhutanese Ngultrum",
% 	"BWP": "Botswanan Pula",
% 	"BYR": "Belarusian Ruble",
% 	"BZD": "Belize Dollar",
% 	"CAD": "Canadian Dollar",
% 	"CDF": "Congolese Franc",
% 	"CHF": "Swiss Franc",
% 	"CLF": "Chilean Unit of Account (UF)",
% 	"CLP": "Chilean Peso",
% 	"CNY": "Chinese Yuan",
% 	"COP": "Colombian Peso",
% 	"CRC": "Costa Rican Colón",
% 	"CUP": "Cuban Peso",
% 	"CVE": "Cape Verdean Escudo",
% 	"CZK": "Czech Republic Koruna",
% 	"DJF": "Djiboutian Franc",
% 	"DKK": "Danish Krone",
% 	"DOP": "Dominican Peso",
% 	"DZD": "Algerian Dinar",
% 	"EEK": "Estonian Kroon",
% 	"EGP": "Egyptian Pound",
% 	"ERN": "Eritrean Nakfa",
% 	"ETB": "Ethiopian Birr",
% 	"EUR": "Euro",
% 	"FJD": "Fijian Dollar",
% 	"FKP": "Falkland Islands Pound",
% 	"GBP": "British Pound Sterling",
% 	"GEL": "Georgian Lari",
% 	"GGP": "Guernsey Pound",
% 	"GHS": "Ghanaian Cedi",
% 	"GIP": "Gibraltar Pound",
% 	"GMD": "Gambian Dalasi",
% 	"GNF": "Guinean Franc",
% 	"GTQ": "Guatemalan Quetzal",
% 	"GYD": "Guyanaese Dollar",
% 	"HKD": "Hong Kong Dollar",
% 	"HNL": "Honduran Lempira",
% 	"HRK": "Croatian Kuna",
% 	"HTG": "Haitian Gourde",
% 	"HUF": "Hungarian Forint",
% 	"IDR": "Indonesian Rupiah",
% 	"ILS": "Israeli New Sheqel",
% 	"IMP": "Manx pound",
% 	"INR": "Indian Rupee",
% 	"IQD": "Iraqi Dinar",
% 	"IRR": "Iranian Rial",
% 	"ISK": "Icelandic Króna",
% 	"JEP": "Jersey Pound",
% 	"JMD": "Jamaican Dollar",
% 	"JOD": "Jordanian Dinar",
% 	"JPY": "Japanese Yen",
% 	"KES": "Kenyan Shilling",
% 	"KGS": "Kyrgystani Som",
% 	"KHR": "Cambodian Riel",
% 	"KMF": "Comorian Franc",
% 	"KPW": "North Korean Won",
% 	"KRW": "South Korean Won",
% 	"KWD": "Kuwaiti Dinar",
% 	"KYD": "Cayman Islands Dollar",
% 	"KZT": "Kazakhstani Tenge",
% 	"LAK": "Laotian Kip",
% 	"LBP": "Lebanese Pound",
% 	"LKR": "Sri Lankan Rupee",
% 	"LRD": "Liberian Dollar",
% 	"LSL": "Lesotho Loti",
% 	"LTL": "Lithuanian Litas",
% 	"LVL": "Latvian Lats",
% 	"LYD": "Libyan Dinar",
% 	"MAD": "Moroccan Dirham",
% 	"MDL": "Moldovan Leu",
% 	"MGA": "Malagasy Ariary",
% 	"MKD": "Macedonian Denar",
% 	"MMK": "Myanma Kyat",
% 	"MNT": "Mongolian Tugrik",
% 	"MOP": "Macanese Pataca",
% 	"MRO": "Mauritanian Ouguiya",
% 	"MTL": "Maltese Lira",
% 	"MUR": "Mauritian Rupee",
% 	"MVR": "Maldivian Rufiyaa",
% 	"MWK": "Malawian Kwacha",
% 	"MXN": "Mexican Peso",
% 	"MYR": "Malaysian Ringgit",
% 	"MZN": "Mozambican Metical",
% 	"NAD": "Namibian Dollar",
% 	"NGN": "Nigerian Naira",
% 	"NIO": "Nicaraguan Córdoba",
% 	"NOK": "Norwegian Krone",
% 	"NPR": "Nepalese Rupee",
% 	"NZD": "New Zealand Dollar",
% 	"OMR": "Omani Rial",
% 	"PAB": "Panamanian Balboa",
% 	"PEN": "Peruvian Nuevo Sol",
% 	"PGK": "Papua New Guinean Kina",
% 	"PHP": "Philippine Peso",
% 	"PKR": "Pakistani Rupee",
% 	"PLN": "Polish Zloty",
% 	"PYG": "Paraguayan Guarani",
% 	"QAR": "Qatari Rial",
% 	"RON": "Romanian Leu",
% 	"RSD": "Serbian Dinar",
% 	"RUB": "Russian Ruble",
% 	"RWF": "Rwandan Franc",
% 	"SAR": "Saudi Riyal",
% 	"SBD": "Solomon Islands Dollar",
% 	"SCR": "Seychellois Rupee",
% 	"SDG": "Sudanese Pound",
% 	"SEK": "Swedish Krona",
% 	"SGD": "Singapore Dollar",
% 	"SHP": "Saint Helena Pound",
% 	"SLL": "Sierra Leonean Leone",
% 	"SOS": "Somali Shilling",
% 	"SRD": "Surinamese Dollar",
% 	"STD": "São Tomé and Príncipe Dobra",
% 	"SVC": "Salvadoran Colón",
% 	"SYP": "Syrian Pound",
% 	"SZL": "Swazi Lilangeni",
% 	"THB": "Thai Baht",
% 	"TJS": "Tajikistani Somoni",
% 	"TMT": "Turkmenistani Manat",
% 	"TND": "Tunisian Dinar",
% 	"TOP": "Tongan Pa?anga",
% 	"TRY": "Turkish Lira",
% 	"TTD": "Trinidad and Tobago Dollar",
% 	"TWD": "New Taiwan Dollar",
% 	"TZS": "Tanzanian Shilling",
% 	"UAH": "Ukrainian Hryvnia",
% 	"UGX": "Ugandan Shilling",
% 	"USD": "United States Dollar",
% 	"UYU": "Uruguayan Peso",
% 	"UZS": "Uzbekistan Som",
% 	"VEF": "Venezuelan Bolívar Fuerte",
% 	"VND": "Vietnamese Dong",
% 	"VUV": "Vanuatu Vatu",
% 	"WST": "Samoan Tala",
% 	"XAF": "CFA Franc BEAC",
% 	"XAG": "Silver (troy ounce)",
% 	"XAU": "Gold (troy ounce)",
% 	"XCD": "East Caribbean Dollar",
% 	"XDR": "Special Drawing Rights",
% 	"XOF": "CFA Franc BCEAO",
% 	"XPF": "CFP Franc",
% 	"YER": "Yemeni Rial",
% 	"ZAR": "South African Rand",
% 	"ZMK": "Zambian Kwacha (pre-2013)",
% 	"ZMW": "Zambian Kwacha",
% 	"ZWL": "Zimbabwean Dollar"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Change this app_id to your own id number for more API requests. Go to
%openexchangerates.org to sign up for an account.
app_id ='b760f1a1d4c1472db5d354388f0302a4';

if nargin == 0
    base = 'USD';
    curr = 'all';
    date = 'latest';
end

if nargin < 3 || isequal(date,'')
    date = 'latest';
elseif ~isequal(date,'latest') 
    %check simple mistakes in format and date range
    startIndex = regexp(date,'[12][019][0-9][0-9]-[01][0-9]-[0-3][0-9]', 'once');
    if isempty(startIndex)
        error('Incorrect date format or value ranges. Use: YYYY-MM-DD');
    end
    date = strcat('historical/',date);
end



url_request = strcat('http://openexchangerates.org/api/',date,...
    '.json?app_id=',app_id);

data = parse_json(urlread(url_request));
all_rates = data{1}.rates;
%convert structure to array
all_names = fieldnames(all_rates); %a cell array of currency abbreviations
all_rates_numbers = cell2mat(struct2cell(all_rates));

if isequal(base,'USD') || isequal(base,'')
    %do nothing, rates are already referenced to USD
else
    %reference to the new base currency rate
    %find the index of the base currency
    [validbase,baseindex] = ismember(base,all_names);
    if ~validbase
        error('Not a valid abbreviation for the base currency');
    else
        all_rates_numbers = all_rates_numbers./all_rates_numbers(baseindex);
    end
end

%check that all currencies in curr are found
%get indices of all desired currencies
if isequal(curr,'all') || isequal(curr,'')
    %return all
    rates = all_rates_numbers;
    currencies = all_names;
else
    if iscell(curr)
        curr_indices = zeros(length(curr),1);
        for i = 1:1:length(curr) 
            [curr_member,curr_index] = ismember(curr{i},all_names);
            if ~curr_member
                error(strcat(curr{i},' is not a valid currency abbreviation.'));
            end
            curr_indices(i) = curr_index;
        end
        currencies = all_names(curr_indices);
        rates = all_rates_numbers(curr_indices);
    else
        %just a single currency to return
        [curr_member,curr_index] = ismember(curr,all_names);
        if ~curr_member
            error(strcat(curr,' is not a valid currency abbreviation.'));
        end
        currencies = curr;
        rates = all_rates_numbers(curr_index);
    end
end

rates_struct = cell2struct(num2cell(rates),currencies,1);
end

function [data, json] = parse_json(json)
% Written by: Joel Feenstra

% [DATA JSON] = PARSE_JSON(json)
% This function parses a JSON string and returns a cell array with the
% parsed data. JSON objects are converted to structures and JSON arrays are
% converted to cell arrays.
%
% Example:
% google_search = 'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=matlab';
% matlab_results = parse_json(urlread(google_search));
% disp(matlab_results{1}.responseData.results{1}.titleNoFormatting)
% disp(matlab_results{1}.responseData.results{1}.visibleUrl)

    data = cell(0,1);

    while ~isempty(json)
        [value, json] = parse_value(json);
        data{end+1} = value; %#ok<AGROW>
    end
end

function [value, json] = parse_value(json)
    value = [];
    if ~isempty(json)
        id = json(1);
        json(1) = [];
        
        json = strtrim(json);
        
        switch lower(id)
            case '"'
                [value json] = parse_string(json);
                
            case '{'
                [value json] = parse_object(json);
                
            case '['
                [value json] = parse_array(json);
                
            case 't'
                value = true;
                if (length(json) >= 3)
                    json(1:3) = [];
                else
                    ME = MException('json:parse_value',['Invalid TRUE identifier: ' id json]);
                    ME.throw;
                end
                
            case 'f'
                value = false;
                if (length(json) >= 4)
                    json(1:4) = [];
                else
                    ME = MException('json:parse_value',['Invalid FALSE identifier: ' id json]);
                    ME.throw;
                end
                
            case 'n'
                value = [];
                if (length(json) >= 3)
                    json(1:3) = [];
                else
                    ME = MException('json:parse_value',['Invalid NULL identifier: ' id json]);
                    ME.throw;
                end
                
            otherwise
                [value json] = parse_number([id json]); % Need to put the id back on the string
        end
    end
end

function [data json] = parse_array(json)
    data = cell(0,1);
    while ~isempty(json)
        if strcmp(json(1),']') % Check if the array is closed
            json(1) = [];
            return
        end
        
        [value json] = parse_value(json);
        
        if isempty(value)
            ME = MException('json:parse_array',['Parsed an empty value: ' json]);
            ME.throw;
        end
        data{end+1} = value; %#ok<AGROW>
        
        while ~isempty(json) && ~isempty(regexp(json(1),'[\s,]','once'))
            json(1) = [];
        end
    end
end

function [data json] = parse_object(json)
    data = [];
    while ~isempty(json)
        id = json(1);
        json(1) = [];
        
        switch id
            case '"' % Start a name/value pair
                [name value remaining_json] = parse_name_value(json);
                if isempty(name)
                    ME = MException('json:parse_object',['Can not have an empty name: ' json]);
                    ME.throw;
                end
                data.(name) = value;
                json = remaining_json;
                
            case '}' % End of object, so exit the function
                return
                
            otherwise % Ignore other characters
        end
    end
end

function [name value json] = parse_name_value(json)
    name = [];
    value = [];
    if ~isempty(json)
        [name json] = parse_string(json);
        
        % Skip spaces and the : separator
        while ~isempty(json) && ~isempty(regexp(json(1),'[\s:]','once'))
            json(1) = [];
        end
        [value json] = parse_value(json);
    end
end

function [string json] = parse_string(json)
    string = [];
    while ~isempty(json)
        letter = json(1);
        json(1) = [];
        
        switch lower(letter)
            case '\' % Deal with escaped characters
                if ~isempty(json)
                    code = json(1);
                    json(1) = [];
                    switch lower(code)
                        case '"'
                            new_char = '"';
                        case '\'
                            new_char = '\';
                        case '/'
                            new_char = '/';
                        case {'b' 'f' 'n' 'r' 't'}
                            new_char = sprintf('\%c',code);
                        case 'u'
                            if length(json) >= 4
                                new_char = sprintf('\\u%s',json(1:4));
                                json(1:4) = [];
                            end
                        otherwise
                            new_char = [];
                    end
                end
                
            case '"' % Done with the string
                return
                
            otherwise
                new_char = letter;
        end
        % Append the new character
        string = [string new_char]; %#ok<AGROW>
    end
end

function [num json] = parse_number(json)
    num = [];
	if ~isempty(json)
        % Validate the floating point number using a regular expression
        [s e] = regexp(json,'^[\w]?[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?[\w]?','once');
        if ~isempty(s)
            num_str = json(s:e);
            json(s:e) = [];
            num = str2double(strtrim(num_str));
        end
    end
end