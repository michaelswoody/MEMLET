function varargout = MEMLET(varargin)
% MEMLET MATLAB code for MEMLET.fig
%   MLE Fitting Program with Graphic User Interface. 
%   Current Version 1.0, released June 2016
%   Written by Michael S Woody. memletinfo@gmail.com
%   For more information, see the user's guide supplied at http://michaelswoody.github.io/MEMLET/
%   To user the program with the command line, use the MEMELTCL.m file
%      
%

% Last Modified by GUIDE v2.5 25-Mar-2017 12:38:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
if ispc  % update the look if using Windows 
   javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsLookAndFeel')
end 
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MEMLET_OpeningFcn, ...
    'gui_OutputFcn',  @MEMLET_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before MEMLET is made visible.
function MEMLET_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MEMLET (see VARARGIN)

% Choose default command line output for MEMLET
handles.output = hObject;



% This sets up the initial plot - only do when we are invisible
% so window can get raised using MEMLET.
% if strcmp(get(hObject,'Visible'),'Checked')
    plot(.5,.5);
    axes(handles.axes1);
    set(gca,'FontSize',10)
     set(gca,'FontUnits','normalized')
% end

%allows latex for delta t
handles.laxis = axes('parent',hObject,'units','normalized','position',[0 0 1 1],'visible','off');
delete(handles.delTtext);

handles.delTtext = text(0.1418,0.456,'$\Delta$t','interpreter','latex');
set(handles.delTtext,'Visible','Off')

handles.showCam.Checked='off';
handles.ShowOther.Checked='off';
axes(handles.axes1);
% UIWAIT makes MEMLET wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = MEMLET_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% function to remove data above and below the minimum and maximum  ranges
function data=removeMinMax(data,handles,tmin,tmax,xInd)
% is a tmin or tmax is present 
if ~iscell(data) && size(data,2)>1 %put multicolumn non-cell data into a cell
    data=mat2cell(data,size(data,1),repmat(1,1,size(data,2)));
end
    if iscell(data)|| size(data,2)>1  % handles cells used for multiple data sets or 2D fits 
        userDataVar= textscan(get(handles.userDataVar,'String'),'%s','delimiter',',');
        numDataVar=length(userDataVar{1}); 
        numDataSets=size(data,2)/numDataVar; 
        if numDataVar==1 
              for j=1:numDataSets
                  keepInd=cell2mat(data(j))>=tmin & cell2mat(data(j))<=tmax;
                    tempdata=cell2mat(data(j));
                    data(j)={tempdata(keepInd)'};  
              end 
        else 
            for j=1:numDataVar:numDataSets*numDataVar
                keepInd=cell2mat(data(j))>=tmin & cell2mat(data(j))<=tmax;
                  for i=0:numDataVar-1 %remove events from each column based on values in  first column of each set
                    tempdata=cell2mat(data(j+i));
                    data(j+i)={tempdata(keepInd)'}; 
                  end    
            end
        end
    else
        data=data(data(:,xInd)>=tmin&data(:,xInd)<=tmax,:); %only selects data greater than or equal to the deadtime  
    end
if  isempty(data)
    msgbox('No data between tmin and tmax');
    return
end




% --- Executes on button press in plotDataBtn. Plots the data that has been
% loaded after clearing everything from the plot. Only plots data that is
% greater than or equal to the specified 
function plotDataBtn_Callback(hObject, eventdata, handles)
% hObject    handle to plotDataBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1); %select the gui's axis 
h=handles.axes1;
if get(handles.cumuBtn,'Value')
 bars=findobj(h,'Type','patch');%get all bars on the original plot 
      bars=[bars findobj(h,'Type','Bar')];%get all bars on the original plot 
   if ~isempty(bars)
    changePlotType=1; 
   else   changePlotType=0; 
  end
elseif get(handles.histBtn,'Value')
    steps=findobj(h,'Type','stair');%get all steps (cumulative dist) on the original plot 
  if ~isempty(steps)
    changePlotType=1; 
  else
      changePlotType=0;
  end

else 
    steps=findobj(h,'Type','stair'); %get all steps (cumulative dist) on the original plot
     bars=findobj(h,'Type','patch');%get all bars on the original plot 
     bars=[bars findobj(h,'Type','Bar')];%get all bars on the original plot 
   
  if ~isempty([steps bars])
    changePlotType=1; 
      else   changePlotType=0; 
  end
end

if changePlotType
     cla;
      legStr=[];
else %if the current plot type is not changing
    %get currrent legend text 
  try 
     [dummy ,dummy,dummy,legStr]=legend; 
     if isempty(legStr) % handles over matlab versions 
         leg=findobj(gcf,'Type','Legend');
         legStr=leg.String;
     end
      % checks to see if this type of fit is already ploted 

        ind=find(strcmp(legStr,['Data']));
  catch
      ind=[];
  end
    %if it is plotted, it deletes it. 
    if ~isempty(ind)
        legend off %turn off legend to ensure corrrect line handles are returned
        h = gca;
        try
        h=h.Children;
        legStr(ind)=[];
        delete(h(length(h)-ind+1)) 
       
        %remove the line corresponding to last fit (first index is most recent fit)
        catch %for earlier version of matlab 
            try
           bars=findobj(h,'Type','patch'); %get all bars on the original plot from old version of matlab 
            otherBars=findobj(h,'Type','bar'); %get all bars on the original plot from old version of matlab 
            steps=findobj(h,'Type','stair');%get all steps (cumulative dist) on the original plot 
             lines=findobj(h,'Type','Line');
                 plotObs=[bars;otherBars; steps; flipud(lines)];
%                delObj=findobj(plotObs,'DisplayName', [fitPDFname ' Fit']);
                 delete(delObj)
            catch
            end
       end
         
    end
end
hold on
%get data from axes app data 
try
    data=getappdata(handles.axes1,'data'); 
catch
    msgbox('Data is not properly loaded. Please load data and try again')
end
tmin=str2double(get(handles.deadTime,'String')); %load deadtime 
 tmax=str2double(get(handles.tmax,'String')); %load maxtime 


xInd=get(handles.xAxisCol,'Value'); % get which column to plot

%remove deadtimes
if ~isnan(tmin)|| ~isnan(tmin)
   if isnan(tmin)
       tmin=-Inf;
   end
   if isnan(tmax);
       tmax=Inf;
   end
   
truncdata=removeMinMax(data,handles,tmin,tmax,xInd);
data=truncdata;
end


yInd=get(handles.yAxisCol,'Value');
% determine what type of plot to do 
if(get(handles.histBtn,'Value')) 
    plotType='hist';
    %clear cumulative data plots 
  
    %plot results as normalized histogram
    if iscell(data) %handles cell data 
        [hisf hisx] =hist(cell2mat(data(xInd)),str2double(get(handles.numBins,'String')));
    else
      [hisf hisx] =hist(data(:,xInd),str2double(get(handles.numBins,'String')));
    end
       normf= hisf./(sum(hisf)*(hisx(2)-hisx(1))); %normalize area under histogram to 1
     
    bar(hisx,normf)
    plotData{3}=0; %set dummy variable 
%plot CDF if requested 
elseif (get(handles.cumuBtn,'Value'))
   
    plotType='cumu';
    if iscell(data)
        ecdf(cell2mat(data(xInd)));
    else
        ecdf(data(:,xInd))
    end 
    plotData{3}=0; %would be 2nd dimension index
%make x-y scatter plot 
else
    plotType='xy';
    if iscell(data)
       try
             plot(cell2mat(data(xInd)),cell2mat(data(yInd)),'.')
       catch ME
            msgbox('Plot could not be performed. Check sizes of datasets.')
            rethrow(ME)
        end
    else
      plot(data(:,xInd),data(:,yInd),'.')
    end
    plotData{3}=yInd; % store the y-column index 
end
%stroe plotData variables for use later as fits are plotted 
plotData{2}=xInd;
plotData{1}=plotType; 


legend([legStr 'Data'])
set(hObject,'userData',plotData); %store plot information in this button 

function plotFit(handles,varargin)
%called whenever a fit is plotted, is used for plotting each fit, the
%log-likelihood ratio test, and bootstrappiung bounds 

axes(handles.axes1); %select the gui's axis 
hold all
xl = xlim;% store limits to keep limits the same by the end 
yl=ylim;
data=getappdata(handles.axes1,'data'); 

%load Fit information  
 fitPDFtypeInd=get(handles.PDFselect,'Value');
    fitPDFtypes=get(handles.PDFselect,'String');
    fitPDFname=fitPDFtypes{fitPDFtypeInd};
      plotType=get(handles.plotDataBtn,'userData'); 
    plotType=plotType{1}; %specifies hist, cuml,or xy
if nargin==1 % for normal fit plot case, no extra arguments
    %load in the PDF and the values and variables
    fitPDF=get(handles.PDF,'String');
    fittedVals=getappdata(handles.fitOutBox,['fit' num2str(fitPDFtypeInd)]);
    userFitVar= textscan(get(handles.userFitVar,'String'),'%s','delimiter',',');
    userDataVar= textscan(get(handles.userDataVar,'String'),'%s','delimiter',',');
    userFitVar= userFitVar{1};userDataVar=userDataVar{1}; %unwrap cells 
elseif nargin==3 %plotting bootstrapping  need to read in BS outputs
    fitPDF=get(handles.PDF,'String');
    out_bs=varargin{1}; % bootstrap outputs 
    confIt=varargin{2}; %confidence intervals 
   fittedVals=getappdata(handles.fitOutBox,['fit' num2str(fitPDFtypeInd)]);
    userFitVar= textscan(get(handles.userFitVar,'String'),'%s','delimiter',',');
    userDataVar= textscan(get(handles.userDataVar,'String'),'%s','delimiter',',');
    fitPDFname=[fitPDFname ' BootStrap'];
    userFitVar= userFitVar{1};userDataVar=userDataVar{1};
elseif nargin==4 %plot log-likelihood testing, which requires the simplified PDF
    fitPDF=varargin{1}; % specified simplified PDF
    fittedVals=varargin{2}; % specified fittedVals 
    userFitVar=varargin{3}; % specified fittedVars 
    userDataVar= textscan(get(handles.userDataVar,'String'),'%s','delimiter',',');
    userDataVar=userDataVar{1}; 
    fitPDFname=['Simplified ' fitPDFname ' Model Test'];
end 

 %get current legend text
 [dummy ,dummy,dummy,legStr]=legend; 
 if isempty(legStr) % handles older matlab versions 
     leg=findobj(gcf,'Type','Legend');
     legStr=leg.String;
 end
    % checks to see if this type of fit is already ploted 
    ind=find(strcmp(legStr,[fitPDFname ' Fit']));
    ind=[ind find(strcmp(legStr,[fitPDFname ' Upper Fit']))];
    ind=[ind find(strcmp(legStr,[fitPDFname ' Lower Fit']))];
    %if it is plotted, it deletes it. 
    if ~isempty(ind)
        legend off %turn off legend to ensure corrrect line handles are returned
        h = gca;
        try
        h=h.Children;
        legStr(ind)=[];
        delete(h(length(h)-ind+1)) 
        legend on
        %remove the line corresponding to last fit (first index is most recent fit)
        catch %for earlier version of matlab 
           bar=findobj(h,'Type','patch');%get all bars on the original plot from old version of matlab 
            steps=findobj(h,'Type','stair');%get all steps (cumulative dist) on the original plot 
             lines=findobj(h,'Type','Line');
                 plotObs=[bar; steps; flipud(lines)];
               delObj=findobj(plotObs,'DisplayName', [fitPDFname ' Fit']);
                 delete(delObj)
       end
         
    end

%if global fit select the correct fitted values 
if get(handles.globFitSelect,'Value')
     xCol=get(handles.xAxisCol,'Value');
     numDataSet= size(data,2)/length(userDataVar);
     globalVar =textscan(get(handles.globalVarBox,'String'),'%s','delimiter',',');
        dataSetInd= ceil(xCol/length(userDataVar)); %which data set 
        k=1; %index of newFittedVals 
        i=1;
     while i<=length(userFitVar) %go through each global var getting the right one 
         if ~strcmp(userFitVar(i),globalVar{1})
             newFittedVal(i)=fittedVals(k);
             i=i+1;
             k=k+1;
         else
             newFittedVal(i)=fittedVals(k+dataSetInd-1);
             i=i+1;
             k=k+numDataSet;
         end
     end
     
        fittedVals=newFittedVal;   
end

  
% if min(size(data))>1 || iscell(data)

% generated the PDF to be plotted using strLinPDF with only two inputs
% (dataVars and fitVars) 
[ PDF userFitVar] = strLinPDF(fitPDF, userFitVar,userDataVar);

deadtime=str2double(get(handles.deadTime,'String'));
if isnan(deadtime) % if no deadtime, start plotting at minimum value 
    xCol=get(handles.xAxisCol,'Value');
    if iscell(data)
         deadtime=min(cell2mat(data(xCol)));
    else
        deadtime=min(data(:,xCol));
    end
end
plotVarx=linspace(deadtime,xl(2),10000)'; %create variables for plotting along x
try
 if strcmp(plotType,'hist') 
     if nargin==3 %in case of bootstrapping need two plots
         for i=1:length(out_bs) % calculate all possible values of PDF
          allVals(i,:)=PDF(plotVarx,out_bs(i,:)');  %evaluate PDF 
         end
         %find the upper and lower values at each x position 
          uppers=prctile(allVals,confIt*100,1);
          lowers=prctile(allVals,100*(1-confIt),1);
        plot(plotVarx,uppers,'k--');
        hold on 
        plot(plotVarx,lowers,'k--');
     else  
        fitted=PDF(plotVarx,fittedVals);  %evaluate PDF
        plot(plotVarx,fitted,'LineWidth',1); %plot PDF 
     end 
 elseif strcmp(plotType,'cumu')
             if nargin==3 %in case of bootstrapping need two plots
                 for i=1:length(out_bs) %find the normalized CDF from all BS values
          allVals(i,:)=PDF(plotVarx,out_bs(i,:)');
          fittedCDF(i,:)=cumtrapz(allVals(i,:)); 
          fittedCDF(i,:)=fittedCDF(i,:)/max(fittedCDF(i,:));
                 end
              uppers=prctile(fittedCDF,confIt*100,1);
              lowers=prctile(fittedCDF,100*(1-confIt),1);
            plot(plotVarx,uppers,'k--');
            hold on 
            plot(plotVarx,lowers,'k--');
               
             
             else 
                 fitted=PDF(plotVarx,fittedVals);  
                fittedCDF=cumtrapz(fitted(~isnan(fitted))); %take out any NaNs when doing cumulative (maybe at x=0?) 
                fittedCDF=fittedCDF/max(fittedCDF); %normalize CDF
                plot(plotVarx(~isnan(fitted)),fittedCDF)
             end
 else %for x-y plot,
             yCol=get(handles.yAxisCol,'Value');
        if mod(yCol,2)==1 %if 
           xCol=get(handles.xAxisCol,'Value');
           if iscell(data) % use the mimimum and maximum values of Y to set limits 
                plotVarY=linspace(min(cell2mat(data(yCol))),max(cell2mat(data(yCol))),50);
           else
                plotVarY=linspace(min(data(:,yCol)),max(data(:,yCol)),50);
           end
          
            for k=1:length(plotVarx) % calculate an expectation value for X for each value of Y 
                if mod(xCol,2)==0
                    intarg=PDF([plotVarY;repmat(plotVarx(k),1,length(plotVarY))]',fittedVals).*plotVarY';
                    expect(k)=trapz(plotVarY,intarg); %plot expectation value
                end
            end 
         plot(plotVarx,expect);
        else %perform similar calculation but with axis switched 
            yCol=get(handles.xAxisCol,'Value'); 
           xCol=get(handles.yAxisCol,'Value');
            plotVarx=linspace(yl(1),yl(2),10000)';
            if iscell(data)
                plotVarY=linspace(min(cell2mat(data(yCol))),max(cell2mat(data(yCol))),50);
            else
                plotVarY=linspace(min(data(:,yCol)),max(data(:,yCol)),50);
            end
            for k=1:length(plotVarx)
                if mod(xCol,2)==0
                    intarg=PDF([plotVarY;repmat(plotVarx(k),1,length(plotVarY))]',fittedVals).*plotVarY';
                    expect(k)=trapz(plotVarY,intarg);
                end
            end 
         plot(expect,plotVarx);
        end

 end
catch ME %general catch if plotting fails (usually only for x-y graph or 2D PDFs) 
    msgbox('Plotting this type of Fit not yet supported')
    rethrow(ME)
end 
 warning off 
    %update legend 
    if nargin==3 %if bootstrapping, need two legend entires 
     newLegEnt=sprintf('%s Upper Fit',fitPDFname); 
     newLegEnt2= sprintf('%s Lower Fit',fitPDFname); 
     legend([legStr newLegEnt newLegEnt2])
    else
    newLegEnt=sprintf('%s Fit',fitPDFname); 
    legend([legStr newLegEnt])
    end
 warning on 

     



% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function LoadStMenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadStMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)



% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on button press in FitDataBtn. Fits the dat a
function FitDataBtn_Callback(hObject, eventdata, handles)
% hObject    handle to FitDataBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%get relevant information 
% calls perform Fit, which actually does the fitting 
 [fittedVals logLikli exitflag output userFitVar]=performFit(handles);

 %generates the text for the output box 
userOut=[];
for i=1:length(userFitVar)
    userOut=[userOut sprintf('%s=%f,\n',char(userFitVar{i}),fittedVals(i))];
end
userOut=[userOut sprintf('Log-likelihood= %f',logLikli)];

fitType=get(handles.PDFselect,'Value');
%save fitted info in main workspace 
  assignin('base',['fittedVals' num2str(fitType)],fittedVals')
    assignin('base',['loglik' num2str(fitType)],logLikli)

% saves fitted information into the GUI 
set(handles.plotFitBtn,'Enable','on')
set(handles.fitOutBox,'String',userOut);
fitPDFtypeInd=get(handles.PDFselect,'Value');
setappdata(handles.fitOutBox,['LL' num2str(fitPDFtypeInd)],logLikli);
setappdata(handles.fitOutBox,['fit' num2str(fitPDFtypeInd)],fittedVals);
setappdata(handles.fitOutBox,['TextOut' num2str(fitPDFtypeInd)],userOut);
plotFit(handles); %plots the fitted values 

%function that is called whenever some data needs to be fit, could be
%considered the main function of the GUI
function [fittedVals, logLikli, varargout] = performFit(handles,varargin)
data=getappdata(handles.axes1,'data'); %get data  
tmin=str2double(get(handles.deadTime,'String'));
tmax=str2double(get(handles.tmax,'String'));

xCol=get(handles.xAxisCol,'Value');

try %read in Fitting Variable and Data Variables 
    if nargin==3 %use a different PDF and fitVars if doing logLikelihood test which should be supplied to performFit
       userPDF= varargin{1};
    else
       userPDF= get(handles.PDF,'String');
    end
    %read in the variables names and unwrap cells 
     userFitVar= textscan(get(handles.userFitVar,'String'),'%s','delimiter',',');
    userFitVar=userFitVar{1};
    userDataVar= textscan(get(handles.userDataVar,'String'),'%s','delimiter',',');
    userDataVar=userDataVar{1};
catch
    msgbox('No data and or fitting variables specified','Please specify variables')
    return
end


   
try %read in bounds and guesses 
    lb= textscan(get(handles.lbBox,'String'),'%s','delimiter',',');
    ub= textscan(get(handles.ubBox,'String'),'%s','delimiter',',');
    guess= textscan(get(handles.guessBox,'String'),'%s','delimiter',',');
catch
    msgbox('Please Check the bounds and guesses','Please specify fitting params')
    return
end
%unwrap the inputs from their cells 
 ub= str2num(char(ub{1})); lb= str2num(char(lb{1})); guess= str2num(char(guess{1}));
 
 if nargin==3 %remove unused fitVars and guesses if doing logLikelihood test
       ind=varargin{2}; %this is a list of the variables that are still being fit in the likelihood test case 
       ub=ub(ind); lb=lb(ind); guess=guess(ind);
       userFitVar=userFitVar(ind);
 end
%if only one dataVar, then select only the specified column of data 

try %check that the number of fitted variables is equal to the lb, ub, and guess 
    [ones(size(userFitVar,1),1) lb ub guess];
catch
    msgbox('the number of fitted variables does not match the guess and/or  bounds','Please check parameters')
    if(~get(handles.globFitSelect,'Value'))
    return
    end
end
if size(data,2)< length(userDataVar) %check that if there are multiple data variables there are at least as many columns
    msgbox('The number of columns of data does not match the number of data variables specified','Invalid data for specified PDF');
end


set(handles.fitNote,'visible','on')
pause(0.001) %to ensure graphics update
numDataVar=length(userDataVar);
if isnan(tmin) % if no deadtimes specified, makes it -Inf 
        tmin=-Inf;
end 
if isnan(tmax) % if no tmax specified, makes it Inf 
    tmax=Inf;
end 
%removes events less than the minimum time from each set of data, based on the
%first column of each dataset (assumes the first column is the variable
%with the minimum value) stores the results in a cell array since the
%number of points may be different between data sets 
%remove deadtimes
if ~isnan(tmin)|| ~isnan(tmin)
   if isnan(tmin)
       tmin=-Inf;
   end
   if isnan(tmax);
       tmax=Inf;
   end
   
data=removeMinMax(data,handles,tmin,tmax,xCol);

end

%handle global fit 
if get(handles.globFitSelect,'Value')
    numFitVar=length(userFitVar);
    numDataSet= size(data,2)/length(userDataVar);
    try
    globalVar =textscan(get(handles.globalVarBox,'String'),'%s','delimiter',','); % get global vars 
    catch 
        msgbox('No Unique Global Variables listed');
        return
    end
     if length(ub)<(numFitVar+(length(globalVar))*(numDataSet-1)) % duplicated the bounds if necessary for each data set 
        for i=1:length(globalVar)
        globVarPos=find(strcmp(userFitVar,globalVar{i})); 
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
     [ custpdf userFitVar] = strLinPDF( userPDF, userFitVar,userDataVar,globalVar{1},numDataSet );
else %non-global fit
  
if length(userDataVar)==1 %if single dimensional data, only use the relavant column specified as Xcol
    if iscell(data)
        data=cell2mat(data(xCol))';
    else
        data=data(:,xCol);
    end
else 
     numDataVar=length(userDataVar); 
     dataSetInd=ceil((xCol)/numDataVar)*(numDataVar)-numDataVar+1;
     if get(handles.XYPlot,'Value')
         yCol=get(handles.yAxisCol,'Value');
         dataSetIndY=ceil((yCol)/numDataVar)*(numDataVar)-numDataVar+1;
         if dataSetIndY~=dataSetInd
             msgbox('X and Y data appear to be from different datasets, please check data, number of variables, and X and Y selectors')
             return
         end
     end
     data=data(:,dataSetInd:dataSetInd+numDataVar-1);
end
%generate the PDF for non-global case 
[ custpdf userFitVar] = strLinPDF( userPDF, userFitVar,userDataVar,iscell(data(1)) );
end
% actually perform Fit  
    try
       if nargin==2% for bootstrappin
        numBoot=varargin{1}; %number of rounds
        set(handles.curIt,'String','0');
        drawnow; %updates the count to zero
        fitType=get(handles.PDFselect,'Value');
       guess=getappdata(handles.fitOutBox,['fit' num2str(fitType)]);
      
       
       try 
           parpool
           poolobj = gcp; % determine number of workers in current pool
           loopsize=poolobj.NumWorkers*2; %use each worker twice by default
       catch
           loopsize=10; %how many iterations to do before updating
       end
       numLoops=floor(numBoot/loopsize);
        warning off 
             if numLoops>0
                for k=1:numLoops
                    parfor (i=1:loopsize)
                        ind=[];
                         if iscell(data) %handle cells for global data sets with various number of points 
                            fitData=cell(1,length(data));
                            for j=1:length(data)
                                tempData=cell2mat(data(j));
                                if mod(j,numDataVar)==0 %only make new indexes for each set of data (
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
                    set(handles.curIt,'String',num2str((k)*loopsize)); 
                    drawnow; %update the count 
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
                    ind2=1;
                        if iscell(data) %handle cells for global data sets with various number of points 
                            fitData=cell(1,length(data));
                           for j=1:length(data)
                                tempData=cell2mat(data(j));
                                if mod(j,numDataVar)==0 %only make new indexes for each set of data
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
                set(handles.curIt,'String',num2str(size(fittedVals,1)));
            end
                warning on
       else %no bootstrapping (Standard case) 
          warning off %don't warn about the fitting itself
                 % Calls the mleAnnealing function 
                 annealTemp=str2num(get(handles.annealTempInput,'String'));
                 [fittedVals logLikli exitflag output]= mleAnneal(custpdf,data,annealTemp,lb,ub,guess);
        warning on
       end
    catch ME %general fitting error message 
        msgbox('Fitting Error')
        set(handles.fitNote,'visible','off')
        rethrow(ME) 
    end
    set(handles.fitNote,'visible','off')
%     varargout{1}=userFitVar;
    if nargout==5 % standard fit returns the most info  
        varargout{1}=exitflag;
        varargout{2}=output; %this is the log likelihood values
        varargout{3}=userFitVar; % return the fitVars 
    elseif nargout==4 % for log likelihood ratio test, don't need userFitVar
         varargout{1}=exitflag;
        varargout{2}=output; %
   elseif nargout==3 % for bootstrapping case
         varargout{1}=userFitVar; 
       
    end




function PDF_Callback(hObject, eventdata, handles)
% hObject    handle to PDF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PDF as text
%        str2double(get(hObject,'String')) returns contents of PDF as a double
setappdata(handles.PDF,'data',get(hObject,'String'));

function PDF_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to PDF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PDF as text
%        str2double(get(hObject,'String')) returns contents of PDF as a double
setappdata(handles.PDF,'data',get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function PDF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PDF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selDatFilBtn.
% function for loading data from a file 
function selDatFilBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selDatFilBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
prePath=getappdata(hObject,'FilePath');
if isempty(prePath) 
[fileName,PathName,FilterIndex]=uigetfile({'*.txt';'*.csv'},'Select Data File'); 
else
   [fileName,PathName,FilterIndex]=uigetfile({'*.txt';'*.csv'},'Select Data File',[prePath '\Data file']); 
end

setappdata(hObject,'FilePath',PathName);

% [fileName,PathName,FilterIndex]=uigetfile({'*.txt';'*.csv'},'Select Data File'); 
setappdata(handles.selDatFilBtn,'data',[PathName fileName]); % save filename as selected 
data=dlmread([PathName fileName]);% read data from file 

%  set(handles.fileName,'String',fileName);
 %remove trailing zeros if neccessary and put into cell format
 if size(data,2)>1
     celldata=cell(1,size(data,2));
 for i=1:size(data,2)
    lastEl=find(data(:,i),1,'last') ; %finds last nonzero element
    celldata(i)={data(1:lastEl,i)}';
 end
 data=celldata;
 end 
 setappdata(handles.axes1,'data',data); 
   checkMultColums(handles,data) %updates X and Y selectors based on number of colums
catch ME
    msgbox('Error Loading Data from file.')
    rethrow(ME)
end
    app=getappdata(handles.fitOutBox); %clear all previous Fits 
    appdatas = fieldnames(app);
        for kA = 1:length(appdatas)
          rmappdata(handles.fitOutBox,appdatas{kA});
        end
        
        bsAD=getappdata(handles.bootBox) ; %clear any bootstrap data 
      appdatas = fieldnames(bsAD);
       for kA = 1:length(appdatas) 
          rmappdata(handles.bootBox,appdatas{kA});
        end
   set(handles.plotFitBtn,'Enable','off');
   clearTextOut(handles) % clears the text display outputs 
   checkMultColums(handles,data)
    axes(handles.axes1); %select the gui's axis 
        cla;
        legend off;%clear any plots 
   
        % --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dataVarName_Callback(hObject, eventdata, handles)
% hObject    handle to dataVarName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dataVarName as text
%        str2double(get(hObject,'String')) returns contents of dataVarName as a double
loadDataBtn_Callback(handles.dataVarName, eventdata, handles) 
setappdata(handles.selDatFilBtn,'data','') %clear file name 

% --- Executes during object creation, after setting all properties.
function dataVarName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataVarName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numBins_Callback(hObject, eventdata, handles)
% hObject    handle to numBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numBins as text
%        str2double(get(hObject,'String')) returns contents of numBins as a double


% --- Executes during object creation, after setting all properties.
function numBins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numBins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function deadTime_Callback(hObject, eventdata, handles)
% hObject    handle to deadTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of deadTime as text
%        str2double(get(hObject,'String')) returns contents of deadTime as a double

updatePDFandVars(handles); %update the PDF when the deadtime changes 
app=getappdata(handles.fitOutBox); %clear all previous Fits 
    appdatas = fieldnames(app);
        for kA = 1:length(appdatas)
          rmappdata(handles.fitOutBox,appdatas{kA});
        end
        set(handles.plotFitBtn,'Enable','off');
         bsAD=getappdata(handles.bootBox) ; %clear any bootstrap data 
      appdatas = fieldnames(bsAD);
       for kA = 1:length(appdatas) 
          rmappdata(handles.bootBox,appdatas{kA});
       end
       clearTextOut(handles)

% --- Executes during object creation, after setting all properties.
function deadTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deadTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function fitOutBox_Callback(hObject, eventdata, handles)
% hObject    handle to fitOutBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fitOutBox as text
%        str2double(get(hObject,'String')) returns contents of fitOutBox as a double

% --- Executes during object creation, after setting all properties.
function fitOutBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fitOutBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in log likelihood testing
function LoglikelihoodTestBtn_Callback(hObject, eventdata, handles)
% hObject    handle to LoglikelihoodTestBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
constInput=get(handles.constIn,'String');
% get out a list of the constrained variables and their values from a comma
% seperated list 
vars=regexp([',' constInput ],'(?<=[,\s]*)[A-Za-z0-9_.]*(?==)','match');
Vals=regexp([constInput ','],'(?<==)([\w\W^]*?)(?=,)','match');
userPDF= get(handles.PDF,'String');
constPDF=userPDF;
%get userFitVars and unwrap 
userFitVar= textscan(get(handles.userFitVar,'String'),'%s','delimiter',',');
 userFitVar=userFitVar{1};
 ind=true;
 k=1; %index of "constant" varaibles 
for i=1:length(vars);
    conVars{k}=vars{i}; conVals{k}=Vals{i};
    ind=ind&~strcmp(userFitVar,conVars{k}); % Make an index of values that never show up as a constant 
    eval(sprintf('constPDF= regexprep(constPDF,''(?<![a-zA-Z_0-9])%s(?![a-zA-Z_0-9])'',conVals(k));',conVars{k}));
    k=k+1;
end
delDF=length(conVars); % number of degrees of freedom between the two data set (equal to the number of variables constrained) 
fitPDFtypeInd=get(handles.PDFselect,'Value'); 
oriLLH=getappdata(handles.fitOutBox,['LL' num2str(fitPDFtypeInd)]); % load the original log-likelihood from the last fit 
[fittedVals logLikli exitflag output]=performFit(handles,constPDF,ind);

set(handles.altLLH,'String',logLikli); % report the alternative model log likelihood 
RLL=2*(oriLLH-logLikli); % the log of the ratio of  the likelihoods 
p=1-chi2cdf(RLL,delDF); %calculate a p-value from the chi2cdf
if p==0;
    set(handles.pval,'String','<1e-16'); %1e-16 is the point when rounding returns 0
else
    set(handles.pval,'String',p); %report the p-value 
end
plotFit(handles,constPDF,fittedVals,userFitVar(ind)); %plot the constrained fit 

 %generates the text for the output box 
AltOut=[];
altVars=userFitVar(ind);
for i=1:length(altVars)
   AltOut=[AltOut sprintf('%s=%f,\n',char(altVars{i}),fittedVals(i))];
end
AltOut=AltOut(1:end-3);
% displays fitted values from alt model 
set(handles.AltFitBox,'String',AltOut);


% --- Executes during object creation, after setting all properties.
function altLLH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to constIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function constIn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to constIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function pValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function userFitVar_Callback(hObject, eventdata, handles)
% hObject    handle to userFitVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of userFitVar as text
%        str2double(get(hObject,'String')) returns contents of userFitVar as a double
setappdata(handles.userFitVar,'data',get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function userFitVar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to userFitVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function userDataVar_Callback(hObject, eventdata, handles)
% hObject    handle to userDataVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of userDataVar as text
%        str2double(get(hObject,'String')) returns contents of userDataVar as a double
setappdata(handles.userDataVar,'data',get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function userDataVar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to userDataVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function xAxisCol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xAxisCol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in plotTypePnl.
function plotTypePnl_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in plotTypePnl
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=get(handles.axes1,'data');
numCol=size(data,2);
%decide whether to enable the x and y axis selection boxes 
if get(handles.XYPlot,'Value')==1
    set(handles.xAxisCol,'Enable','on');
    set(handles.yAxisCol,'Enable','on');   
elseif numCol==1 %if only one data set, disable column selectors 
    set(handles.xAxisCol,'Enable','off');
    set(handles.yAxisCol,'Enable','off');
else %if multiple columns, allow user to choose which to plot with x data selector
    set(handles.yAxisCol,'Enable','off');
    set(handles.xAxisCol,'Enable','on');
end



% --- Executes during object creation, after setting all properties.
function yAxisCol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yAxisCol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function checkMultColums(handles,data)
%    Code which automatically populates tmin and tmax (NOT RECOMMENDED)
%    set(handles.tmax,'String',num2str(max(data)));
%    set(handles.deadTime,'String',num2str(min(data)));
%    updatePDFandVars(handles) 

 set(handles.text32,'Visible','on');
  numCol=size(data,2);
   %populate the X and Y selector list 
    if numCol>1; %if contains multiple columns 
        for i=1:numCol
            numCell{i}=sprintf('%u',i); %make a list cell of strings for each set
        end
        %populate the column select tools
        set(handles.xAxisCol,'Enable','on');
        set(handles.xAxisCol,'String',numCell);
           set(handles.yAxisCol,'String',numCell);
         set(handles.xAxisCol,'Value',1);
        set(handles.yAxisCol,'Value',2);
        set(handles.yAxisCol,'Enable','on');
         set(handles.yAxisCol,'Enable','on');
         set(handles.yAxisCol,'Enable','on');
        set(handles.text12,'Visible','on');
           set(handles.text13,'Visible','on');
              set(handles.text32,'Visible','on');
         set(handles.xAxisCol,'Visible','on');
  
        set(handles.yAxisCol,'Visible','off');
          set(handles.XYPlot,'Enable','on');
            
    else %if only one column set both to 1 
%         set(handles.xAxisCol,'Enable','off');
%         set(handles.yAxisCol,'Enable','off');
       
        set(handles.XYPlot,'Enable','off');
        set(handles.yAxisCol,'Enable','off');
        set(handles.text12,'Visible','off');
           set(handles.text13,'Visible','off');
              set(handles.text32,'Visible','off');
        set(handles.xAxisCol,'Value',1);
        set(handles.yAxisCol,'Value',1);
          set(handles.xAxisCol,'Visible','off');
        set(handles.yAxisCol,'Visible','off');
      
          
       if get(handles.XYPlot,'Value')==1
          set(handles.histBtn,'Value',1);
       end
    end
    plotSelectBtns_SelectionChangedFcn(handles.plotSelectBtns, [], handles)

% --- Executes on button press in loadDataBtn.
function loadDataBtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    dataVar = get(handles.dataVarName, 'String'); %check for variable name 
      try
            data=evalin('base',dataVar); %load variable from base workspace
            if size(data,1)==1 %make a column vector if row 
            data=data';
            end
            if iscell(data) && size(data,2)==1 % reorient data in cell for compatibility 
            data=data';
            end 
        catch
%             msgbox('Could not load data from given variable','Data Load Error')
        end
   checkMultColums(handles,data) %updates X and Y selectors based on number of colums
  
    setappdata(handles.axes1,'data',data); %store data in the graph 
    app=getappdata(handles.fitOutBox); %clear all previous Fits 
    appdatas = fieldnames(app); %c
        for kA = 1:length(appdatas) 
          rmappdata(handles.fitOutBox,appdatas{kA});
        end
        %clear all old bootstrap data 
     bsAD=getappdata(handles.bootBox) ;
      appdatas = fieldnames(bsAD);
       for kA = 1:length(appdatas) 
          rmappdata(handles.bootBox,appdatas{kA});
        end
        
        set(handles.plotFitBtn,'Enable','off');
   clearTextOut(handles)
%     axes(handles.axes1); %select the gui's axis 
%         cla;
        %call clear plot function
    ClearPlotBtn_Callback(handles.ClearPlotBtn, eventdata, handles)
catch ME
    msgbox('Data could not be loaded','Data Input Error')
    rethrow(ME)
end



    % functoin which checks the PDF list and updates the current PDF,
    % called when PDF or deadtime is changed 
function updatePDFandVars(handles)
tmin=str2double(get(handles.deadTime,'String')); %get deadtime 
tmax=str2double(get(handles.tmax,'String')); %get maxtime
delT=str2double(get(handles.delTbox,'String')); % 
PDFlist=get(handles.PDFselect,'String'); %get all the current PDF's 
fitType=PDFlist{get(handles.PDFselect,'Value')};
if isnan(tmin)
    if isnan(tmax)
        limtype=0;%no limit
    else
        limtype=2;%tmax only
    end 
else
      if isnan(tmax)
        limtype=1; %tmin only
    else
        limtype=3; %tmax and tmin
      end
end

if ~strcmp(fitType,'Other') % if not a custom PDF 
    %load the PDF and bounds/guess from the PDFList function 
    [userPDF userDataVar userFitVar lb ub guess]=PDFList(fitType,'all',limtype);
    
    del_tPos = strfind(userPDF, 'del_t');
    %replace the tdead text with the actual deadtime 
     if ~isnan(tmin)
            userPDF=regexprep(userPDF, 'tmin',num2str(tmin));
    end
     userPDF=regexprep(userPDF, 'tmax',num2str(tmax));
    if ~isnan(delT)
           userPDF=regexprep(userPDF, 'del_t',num2str(delT));
    end
    %store all the values 
    set(handles.PDF,'String',userPDF)
        set(handles.userDataVar,'String',userDataVar)
        set(handles.userFitVar,'String',userFitVar)
        set(handles.lbBox,'String',lb)
        set(handles.ubBox,'String',ub)
        set(handles.guessBox,'String',guess)
else % a custom PDF 
    try
          userPDF=getappdata(handles.PDF,'data');% get the custom PDF
          del_tPos = strfind(userPDF, 'del_t');
        if ~isnan(tmin) %if there is a deadtime 
             %replace anything that says tdead with the deadtime specified 
             try
            userPDF=regexprep(userPDF, 'tmin',num2str(tmin));
            set(handles.PDF,'String',userPDF)
             catch
                 msgbox('no tmin found in equation')
                 set(handles.PDF,'String',userPDF)
             end
        end
        if ~isnan(tmax) %if there is a deadtime 
              try
            userPDF=regexprep(userPDF, 'tmax',num2str(tmax));
             set(handles.PDF,'String',userPDF)
              catch
                   msgbox('no tmax found in equation')
                   set(handles.PDF,'String',userPDF)
             end
        end
% retrieve the previously typed custom PDF 
        set(handles.userDataVar,'String',getappdata(handles.userDataVar,'data'))
        set(handles.userFitVar,'String',getappdata(handles.userFitVar,'data'))
        set(handles.lbBox,'String',getappdata(handles.lbBox,'data'))
        set(handles.ubBox,'String',getappdata(handles.ubBox,'data'))
        set(handles.guessBox,'String',getappdata(handles.guessBox,'data'))
        set(handles.showFitOpt,'Value',1);
        showFitOpt_Callback(handles.showFitOpt, [], handles)
    catch ME 
        msgbox('Error in PDF selection')
        rethrow ME
    end

end

if isempty(del_tPos)
    set(handles.delTbox,'Visible','Off')
    set(handles.delTtext,'Visible','Off')
else
    set(handles.delTbox,'Visible','On')
     set(handles.delTtext,'Visible','On')
end

    
function lbBox_Callback(hObject, eventdata, handles)
% hObject    handle to lbBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lbBox as text
%        str2double(get(hObject,'String')) returns contents of lbBox as a double
setappdata(handles.lbBox,'data',get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function lbBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ubBox_Callback(hObject, eventdata, handles)
% hObject    handle to ubBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ubBox as text
%        str2double(get(hObject,'String')) returns contents of ubBox as a double
setappdata(handles.ubBox,'data',get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function ubBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ubBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function guessBox_Callback(hObject, eventdata, handles)
% hObject    handle to guessBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of guessBox as text
%        str2double(get(hObject,'String')) returns contents of guessBox as a double
setappdata(handles.guessBox,'data',get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function guessBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to guessBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function pval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function bootNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bootNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RunBootBtn. which runs the bootstrapping
% rountine 
function RunBootBtn_Callback(hObject, eventdata, handles)
% hObject    handle to RunBootBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

numBoot=str2double(get(handles.bootNum,'String')); %how many rounds 
%call performFit to actually do the calculations 
 [out_bs logLikli userFitVar]= performFit(handles,numBoot); 
bootOut=[];
 fitPDFtypeInd=get(handles.PDFselect,'Value');
 %save the bootstrapped values in the GUI and main workspace 
setappdata(handles.bootBox,['data' num2str(fitPDFtypeInd)],out_bs)
  assignin('base',['BS_out_' num2str(fitPDFtypeInd)],out_bs)
 
  %calls confInt_Callback to handle the calculation and display of the
  %intervals 
  confInt_Callback(handles.confInt, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function curIt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to curIt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%executes when the confidence interval is changed 
function confInt_Callback(hObject, eventdata, handles)
% hObject    handle to confInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of confInt as text
%        str2double(get(hObject,'String')) returns contents of confInt as a double
 try
    fitPDFtypeInd=get(handles.PDFselect,'Value'); 
    %get the boostrapped outputs 
    out_bs=getappdata(handles.bootBox,['data' num2str(fitPDFtypeInd)]);
    if isempty(out_bs)
        set(handles.bootBox,'String','Bootstrap Data Not Available');
%         msgbox('Bootstrap Data Not Available')
        return
    end 
    %sort the bootstrapped alues 
    out_bs=sort(out_bs);
 catch
    set(handles.bootBox,'String',''); % if no BS data, the clear box 
 end

j=1;
k=1;
userFitVar= textscan(get(handles.userFitVar,'String'),'%s','delimiter',',');
userFitVar=userFitVar{1};
 if get(handles.globFitSelect,'Value') %handle global fits 
          globVars= textscan(get(handles.globalVarBox,'String'),'%s','delimiter',',');
          globVars=globVars{1};
          %complicated way to find the number of data sets
          numDataSet=(size(out_bs,2)-sum(1-strcmp(userFitVar,globVars)))/(size(globVars,2));
          % go through all the fitted variables, including the "extra" ones from
          % the global fit
        for i=1:size(out_bs,2)
           if max(strcmp(userFitVar{j},globVars)) %if currently on a global Variable 
            userFitVarAll{i}= sprintf('%s_%u',userFitVar{j},k);
            k=k+1;
            if k>numDataSet %one you go through all the version of the current variable 
                j=j+1;
                k=1; %reset k 
            end
           else %if a shared variable 
                k=1; %reset k to 
                userFitVarAll{i}=userFitVar{j};
                j=j+1;
            end
        end
     userFitVar=userFitVarAll; %update the fitVars 
 end
bootOut=[];

confInt=str2double(get(handles.confInt,'String'));
%find the confidence intervals 
upperConf=out_bs(ceil(size(out_bs,1)*(1-(1-confInt)/2)),:);
lowerConf=out_bs(ceil(size(out_bs,1)*(1-confInt)/2),:);
% means=mean(out_bs); %this mean has no meaning really 
%save confidence interval to the main workspace 
 assignin('base',['BS_' num2str(fitPDFtypeInd) '_ConfInt_' num2str(confInt*100)],[upperConf; lowerConf]')
 %generate text 
for k=1:size(out_bs,2)
    bootOut=[bootOut sprintf('%s %u%% conf: %f - %f\n',char(userFitVar{k}),confInt*100,lowerConf(k),upperConf(k))];
end
set(handles.bootBox,'String',bootOut);
setappdata(handles.bootBox,sprintf('bootOut%d',fitPDFtypeInd),bootOut);





% --- Executes during object creation, after setting all properties.
function confInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to confInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveBoot
% --- Saves the bootstrap results directly to a file
function saveBoot_Callback(hObject, eventdata, handles)
% hObject    handle to saveBoot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userFitVar= textscan(get(handles.userFitVar,'String'),'%s','delimiter',',');
userFitVar=userFitVar{1};
try
     fitPDFtypeInd=get(handles.PDFselect,'Value');
    out_bs=getappdata(handles.bootBox,['data' num2str(fitPDFtypeInd)]);
catch
    msgbox('Bootstrap Data not Availible');
end
prePath=getappdata(hObject,'FilePath');
if isempty(prePath)
[FileName,PathName] = uiputfile('BootStrap Output.csv','Please select a file to save the Bootstrap Output');
else
 [FileName,PathName] = uiputfile([prePath 'BootStrap Output.csv'],'Please select a file to save the Bootstrap Output');
end

setappdata(hObject,'FilePath',PathName);

try
    T = array2table(out_bs,'VariableNames',userFitVar);
writetable(T,[PathName,FileName])
%  image=[1 1];
%  imaage=image+[2;2];
catch %try another way to write is xlswrite fails 
    fid = fopen([PathName,FileName], 'w+') ;
    for i=1:size(userFitVar,1)-1
     fprintf(fid, '%s,', userFitVar{i}) ;
    end
    fprintf(fid, '%s\n', userFitVar{end}) ;
 fclose(fid) ;
 dlmwrite([PathName,FileName], out_bs, '-append') ;
 xlswrite
end 
% --- Executes on button press in plotBootDist.
function plotBootDist_Callback(hObject, eventdata, handles)
% hObject    handle to plotBootDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userFitVar= textscan(get(handles.userFitVar,'String'),'%s','delimiter',',');
userFitVar=userFitVar{1};
%try to load the neccessary information from the GUI 
try
     fitPDFtypeInd=get(handles.PDFselect,'Value');
    out_bs=getappdata(handles.bootBox,['data' num2str(fitPDFtypeInd)]);
catch
    msgbox('Bootstrap Data not Availible');
end
k=1;  

      if get(handles.globFitSelect,'Value') %handle global fits 
          j=1;
          %determine how many variables there really are based on number of
          %data sets and the number of Global vs shared variables 
          globVars= textscan(get(handles.globalVarBox,'String'),'%s','delimiter',',');
          globVars=globVars{1};
          numDataSet=(size(out_bs,2)-sum(1-strcmp(userFitVar,globVars)))/(size(globVars,2));
          for i=1:size(out_bs,2)
            figure
            histogram(out_bs(:,i));%plot the bootstrap output 
            % if its a unique variable, give it the right title 
            if max(strcmp(userFitVar{j},globVars))
            figTitle=sprintf('Bootstrapping Distribution of %s_%u',userFitVar{j},k);
            xlabelStr=[userFitVar{j} '_' num2str(k)];
            k=k+1;
            if k>numDataSet
                j=j+1;
            end
            
            else %if shared variable, give it the right (simple) name 
                k=1;
                figTitle=sprintf('Bootstrapping Distribution of %s',userFitVar{j});
                 xlabelStr=[userFitVar{j}];
                j=j+1;
            end
            title(figTitle); 
             xlabel(xlabelStr)
            ylabel('Counts');

          end
      else %non-global is simplier case
          for i=1:size(out_bs,2)
              figure
            hist(out_bs(:,i),60);
            figTitle=sprintf('Bootstrapping Distribution of %s',userFitVar{i});
            xlabelStr=userFitVar{i};
            title(figTitle); 
        xlabel(xlabelStr)
        ylabel('Counts');

          end
      end

    % --- Executes during object creation, after setting all properties.
function PDFselect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PDFselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%populates the list of PDF names when the GUI is started by asking the
%PDFList function 
PDFnames=PDFList('all');
PDFnames={PDFnames{:} 'Other' 'Use Show PDFs menu for more...'};
set(hObject,'String',PDFnames)


% --- Executes on selection change in PDFselect. 
function PDFselect_Callback(hObject, eventdata, handles)
% hObject    handle to PDFselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PDFselect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        PDFselect
updatePDFandVars(handles) %main function to handle change 
fitType=get(hObject,'Value');
% if there is a previous fit already stored for this PDF, allow the user to
% replot it and display those values on the GUI 
if ~isempty(getappdata(handles.fitOutBox,['fit' num2str(fitType)]));
    set(handles.plotFitBtn,'Enable','on')
    set(handles.plotFitBtn,'Enable','on')
    userOut=getappdata(handles.fitOutBox,['TextOut' num2str(fitType)]);
    set(handles.fitOutBox,'String',userOut);
try % see if you can also update the bootstrap bounds (only will work if BS was already done)
    confInt_Callback(handles.confInt, [], handles)
catch
end
else %if this PDF hasn't been fit yet, don't allow plotting, and clear text
    set(handles.plotFitBtn,'Enable','off')
    clearTextOut(handles)
end

%function to clear all text outputs
function clearTextOut(handles)
    set(handles.fitOutBox,'String','');
    set(handles.bootBox,'String','');
    set(handles.pval,'String','');
    set(handles.pval,'String','');
    set(handles.altLLH,'String','');
    set(handles.AltFitBox,'String','');
     
     
    




% --- Executes during object creation, after setting all properties.
function fileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotFitBtn.
function plotFitBtn_Callback(hObject, eventdata, handles)
% hObject    handle to plotFitBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plotFit(handles)


% --- Executes on button press in plotBootBndsBtn.
function plotBootBndsBtn_Callback(hObject, eventdata, handles)
% hObject    handle to plotBootBndsBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 fitPDFtypeInd=get(handles.PDFselect,'Value');
 %get the relevant bootstrap data
out_bs=getappdata(handles.bootBox,['data' num2str(fitPDFtypeInd)]);
confInt=str2double(get(handles.confInt,'String'));
%call plotFit to actually perform the plotting
plotFit(handles,out_bs,confInt);
% plotFit(handles,upperConf,lowerConf);


% --- Executes on button press in popFigBtn.
% creates a figure accessible to the user 
function popFigBtn_Callback(hObject, eventdata, handles)
% hObject    handle to popFigBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h1=handles.axes1; %handle to GUI plot
%read the legend for old Version of Matlab 
 [dummy ,dummy,dummy,legStr]=legend;
 if isempty(legStr) %handles the newer versions 
     leg=findobj(gcf,'Type','Legend');
     legStr=leg.String;
 end
 endnewFig=figure; %new popout figure 
bar=findobj(h1,'Type','patch');%get all bars on the original plot from old version of matlab 
bar=[bar findobj(h1,'Type','bar')];%get bars from newer version of matlab
steps=findobj(h1,'Type','stair');%get all steps (cumulative dist) on the original plot 
lines=findobj(h1,'Type','Line'); %get all lines on the original plot 

copyobj(bar, gca); %put lines on the popout
copyobj(steps, gca); %put lines on the popout
copyobj(lines, gca); %put lines on the popout
legend(legStr); %replot legend which doesn't transfer well automatically
set(gca,'Units','normalized','Position',[0.1 0.1 0.8 0.8]); %resize


% --------------------------------------------------------------------
% save the state of the GUI (including all fits, bootstraps, etc)
function saveStMenu_Callback(hObject, eventdata, handles)
% hObject    handle to saveStMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h1=handles.axes1;
[FileName,PathName,FilterIndex] = uiputfile('.fig','Save Fitting State to...');
saveas(h1,[PathName FileName]);


% --- Executes on button press in globFitSelect.
function globFitSelect_Callback(hObject, eventdata, handles)
% hObject    handle to globFitSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of globFitSelect

% Decides whether or not to show the box allowing the user to input global
% variable 
if get(hObject,'Value')
    set(handles.globalVarBox,'Visible','On')
    set(handles.globVarTxt,'Visible','On')
else
    set(handles.globalVarBox,'Visible','Off')
    set(handles.globVarTxt,'Visible','Off')
end


% --- Executes during object creation, after setting all properties.
function globalVarBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to globalVarBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function annealTempInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to annealTempInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showFitOpt.
function showFitOpt_Callback(hObject, eventdata, handles)
% hObject    handle to showFitOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showFitOpt
if get(hObject,'Value')
    set(handles.fitOptPan,'Visible','On')
else
    set(handles.fitOptPan,'Visible','Off')
end



% --- Executes when selected object is changed in plotSelectBtns.
function plotSelectBtns_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in plotSelectBtns 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.histBtn,'Value')==1
set(handles.text2,'Visible','On')
set(handles.numBins,'Visible','On')
else
   set(handles.text2,'Visible','Off')
set(handles.numBins,'Visible','Off')
end
if get(handles.XYPlot,'Value')==1
    set(handles.xAxisCol,'Visible','On')
    set(handles.yAxisCol,'Visible','On')
    set(handles.text32,'Visible','On')
    set(handles.text13,'Visible','On')
      set(handles.xAxisCol,'Position',[0.372 0.07 0.081145 0.24]);
  
else
    set(handles.yAxisCol,'Visible','Off')
    set(handles.text32,'Visible','Off')
    set(handles.text13,'Visible','Off')
      set(handles.xAxisCol,'Position',[0.452 0.07 0.081145 0.24]);
end



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over dataVarName.
function dataVarName_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to dataVarName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadDataBtn_Callback(handles.dataVarName, eventdata, handles)


% --- Executes on button press in clear plot button 
function ClearPlotBtn_Callback(hObject, eventdata, handles)
% hObject    handle to ClearPlotBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1); %select the gui's axis 
 %clear all previous plots 
        h=handles.axes1;
            bars=findobj(h,'Type','patch');%get all bars on the original plot from old version of matlab 
            steps=findobj(h,'Type','stair');%get all steps (cumulative dist) on the original plot 
             lines=findobj(h,'Type','Line');
             legends=legend;
            plotObs=[bars; lines; steps;legends];
           delete(plotObs)
           cla;
           



function tmax_Callback(hObject, eventdata, handles)
% hObject    handle to tmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tmax as text
%        str2double(get(hObject,'String')) returns contents of tmax as a double
deadTime_Callback(handles.deadTime, eventdata, handles); %clear data like when changing deadtime

% --- Executes during object creation, after setting all properties.
function tmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in saveFitValBtn.
function saveFitValBtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveFitValBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

allPDFS=get(handles.PDFselect,'String');
numPDFs=size(allPDFS,1);
%get data name 
dataName=getappdata(handles.selDatFilBtn,'data');
dataName=strrep(dataName,'\','/');
if strcmp(dataName,'')
    try
        dataName=get(handles.dataVarName,'String');
    catch
        msgbox('No data loaded')
        return
    end
end
textOut=['Data' sprintf('\t') dataName sprintf('\n')];

%get tmin and tmax
tminVal=get(handles.deadTime,'String');
if ~isempty(tminVal)
    textOut=[textOut 'tmin' sprintf('\t') tminVal sprintf('\n')];
end
tmaxVal=get(handles.tmax,'String');
if ~isempty(tmaxVal)
    textOut=[textOut 'tmax' sprintf('\t') tmaxVal sprintf('\n')];
end

for j=1:numPDFs %cycle through all PDFs
   if ~isempty(getappdata(handles.fitOutBox,['fit' num2str(j)]));
        fitName=allPDFS{j};  
        %get name of PDF which has been fit
        textOut=[textOut sprintf('\n%s\n',fitName)];
        fittedVals=getappdata(handles.fitOutBox,['fit' num2str(j)]);  
        userFitVar= PDFList(fitName,'fitVar');
          userFitVar= textscan(userFitVar,'%s','delimiter',',');
            userFitVar=userFitVar{1};
        %if a non-global fit, export values tab delimited
        if length(fittedVals)==length(userFitVar) 
            logLikli=getappdata(handles.fitOutBox,['LL' num2str(j)]);
            %generate the text output for the GUI
            for i=1:length(userFitVar)
                textOut=[textOut sprintf('%s \t %f\n',char(userFitVar{i}),fittedVals(i))];
            end
            textOut=[textOut sprintf('Log-likelihood \t %f \n',logLikli)];
        else %if global fit, output text directly from fitted val box
           fitOut=getappdata(handles.fitOutBox,['TextOut' num2str(j)]);
           textOut=[textOut fitOut sprintf('\n')];
        end   
         %get bootstrapping data if present 
        BootText=getappdata(handles.bootBox,sprintf('bootOut%d',j));
        if ~isempty(BootText)
            BootText=strrep(BootText,'%','%%');
            textOut=[textOut 'Confidence Intervals' sprintf('\n') BootText sprintf('\n')];
        end
    end 
end
textOut=[textOut sprintf('\n \n')]; %add two lines after each data set
if ~exist('fitName')
    msgbox('No fits performed yet on this data')
    return
end

prePath=getappdata(hObject,'FilePath');
if isempty(prePath)
[FileName,PathName] = uiputfile('Fit Output.txt','Please select a file to save the Fitted Values');
else
    [FileName,PathName] = uiputfile([ prePath 'Fit Output.txt'],'Please select a file to save the Fitted Values');
end
%give option to append to existing text file or to overwrite
if exist([PathName FileName], 'file') == 2
    append = questdlg('File Exists. Append Output or Overwrite?','Append or Overwrite?','Append','Overwrite','Append');
    if strcmp(append,'Append')
    fid=fopen([PathName FileName],'a');
    else
    fid=fopen([PathName FileName],'w');
    end
else 
     fid=fopen([PathName FileName],'w');
end
%write output, and remember file path chosen 
setappdata(hObject,'FilePath',PathName);
fprintf(fid, textOut);
fclose(fid);





function delTbox_Callback(hObject, eventdata, handles)
% hObject    handle to delTbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delTbox as text
%        str2double(get(hObject,'String')) returns contents of delTbox as a double
updatePDFandVars(handles); %update the PDF when the del_t changes 

% --- Executes during object creation, after setting all properties.
function delTbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delTbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function globalVarBox_Callback(hObject, eventdata, handles)
% hObject    handle to globalVarBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of globalVarBox as text
%        str2double(get(hObject,'String')) returns contents of globalVarBox as a double


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function showCam_Callback(hObject, eventdata, handles)
% hObject    handle to showCam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(hObject.Checked,'off')
    hObject.Checked='on';
    else
    hObject.Checked ='off';
end
    %populates the list of PDF names when the GUI is started by asking the
%PDFList function 
RefreshPDFList(handles);

% --------------------------------------------------------------------
function ShowOther_Callback(hObject, eventdata, handles)
% hObject    handle to ShowOther (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(hObject.Checked,'off')
    hObject.Checked='on';
else
    hObject.Checked ='off';
end

    RefreshPDFList(handles);

function RefreshPDFList(handles) 
search=[];
if strcmp(handles.showCam.Checked,'on')
    search=[search 'Cam'];
end
if strcmp(handles.ShowOther.Checked,'on')
    search=[search 'Oth'];
end
if isempty(search)
    search='all';
end
OldValue=handles.PDFselect.String(handles.PDFselect.Value);
PDFnames=PDFList(search);
PDFnames={PDFnames{:} 'Other'};
if ~strcmp(search,'CamOth')
   PDFnames={PDFnames{:} 'Use Show PDFs menu for more...'};
end
newInd=1; reset=1;
for i=1:size(PDFnames,2)
    if strcmp(PDFnames{i},OldValue)
        newInd=i;
         reset=reset-1;
    else 
    end
end
    
set(handles.PDFselect,'String',PDFnames)
handles.PDFselect.Value=newInd;
if reset==1
     updatePDFandVars(handles);
end


function constIn_Callback(hObject, eventdata, handles)