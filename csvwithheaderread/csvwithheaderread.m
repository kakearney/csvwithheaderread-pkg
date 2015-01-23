function A = csvwithheaderread(file, varargin)
%CSVWITHHEADERREAD Read csv file with header row, mixed types allowed
%
% A = csvwithheaderread(file)
% A = csvwithheaderread(file, 'sepcol1')
% A = csvwithheaderread(file, 'bycol')
% A = csvwithheaderread(..., 'convertnum');
%
% Input variables:
%
%   file:           name of comma-delimited file.  Should include one
%                   header row with column names, then data  
%
%   'sepcol1':      Column 1 contains row names; return these separately
%                   from main data 
%
%   'bycol':        Return data by column, rather than as one matrix
%
%   'convertnum':   Convert data matrix (or column matrices) to numeric
%                   array if possible.  
%
% Output variables:
%
%   A:          1 x 1 structure of output

%------------------------
% Parse input
%------------------------

if ~exist(file, 'file')
    error('File not found');
end

if any(strcmp(varargin, 'bycol'))
    bycol = true;
else
    bycol = false;
end

if any(strcmp(varargin, 'convertnum'))
    convertnum = true;
else
    convertnum = false;
end

if any(strcmp(varargin, 'sepcol1'))
    sepcol1 = true;
else
    sepcol1 = false;
end


%------------------------
% Read file
%------------------------

fid = fopen(file, 'rt');
header = textscan(fid, '%s', 1, 'delimiter', '\n'); 
fclose(fid);

cols = textscan(header{1}{1}, '%s', 'delimiter', ',');
cols = cols{1};
ncol = length(cols);
fmt = repmat('%s', 1, ncol);

fid = fopen(file, 'rt');
data = textscan(fid, fmt, 'delimiter', ',', 'headerlines', 1);
fclose(fid);

%------------------------
% Reformat if necessary
%------------------------

if bycol
    cols = regexprep(cols, '[^\w_]', '');
    A = cell2struct(data', cols);
    if convertnum
        for ic = 1:ncol
            A.(cols{ic}) = convert2num(A.(cols{ic}));
        end
    end
elseif sepcol1
    A.cols = cols(2:end);
    col1 = regexprep(cols{1}, '[^\w_]', '');
    A.(col1) = data{:,1};
    A.data = cat(2, data{:,2:end});
    if convertnum
        A.(col1) = convert2num(A.(col1));
        A.data = convert2num(A.data);
    end 
else
    A.cols = regexprep(cols, '[^\w_]', '');
    A.data = cat(2, data{:});
    if convertnum
        A.data = convert2num(A.data);
    end
end

    
% Convert to num

function num = convert2num(str)
tmp = cellfun(@str2double, str);
actualnan = strcmp(lower(str), 'nan');
if any(isnan(tmp(:)) & ~actualnan(:))
    num = str;
else
    num = tmp;
end


   


