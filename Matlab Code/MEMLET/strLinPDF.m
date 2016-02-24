function [ linearPDF userFitVar ] = strLinPDF( userPDF, userFitVar,userDataVar,varargin )
%str2LinPDF takes a string and creates a usable PDF function and makes it
%global if enough arguments are supplied 
% Varargin{1} should be a cell array of strings of the global variables that
% are unique for each data set
% Varargin{2} should be the number of data sets being fit 
    
linUserPDF=char(userPDF);

if nargin==5 % if a global fit is neccessary, a combined PDF is generated 
    
    globalVar=varargin(1);
    globalVar=globalVar{1};
    numDataSets=cell2mat(varargin(2));
    finalPDF='';
    for k=1:numDataSets % a PDF is made first for each set of data 
        globalPDF=linUserPDF;
        %need to select only the global variables, remove the original from
        %the cell array of fitting variables and add back in their
        %independent versions     
        for  i=1:length(globalVar) %replaces the global var with the modified one for this data set (adding _#) 
        eval(sprintf('globalPDF=strrep(char(globalPDF),''%s'',''%s_%u'');',char(globalVar{i}),char(globalVar{i}),k))
        globVarPos=find(strcmp(userFitVar,globalVar{i})); 
        %updates the list of fittedVariables 
        userFitVar = [userFitVar(1:(globVarPos+(k-1))); sprintf('%s_%u',char(globalVar{i}),k); userFitVar((globVarPos+(k)):end)];
        end 
        for i=1:length(userDataVar) %replaces the data var index with the right one for this dataset 
            newInd=(k-1)*length(userDataVar)+i; %takes into account multiple columns representing one dataset
           eval(sprintf('globalPDF=regexprep(globalPDF,''(?<![a-zA-Z_0-9])%s(?![a-zA-Z_0-9])'',''cell2mat(dataVar(:,%u))'');',char(userDataVar{i}),newInd))
        end 
        finalPDF{k}=globalPDF;    
    end
    linUserPDF=finalPDF;
    for i=1:size(globalVar,1);
    userFitVar= userFitVar(~strcmp(userFitVar,globalVar(i))); %remove the original global variable 
    end
    numFitVar=length(userFitVar);
    for i=1:numFitVar % replaces the actual variable names with indexed fitVar
    eval(sprintf('linUserPDF=regexprep(linUserPDF,''(?<![a-zA-Z_0-9])%s(?![a-zA-Z_0-9])'',''fitVar(%u)'');',char(userFitVar{i}),i))
    end
   
else %if non global fit 
    numFitVar=length(userFitVar);
    for i=1:numFitVar %replaces variable names with indexed generic name fitVar
    eval(sprintf('linUserPDF=regexprep(linUserPDF,''(?<![a-zA-Z_0-9])%s(?![a-zA-Z_0-9])'',''fitVar(%u)'');',char(userFitVar{i}),i))
    end
    for i=1:length(userDataVar) %replaces data variable names with indexed generic name dataVar
        if nargin==4 && varargin{1} %if the data is in cells
        eval(sprintf('linUserPDF=regexprep(linUserPDF,''(?<![a-zA-Z_0-9])%s(?![a-zA-Z_0-9])'',''cell2mat(dataVar(:,%u))'');',char(userDataVar{i}),i))
        else
        eval(sprintf('linUserPDF=regexprep(linUserPDF,''(?<![a-zA-Z_0-9])%s(?![a-zA-Z_0-9])'',''dataVar(:,%u)'');',char(userDataVar{i}),i))
        end
    end
end  
% makes sure to do elementwise opperations 
linUserPDF=strrep(linUserPDF,'*','.*');
linUserPDF=strrep(linUserPDF,'/','./');
linUserPDF=strrep(linUserPDF,'^','.^');
%make the PDF (currently a string) into a function
if nargin==5 %global case produces a cell containing all the functions
    for i=1:length(linUserPDF)
         eval(['linearPDF{i}=@(dataVar,fitVar)' linUserPDF{i} ';']);
    end
else %non-global fitting case
eval(['linearPDF=@(dataVar,fitVar)' linUserPDF ';']);
end
end


