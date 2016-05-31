function [probability] = **functionName**(**DataVar1**,**fittedVar1**,**fittedVar2**,varargin)

% Template for a custom PDF
%   Text between double asterisk(**) should be replaced. 
%   See the other .m files in this PDF folder for examples of how to
%   format this type of file 
%   Type the name of your function above, and all your data variables and
%   fitted variables, make the last argument "varargin" if you want to
%   specify a function that can take a tmin and/or tmax

% The metaData variable contains all the information about the PDF
metaData=struct('name','**PDFname**',...  %give the PDF a name to appear in the drop down list 
            % specify the functional form of the PDF as a string, this can
            % be the function written out (ex. BetaPDF.m) or a call to this
            % .m file (ex. tripPDFHypo.m) 
            'PDF',  '**Functional Form of PDF**',...
            % give a comma seperated string of all the data Variables
            'dataVar','**t**',...
            % give a comma seperated string of all the  fitting Variables
            'fitVar', '**A,B,k1,k2,k3**',...
            % give a comma seperated string of the default upper bounds in
            % the same order as fitVar above
            'ub',   '**1,1,10000,10000,10000**',...
            % give a comma seperated string of the default lower bounds in
            % the same order as fitVar above
            'lb',   '**0,0,0,0,0**',...
            % give a comma seperated string of the default guesses in
            % the same order as fitVar above   
            'guess','**0.2,0.4,10,100,1000**');
   
            
            
%this  block handles when the program request the metaData only. This
%is done when the function is called with only one input argument, which
%tells whether there is a minimum time, maximim time, both, or neither
%specified. In this case, there is only one input argument
if nargin==1;
     % this switch statement is only needed if alternative PDFs are 
    % provided for cases when there is a tmin or tmax
    limtype=**DataVar1**; %change this to match DataVar1 on line 1
  
    switch limtype 
        case 0 % when no tmin or tmax, use the PDF specified above
        case 1 %when tmin exists, give an alternative PDF (see TwoPhasePDFHypo for example) 
       metaData.PDF='**PDF function that includes tmin** ';
        case 2 %when tmax exists, given alternative PDF
        metaData.PDF='**PDF function that includes tmax** ';
         case 3 %when both tmin and tmax exists, given alternative PDF
        metaData.PDF='**PDF function that includes tmin and tmax** ';
    end
    %this is important that the metaData is returned when this function is
    %called with only one argument
    probability=metaData; %return the MetaData as the sole output
    return
    
    
    %these statements will handle passing a tmin or tmax into a more
    %complex function (see TripExpPDF.m) for an example. In most cases
    %these can be removed. 
elseif nargin==**4**; % this number should be one more than the number of data Vars and fitted Vars 
	tmin=varargin{1}; %assign tdead to the extra argument passed in 
    tmax=Inf;
elseif nargin==**5**;
    tmin=varargin{1};
    tmax=varargin{2};
end 


% here you can specify the actual functional form if it is too long or 
% complicated to fit into a single line in the metadata above
probability= **PDF functional Form**;


end

