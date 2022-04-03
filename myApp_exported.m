classdef myApp_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        DataPreparationPanel            matlab.ui.container.Panel
        SelectDatasetButtonGroup        matlab.ui.container.ButtonGroup
        SWaTButton                      matlab.ui.control.ToggleButton
        UAVButton                       matlab.ui.control.ToggleButton
        AVSButton                       matlab.ui.control.ToggleButton
        NetworkButtonGroup              matlab.ui.container.ButtonGroup
        PretrainedButton                matlab.ui.control.RadioButton
        TrainnewnetworkButton           matlab.ui.control.RadioButton
        NextButton                      matlab.ui.control.Button
        PreprocessingPanel              matlab.ui.container.Panel
        PreprocessingmethodButtonGroup  matlab.ui.container.ButtonGroup
        StandarizeButton                matlab.ui.control.ToggleButton
        Rescale01Button                 matlab.ui.control.ToggleButton
        NothingButton                   matlab.ui.control.ToggleButton
        RestartButton                   matlab.ui.control.Button
        NextButton_2                    matlab.ui.control.Button
        NetworkButtonGroup_2            matlab.ui.container.ButtonGroup
        PredictiveButton                matlab.ui.control.RadioButton
        ReconstructionButton            matlab.ui.control.RadioButton
        SWaTDataPanel                   matlab.ui.container.Panel
        UITable                         matlab.ui.control.Table
        SelectedSensorCheckBox          matlab.ui.control.CheckBox
        TextArea                        matlab.ui.control.TextArea
        NextButton_3                    matlab.ui.control.Button
        ResetButton_2                   matlab.ui.control.Button
        VisualizedataButton_2           matlab.ui.control.Button
        SelectedSensorLampLabel         matlab.ui.control.Label
        SelectedSensorLamp              matlab.ui.control.Lamp
        NetworkOptionsPanel             matlab.ui.container.Panel
        Image                           matlab.ui.control.Image
        RestartButton_2                 matlab.ui.control.Button
        TrainButton                     matlab.ui.control.Button
        NetworkspecificityDropDownLabel  matlab.ui.control.Label
        NetworkspecificityDropDown      matlab.ui.control.DropDown
        NumberofneuronsEditFieldLabel   matlab.ui.control.Label
        NumberofneuronsEditField        matlab.ui.control.NumericEditField
        HiddenUnitsEditFieldLabel       matlab.ui.control.Label
        HiddenUnitsEditField            matlab.ui.control.NumericEditField
        WindowsizewEditFieldLabel       matlab.ui.control.Label
        WindowsizewEditField            matlab.ui.control.NumericEditField
        StepSizesEditFieldLabel         matlab.ui.control.Label
        StepSizesEditField              matlab.ui.control.NumericEditField
        FilterNumberEditFieldLabel      matlab.ui.control.Label
        FilterNumberEditField           matlab.ui.control.NumericEditField
        EpochsEditFieldLabel            matlab.ui.control.Label
        EpochsEditField                 matlab.ui.control.NumericEditField
        MinibatchsizeEditFieldLabel     matlab.ui.control.Label
        MinibatchsizeEditField          matlab.ui.control.NumericEditField
        SavenettoworkspaceButton        matlab.ui.control.Button
        UsevaldataCheckBox              matlab.ui.control.CheckBox
        NetworkdesciptionButton         matlab.ui.control.Button
        NextButton_4                    matlab.ui.control.Button
        RatioEditField_2Label           matlab.ui.control.Label
        RatioEditField                  matlab.ui.control.NumericEditField
        AVSPreparationPanel             matlab.ui.container.Panel
        VehiculescenarioButtonGroup     matlab.ui.container.ButtonGroup
        HighwayButton                   matlab.ui.control.ToggleButton
        TownButton                      matlab.ui.control.ToggleButton
        RestartButton_3                 matlab.ui.control.Button
        NextButton_5                    matlab.ui.control.Button
        VisualizedataButton_3           matlab.ui.control.Button
        UAVPreparationPanel             matlab.ui.container.Panel
        SensordataselectionButtonGroup  matlab.ui.container.ButtonGroup
        AccelerometerButton             matlab.ui.control.ToggleButton
        GyroscopeButton                 matlab.ui.control.ToggleButton
        RestartButton_4                 matlab.ui.control.Button
        NextButton_6                    matlab.ui.control.Button
        VisualizedataButton_4           matlab.ui.control.Button
        FaultydataselectionPanel_AVS    matlab.ui.container.Panel
        FaulttypeButtonGroup            matlab.ui.container.ButtonGroup
        OffsetButton                    matlab.ui.control.ToggleButton
        NoiseButton                     matlab.ui.control.ToggleButton
        StuckvalueButton                matlab.ui.control.ToggleButton
        VisualizedataButton_5           matlab.ui.control.Button
        FaultdurationDropDownLabel      matlab.ui.control.Label
        FaultdurationDropDown           matlab.ui.control.DropDown
        ScenarioListBoxLabel            matlab.ui.control.Label
        ScenarioListBox                 matlab.ui.control.ListBox
        PredictdataButton               matlab.ui.control.Button
        OnlinedetectionsimulationButton  matlab.ui.control.Button
        FaultydataselectionPanel_UAVAcc  matlab.ui.container.Panel
        FaulttypeButtonGroup_2          matlab.ui.container.ButtonGroup
        OffsetButton_2                  matlab.ui.control.ToggleButton
        PackagedropButton               matlab.ui.control.ToggleButton
        StuckedvalueButton_2            matlab.ui.control.ToggleButton
        ScenarioListBox_2Label          matlab.ui.control.Label
        ScenarioListBox_2               matlab.ui.control.ListBox
        PredictdataButton_2             matlab.ui.control.Button
        FaulttypeButtonGroup_4          matlab.ui.container.ButtonGroup
        OffsetButton_4                  matlab.ui.control.ToggleButton
        NoiseButton_3                   matlab.ui.control.ToggleButton
        StuckedvalueButton_4            matlab.ui.control.ToggleButton
        FaultydataselectionPanel_SWaT   matlab.ui.container.Panel
        FaulttypeButtonGroup_3          matlab.ui.container.ButtonGroup
        OffsetButton_3                  matlab.ui.control.ToggleButton
        NoiseButton_2                   matlab.ui.control.ToggleButton
        StuckedvalueButton_3            matlab.ui.control.ToggleButton
        DayListBoxLabel                 matlab.ui.control.Label
        DayListBox                      matlab.ui.control.ListBox
        PredictdataButton_3             matlab.ui.control.Button
    end

    
    properties (Access = private)
        %% Data
        faultFreeData % fault free data
        dataProc % preprocessed data
        trainingData % training data
        dataXTrain
        dataYTrain
        XTrain
        YTrain
        XVal
        YVal
        AVSType
        %%
        
        %% Network
        NetworkDescApp % Network description app
        layers
        options
        netDescription % Description
        %%
        
        %% Rescale
        mini
        maxi
        %%
        
        %% Standarize
        mu
        sig
        %%
        
        saveNetPopupWin
        staticThreshold % Static theshold        
        trainPredict % trainDataPrediction
        anomValData
    end
    
    properties (Access = public)
        SWaT = load("APP\myApp_resources\SWaT\SWaT Data.mat");% Description
        UAVAcc = load("APP\myApp_resources\UAV\UAV Acc.mat", "faultFreeAcc");
        UAVAccFault = load("APP\myApp_resources\UAV\faultyAcc.mat");
        UAVGyrFault = load("APP\myApp_resources\UAV\faultyGyr.mat");
        UAVGyr = load("APP\myApp_resources\UAV\UAV Gyr.mat", "faultFreeGyr");
        AVS = load("APP\myApp_resources\AVS\AVS.mat");
        net % Description
        netOptions
    end
    
    methods (Access = private)
        
        function resetApp(app)
            % Make current instance of app invisible
            app.UIFigure.Visible = 'off';
            % Delete old instance
            delete(app)
            % Open 2nd instance of app
            myApp();
        end
        
        function layers = createGraph(app)            
                if strcmp(app.NetworkspecificityDropDown.Value, 'Shallow')
                    neurons = app.NumberofneuronsEditField.Value;
                    layers = [sequenceInputLayer(1, "Name", "Input")
                        fullyConnectedLayer(neurons, "Name", " Encode: Fully Connected with " + num2str(neurons) + " neurons")
                        fullyConnectedLayer(floor(neurons/2), "Name", "Encode: Fully Connected with " + num2str(floor(neurons/2)) + " neurons")
                        fullyConnectedLayer(floor(floor(neurons/2)/2), "Name", "Encode: Fully Connected with " + num2str(floor(floor(neurons/2)/2)) + " neurons")
                        fullyConnectedLayer(floor(neurons/2), "Name", "Decode:Fully Connected with " + num2str(floor(neurons/2)) + " neurons")
                        fullyConnectedLayer(neurons, "Name", "Decode: Fully Connected with " + num2str(neurons) + " neurons")
                        fullyConnectedLayer(1, "Name", "Out")
                        regressionLayer("Name", "Output")];
                    layers = layerGraph(layers);
                elseif strcmp(app.NetworkspecificityDropDown.Value, 'Hybrid (RNN-CNN)')
                    layers = [...
                        % input
                        sequenceInputLayer([1 1 1],'Name','Input')
                        sequenceFoldingLayer('Name','Fold')
                        
                        % CNN
                        convolution2dLayer(5,app.FilterNumberEditField.Value,'Padding','same','WeightsInitializer','he','Name',"Conv1: filter size: 5, #filters: " + num2str(app.FilterNumberEditField.Value),'DilationFactor',1);
                        batchNormalizationLayer('Name','bn')
                        reluLayer('Name','elu')
                        convolution2dLayer(5,app.FilterNumberEditField.Value,'Padding','same','WeightsInitializer','he','Name',"Conv2: filter size: 5, #filters: " + num2str(app.FilterNumberEditField.Value),'DilationFactor',1);
                        reluLayer('Name','elu1')
                        averagePooling2dLayer(1,'Stride',5,'Name','Pooling')
                        
                        % Flatten
                        sequenceUnfoldingLayer('Name','Unfold')
                        flattenLayer('Name','Flatten')
                        
                        % RNN
                        lstmLayer(app.HiddenUnitsEditField.Value,'Name',"LSTM1: " + num2str(app.HiddenUnitsEditField.Value) + " hidden units",'RecurrentWeightsInitializer','He','InputWeightsInitializer','He')
                        dropoutLayer(0.25,'Name','Dropout')
                        lstmLayer(app.HiddenUnitsEditField.Value,'Name',"LSTM2: " + num2str(app.HiddenUnitsEditField.Value) + " hidden units",'RecurrentWeightsInitializer','He','InputWeightsInitializer','He')
                        
                        % output
                        fullyConnectedLayer(1,'Name','Fully connected')
                        regressionLayer('Name','Output')    ];
                    
                    layers = layerGraph(layers);
                    layers= connectLayers(layers,'Fold/miniBatchSize','Unfold/miniBatchSize');
                else
                    layers = [
                        sequenceInputLayer(1, "Name", "Input")
                        lstmLayer(app.HiddenUnitsEditField.Value, "Name","LSTM1: " + num2str(app.HiddenUnitsEditField.Value) + " hidden units")
                        dropoutLayer(0.3, "Name", "Dropout")
                        lstmLayer(app.HiddenUnitsEditField.Value, "Name", "LSTM2: " + num2str(app.HiddenUnitsEditField.Value) + " hidden units")
                        fullyConnectedLayer(1,"Name", "Fully connected")
                        regressionLayer("Name", "Output")];
                    layers = layerGraph(layers);
                end
        end
        
        function oldPointer = beginTask(app, figure)
            oldPointer = get(app.UIFigure, 'pointer');
            set(app.UIFigure, 'pointer', 'watch');
            figure.Enable = 'off';
            drawnow;
        end
        
        function endTask(app, figure, oldPointer)
            set(app.UIFigure, 'pointer', oldPointer);
            figure.Enable = 'on';
        end
        
        function openAndResizeWindow(app, figure_out, figure_in)
            figure_out.Visible = 'off';
            figure_out.Enable = 'off';
            figure_in.Position(1) = figure_out.Position(1);
            figure_in.Position(2) = figure_out.Position(2);
            pos = figure_in.Position;
            app.UIFigure.Position(3)= pos(3);
            app.UIFigure.Position(4)= pos(4);
            movegui(app.UIFigure,"center")
            figure_in.Visible = 'on';
            figure_in.Enable = 'on';
            app.UIFigure.Visible = 'on';
        end
        
        function desc = generateDesc(app)
            if app.NetworkButtonGroup_2.SelectedObject == app.ReconstructionButton
                if strcmp(app.NetworkspecificityDropDown.Value, 'Shallow')
                    desc = "Shallow Autoencoder with 5 hidden layers";
                elseif strcmp(app.NetworkspecificityDropDown.Value,'Hybrid (RNN-CNN)')
                    desc = "Hybrid CNN-LSTM Autoencoder";
                else
                    desc = "LSTM Autoencoder";
                end
            else
                if strcmp(app.NetworkspecificityDropDown.Value,'Hybrid (RNN-CNN)')
                    desc = "Hybrid CNN-LSTM predictive network";
                elseif strcmp(app.NetworkspecificityDropDown.Value,'RNN')
                    desc = "RNN predictive network with GRU layers";
                else
                    desc = "RNN predictive network with LSTM layers";
                end
            end
        end
        
        function [rescaledData, maxi, mini] = rescaleData(~,data)
            if iscell(data)
                maxi = max([data{:,1}]);
                mini = min([data{:,1}]);
                rescaledData = data;
                for i = 1:size(data,1)
                    rescaledData{i,1} = (data{i,1}-mini)/(maxi-mini);
                end
            else
                maxi = max(data);
                mini = min(data);
                rescaledData = (data-mini)/(maxi-mini);
            end
        end
        
        function trainLSTM_AE(app)
            if iscell(app.XTrain)
                outputmode = 'sequence';
                sizeOut = size(app.XTrain{1,1},1);
            else
                outputmode = 'last';
                sizeOut = 1;
            end
            layers = [
                sequenceInputLayer(size(app.XTrain{1,1},1))
                lstmLayer(app.HiddenUnitsEditField.Value)
                dropoutLayer(0.3)
                lstmLayer(app.HiddenUnitsEditField.Value, "OutputMode", outputmode)
                fullyConnectedLayer(sizeOut)
                regressionLayer]; %#ok<*ADPROPLC>
            if isempty(app.XVal)
                options = trainingOptions("adam", ...
                    "Plots","training-progress", ...
                    "MaxEpochs", app.EpochsEditField.Value, ...
                    "MiniBatchSize", app.MinibatchsizeEditField.Value, ...
                    "InitialLearnRate", 0.001);
            else
                options = trainingOptions("adam", ...
                    "Plots","training-progress", ...
                    "MaxEpochs", app.EpochsEditField.Value, ...
                    "MiniBatchSize", app.MinibatchsizeEditField.Value, ...
                    "InitialLearnRate", 0.001, ...
                    "ValidationData", {app.XVal, app.XVal}, ...
                    "ValidationFrequency", floor(size(app.XTrain,1)/(3*app.MinibatchsizeEditField.Value)));
            end
            [app.net, app.netOptions] = trainNetwork(app.XTrain, app.XTrain, layers, options);
        end
        
        
        function [XtrEnd,YtrEnd] = splitData(app, data)
            [m, ~] = size(data);
            if m > 1
                data = data';
            end
            XTrain = lagmatrix(data, 1:app.WindowsizewEditField.Value);
            
            XTrain = XTrain(app.WindowsizewEditField.Value+1:end,:)';
            YTrain = data(app.WindowsizewEditField.Value+1:end); %#ok<*ADPROP>
            
            sizeMax = floor(size(YTrain,2)/app.StepSizesEditField.Value);
            
            
            XtrEnd = cell(size(YTrain,2)-app.StepSizesEditField.Value+1, 1);
            if app.StepSizesEditField.Value ~= 1
                YtrEnd = cell(size(YTrain,2)-app.StepSizesEditField.Value+1, 1);
                for i = 1:size(YTrain,2)-app.StepSizesEditField.Value+1
                    XtrEnd{i,1} = flip(XTrain(:,i));
                    YtrEnd{i,1} = YTrain(:,i:i+app.StepSizesEditField.Value-1)';
                end
            else
                YtrEnd = [];
                for i = 1:size(YTrain,2)-app.StepSizesEditField.Value+1
                    XtrEnd{i,1} = flip(XTrain(:,i));
                    YtrEnd(i,1) = YTrain(:,i:i+app.StepSizesEditField.Value-1)';
                end
            end
        end
        
        function splitTrainVal(app)
            if app.RatioEditField.Enable == 1
                P = app.RatioEditField.Value;
                m = size(app.dataXTrain,1);                
                idx = randperm(m);
                app.XTrain = app.dataXTrain(idx(1:round(P*m)),:);
                app.YTrain = app.dataYTrain(idx(1:round(P*m)),:);
                app.XVal = app.dataXTrain(idx(round(P*m)+1:end),:);
                app.YVal = app.dataYTrain(idx(round(P*m)+1:end),:);
            else
                app.XTrain = app.dataXTrain; app.YTrain = app.dataYTrain;
            end
            
        end
        
        function d = saveNetPopup(app)
            d = dialog("Name", "Save Network", "Position", [61 55 230 100], "Visible", "off", "WindowStyle", "modal");
            moveToFigCenter(app, d)
            netName = uicontrol("Parent",d, ...
                "Style","edit", ...
                "Position",[111 64 100 22]);
            netNameTxt = uicontrol("Parent", d, ...
                "Style", "text", ...
                "Position",[13 64 83 22], ...
                "String", "Network name"); %#ok<*NASGU>
            checkBox = uicontrol("Parent",d, ...
                "Style","checkbox", ...
                "String", "Export net options", ...
                "Position", [13 43 119 22]);
            btn = uicontrol("Parent",d, ...
                "Style","pushbutton", ...
                "Position", [70 12 100 22], ...
                "String", "Save", ...
                "Callback", @btnPush);
            d.Visible = 'on';
            function btnPush(src, event) %#ok<*INUSD>
                try
                    assignin("base", netName.String, app.net)
                    if checkBox.Value == 1
                        assignin("base", netName.String+"_options", app.netOptions)
                    end
                    btn.String = "Saved!";
                catch ME
                    d.Visible = 'off';
                    message = sprintf("Invalid variable name: '"+netName.String+"'\nPlease enter a valid name");
                    uialert(app.UIFigure,message,'Error Message', "CloseFcn",@closeAlert);
                    
                end
                function closeAlert(src, evnt)
                    d.Visible = "on";
                end
            end
        end
        
        function moveToFigCenter(app, fig2)
            pos = app.UIFigure.Position;
            fig2.Position(1) = pos(1);
            fig2.Position(2) = pos(2);
            pos2 = fig2.Position;
            pos2(1) = pos2(1)+pos(3)/2-pos2(3)/2;
            pos2(2) = pos2(2)+pos(4)/2-pos2(4)/2;
            fig2.Position = pos2;
        end
        
        function [trainData,dataResp] = splitDataEnd(app)
            if isa(app.dataProc, 'double')
                [trainData, dataResp] = splitData(app, app.dataProc);
            else
                trainData = cell(0,1);
                dataResp = [];
                for i = 1:size(app.dataProc,1)
                    [A, B] = splitData(app, app.dataProc{i,1});
                    trainData = [trainData; A];
                    dataResp = [dataResp; B];
                end
            end
        end
        
        
        function trainShallow_AE(app)
            neurons = app.NumberofneuronsEditField.Value;
            layers = [sequenceInputLayer(size(app.XTrain{1,1},1), "Name", "Input")
                fullyConnectedLayer(neurons, "Name", " Encode: Fully Connected with " + num2str(neurons) + " neurons")
                fullyConnectedLayer(floor(neurons/2), "Name", "Encode: Fully Connected with " + num2str(floor(neurons/2)) + " neurons")
                fullyConnectedLayer(floor(floor(neurons/2)/2), "Name", "Encode: Fully Connected with " + num2str(floor(floor(neurons/2)/2)) + " neurons")
                fullyConnectedLayer(floor(neurons/2), "Name", "Decode:Fully Connected with " + num2str(floor(neurons/2)) + " neurons")
                fullyConnectedLayer(neurons, "Name", "Decode: Fully Connected with " + num2str(neurons) + " neurons")
                fullyConnectedLayer(size(app.XTrain{1,1},1), "Name", "Out")
                regressionLayer("Name", "Output")];
            if isempty(app.XVal)
                options = trainingOptions("adam", ...
                    "Plots","training-progress", ...
                    "MaxEpochs", app.EpochsEditField.Value, ...
                    "MiniBatchSize", app.MinibatchsizeEditField.Value, ...
                    "InitialLearnRate", 0.001);
            else
                options = trainingOptions("adam", ...
                    "Plots","training-progress", ...
                    "MaxEpochs", app.EpochsEditField.Value, ...
                    "MiniBatchSize", app.MinibatchsizeEditField.Value, ...
                    "InitialLearnRate", 0.001, ...
                    "ValidationData", {app.XVal, app.XVal}, ...
                    "ValidationFrequency", floor(size(app.XTrain,1)/(3*app.MinibatchsizeEditField.Value)));
            end
            [app.net, app.netOptions] = trainNetwork(app.XTrain, app.XTrain, layers, options);
        end
        
        function trainHy_AE(app)
            numFeatures = size(app.XTrain{1,1}); % it depends on the roll back window (No of features, one output)
            
            numResponses = numFeatures(1);
            FiltZise = 5;
            learningrate = 0.001;
            
            
            
            %Learning rate
            %     solver = "adam";% solver option
            if gpuDeviceCount>0
                mydevice = 'gpu';
            else
                mydevice = 'cpu';
            end
            if isempty(app.XVal)
                options = trainingOptions('adam', ...
                    'MaxEpochs',app.EpochsEditField.Value, ...
                    'GradientThreshold',1, ...
                    'InitialLearnRate',learningrate, ...
                    'LearnRateSchedule',"piecewise", ...
                    'LearnRateDropPeriod',96, ...
                    'LearnRateDropFactor',0.25, ...
                    'MiniBatchSize',app.MinibatchsizeEditField.Value,...
                    'Verbose',false, ...
                    'Shuffle',"every-epoch",...
                    'ExecutionEnvironment',mydevice,...
                    'Plots','training-progress');
            else
                options = trainingOptions('adam', ...
                    'MaxEpochs',app.EpochsEditField.Value, ...
                    'GradientThreshold',1, ...
                    'InitialLearnRate',learningrate, ...
                    'LearnRateSchedule',"piecewise", ...
                    'LearnRateDropPeriod',96, ...
                    'LearnRateDropFactor',0.25, ...
                    'MiniBatchSize',app.MinibatchsizeEditField.Value,...
                    'Verbose',false, ...
                    'Shuffle',"every-epoch",...
                    'ExecutionEnvironment',mydevice,...
                    'Plots','training-progress', ...
                    "ValidationData", {app.XVal, app.XVal}, ...
                    "ValidationFrequency", floor(size(app.XTrain,1)/(3*app.MinibatchsizeEditField.Value)));
            end
            layers = [...
                % input
                sequenceInputLayer([numFeatures 1],'Name','Input')
                sequenceFoldingLayer('Name','Fold')
                
                % CNN
                convolution2dLayer(5,app.FilterNumberEditField.Value,'Padding','same','WeightsInitializer','he','Name',"Conv1: filter size: 5, #filters: " + num2str(app.FilterNumberEditField.Value),'DilationFactor',1);
                batchNormalizationLayer('Name','bn')
                reluLayer('Name','elu')
                convolution2dLayer(5,app.FilterNumberEditField.Value,'Padding','same','WeightsInitializer','he','Name',"Conv2: filter size: 5, #filters: " + num2str(app.FilterNumberEditField.Value),'DilationFactor',1);
                reluLayer('Name','elu1')
                averagePooling2dLayer(1,'Stride',5,'Name','Pooling')
                
                % Flatten
                sequenceUnfoldingLayer('Name','Unfold')
                flattenLayer('Name','Flatten')
                
                % RNN
                lstmLayer(app.HiddenUnitsEditField.Value,'Name',"LSTM1: " + num2str(app.HiddenUnitsEditField.Value) + " hidden units",'RecurrentWeightsInitializer','He','InputWeightsInitializer','He')
                dropoutLayer(0.25,'Name','Dropout')
                lstmLayer(app.HiddenUnitsEditField.Value,'Name',"LSTM2: " + num2str(app.HiddenUnitsEditField.Value) + " hidden units",'RecurrentWeightsInitializer','He','InputWeightsInitializer','He')
                
                % output
                fullyConnectedLayer(numResponses,'Name','Fully connected')
                regressionLayer('Name','Output')    ];
            
            layers = layerGraph(layers);
            layers= connectLayers(layers,'Fold/miniBatchSize','Unfold/miniBatchSize');
            [app.net, app.netOptions] = trainNetwork(app.XTrain, app.XTrain, layers, options);
        end
        
        function trainLSTM(app)
            if strcmp(class(app.YTrain), 'cell')
                outputmode = 'sequence';
                sizeOut = size(app.YTrain{1,1},1);
            else
                outputmode = 'last';
                sizeOut = 1;
            end
            layers = [
                sequenceInputLayer(size(app.XTrain{1,1},1))
                lstmLayer(app.HiddenUnitsEditField.Value)
                dropoutLayer(0.3)
                lstmLayer(app.HiddenUnitsEditField.Value, "OutputMode", outputmode)
                fullyConnectedLayer(sizeOut)
                regressionLayer]; %#ok<*ADPROPLC>
            if isempty(app.XVal)
                options = trainingOptions("adam", ...
                    "Plots","training-progress", ...
                    "MaxEpochs", app.EpochsEditField.Value, ...
                    "MiniBatchSize", app.MinibatchsizeEditField.Value, ...
                    "InitialLearnRate", 0.001);
            else
                options = trainingOptions("adam", ...
                    "Plots","training-progress", ...
                    "MaxEpochs", app.EpochsEditField.Value, ...
                    "MiniBatchSize", app.MinibatchsizeEditField.Value, ...
                    "InitialLearnRate", 0.001, ...
                    "ValidationData", {app.XVal, app.YVal}, ...
                    "ValidationFrequency", floor(size(app.XTrain,1)/(3*app.MinibatchsizeEditField.Value)));
            end
            [app.net, app.netOptions] = trainNetwork(app.XTrain, app.YTrain, layers, options);
        end
        
        function trainRNN(app)
            if strcmp(class(app.YTrain), 'cell')
                outputmode = 'sequence';
                sizeOut = size(app.YTrain{1,1},1);
            else
                outputmode = 'last';
                sizeOut = 1;
            end
            layers = [
                sequenceInputLayer(size(app.XTrain{1,1},1))
                gruLayer(app.HiddenUnitsEditField.Value)
                dropoutLayer(0.3)
                gruLayer(app.HiddenUnitsEditField.Value, "OutputMode", outputmode)
                fullyConnectedLayer(sizeOut)
                regressionLayer]; %#ok<*ADPROPLC>
            if isempty(app.XVal)
                options = trainingOptions("adam", ...
                    "Plots","training-progress", ...
                    "MaxEpochs", app.EpochsEditField.Value, ...
                    "MiniBatchSize", app.MinibatchsizeEditField.Value, ...
                    "InitialLearnRate", 0.001);
            else
                options = trainingOptions("adam", ...
                    "Plots","training-progress", ...
                    "MaxEpochs", app.EpochsEditField.Value, ...
                    "MiniBatchSize", app.MinibatchsizeEditField.Value, ...
                    "InitialLearnRate", 0.001, ...
                    "ValidationData", {app.XVal, app.YVal}, ...
                    "ValidationFrequency", floor(size(app.XTrain,1)/(3*app.MinibatchsizeEditField.Value)));
            end
            [app.net, app.netOptions] = trainNetwork(app.XTrain, app.YTrain, layers, options);
        end
        
        function trainHy(app)
            numFeatures = size(app.XTrain{1});% it depends on the roll back window (No of features, one output)
            numResponses = 1;FiltZise = 5;
            learningrate = 0.001;
            %Learning rate
            %     solver = "adam";% solver option
            if gpuDeviceCount>0
                mydevice = 'gpu';
            else
                mydevice = 'cpu';
            end
            if isempty(app.XVal)
                options = trainingOptions('adam', ...
                    'MaxEpochs',app.EpochsEditField.Value, ...
                    'GradientThreshold',1, ...
                    'InitialLearnRate',learningrate, ...
                    'LearnRateSchedule',"piecewise", ...
                    'LearnRateDropPeriod',96, ...
                    'LearnRateDropFactor',0.25, ...
                    'MiniBatchSize',app.MinibatchsizeEditField.Value,...
                    'Verbose',false, ...
                    'Shuffle',"every-epoch",...
                    'ExecutionEnvironment',mydevice,...
                    'Plots','training-progress');
            else
                options = trainingOptions('adam', ...
                    'MaxEpochs',app.EpochsEditField.Value, ...
                    'GradientThreshold',1, ...
                    'InitialLearnRate',learningrate, ...
                    'LearnRateSchedule',"piecewise", ...
                    'LearnRateDropPeriod',96, ...
                    'LearnRateDropFactor',0.25, ...
                    'MiniBatchSize',app.MinibatchsizeEditField.Value,...
                    'Verbose',false, ...
                    'Shuffle',"every-epoch",...
                    'ExecutionEnvironment',mydevice,...
                    'Plots','training-progress', ...
                    "ValidationData", {app.XVal, app.YVal}, ...
                    "ValidationFrequency", floor(size(app.XTrain,1)/(3*app.MinibatchsizeEditField.Value)));
            end
            layers = [...
                % input
                sequenceInputLayer([numFeatures 1],'Name','Input')
                sequenceFoldingLayer('Name','Fold')
                
                % CNN
                convolution2dLayer(5,app.FilterNumberEditField.Value,'Padding','same','WeightsInitializer','he','Name',"Conv1: filter size: 5, #filters: " + num2str(app.FilterNumberEditField.Value),'DilationFactor',1);
                batchNormalizationLayer('Name','bn')
                reluLayer('Name','elu')
                convolution2dLayer(5,app.FilterNumberEditField.Value,'Padding','same','WeightsInitializer','he','Name',"Conv2: filter size: 5, #filters: " + num2str(app.FilterNumberEditField.Value),'DilationFactor',1);
                reluLayer('Name','elu1')
                averagePooling2dLayer(1,'Stride',5,'Name','Pooling')
                
                % Flatten
                sequenceUnfoldingLayer('Name','Unfold')
                flattenLayer('Name','Flatten')
                
                % RNN
                lstmLayer(app.HiddenUnitsEditField.Value,'Name',"LSTM1: " + num2str(app.HiddenUnitsEditField.Value) + " hidden units",'RecurrentWeightsInitializer','He','InputWeightsInitializer','He')
                dropoutLayer(0.25,'Name','Dropout')
                lstmLayer(app.HiddenUnitsEditField.Value,'Name',"LSTM2: " + num2str(app.HiddenUnitsEditField.Value) + " hidden units",'RecurrentWeightsInitializer','He','InputWeightsInitializer','He', "OutputMode", "last")
                
                % output
                fullyConnectedLayer(numResponses,'Name','Fully connected')
                regressionLayer('Name','Output')    ];
            
            layers = layerGraph(layers);
            layers= connectLayers(layers,'Fold/miniBatchSize','Unfold/miniBatchSize');
            [app.net, app.netOptions] = trainNetwork(app.XTrain, app.YTrain, layers, options);
        end
        
        function legendBDCB(app, ~,evnt, axes)
            % This function uses the postion data from where the legend was
            % clicked to toggle a line on/off
            
            % First, get all of the lines
            lines = axes.Children;
            
            % Next, create segments based off of the number of lines. Based on
            % where the user clicked in the legend, we will assign that click
            % location to a line. This call generates a grid of equally spaced
            % ranges, with the number of ranges equaling the number of lines
            click_locations = linspace(0,1,numel(lines)+1);
            
            % Get corresponding bin based on the 2nd value of
            % evnt.IntersectionPoint. This corresponds to the vertical distance
            % within the legend, which we can use to identify what line
            % (roughly) in the legend was clicked
            line_num = discretize(evnt.IntersectionPoint(2),click_locations);
            
            % Set the visiblility of the corresponding line 'off' or 'on'
            relevant_line = lines(line_num);
            if strcmp(relevant_line.Visible,'on')
                relevant_line.Visible = 'off';
            else
                relevant_line.Visible = 'on';
            end
            
        end
        
        function preprocData(app)
            switch app.PreprocessingmethodButtonGroup.SelectedObject
                case app.Rescale01Button
                    [app.dataProc, app.maxi, app.mini] = rescaleData(app,app.faultFreeData);
                case app.StandarizeButton
                    try
                        [app.dataProc, app.mu, app.sig] = zscore(app.faultFreeData);
                    catch ME % if multiple fault free data, combine them all and standarize whole data
                        [~, app.mu, app.sig] = zscore([app.faultFreeData{:,1}]);
                        app.dataProc = cell(max(size(app.faultFreeData)),1);
                        for i = 1:max(size(app.dataProc))
                            app.dataProc{i,1} = (app.faultFreeData{i,1}-app.mu)/app.sig;
                        end
                    end
                case app.NothingButton
                    app.dataProc = app.faultFreeData;
            end
        end
        
        function pred = reshapeAutoencPred(app, data)
            c = [];
            for i = 1:size(data,1)
                c(:,i) = data{i};
            end
            b = [];
            c = flip(c);
            for i = 1:size(c,2)-app.WindowsizewEditField.Value
                b(i,:) = median(diag(c(:,i:i+app.WindowsizewEditField.Value-1)));
            end
            pred = b;            
        end
        
        function data = randomAnomData(app, anomData, ratio)            
            [m, ~] = size(anomData);
            idx = randperm(m);
            data = anomData(idx(1:round(ratio*m)),:); 
        end
        
        function threshold = findStaticThresh(app, resAnom, anomLabels)
            beta = 1;
            idx = [];
            threshMax = linspace(min(resAnom),max(resAnom), 200);
            y = logical([]);
            if size(anomLabels, 2) ~= 1
                anomLabels = anomLabels';
            end
            for i = 1:200
                y(:,i) = resAnom > threshMax(i);
            end
            if size(anomLabels) ~= size(y)
                anomLabels = anomLabels';
            end
            precision = []; recall = []; Fscore = [];            
            for i = 1:200
                k = confusionmat(logical(anomLabels), logical(y(:,i)));
                if width(k) > 1
                    precision(i) = k(2,2)/(k(2,2)+k(1,2));
                    recall(i) = k(2,2)/(k(2,2)+k(2,1));
                    Fscore(i) = (1+beta^2)*(precision(i)*recall(i))/(precision(i)*beta^2+recall(i));
                end
            end
            MaxFScore = max(Fscore);
            thrIdx = find(Fscore == MaxFScore);
            clear thrMax
            if size(thrIdx, 2) >1
                p = thrIdx(1);
                thrMax = threshMax(thrIdx(end));
            else
                p = thrIdx;
            end
            
            threshold = threshMax(p);
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            %set all secondary panels to invisible
            app.UIFigure.Visible = 'off';
            app.NetworkOptionsPanel.Visible = 'off';
            app.SWaTDataPanel.Visible = 'off';
            app.PreprocessingPanel.Visible = 'off';
            app.UAVPreparationPanel.Visible = 'off';
            app.AVSPreparationPanel.Visible = 'off';
            %
            movegui(app.UIFigure,"center")
            app.UIFigure.Visible = 'on';
            app.HiddenUnitsEditField.Visible = 0;
            app.HiddenUnitsEditFieldLabel.Visible = 0;
            app.FilterNumberEditField.Visible = 0;
            app.FilterNumberEditFieldLabel.Visible = 0;                
        end

        % Button pushed function: NextButton
        function NextButtonPushed(app, event)
            oldP = beginTask(app, app.DataPreparationPanel);
            switch app.NetworkButtonGroup.SelectedObject
                case app.TrainnewnetworkButton
                    switch app.SelectDatasetButtonGroup.SelectedObject
                        case app.SWaTButton
                            app.faultFreeData = app.SWaT.SWaTDatasetNormalv0;
                            app.UITable.Data = app.faultFreeData;
                            app.UITable.ColumnName = app.faultFreeData.Properties.VariableNames;
                            s = uistyle('BackgroundColor','blue');
                            addStyle(app.UITable,s,'column',[3 20 29 30])
                            openAndResizeWindow(app, app.DataPreparationPanel, app.SWaTDataPanel);
                        case app.AVSButton
                            openAndResizeWindow(app, app.DataPreparationPanel, app.AVSPreparationPanel);
                        case app.UAVButton
                            openAndResizeWindow(app, app.DataPreparationPanel, app.UAVPreparationPanel);
                    end
                case app.PretrainedButton
                    switch app.SelectDatasetButtonGroup.SelectedObject
                        case app.SWaTButton
                            
                        case app.AVSButton
                            
                        case app.UAVButton
                            
                    end
            end
            endTask(app, app.DataPreparationPanel, oldP);
        end

        % Button pushed function: RestartButton
        function RestartButtonPushed(app, event)
            resetApp(app);
        end

        % Callback function
        function VisualizedataButtonPushed(app, event)
            oldP = beginTask(app, app.PreprocessingPanel);
            if app.SelectDatasetButtonGroup.SelectedObject == app.SWaTButton
                plot(datetime(app.faultFreeData{7*60*60+60*30:end,1}),app.faultFreeData{7*60*60+60*30:end,3})
            end
            endTask(app, app.PreprocessingPanel, oldP);
        end

        % Cell selection callback: UITable
        function UITableCellSelection(app, event)
            global indices
            try
                removeStyle(app.UITable,2)
            catch ME
                
            end
            indices = event.Indices;
            idx = indices(1,2);
            if ismember(idx, [3 20 29 30])
                app.SelectedSensorCheckBox.Value = 1;
                app.VisualizedataButton_2.Enable = 1;
                app.NextButton_3.Enable = 1;
                app.SelectedSensorLampLabel.Text = app.UITable.ColumnName(idx);
                app.SelectedSensorLamp.Color = 'green';
                app.SelectedSensorCheckBox.Text = app.UITable.ColumnName(idx);
                s = uistyle('BackgroundColor','green');
                addStyle(app.UITable,s,'column', idx)
            else
                app.SelectedSensorCheckBox.Value = 0;
                app.VisualizedataButton_2.Enable = 0;
                app.NextButton_3.Enable = 0;
                app.SelectedSensorLampLabel.Text = app.UITable.ColumnName(idx);
                app.SelectedSensorLamp.Color = 'red';
                app.SelectedSensorCheckBox.Text = app.UITable.ColumnName(idx);
                s = uistyle('BackgroundColor','red');
                addStyle(app.UITable,s,'column', idx)
            end
            
        end

        % Button pushed function: ResetButton_2
        function ResetButton_2Pushed(app, event)
            resetApp(app);
        end

        % Button pushed function: NextButton_3
        function NextButton_3Pushed(app, event)
            global indices
            oldP = beginTask(app, app.SWaTDataPanel);
            beg = 7*60*60+60*30;
            endI = beg + 60*60*18;
            app.faultFreeData = app.UITable.Data{beg:endI,indices(1,2)};
            openAndResizeWindow(app, app.SWaTDataPanel, app.PreprocessingPanel)
            endTask(app, app.PreprocessingPanel, oldP);
        end

        % Button pushed function: VisualizedataButton_2
        function VisualizedataButton_2Pushed(app, event)
            global indices
            oldP = beginTask(app, app.SWaTDataPanel);
            if app.SelectedSensorCheckBox.Value == 1
                fig = uifigure;
                name = get(app.SelectedSensorCheckBox, 'Text');
                name = "Sensor: "+char(name);
                set(fig, 'Name', name)
                ax = uiaxes(fig,'Position',[10 10 550 400]);
                x = datetime(app.UITable.Data{7*60*60+60*30:end,1});
                y = app.UITable.Data{7*60*60+60*30:end,indices(1,2)};
                plot(ax,x,y)
                lim1 = datetime(app.UITable.Data{7*60*60+60*30,1});
                lim2 = datetime(app.UITable.Data{end,1});
                xlim(ax, [lim1 lim2])
            end
            endTask(app, app.SWaTDataPanel, oldP);
        end

        % Value changed function: NetworkspecificityDropDown
        function NetworkspecificityDropDownValueChanged(app, event)
            value = app.NetworkspecificityDropDown.Value;
            if strcmp(value, 'Shallow')
                app.FilterNumberEditField.Visible = 0;
                app.FilterNumberEditFieldLabel.Visible = 0;
                app.HiddenUnitsEditField.Visible = 0;
                app.HiddenUnitsEditFieldLabel.Visible = 0;
                app.NumberofneuronsEditField.Visible = 1;
                app.NumberofneuronsEditFieldLabel.Visible = 1;
                app.NumberofneuronsEditField.Value = 32;
                app.EpochsEditField.Value = 35;
                app.MinibatchsizeEditField.Value = 70;
            elseif strcmp(value, 'LSTM')
                app.FilterNumberEditField.Visible = 0;
                app.FilterNumberEditFieldLabel.Visible = 0;
                app.HiddenUnitsEditField.Visible = 1;
                app.HiddenUnitsEditFieldLabel.Visible = 1;
                app.NumberofneuronsEditField.Visible = 0;
                app.NumberofneuronsEditFieldLabel.Visible = 0;
                app.HiddenUnitsEditField.Value = 80;
                app.EpochsEditField.Value = 35;
                app.MinibatchsizeEditField.Value = 70;
            elseif strcmp(value, 'Hybrid (RNN-CNN)')
                app.FilterNumberEditField.Visible = 1;
                app.FilterNumberEditFieldLabel.Visible = 1;
                app.HiddenUnitsEditField.Visible = 1;
                app.HiddenUnitsEditFieldLabel.Visible = 1;
                app.NumberofneuronsEditField.Visible = 0;
                app.NumberofneuronsEditFieldLabel.Visible = 0;
                app.HiddenUnitsEditField.Value = 50;
                app.FilterNumberEditField.Value = 32;
                app.EpochsEditField.Value = 35;
                app.MinibatchsizeEditField.Value = 70;
            else
                app.FilterNumberEditField.Visible = 0;
                app.FilterNumberEditFieldLabel.Visible = 0;
                app.HiddenUnitsEditField.Visible = 1;
                app.HiddenUnitsEditFieldLabel.Visible = 1;
                app.NumberofneuronsEditField.Visible = 0;
                app.NumberofneuronsEditFieldLabel.Visible = 0;
                app.HiddenUnitsEditField.Value = 80;
                app.EpochsEditField.Value = 35;
                app.MinibatchsizeEditField.Value = 70;
            end
        end

        % Button pushed function: NextButton_2
        function NextButton_2Pushed(app, event)
            oldP = beginTask(app, app.PreprocessingPanel);
            preprocData(app)
            switch app.NetworkButtonGroup_2.SelectedObject
                case app.ReconstructionButton
                    openAndResizeWindow(app, app.PreprocessingPanel, app.NetworkOptionsPanel)
                case app.PredictiveButton
                    app.NetworkspecificityDropDown.Items{1} = 'GRU';
                    app.FilterNumberEditField.Visible = 0;
                    app.FilterNumberEditFieldLabel.Visible = 0;
                    app.HiddenUnitsEditField.Visible = 1;
                    app.HiddenUnitsEditFieldLabel.Visible = 1;
                    app.NumberofneuronsEditField.Visible = 0;
                    app.NumberofneuronsEditFieldLabel.Visible = 0;
                    app.HiddenUnitsEditField.Value = 80;
                    app.EpochsEditField.Value = 35;
                    app.MinibatchsizeEditField.Value = 70;
                    openAndResizeWindow(app, app.PreprocessingPanel, app.NetworkOptionsPanel)
            end
            drawnow            
            endTask(app, app.PreprocessingPanel, oldP);
        end

        % Button pushed function: RestartButton_2
        function RestartButton_2Pushed(app, event)
            resetApp(app)
        end

        % Button pushed function: NetworkdesciptionButton
        function NetworkdesciptionButtonPushed(app, event)
            oldP = beginTask(app, app.NetworkOptionsPanel);
            delete(app.NetworkDescApp)
            lay = createGraph(app);
            app.netDescription = generateDesc(app);
            app.NetworkDescApp = netDescApp(app, lay, app.netDescription);
            endTask(app, app.NetworkOptionsPanel, oldP);
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app.NetworkDescApp)
            delete(app)
        end

        % Button pushed function: TrainButton
        function TrainButtonPushed(app, event)
            oldP = beginTask(app, app.NetworkOptionsPanel);
            %train on non anomalous data
            [app.dataXTrain,app.dataYTrain] = splitDataEnd(app);            
            splitTrainVal(app)            
            switch app.NetworkButtonGroup_2.SelectedObject
                case app.ReconstructionButton
                    switch app.NetworkspecificityDropDown.Value
                        case app.NetworkspecificityDropDown.Items{2} %LSTM
                            trainLSTM_AE(app);
                        case app.NetworkspecificityDropDown.Items{1} %Shallow
                            trainShallow_AE(app);
                        case app.NetworkspecificityDropDown.Items{3} %Hybrid
                            trainHy_AE(app);
                    end
                case app.PredictiveButton
                    switch app.NetworkspecificityDropDown.Value
                        case app.NetworkspecificityDropDown.Items{1} %GRU
                            trainLSTM(app);
                        case app.NetworkspecificityDropDown.Items{2} %LSTM
                            trainRNN(app);
                        case app.NetworkspecificityDropDown.Items{3} %Hybrid
                            trainHy(app)
                    end
            end            
            if ~isempty(app.net)
                app.NextButton_4.Enable = 1;
            end
            
            %preproc ans split val anom data  
            switch app.SelectDatasetButtonGroup.SelectedObject
                case app.AVSButton
                    if size(app.anomValData, 1) == 1
                        switch app.PreprocessingmethodButtonGroup.SelectedObject
                            case app.NothingButton
                                
                            case app.Rescale01Button
                                app.anomValData{1,1} = (app.anomValData{1,1}-app.mini)/(app.maxi-app.mini);
                            case app.StandarizeButton
                                app.anomValData{1,1} = (app.anomValData{1,1}-app.mu)/app.sig;
                        end
                        [XValAnom, YValAnom] = splitData(app, app.anomValData{1,1});
                        [~, anomLabels] = splitData(app, app.anomValData{1,2});
                        anomLabels = logical(anomLabels);
                    else
                        for i = 1:size(app.anomValData,1)
                            switch app.PreprocessingmethodButtonGroup.SelectedObject
                                case app.NothingButton
                                    app.anomValData{i,1} = app.anomValData{i,1};
                                case app.Rescale01Button
                                    app.anomValData{i,1} = (app.anomValData{i,1}-app.mini)/(app.maxi-app.mini);
                                case app.StandarizeButton
                                    app.anomValData{i,1} = (app.anomValData{i,1}-app.mu)/app.sig;
                            end
                        end
                        XValAnom = cell(0,1);
                        YValAnom = [];
                        anomLabels = [];
                        for i = 1:size(app.anomValData,1)
                            [A, B] = splitData(app, app.anomValData{i,1});
                            [~, C] = splitData(app, app.anomValData{i,2});
                            XValAnom = [XValAnom; A];
                            YValAnom = [YValAnom; B];
                            anomLabels = [anomLabels; C];
                        end
                        anomLabels = logical(anomLabels);
                    end
                    anomPred = predict(app.net, XValAnom);
                    if app.NetworkButtonGroup_2.SelectedObject == app.PredictiveButton
                        resAnom = abs(anomPred-YValAnom);
                    else
                        anomPred = reshapeAutoencPred(app, anomPred);
                        YValAnom = YValAnom(1:end-app.WindowsizewEditField.Value);
                        anomLabels = anomLabels(1:end-app.WindowsizewEditField.Value);
                        resAnom = abs(anomPred-YValAnom);
                    end
                    app.staticThreshold = findStaticThresh(app, resAnom, anomLabels);
                case app.UAVButton
                    fn = fieldnames(app.anomValData);
                    for k = 1:numel(fn)
                        if size(app.anomValData.(fn{k}), 1) == 1
                            switch app.PreprocessingmethodButtonGroup.SelectedObject
                                case app.NothingButton
                                    
                                case app.Rescale01Button
                                    app.anomValData.(fn{k}){1,1} = (app.anomValData.(fn{k}){1,1}-app.mini)/(app.maxi-app.mini);
                                case app.StandarizeButton
                                    app.anomValData.(fn{k}){1,1} = (app.anomValData.(fn{k}){1,1}-app.mu)/app.sig;
                            end
                            [XValAnom, YValAnom] = splitData(app, app.anomValData.(fn{k}){1,1});
                            [~, anomLabels] = splitData(app, app.anomValData.(fn{k}){1,2});
                            anomLabels = logical(anomLabels);
                        else
                            for i = 1:size(app.anomValData,1)
                                switch app.PreprocessingmethodButtonGroup.SelectedObject
                                    case app.NothingButton
                                        app.anomValData.(fn{k}){i,1} = app.anomValData.(fn{k}){i,1};
                                    case app.Rescale01Button
                                        app.anomValData.(fn{k}){i,1} = (app.anomValData.(fn{k}){i,1}-app.mini)/(app.maxi-app.mini);
                                    case app.StandarizeButton
                                        app.anomValData.(fn{k}){i,1} = (app.anomValData.(fn{k}){i,1}-app.mu)/app.sig;
                                end
                            end
                            XValAnom = cell(0,1);
                            YValAnom = [];
                            anoms = [];
                            for i = 1:size(app.anomValData,1)
                                [A, B] = splitData(app, app.anomValData.(fn{k}){i,1});
                                [~, C] = splitData(app, app.anomValData.(fn{k}){i,2});
                                XValAnom = [XValAnom; A];
                                YValAnom = [YValAnom; B];
                                anoms = [anoms; C];
                            end
                            anomLabels.(fn{k}) = logical(anoms);
                        end
                        anomPred = predict(app.net, XValAnom);
                        if app.NetworkButtonGroup_2.SelectedObject == app.PredictiveButton
                            resAnom = abs(anomPred-YValAnom);
                        else
                            anomPred = reshapeAutoencPred(app, anomPred);
                            YValAnom = YValAnom(1:end-app.WindowsizewEditField.Value);
                            anomLabels.(fn{k}) = anomLabels.(fn{k})(1:end-app.WindowsizewEditField.Value);
                            resAnom = abs(anomPred-YValAnom);
                        end
                        app.staticThreshold.(fn{k}) = findStaticThresh(app, resAnom, anomLabels.(fn{k}));
                    end
                case app.SWaTButton 
                    anomPred = predict(app.net, app.XTrain);
                    resAnom = abs(anomPred-app.YTrain);
                    app.staticThreshold = max(resAnom);
            end
            assignin("base", "staticThresh", app.staticThreshold)
            %prepare non anomalous training data
% %             app.trainPredict = predict(app.net, app.XTrain);            
% %             if app.NetworkButtonGroup_2.SelectedObject == app.PredictiveButton
% %                 res = abs(app.trainPredict-app.YTrain);
% %                 labels = false(1,length(res));
% %             else
% %                 app.trainPredict = reshapeAutoencPred(app, app.trainPredict);        
% %                 YTrain = app.YTrain(1:end-app.WindowsizewEditField.Value);
% %                 labels = false(1,length(YTrain));
% %                 res = abs(app.trainPredict-YTrain);
% %             end
            
            %find best threshold            
% %             app.staticThreshold = findStaticThresh(app, resAnom, anomLabels);
% %             beta = 1;           
% %             idx = [];
% %             threshMax = linspace(min(resAnom),max(resAnom), 200);
% %             y = logical([]);
% %             if size(anomLabels, 2) ~= 1
% %                 anomLabels = anomLabels';
% %             end
% %             for i = 1:200
% %                 y(:,i) = resAnom > threshMax(i);                
% %             end
% %             
% %             precision = []; recall = []; Fscore = [];
% %             
% %             for i = 1:200
% %                 k = confusionmat(anomLabels, y(:,i));
% %                 if width(k) > 1
% %                     precision(i) = k(2,2)/(k(2,2)+k(1,2));
% %                     recall(i) = k(2,2)/(k(2,2)+k(2,1));                    
% %                     Fscore(i) = (1+beta^2)*(precision(i)*recall(i))/(precision(i)*beta^2+recall(i));
% %                 end
% %             end
% %             MaxFScore = max(Fscore);
% %             thrIdx = find(Fscore == MaxFScore);            
% %             clear thrMax
% %             if size(thrIdx, 2) >1
% %                 p = thrIdx(1);
% %                 thrMax = threshMax(thrIdx(end));
% %             else
% %                 p = thrIdx;
% %             end
% %             
% %             app.staticThreshold = threshMax(p);
            
            endTask(app, app.NetworkOptionsPanel, oldP)
        end

        % Button pushed function: SavenettoworkspaceButton
        function SavenettoworkspaceButtonPushed(app, event)
            if ~isempty(app.net)
                app.NetworkOptionsPanel.Enable = 'off';
                app.saveNetPopupWin = saveNetPopup(app);
                waitfor(app.saveNetPopupWin)
                app.NetworkOptionsPanel.Enable = 'on';
            else
                uialert(app.UIFigure,'There is still no trained network to save','Invalid File');
            end
        end

        % Value changed function: UsevaldataCheckBox
        function UsevaldataCheckBoxValueChanged(app, event)
            value = app.UsevaldataCheckBox.Value;
            if value == 1
                app.RatioEditField.Enable = 1;
                app.RatioEditField_2Label.Enable = 1;
            else
                app.RatioEditField.Enable = 0;
                app.RatioEditField_2Label.Enable = 0;
            end
        end

        % Button pushed function: VisualizedataButton_3
        function VisualizedataButton_3Pushed(app, event)
            oldP = beginTask(app, app.AVSPreparationPanel);
            appTitle = "AVS Data";
            switch app.VehiculescenarioButtonGroup.SelectedObject
                case app.TownButton                    
                    name = "Town scenario data";                    
                    y = app.AVS.faultFree(13:end, 1);                    
                    plotData(app, y, name, appTitle)
                case app.HighwayButton                    
                    name = "Town scenario data";                    
                    y = app.AVS.faultFree(1:12, 1);
                    plotData(app, y, name, appTitle)
            end
            endTask(app, app.AVSPreparationPanel, oldP);
        end

        % Button pushed function: RestartButton_3
        function RestartButton_3Pushed(app, event)
            resetApp(app)
        end

        % Button pushed function: NextButton_5
        function NextButton_5Pushed(app, event)
            oldP = beginTask(app, app.AVSPreparationPanel);            
            switch app.VehiculescenarioButtonGroup.SelectedObject
                case app.TownButton
                    app.faultFreeData = app.AVS.faultFree(13:end,1);
                    app.AVSType = 13:24;
                    
                case app.HighwayButton
                    app.faultFreeData = app.AVS.faultFree(1:12, 1);
                    app.AVSType = 1:12;
            end
            faultIdx = min(app.AVSType)*8-7:max(app.AVSType)*8;   
            data = [app.AVS.dataNoise(faultIdx,:); app.AVS.dataOffset(faultIdx,:)];
            [m, n] = size(data);
            idx = randperm(m);
            app.anomValData = data(idx(1:round(0.2*m)),:); 
            openAndResizeWindow(app, app.AVSPreparationPanel, app.PreprocessingPanel)
            endTask(app, app.AVSPreparationPanel, oldP);
        end

        % Button pushed function: RestartButton_4
        function RestartButton_4Pushed(app, event)
            resetApp(app)
        end

        % Button pushed function: NextButton_6
        function NextButton_6Pushed(app, event)
            oldP = beginTask(app, app.UAVPreparationPanel);
            switch app.SensordataselectionButtonGroup.SelectedObject
                case app.AccelerometerButton
                    app.faultFreeData = app.UAVAcc.faultFreeAcc;
                case app.GyroscopeButton
                    app.faultFreeData = app.UAVGyr.faultFreeGyr;
            end            
            openAndResizeWindow(app, app.UAVPreparationPanel, app.PreprocessingPanel)
            app.UAVGyrFault = app.UAVGyrFault.faultyGyr;
            app.UAVAccFault = app.UAVAccFault.faultyAcc;
            if app.SensordataselectionButtonGroup.SelectedObject == app.AccelerometerButton                   
                app.anomValData.Offset = randomAnomData(app, app.UAVAccFault.Offset, 0.2);
                app.anomValData.PackageDrop = randomAnomData(app, app.UAVAccFault.PackageDrop, 0.2);
                app.anomValData.StuckAt = randomAnomData(app, app.UAVAccFault.StuckAt, 0.2);
%                 app.anomValData.Offset = app.UAVAccFault.Offset;
%                 app.anomValData.PackageDrop = app.UAVAccFault.PackageDrop;
%                 app.anomValData.StuckAt = app.UAVAccFault.StuckAt;
            else
                app.anomValData.Offset = randomAnomData(app, app.UAVGyrFault.Offset, 0.2);
                app.anomValData.Noise = randomAnomData(app, app.UAVGyrFault.Noise, 0.2);
                app.anomValData.StuckAt = randomAnomData(app, app.UAVGyrFault.StuckAt, 0.2);
            end
            endTask(app, app.UAVPreparationPanel, oldP);
        end

        % Button pushed function: NextButton_4
        function NextButton_4Pushed(app, event)
            oldP = beginTask(app, app.NetworkOptionsPanel);
            switch app.SelectDatasetButtonGroup.SelectedObject
                case app.AVSButton
                    openAndResizeWindow(app, app.NetworkOptionsPanel, app.FaultydataselectionPanel_AVS)
                case app.UAVButton
                    switch app.SensordataselectionButtonGroup.SelectedObject
                        case app.AccelerometerButton
                            openAndResizeWindow(app, app.NetworkOptionsPanel, app.FaultydataselectionPanel_UAVAcc)   
                            app.ScenarioListBox_2.Items = app.ScenarioListBox_2.Items(1:10);
                            app.ScenarioListBox_2.ItemsData = app.ScenarioListBox_2.ItemsData(1:10);
                        case app.GyroscopeButton
                            openAndResizeWindow(app, app.NetworkOptionsPanel, app.FaultydataselectionPanel_UAVAcc)
                            app.FaulttypeButtonGroup_4.Visible = 'on';
                            app.FaulttypeButtonGroup_2.Visible = 'off';
                    end
                case app.SWaTButton              
                    openAndResizeWindow(app, app.NetworkOptionsPanel, app.FaultydataselectionPanel_SWaT);
            end                       
            
            endTask(app, app.NetworkOptionsPanel, oldP);
        end

        % Button pushed function: VisualizedataButton_5
        function VisualizedataButton_5Pushed(app, event)
            oldP = beginTask(app, app.FaultydataselectionPanel_AVS);
            faultIdx = min(app.AVSType)*8-7:max(app.AVSType)*8;
            dataCleanIdx = str2double(app.ScenarioListBox.Value);
            switch app.FaulttypeButtonGroup.SelectedObject
                case app.StuckvalueButton   
                    faultType = app.AVS.dataStuckAt(faultIdx,:);   
                case app.NoiseButton
                    faultType = app.AVS.dataNoise(faultIdx,:);
                case app.OffsetButton
                    faultType = app.AVS.dataOffset(faultIdx,:);
            end            
            IDX = str2double(app.FaultdurationDropDown.Value);
            dataIdx = 8*(dataCleanIdx-1)+IDX;            
            faultData = faultType{dataIdx,1};
            f = uifigure;
            f.Visible = 'off';
            ax = uiaxes(f);
            f.Position(3) = ax.Position(3)+10;
            f.Position(4) = ax.Position(4)+10;
            plot(ax, faultData)
            movegui(f, "center")
            f.Visible = 'on';
            endTask(app, app.FaultydataselectionPanel_AVS, oldP);
        end

        % Button pushed function: VisualizedataButton_4
        function VisualizedataButton_4Pushed(app, event)
            oldP = beginTask(app, app.UAVPreparationPanel);
            appTitle = "UAV Data";
            switch app.SensordataselectionButtonGroup.SelectedObject
                case app.GyroscopeButton
                    name = "Gyroscope data";
                    y = app.UAVGyr.faultFreeGyr;                    
                    plotData(app, y, name, appTitle);
                case app.AccelerometerButton
                    name = "Accuator data";
                    y = app.UAVAcc.faultFreeAcc;
                    plotData(app, y, name, appTitle);
            end
            endTask(app, app.UAVPreparationPanel, oldP);
        end

        % Button pushed function: PredictdataButton
        function PredictdataButtonPushed(app, event)
            %oldP = beginTask(app, app.FaultydataselectionPanel_AVS);
            faultIdx = min(app.AVSType)*8-7:max(app.AVSType)*8;
            dataCleanIdx = str2double(app.ScenarioListBox.Value);
            switch app.FaulttypeButtonGroup.SelectedObject
                case app.StuckvalueButton
                    faultType = app.AVS.dataStuckAt(faultIdx,:);
                case app.NoiseButton
                    faultType = app.AVS.dataNoise(faultIdx,:);
                case app.OffsetButton
                    faultType = app.AVS.dataOffset(faultIdx,:);
            end
            IDX = str2double(app.FaultdurationDropDown.Value);
            dataIdx = 8*(dataCleanIdx-1)+IDX;
            faultData = faultType{dataIdx,1};            
            switch app.PreprocessingmethodButtonGroup.SelectedObject
                case app.NothingButton
                    dataTest = faultData;
                case app.Rescale01Button
                    dataTest = (faultData-app.mini)/(app.maxi-app.mini);
                case app.StandarizeButton
                    dataTest = (faultData-app.mu)/app.sig;
            end                    
            [XTest, YTest] = splitData(app, dataTest);
            pred = predict(app.net, XTest);
            if app.NetworkButtonGroup_2.SelectedObject == app.PredictiveButton
                labels = logical(faultType{dataIdx, 2}(app.WindowsizewEditField.Value+1:end));
            else
                c = [];
                for i = 1:size(pred,1)
                    c(:,i) = pred{i};
                end
                b = [];
                c = flip(c);
                for i = 1:size(c,2)-app.WindowsizewEditField.Value
                    b(i,:) = median(diag(c(:,i:i+app.WindowsizewEditField.Value-1)));
                end
                pred = b;
                labels = logical(faultType{dataIdx, 2}(app.WindowsizewEditField.Value+1:end-app.WindowsizewEditField.Value));
                YTest = YTest(1:end-app.WindowsizewEditField.Value);
            end
            
            plotResultsAndEval(app, pred(1:end-1), YTest(1:end-1), labels(1:end-1), 100, app.staticThreshold);
            %endTask(app, app.FaultydataselectionPanel_AVS, oldP);
        end

        % Button pushed function: PredictdataButton_2
        function PredictdataButton_2Pushed(app, event)
%             oldP = beginTask(app, app.FaultydataselectionPanel_AVS);            
            dataIdx = str2double(app.ScenarioListBox_2.Value);
            switch app.SensordataselectionButtonGroup.SelectedObject
                case app.AccelerometerButton
                    switch app.FaulttypeButtonGroup_2.SelectedObject
                        case app.StuckvalueButton_2
                            faultType = app.UAVAccFault.StuckAt;
                            threshold = app.staticThreshold.StuckAt;
                        case app.PackagedropButton
                            faultType = app.UAVAccFault.PackageDrop;
                            threshold = app.staticThreshold.PackageDrop;
                        case app.OffsetButton_2
                            faultType = app.UAVAccFault.Offset;
                            threshold = app.staticThreshold.Offset;
                    end
                case app.GyroscopeButton
                    switch app.FaulttypeButtonGroup_4.SelectedObject
                        case app.StuckedvalueButton_4
                            faultType = app.UAVGyrFault.StuckAt;
                            threshold = app.staticThreshold.StuckAt;
                        case app.NoiseButton_3
                            faultType = app.UAVGyrFault.Noise;
                            threshold = app.staticThreshold.Noise;
                        case app.OffsetButton_4
                            faultType = app.UAVGyrFault.Offset;
                            threshold = app.staticThreshold.Offset;
                    end
            end
              
            faultData = faultType{dataIdx,1};            
            switch app.PreprocessingmethodButtonGroup.SelectedObject
                case app.NothingButton
                    dataTest = faultData;
                case app.Rescale01Button
                    dataTest = (faultData-app.mini)/(app.maxi-app.mini);
                case app.StandarizeButton
                    dataTest = (faultData-app.mu)/app.sig;
            end                    
            [XTest, YTest] = splitData(app, dataTest);
            pred = predict(app.net, XTest);
            if app.NetworkButtonGroup_2.SelectedObject == app.PredictiveButton
                labels = logical(faultType{dataIdx, 2}(app.WindowsizewEditField.Value+1:end));
            else
                c = [];
                for i = 1:size(pred,1)
                    c(:,i) = pred{i};
                end
                b = [];
                c = flip(c);
                for i = 1:size(c,2)-app.WindowsizewEditField.Value
                    b(i,:) = median(diag(c(:,i:i+app.WindowsizewEditField.Value-1)));
                end
                pred = b;
                labels = logical(faultType{dataIdx, 2}(app.WindowsizewEditField.Value+1:end-app.WindowsizewEditField.Value));
                YTest = YTest(1:end-app.WindowsizewEditField.Value);
            end
            plotResultsAndEval(app, pred, YTest, labels, 1000, threshold);
            
%             endTask(app, app.FaultydataselectionPanel_AVS, oldP);
        end

        % Button pushed function: OnlinedetectionsimulationButton
        function OnlinedetectionsimulationButtonPushed(app, event)
%             oldP = beginTask(app, app.FaultydataselectionPanel_AVS);            
            faultIdx = min(app.AVSType)*8-7:max(app.AVSType)*8;
            dataCleanIdx = str2double(app.ScenarioListBox.Value);
            switch app.FaulttypeButtonGroup.SelectedObject
                case app.StuckvalueButton
                    faultType = app.AVS.dataStuckAt(faultIdx,:);
                case app.NoiseButton
                    faultType = app.AVS.dataNoise(faultIdx,:);
                case app.OffsetButton
                    faultType = app.AVS.dataOffset(faultIdx,:);
            end
            IDX = str2double(app.FaultdurationDropDown.Value);
            dataIdx = 8*(dataCleanIdx-1)+IDX;
            faultData = faultType{dataIdx,1};            
            switch app.PreprocessingmethodButtonGroup.SelectedObject
                case app.NothingButton
                    dataTest = faultData;
                case app.Rescale01Button
                    dataTest = (faultData-app.mini)/(app.maxi-app.mini);
                case app.StandarizeButton
                    dataTest = (faultData-app.mu)/app.sig;
            end                             
            labels = logical(faultType{dataIdx, 2});   
            if app.NetworkButtonGroup_2.SelectedObject == app.PredictiveButton
                method = 'Predictive';
            else
                method = 'Reconstruction';
            end
            simulinkModel(app, method, app.net, dataTest, labels, app.staticThreshold)
%             endTask(app, app.FaultydataselectionPanel_AVS, oldP);            
        end

        % Selection changed function: FaulttypeButtonGroup_4
        function FaulttypeButtonGroup_4SelectionChanged(app, event)
            selectedButton = app.FaulttypeButtonGroup_4.SelectedObject;    
        end

        % Button pushed function: PredictdataButton_3
        function PredictdataButton_3Pushed(app, event)
            global indices
%             oldP = beginTask(app, app.FaultydataselectionPanel_SWaT);
            day = str2double(app.DayListBox.Value);            
            faultData = app.SWaT.SWaTDatasetAttackv0{1+(day-1)*60*60*24:day*60*60*24,indices(1,2)};    
            switch app.PreprocessingmethodButtonGroup.SelectedObject
                case app.NothingButton
                    dataTest = faultData;
                case app.Rescale01Button
                    dataTest = (faultData-app.mini)/(app.maxi-app.mini);
                case app.StandarizeButton
                    dataTest = (faultData-app.mu)/app.sig;
            end                    
            [XTest, YTest] = splitData(app, dataTest);
            pred = predict(app.net, XTest);
            labs = app.SWaT.SWaTDatasetAttackv0.NormalAttack(1+(day-1)*60*60*24:day*60*60*24);
            labels = false(length(labs),1);
            labels(labs == "Attack") = true;
            if app.NetworkButtonGroup_2.SelectedObject == app.PredictiveButton
                labels = logical(labels(app.WindowsizewEditField.Value+1:end));
            else
                c = [];
                for i = 1:size(pred,1)
                    c(:,i) = pred{i};
                end
                b = [];
                c = flip(c);
                for i = 1:size(c,2)-app.WindowsizewEditField.Value
                    b(i,:) = median(diag(c(:,i:i+app.WindowsizewEditField.Value-1)));
                end
                pred = b;
                labels = logical(labels(app.WindowsizewEditField.Value+1:end-app.WindowsizewEditField.Value));
                YTest = YTest(1:end-app.WindowsizewEditField.Value);
            end
            plotResultsAndEval(app, pred, YTest, labels, 1500, app.staticThreshold);
%             endTask(app, app.FaultydataselectionPanel_SWaT, oldP);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Color = [0.9412 0.9412 0.9412];
            app.UIFigure.Position = [1050 150 216 266];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Resize = 'off';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.HandleVisibility = 'on';

            % Create DataPreparationPanel
            app.DataPreparationPanel = uipanel(app.UIFigure);
            app.DataPreparationPanel.AutoResizeChildren = 'off';
            app.DataPreparationPanel.TitlePosition = 'centertop';
            app.DataPreparationPanel.Title = 'Data Preparation';
            app.DataPreparationPanel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.DataPreparationPanel.Position = [1 -1 216 266];

            % Create SelectDatasetButtonGroup
            app.SelectDatasetButtonGroup = uibuttongroup(app.DataPreparationPanel);
            app.SelectDatasetButtonGroup.AutoResizeChildren = 'off';
            app.SelectDatasetButtonGroup.TitlePosition = 'centertop';
            app.SelectDatasetButtonGroup.Title = 'Select Dataset';
            app.SelectDatasetButtonGroup.Position = [42 122 132 105];

            % Create SWaTButton
            app.SWaTButton = uitogglebutton(app.SelectDatasetButtonGroup);
            app.SWaTButton.Text = 'SWaT';
            app.SWaTButton.Position = [16 52 100 22];
            app.SWaTButton.Value = true;

            % Create UAVButton
            app.UAVButton = uitogglebutton(app.SelectDatasetButtonGroup);
            app.UAVButton.Text = 'UAV';
            app.UAVButton.Position = [16 31 100 22];

            % Create AVSButton
            app.AVSButton = uitogglebutton(app.SelectDatasetButtonGroup);
            app.AVSButton.Text = 'AVS';
            app.AVSButton.Position = [16 10 100 22];

            % Create NetworkButtonGroup
            app.NetworkButtonGroup = uibuttongroup(app.DataPreparationPanel);
            app.NetworkButtonGroup.AutoResizeChildren = 'off';
            app.NetworkButtonGroup.TitlePosition = 'centertop';
            app.NetworkButtonGroup.Title = 'Network';
            app.NetworkButtonGroup.Position = [42 42 132 69];

            % Create PretrainedButton
            app.PretrainedButton = uiradiobutton(app.NetworkButtonGroup);
            app.PretrainedButton.Text = 'Pretrained';
            app.PretrainedButton.Position = [11 23 77 22];
            app.PretrainedButton.Value = true;

            % Create TrainnewnetworkButton
            app.TrainnewnetworkButton = uiradiobutton(app.NetworkButtonGroup);
            app.TrainnewnetworkButton.Text = 'Train new network';
            app.TrainnewnetworkButton.Position = [11 1 119 22];

            % Create NextButton
            app.NextButton = uibutton(app.DataPreparationPanel, 'push');
            app.NextButton.ButtonPushedFcn = createCallbackFcn(app, @NextButtonPushed, true);
            app.NextButton.Position = [61 13 100 22];
            app.NextButton.Text = 'Next';

            % Create PreprocessingPanel
            app.PreprocessingPanel = uipanel(app.UIFigure);
            app.PreprocessingPanel.AutoResizeChildren = 'off';
            app.PreprocessingPanel.TitlePosition = 'centertop';
            app.PreprocessingPanel.Title = 'Preprocessing';
            app.PreprocessingPanel.Position = [-283 1 216 266];

            % Create PreprocessingmethodButtonGroup
            app.PreprocessingmethodButtonGroup = uibuttongroup(app.PreprocessingPanel);
            app.PreprocessingmethodButtonGroup.AutoResizeChildren = 'off';
            app.PreprocessingmethodButtonGroup.Title = 'Preprocessing method';
            app.PreprocessingmethodButtonGroup.Position = [42 122 132 105];

            % Create StandarizeButton
            app.StandarizeButton = uitogglebutton(app.PreprocessingmethodButtonGroup);
            app.StandarizeButton.Text = 'Standarize';
            app.StandarizeButton.Position = [16 52 100 22];
            app.StandarizeButton.Value = true;

            % Create Rescale01Button
            app.Rescale01Button = uitogglebutton(app.PreprocessingmethodButtonGroup);
            app.Rescale01Button.Text = 'Rescale [0,1]';
            app.Rescale01Button.Position = [16 31 100 22];

            % Create NothingButton
            app.NothingButton = uitogglebutton(app.PreprocessingmethodButtonGroup);
            app.NothingButton.Text = 'Nothing';
            app.NothingButton.Position = [16 10 100 22];

            % Create RestartButton
            app.RestartButton = uibutton(app.PreprocessingPanel, 'push');
            app.RestartButton.ButtonPushedFcn = createCallbackFcn(app, @RestartButtonPushed, true);
            app.RestartButton.Position = [9 13 90 22];
            app.RestartButton.Text = 'Restart';

            % Create NextButton_2
            app.NextButton_2 = uibutton(app.PreprocessingPanel, 'push');
            app.NextButton_2.ButtonPushedFcn = createCallbackFcn(app, @NextButton_2Pushed, true);
            app.NextButton_2.Position = [116 13 91 22];
            app.NextButton_2.Text = 'Next';

            % Create NetworkButtonGroup_2
            app.NetworkButtonGroup_2 = uibuttongroup(app.PreprocessingPanel);
            app.NetworkButtonGroup_2.AutoResizeChildren = 'off';
            app.NetworkButtonGroup_2.TitlePosition = 'centertop';
            app.NetworkButtonGroup_2.Title = 'Network';
            app.NetworkButtonGroup_2.Position = [42 43 132 69];

            % Create PredictiveButton
            app.PredictiveButton = uiradiobutton(app.NetworkButtonGroup_2);
            app.PredictiveButton.Text = 'Predictive';
            app.PredictiveButton.Position = [11 23 75 22];
            app.PredictiveButton.Value = true;

            % Create ReconstructionButton
            app.ReconstructionButton = uiradiobutton(app.NetworkButtonGroup_2);
            app.ReconstructionButton.Text = 'Reconstruction';
            app.ReconstructionButton.Position = [11 1 102 22];

            % Create SWaTDataPanel
            app.SWaTDataPanel = uipanel(app.UIFigure);
            app.SWaTDataPanel.AutoResizeChildren = 'off';
            app.SWaTDataPanel.TitlePosition = 'centertop';
            app.SWaTDataPanel.Title = 'SWaT Data';
            app.SWaTDataPanel.Position = [-283 -310 617 290];

            % Create UITable
            app.UITable = uitable(app.SWaTDataPanel);
            app.UITable.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'; 'Column 4'};
            app.UITable.RowName = {};
            app.UITable.CellSelectionCallback = createCallbackFcn(app, @UITableCellSelection, true);
            app.UITable.Position = [1 1 440 270];

            % Create SelectedSensorCheckBox
            app.SelectedSensorCheckBox = uicheckbox(app.SWaTDataPanel);
            app.SelectedSensorCheckBox.Text = '''Selected Sensor''';
            app.SelectedSensorCheckBox.Position = [471 196 115 22];

            % Create TextArea
            app.TextArea = uitextarea(app.SWaTDataPanel);
            app.TextArea.BackgroundColor = [0.9412 0.9412 0.9412];
            app.TextArea.Position = [440 234 177 37];
            app.TextArea.Value = {'Please select a sensor from the table'};

            % Create NextButton_3
            app.NextButton_3 = uibutton(app.SWaTDataPanel, 'push');
            app.NextButton_3.ButtonPushedFcn = createCallbackFcn(app, @NextButton_3Pushed, true);
            app.NextButton_3.Enable = 'off';
            app.NextButton_3.Position = [479 39 100 22];
            app.NextButton_3.Text = 'Next';

            % Create ResetButton_2
            app.ResetButton_2 = uibutton(app.SWaTDataPanel, 'push');
            app.ResetButton_2.ButtonPushedFcn = createCallbackFcn(app, @ResetButton_2Pushed, true);
            app.ResetButton_2.Position = [479 10 100 22];
            app.ResetButton_2.Text = 'Reset';

            % Create VisualizedataButton_2
            app.VisualizedataButton_2 = uibutton(app.SWaTDataPanel, 'push');
            app.VisualizedataButton_2.ButtonPushedFcn = createCallbackFcn(app, @VisualizedataButton_2Pushed, true);
            app.VisualizedataButton_2.Enable = 'off';
            app.VisualizedataButton_2.Position = [479 108 100 22];
            app.VisualizedataButton_2.Text = 'Visualize data';

            % Create SelectedSensorLampLabel
            app.SelectedSensorLampLabel = uilabel(app.SWaTDataPanel);
            app.SelectedSensorLampLabel.HorizontalAlignment = 'center';
            app.SelectedSensorLampLabel.Position = [491 144 98 22];
            app.SelectedSensorLampLabel.Text = '''Selected Sensor''';

            % Create SelectedSensorLamp
            app.SelectedSensorLamp = uilamp(app.SWaTDataPanel);
            app.SelectedSensorLamp.Position = [466 145 20 20];
            app.SelectedSensorLamp.Color = [0.9294 0.6941 0.1255];

            % Create NetworkOptionsPanel
            app.NetworkOptionsPanel = uipanel(app.UIFigure);
            app.NetworkOptionsPanel.AutoResizeChildren = 'off';
            app.NetworkOptionsPanel.TitlePosition = 'centertop';
            app.NetworkOptionsPanel.Title = 'Network Options';
            app.NetworkOptionsPanel.Position = [247 1 432 266];

            % Create Image
            app.Image = uiimage(app.NetworkOptionsPanel);
            app.Image.Position = [6 8 203 112];
            app.Image.ImageSource = 'window step.png';

            % Create RestartButton_2
            app.RestartButton_2 = uibutton(app.NetworkOptionsPanel, 'push');
            app.RestartButton_2.ButtonPushedFcn = createCallbackFcn(app, @RestartButton_2Pushed, true);
            app.RestartButton_2.Position = [213 8 94 23];
            app.RestartButton_2.Text = 'Restart';

            % Create TrainButton
            app.TrainButton = uibutton(app.NetworkOptionsPanel, 'push');
            app.TrainButton.ButtonPushedFcn = createCallbackFcn(app, @TrainButtonPushed, true);
            app.TrainButton.Position = [213 44 94 34];
            app.TrainButton.Text = 'Train';

            % Create NetworkspecificityDropDownLabel
            app.NetworkspecificityDropDownLabel = uilabel(app.NetworkOptionsPanel);
            app.NetworkspecificityDropDownLabel.Position = [6 213 112 22];
            app.NetworkspecificityDropDownLabel.Text = 'Network specificity';

            % Create NetworkspecificityDropDown
            app.NetworkspecificityDropDown = uidropdown(app.NetworkOptionsPanel);
            app.NetworkspecificityDropDown.Items = {'Shallow', 'LSTM', 'Hybrid (RNN-CNN)'};
            app.NetworkspecificityDropDown.ValueChangedFcn = createCallbackFcn(app, @NetworkspecificityDropDownValueChanged, true);
            app.NetworkspecificityDropDown.Position = [123 213 86 22];
            app.NetworkspecificityDropDown.Value = 'Shallow';

            % Create NumberofneuronsEditFieldLabel
            app.NumberofneuronsEditFieldLabel = uilabel(app.NetworkOptionsPanel);
            app.NumberofneuronsEditFieldLabel.Position = [6 185 112 22];
            app.NumberofneuronsEditFieldLabel.Text = 'Number of neurons';

            % Create NumberofneuronsEditField
            app.NumberofneuronsEditField = uieditfield(app.NetworkOptionsPanel, 'numeric');
            app.NumberofneuronsEditField.Tooltip = {'Number for first layer. then n2 = n/2 and n3 = n2/2'};
            app.NumberofneuronsEditField.Position = [155 185 54 22];
            app.NumberofneuronsEditField.Value = 32;

            % Create HiddenUnitsEditFieldLabel
            app.HiddenUnitsEditFieldLabel = uilabel(app.NetworkOptionsPanel);
            app.HiddenUnitsEditFieldLabel.Position = [6 185 74 22];
            app.HiddenUnitsEditFieldLabel.Text = 'Hidden Units';

            % Create HiddenUnitsEditField
            app.HiddenUnitsEditField = uieditfield(app.NetworkOptionsPanel, 'numeric');
            app.HiddenUnitsEditField.Position = [155 185 54 22];
            app.HiddenUnitsEditField.Value = 32;

            % Create WindowsizewEditFieldLabel
            app.WindowsizewEditFieldLabel = uilabel(app.NetworkOptionsPanel);
            app.WindowsizewEditFieldLabel.Position = [6 156 93 22];
            app.WindowsizewEditFieldLabel.Text = 'Window size (w)';

            % Create WindowsizewEditField
            app.WindowsizewEditField = uieditfield(app.NetworkOptionsPanel, 'numeric');
            app.WindowsizewEditField.Position = [155 156 54 22];
            app.WindowsizewEditField.Value = 35;

            % Create StepSizesEditFieldLabel
            app.StepSizesEditFieldLabel = uilabel(app.NetworkOptionsPanel);
            app.StepSizesEditFieldLabel.Position = [6 127 74 22];
            app.StepSizesEditFieldLabel.Text = 'Step Size (s)';

            % Create StepSizesEditField
            app.StepSizesEditField = uieditfield(app.NetworkOptionsPanel, 'numeric');
            app.StepSizesEditField.Position = [155 127 54 22];
            app.StepSizesEditField.Value = 1;

            % Create FilterNumberEditFieldLabel
            app.FilterNumberEditFieldLabel = uilabel(app.NetworkOptionsPanel);
            app.FilterNumberEditFieldLabel.Position = [213 185 94 22];
            app.FilterNumberEditFieldLabel.Text = 'Filter Number';

            % Create FilterNumberEditField
            app.FilterNumberEditField = uieditfield(app.NetworkOptionsPanel, 'numeric');
            app.FilterNumberEditField.Position = [377 185 51 22];

            % Create EpochsEditFieldLabel
            app.EpochsEditFieldLabel = uilabel(app.NetworkOptionsPanel);
            app.EpochsEditFieldLabel.Position = [213 156 46 22];
            app.EpochsEditFieldLabel.Text = 'Epochs';

            % Create EpochsEditField
            app.EpochsEditField = uieditfield(app.NetworkOptionsPanel, 'numeric');
            app.EpochsEditField.Position = [377 156 51 22];
            app.EpochsEditField.Value = 35;

            % Create MinibatchsizeEditFieldLabel
            app.MinibatchsizeEditFieldLabel = uilabel(app.NetworkOptionsPanel);
            app.MinibatchsizeEditFieldLabel.Position = [213 127 94 22];
            app.MinibatchsizeEditFieldLabel.Text = 'Minibatch size';

            % Create MinibatchsizeEditField
            app.MinibatchsizeEditField = uieditfield(app.NetworkOptionsPanel, 'numeric');
            app.MinibatchsizeEditField.Position = [377 127 51 22];
            app.MinibatchsizeEditField.Value = 70;

            % Create SavenettoworkspaceButton
            app.SavenettoworkspaceButton = uibutton(app.NetworkOptionsPanel, 'push');
            app.SavenettoworkspaceButton.ButtonPushedFcn = createCallbackFcn(app, @SavenettoworkspaceButtonPushed, true);
            app.SavenettoworkspaceButton.VerticalAlignment = 'top';
            app.SavenettoworkspaceButton.WordWrap = 'on';
            app.SavenettoworkspaceButton.Position = [322 42 94 36];
            app.SavenettoworkspaceButton.Text = 'Save net to workspace';

            % Create UsevaldataCheckBox
            app.UsevaldataCheckBox = uicheckbox(app.NetworkOptionsPanel);
            app.UsevaldataCheckBox.ValueChangedFcn = createCallbackFcn(app, @UsevaldataCheckBoxValueChanged, true);
            app.UsevaldataCheckBox.Text = 'Use val data';
            app.UsevaldataCheckBox.Position = [213 213 89 22];

            % Create NetworkdesciptionButton
            app.NetworkdesciptionButton = uibutton(app.NetworkOptionsPanel, 'push');
            app.NetworkdesciptionButton.ButtonPushedFcn = createCallbackFcn(app, @NetworkdesciptionButtonPushed, true);
            app.NetworkdesciptionButton.WordWrap = 'on';
            app.NetworkdesciptionButton.Position = [256 90 122 22];
            app.NetworkdesciptionButton.Text = 'Network desciption';

            % Create NextButton_4
            app.NextButton_4 = uibutton(app.NetworkOptionsPanel, 'push');
            app.NextButton_4.ButtonPushedFcn = createCallbackFcn(app, @NextButton_4Pushed, true);
            app.NextButton_4.Enable = 'off';
            app.NextButton_4.Position = [322 8 94 22];
            app.NextButton_4.Text = 'Next';

            % Create RatioEditField_2Label
            app.RatioEditField_2Label = uilabel(app.NetworkOptionsPanel);
            app.RatioEditField_2Label.HorizontalAlignment = 'right';
            app.RatioEditField_2Label.Enable = 'off';
            app.RatioEditField_2Label.Position = [335 213 34 22];
            app.RatioEditField_2Label.Text = 'Ratio';

            % Create RatioEditField
            app.RatioEditField = uieditfield(app.NetworkOptionsPanel, 'numeric');
            app.RatioEditField.Limits = [0 1];
            app.RatioEditField.Enable = 'off';
            app.RatioEditField.Tooltip = {'Train/Validation ratio'; '0 < value < 1'; 'Recommended: 0.8'};
            app.RatioEditField.Position = [377 213 51 22];
            app.RatioEditField.Value = 0.8;

            % Create AVSPreparationPanel
            app.AVSPreparationPanel = uipanel(app.UIFigure);
            app.AVSPreparationPanel.AutoResizeChildren = 'off';
            app.AVSPreparationPanel.TitlePosition = 'centertop';
            app.AVSPreparationPanel.Title = 'AVS Preparation';
            app.AVSPreparationPanel.Position = [-511 43 215 222];

            % Create VehiculescenarioButtonGroup
            app.VehiculescenarioButtonGroup = uibuttongroup(app.AVSPreparationPanel);
            app.VehiculescenarioButtonGroup.AutoResizeChildren = 'off';
            app.VehiculescenarioButtonGroup.Title = 'Vehicule scenario';
            app.VehiculescenarioButtonGroup.Position = [42 98 132 87];

            % Create HighwayButton
            app.HighwayButton = uitogglebutton(app.VehiculescenarioButtonGroup);
            app.HighwayButton.Text = 'Highway';
            app.HighwayButton.Position = [16 34 100 22];
            app.HighwayButton.Value = true;

            % Create TownButton
            app.TownButton = uitogglebutton(app.VehiculescenarioButtonGroup);
            app.TownButton.Text = 'Town';
            app.TownButton.Position = [16 13 100 22];

            % Create RestartButton_3
            app.RestartButton_3 = uibutton(app.AVSPreparationPanel, 'push');
            app.RestartButton_3.ButtonPushedFcn = createCallbackFcn(app, @RestartButton_3Pushed, true);
            app.RestartButton_3.Position = [11 14 90 22];
            app.RestartButton_3.Text = 'Restart';

            % Create NextButton_5
            app.NextButton_5 = uibutton(app.AVSPreparationPanel, 'push');
            app.NextButton_5.ButtonPushedFcn = createCallbackFcn(app, @NextButton_5Pushed, true);
            app.NextButton_5.Position = [118 14 91 22];
            app.NextButton_5.Text = 'Next';

            % Create VisualizedataButton_3
            app.VisualizedataButton_3 = uibutton(app.AVSPreparationPanel, 'push');
            app.VisualizedataButton_3.ButtonPushedFcn = createCallbackFcn(app, @VisualizedataButton_3Pushed, true);
            app.VisualizedataButton_3.Position = [58 59 100 22];
            app.VisualizedataButton_3.Text = 'Visualize data';

            % Create UAVPreparationPanel
            app.UAVPreparationPanel = uipanel(app.UIFigure);
            app.UAVPreparationPanel.AutoResizeChildren = 'off';
            app.UAVPreparationPanel.TitlePosition = 'centertop';
            app.UAVPreparationPanel.Title = 'UAV Preparation';
            app.UAVPreparationPanel.Position = [-511 -220 215 222];

            % Create SensordataselectionButtonGroup
            app.SensordataselectionButtonGroup = uibuttongroup(app.UAVPreparationPanel);
            app.SensordataselectionButtonGroup.AutoResizeChildren = 'off';
            app.SensordataselectionButtonGroup.Title = 'Sensor data selection';
            app.SensordataselectionButtonGroup.Position = [42 98 132 87];

            % Create AccelerometerButton
            app.AccelerometerButton = uitogglebutton(app.SensordataselectionButtonGroup);
            app.AccelerometerButton.Text = 'Accelerometer';
            app.AccelerometerButton.Position = [16 34 100 22];
            app.AccelerometerButton.Value = true;

            % Create GyroscopeButton
            app.GyroscopeButton = uitogglebutton(app.SensordataselectionButtonGroup);
            app.GyroscopeButton.Text = 'Gyroscope';
            app.GyroscopeButton.Position = [16 13 100 22];

            % Create RestartButton_4
            app.RestartButton_4 = uibutton(app.UAVPreparationPanel, 'push');
            app.RestartButton_4.ButtonPushedFcn = createCallbackFcn(app, @RestartButton_4Pushed, true);
            app.RestartButton_4.Position = [11 14 90 22];
            app.RestartButton_4.Text = 'Restart';

            % Create NextButton_6
            app.NextButton_6 = uibutton(app.UAVPreparationPanel, 'push');
            app.NextButton_6.ButtonPushedFcn = createCallbackFcn(app, @NextButton_6Pushed, true);
            app.NextButton_6.Position = [118 14 91 22];
            app.NextButton_6.Text = 'Next';

            % Create VisualizedataButton_4
            app.VisualizedataButton_4 = uibutton(app.UAVPreparationPanel, 'push');
            app.VisualizedataButton_4.ButtonPushedFcn = createCallbackFcn(app, @VisualizedataButton_4Pushed, true);
            app.VisualizedataButton_4.Position = [58 59 100 22];
            app.VisualizedataButton_4.Text = 'Visualize data';

            % Create FaultydataselectionPanel_AVS
            app.FaultydataselectionPanel_AVS = uipanel(app.UIFigure);
            app.FaultydataselectionPanel_AVS.AutoResizeChildren = 'off';
            app.FaultydataselectionPanel_AVS.TitlePosition = 'centertop';
            app.FaultydataselectionPanel_AVS.Title = 'Faulty data selection';
            app.FaultydataselectionPanel_AVS.BackgroundColor = [0.9412 0.9412 0.9412];
            app.FaultydataselectionPanel_AVS.Position = [345 -391 216 369];

            % Create FaulttypeButtonGroup
            app.FaulttypeButtonGroup = uibuttongroup(app.FaultydataselectionPanel_AVS);
            app.FaulttypeButtonGroup.AutoResizeChildren = 'off';
            app.FaulttypeButtonGroup.TitlePosition = 'centertop';
            app.FaulttypeButtonGroup.Title = 'Fault type';
            app.FaulttypeButtonGroup.Position = [42 225 132 105];

            % Create OffsetButton
            app.OffsetButton = uitogglebutton(app.FaulttypeButtonGroup);
            app.OffsetButton.Text = 'Offset';
            app.OffsetButton.Position = [16 52 100 22];
            app.OffsetButton.Value = true;

            % Create NoiseButton
            app.NoiseButton = uitogglebutton(app.FaulttypeButtonGroup);
            app.NoiseButton.Text = 'Noise';
            app.NoiseButton.Position = [16 31 100 22];

            % Create StuckvalueButton
            app.StuckvalueButton = uitogglebutton(app.FaulttypeButtonGroup);
            app.StuckvalueButton.Text = 'Stuck value';
            app.StuckvalueButton.Position = [16 10 100 22];

            % Create VisualizedataButton_5
            app.VisualizedataButton_5 = uibutton(app.FaultydataselectionPanel_AVS, 'push');
            app.VisualizedataButton_5.ButtonPushedFcn = createCallbackFcn(app, @VisualizedataButton_5Pushed, true);
            app.VisualizedataButton_5.Position = [58 91 100 22];
            app.VisualizedataButton_5.Text = 'Visualize data';

            % Create FaultdurationDropDownLabel
            app.FaultdurationDropDownLabel = uilabel(app.FaultydataselectionPanel_AVS);
            app.FaultdurationDropDownLabel.Position = [10 189 79 22];
            app.FaultdurationDropDownLabel.Text = 'Fault duration';

            % Create FaultdurationDropDown
            app.FaultdurationDropDown = uidropdown(app.FaultydataselectionPanel_AVS);
            app.FaultdurationDropDown.Items = {'0.6s', '1:2s', '1.8s', '2.4s', '3.0s', '3.6s', '4.2s', '5.0s'};
            app.FaultdurationDropDown.ItemsData = {'1', '2', '3', '4', '5', '6', '7', '8'};
            app.FaultdurationDropDown.Position = [104 189 100 22];
            app.FaultdurationDropDown.Value = '1';

            % Create ScenarioListBoxLabel
            app.ScenarioListBoxLabel = uilabel(app.FaultydataselectionPanel_AVS);
            app.ScenarioListBoxLabel.Position = [10 160 53 22];
            app.ScenarioListBoxLabel.Text = 'Scenario';

            % Create ScenarioListBox
            app.ScenarioListBox = uilistbox(app.FaultydataselectionPanel_AVS);
            app.ScenarioListBox.Items = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'};
            app.ScenarioListBox.ItemsData = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'};
            app.ScenarioListBox.Position = [104 126 100 56];
            app.ScenarioListBox.Value = '1';

            % Create PredictdataButton
            app.PredictdataButton = uibutton(app.FaultydataselectionPanel_AVS, 'push');
            app.PredictdataButton.ButtonPushedFcn = createCallbackFcn(app, @PredictdataButtonPushed, true);
            app.PredictdataButton.Position = [57 60 102 22];
            app.PredictdataButton.Text = 'Predict data';

            % Create OnlinedetectionsimulationButton
            app.OnlinedetectionsimulationButton = uibutton(app.FaultydataselectionPanel_AVS, 'push');
            app.OnlinedetectionsimulationButton.ButtonPushedFcn = createCallbackFcn(app, @OnlinedetectionsimulationButtonPushed, true);
            app.OnlinedetectionsimulationButton.WordWrap = 'on';
            app.OnlinedetectionsimulationButton.Position = [57 16 104 34];
            app.OnlinedetectionsimulationButton.Text = 'Online detection simulation';

            % Create FaultydataselectionPanel_UAVAcc
            app.FaultydataselectionPanel_UAVAcc = uipanel(app.UIFigure);
            app.FaultydataselectionPanel_UAVAcc.AutoResizeChildren = 'off';
            app.FaultydataselectionPanel_UAVAcc.TitlePosition = 'centertop';
            app.FaultydataselectionPanel_UAVAcc.Title = 'Faulty data selection';
            app.FaultydataselectionPanel_UAVAcc.BackgroundColor = [0.9412 0.9412 0.9412];
            app.FaultydataselectionPanel_UAVAcc.Position = [582 -342 216 320];

            % Create FaulttypeButtonGroup_2
            app.FaulttypeButtonGroup_2 = uibuttongroup(app.FaultydataselectionPanel_UAVAcc);
            app.FaulttypeButtonGroup_2.AutoResizeChildren = 'off';
            app.FaulttypeButtonGroup_2.TitlePosition = 'centertop';
            app.FaulttypeButtonGroup_2.Title = 'Fault type';
            app.FaulttypeButtonGroup_2.Position = [42 176 132 105];

            % Create OffsetButton_2
            app.OffsetButton_2 = uitogglebutton(app.FaulttypeButtonGroup_2);
            app.OffsetButton_2.Text = 'Offset';
            app.OffsetButton_2.Position = [16 52 100 22];
            app.OffsetButton_2.Value = true;

            % Create PackagedropButton
            app.PackagedropButton = uitogglebutton(app.FaulttypeButtonGroup_2);
            app.PackagedropButton.Text = 'Package drop';
            app.PackagedropButton.Position = [16 31 100 22];

            % Create StuckedvalueButton_2
            app.StuckedvalueButton_2 = uitogglebutton(app.FaulttypeButtonGroup_2);
            app.StuckedvalueButton_2.Text = 'Stucked value';
            app.StuckedvalueButton_2.Position = [16 10 100 22];

            % Create ScenarioListBox_2Label
            app.ScenarioListBox_2Label = uilabel(app.FaultydataselectionPanel_UAVAcc);
            app.ScenarioListBox_2Label.Position = [11 111 53 22];
            app.ScenarioListBox_2Label.Text = 'Scenario';

            % Create ScenarioListBox_2
            app.ScenarioListBox_2 = uilistbox(app.FaultydataselectionPanel_UAVAcc);
            app.ScenarioListBox_2.Items = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20'};
            app.ScenarioListBox_2.ItemsData = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20'};
            app.ScenarioListBox_2.Position = [105 77 100 56];
            app.ScenarioListBox_2.Value = '1';

            % Create PredictdataButton_2
            app.PredictdataButton_2 = uibutton(app.FaultydataselectionPanel_UAVAcc, 'push');
            app.PredictdataButton_2.ButtonPushedFcn = createCallbackFcn(app, @PredictdataButton_2Pushed, true);
            app.PredictdataButton_2.Position = [58 12 102 22];
            app.PredictdataButton_2.Text = 'Predict data';

            % Create FaulttypeButtonGroup_4
            app.FaulttypeButtonGroup_4 = uibuttongroup(app.FaultydataselectionPanel_UAVAcc);
            app.FaulttypeButtonGroup_4.AutoResizeChildren = 'off';
            app.FaulttypeButtonGroup_4.SelectionChangedFcn = createCallbackFcn(app, @FaulttypeButtonGroup_4SelectionChanged, true);
            app.FaulttypeButtonGroup_4.TitlePosition = 'centertop';
            app.FaulttypeButtonGroup_4.Title = 'Fault type';
            app.FaulttypeButtonGroup_4.Visible = 'off';
            app.FaulttypeButtonGroup_4.Position = [43 176 132 105];

            % Create OffsetButton_4
            app.OffsetButton_4 = uitogglebutton(app.FaulttypeButtonGroup_4);
            app.OffsetButton_4.Text = 'Offset';
            app.OffsetButton_4.Position = [16 52 100 22];
            app.OffsetButton_4.Value = true;

            % Create NoiseButton_3
            app.NoiseButton_3 = uitogglebutton(app.FaulttypeButtonGroup_4);
            app.NoiseButton_3.Text = 'Noise';
            app.NoiseButton_3.Position = [16 31 100 22];

            % Create StuckedvalueButton_4
            app.StuckedvalueButton_4 = uitogglebutton(app.FaulttypeButtonGroup_4);
            app.StuckedvalueButton_4.Text = 'Stucked value';
            app.StuckedvalueButton_4.Position = [16 10 100 22];

            % Create FaultydataselectionPanel_SWaT
            app.FaultydataselectionPanel_SWaT = uipanel(app.UIFigure);
            app.FaultydataselectionPanel_SWaT.AutoResizeChildren = 'off';
            app.FaultydataselectionPanel_SWaT.TitlePosition = 'centertop';
            app.FaultydataselectionPanel_SWaT.Title = 'Faulty data selection';
            app.FaultydataselectionPanel_SWaT.BackgroundColor = [0.9412 0.9412 0.9412];
            app.FaultydataselectionPanel_SWaT.Position = [820 -342 216 320];

            % Create FaulttypeButtonGroup_3
            app.FaulttypeButtonGroup_3 = uibuttongroup(app.FaultydataselectionPanel_SWaT);
            app.FaulttypeButtonGroup_3.AutoResizeChildren = 'off';
            app.FaulttypeButtonGroup_3.TitlePosition = 'centertop';
            app.FaulttypeButtonGroup_3.Title = 'Fault type';
            app.FaulttypeButtonGroup_3.Position = [42 176 132 105];

            % Create OffsetButton_3
            app.OffsetButton_3 = uitogglebutton(app.FaulttypeButtonGroup_3);
            app.OffsetButton_3.Text = 'Offset';
            app.OffsetButton_3.Position = [16 52 100 22];
            app.OffsetButton_3.Value = true;

            % Create NoiseButton_2
            app.NoiseButton_2 = uitogglebutton(app.FaulttypeButtonGroup_3);
            app.NoiseButton_2.Text = 'Noise';
            app.NoiseButton_2.Position = [16 31 100 22];

            % Create StuckedvalueButton_3
            app.StuckedvalueButton_3 = uitogglebutton(app.FaulttypeButtonGroup_3);
            app.StuckedvalueButton_3.Text = 'Stucked value';
            app.StuckedvalueButton_3.Position = [16 10 100 22];

            % Create DayListBoxLabel
            app.DayListBoxLabel = uilabel(app.FaultydataselectionPanel_SWaT);
            app.DayListBoxLabel.Position = [11 111 27 22];
            app.DayListBoxLabel.Text = 'Day';

            % Create DayListBox
            app.DayListBox = uilistbox(app.FaultydataselectionPanel_SWaT);
            app.DayListBox.Items = {'1', '2', '3', '4', '5', '6'};
            app.DayListBox.ItemsData = {'1', '2', '3', '4', '5', '6'};
            app.DayListBox.Position = [105 77 100 56];
            app.DayListBox.Value = '1';

            % Create PredictdataButton_3
            app.PredictdataButton_3 = uibutton(app.FaultydataselectionPanel_SWaT, 'push');
            app.PredictdataButton_3.ButtonPushedFcn = createCallbackFcn(app, @PredictdataButton_3Pushed, true);
            app.PredictdataButton_3.Position = [63 11 102 22];
            app.PredictdataButton_3.Text = 'Predict data';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = myApp_exported

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.UIFigure)

                % Execute the startup function
                runStartupFcn(app, @startupFcn)
            else

                % Focus the running singleton app
                figure(runningApp.UIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end