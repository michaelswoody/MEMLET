function [fittedVals, logLikli] =  MEMLETCL(data, userPDF, dataVar, fitVar, lb,ub, guess,annealTemp, varargin)
% (v1.0) function which performed the MLE fit just as in the MEMLET GUI program.
% bootstrapping can be performed via parallel computation by inputting the
% number of rounds of bootstrapping required. For more information, see the
% accompaning documentation. 

% Output Arguments: 
% fittedVals: an array of the fitted values from the MLE which is the same
% length as fittedVars. If bootstrapping is employed, it is a matrix with
% the width of fittedVars and length of the number of rounds of
% bootstrapping requested. The fitted values of each round of boostrapping
% are returned.
% % logLikli: The log-likelihood returned by the fit. This can be used for
% log-likelihood ratio testing. For bootstrapping a column vector of
%  log-likelihoods from each round is returned.
% 
% Input Arguments:
% 
% data: a column vector of data values. Global fitting is not supported in this command line function.
% userPDF: a string containing the PDF to be fit to the data, this string
% should contain all the fit and data variables given. 
% dataVar: a string containing the data variable(s) separated by commas
% fitVar: a string containing the fitting variable(s) separated by commas
% lb: the lower bounds for the fitted variables (string with values separated by commas,  the number of values must equal to the number of fitted variables) 
% ub: the upper bounds for the fitted variables (string with values separated by commas,  the number of values must equal to the number of fitted variables) 
% guess: the initial guess for the fitted variables (numeric array with a length equal
% to the number of fitted variables, or string with values separated by commas,  the number of values must equal to the number of fitted variables) 
% annealTemp: The initial annealing temperature
% Varargin: optional argument specifying either the number of rounds of
% bootstrapping to be performed (integer) or a string to specify which global
% variables are unique between datasets to perform a global fit. 

%process the strings of variables, bounds and guesses
fitVar= textscan(fitVar,'%s','delimiter',',');
fitVar=fitVar{1};
dataVar= textscan(dataVar,'%s','delimiter',',');
dataVar=dataVar{1};
lb= textscan(lb,'%s','delimiter',','); 
ub= textscan(ub,'%s','delimiter',',');
if ischar(guess)
guess= textscan(guess,'%s','delimiter',',');
guess= str2num(char(guess{1}));
end
ub= str2num(char(ub{1})); lb= str2num(char(lb{1})); 

%Make the PDF string into a function 
 [ custpdf, userFitVar] = strLinPDF( userPDF, fitVar, dataVar );

 if nargin==8 %no bootstrapping case 
    [fittedVals logLikli exitflag output]= mleAnneal(custpdf,data,annealTemp,lb,ub,guess);
 elseif nargin==9
     if isnumeric(varargin{1})% for doing bootstrapping 
    numBoot=varargin{1}; %number of rounds  
    loopsize=14; %how many iterations to do before updatin  
        numLoops=floor(numBoot/loopsize); % how many loops
        warning off 
             if numLoops>0
                for k=1:numLoops
                    parfor (i=1:loopsize)
                        ind=[];
                         if iscell(data) %handle cells for global data sets with various number of points 
                            fitData=cell(1,length(data));
                            for j=1:length(data)
                                tempData=cell2mat(data(j));
                                if mod(j,numDataVar)==1 %only make new indexes for each set of data (
                                ind=ceil(length(tempData)*rand(1,length(tempData)));
                                end
                                fitData(j)={tempData(ind)};
                            end
                         else % select (with replacement) the same number of points from the data set 
                            ind=ceil(length(data)*rand(1,length(data)));
                            fitData=data(ind,:);
                        end
                        [fittedVal, logLikliIt, dummy, dummy]=mleAnnealBoot(custpdf,fitData,lb,ub,guess);
                        tempfittedVals(i,:)=fittedVal; % store the fitted values 
                        logLikli(i,:)=logLikliIt;
                    end
                    fittedVals((k-1)*loopsize+1:(k)*loopsize,:)=tempfittedVals(:,:); %read out the fitted values from this loop iteration 
                  
                end
             else %if in the strange case you request fewer rounds of bootstrapping than the loopsize 
                k=0;
             end
            % perform the rest of the fits if doing a non-integer mutliple
            % of the loopsize 
            remainder=mod(numBoot,loopsize);
            if ~remainder==0
                tempfittedVals=[];
               parfor i=1:remainder
                    
                        if iscell(data) %handle cells for global data sets with various number of points 
                            fitData=cell(1,length(data));
                           for j=1:length(data)
                                tempData=cell2mat(data(j));
                                if mod(j,numDataVar)==1 %only make new indexes for each set of data
                                ind2=ceil(length(tempData)*rand(1,length(tempData)));
                                end
                                fitData(j)={tempData(ind2)};
                            end
                            
                        else
                            ind2=ceil(length(data)*rand(1,length(data)));
                            fitData=data(ind2,:);
                        end
                        [fittedVal, logLikliIt, dummy, dummy]=mleAnnealBoot(custpdf,fitData,lb,ub,guess);
                        tempfittedVals(i,:)=fittedVal;
                        logLikli(i,:)=logLikliIt;
                end
                 fittedVals((k)*loopsize+1:(k)*loopsize+remainder,:)= tempfittedVals(:,:);
            end  
     else %if global fit
         numFitVar=length(fitVar);
    numDataSet= size(data,2)/length(dataVar);
    
    globalVar =textscan(varargin{1},'%s','delimiter',','); % get global vars 
     if length(ub)<(numFitVar+(length(globalVar))*(numDataSet-1)) % duplicated the bounds if necessary for each data set 
        for i=1:length(globalVar)
        globVarPos=find(strcmp(fitVar,globalVar{i})); 
        %fill in bounds and guesses for newly created variables 
        ub=[ub(1:(globVarPos-1)); repmat(ub(globVarPos),numDataSet,1); ub(globVarPos+1:end)];
         lb =[lb(1:(globVarPos-1)); repmat(lb(globVarPos),numDataSet,1); lb(globVarPos+1:end)];
         guess=[guess(1:(globVarPos-1)); repmat(guess(globVarPos),numDataSet,1); guess(globVarPos+1:end)];
        end
     end
     if isempty(globVarPos)
         msgbox('Global Fit Variable not found in fitting variables');
     end
     %makes the PDF for the global case 
     [ custpdf userFitVar] = strLinPDF( userPDF, fitVar,dataVar,globalVar{1},numDataSet );
      [fittedVals logLikli exitflag output]= mleAnneal(custpdf,data,annealTemp,lb,ub,guess);
     end
     
end