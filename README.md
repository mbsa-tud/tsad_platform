# TSAD Platform Manual

<<<<<<< HEAD
A platform for time series anomaly detection.

## Getting Started

1. Install MATLAB Toolboxes:
=======
**A platform for evaluating time series anomaly detection (TSAD) methods.**

**Automatically train, test, compare and optimize many models or add your custom ones.**

---

## Getting started

1. Download this repository.
2. Install MATLAB Toolboxes:
>>>>>>> 4606f0a840124cab970ece83ecf2ad15e8d6c0c1
    * `Simulink`
    * `Signal Processing Toolbox`
    * `DSP System Toolbox`
    * `Image Processing Toolbox`
    * `Econometrics Toolbox`
    * `Predictive Maintenance Toolbox`
    * `Statistics and Machine Learning Toolbox`
<<<<<<< HEAD
    * `deep-learning Toolbox`
2. Download the Anomaly Detection Toolbox from `https://github.com/dsmi-lab-ntust/AnomalyDetectionToolbox.git`, and add the `Anomaly Detection Toolbox` to the MATLAB path. To use MERLIN, download it and add it to the MATLAB path.
3. Add the `tsad_platform` folder to the MATLAB path (without subfolders).
4. Add the `src` and `Sim Models` folders to the MATLAB path (with subfolders).
5. Open the `tsad_platform` folder with MATLAB.
6. Open the `TSADPlatform.mlapp` file with MATLAB App Designer (double click on it).
7. Click the `Run` icon on the top of the App Designer window to start the platform.

---

## Overview

On the top of the platform you will find the `Settings` menu (1) and seven different `Panels` (2):

<img src="media/final_panels.png" alt="Panels" title="Panels" width=600/>

In the [Settings](#settings) you can control the following things:

* [Threshold Selection](#threshold-selection): What thresholds to enable within the platform.
* [Dynamic Threshold](#dynamic-threshold): The default configuration for the dynamic threshold.
* [Optimization](#optimization-logging): Whether to export logdata during an optimization process.

**Manually train and test models:**

1. Import a dataset on the [Data](#importing-a-dataset) panel.
2. Split and process the dataset on the [Preprocessing](#preprocessing-and-splitting-the-dataset) panel.
3. Configure, train and optimize models on the [Training](#training-and-optimization) panel.
4. Test the models on the [Detection](#detection) and [Simulink Detection](#simulink-detection) panels.
5. (optional) Configure, train and test the dynamic switch mechanism on the [Dynamic Switch](#dynamic-switch) panel (only possible for univariate datasets with multiple files for testing).

**Automatically train and test models on single- or multi-entity datasets:**

1. Configure models on the [Training](#training-and-optimization) panel.
2. Configure and start the auto-run function on the [Auto Run](#auto-run) panel.

---

## Settings

You can find the platform settings in the top left corner.

### Threshold selection

The selection of thresholds controls which thresholds are calculated by the platform.
Only the selected ones are used during the auto-evaluation on the `Auto Run` panel.

To select thresholds, proceed as follows:

1. Click `Settings > Threshold Selection` to open the threshold selection window.

    <img src="media/final_threshold_selection.png" alt="Threshold selection settings" title="Threshold selection settings" width=260/>

2. Select the desired thresholds (1).
3. Click `Save` (2) to save the new selection.

### Dynamic threshold

These options control the default parameters for the dynmaic threshold, which can also be configured on the `Detection` panel. To update their values, proceed as follows:

1. Click `Settings > Dynamic Threshold` to open the dynamic threshold settings window.

    <img src="media/final_settings_dynamic_threshold.png" alt="Dynamic threshold settings" title="Dynamic threshold settings" width=200/>

2. Configure the parameters (1).
3. Click `Save` (2) to save the new parameters.

### Optimization logging

During an optimization, the platform has the ability to export all scores for each iteration of the optimization process to a folder called `Optimization_Logdata` within the current MATLAB folder.
To enable this feature, proceed as follows:

1. Click `Settings > Optimization` to open the optimization settings window.

    <img src="media/final_settings_optimization_logdata.png" alt="Optimization logging settings" title="Optimization logging settings" width=160/>

2. Check the `Export Logdata` checkbox (1).
3. Click `Save` (2) to save your changes.

---

## Importing a dataset

A dataset can be loaded on the `Data` panel:

<img src="media/final_data_panel.png" alt="Data panel" title="Data panel" width=900/>

1. On the `Data` panel, click `Browse` (1) to select a folder from the computer or enter a path manually.
2. Click `Load Data` (2) to import the selected dataset.

The **format** of a dataset must be as such:

* It contains a folder called `test` (mandatory) and a folder called `train` (optional for methods not requiring prior training).
* Each folder contains an arbitrary amount of **CSV** files with the following format:

| timestamp | value1 | value2 | is_anomaly |
|-|-|-|-|
|1|1.2345|0.223|0|
|2|1.2566|0.111|0|
|3|-1.3111|0|1|

* **Timestamp**: The equally spaced timestamps. Can be increasing numeric values or common datatime strings.
* **Values**: The values for the individual channels of the dataset. For univariate data there is just one value-column.
* **is_anomaly**: The anomaly indicators for each observation. 1 = anomaly, 0 = fault-free.

**NOTE** The column-names don't need to be as presented. The platfrom interprets the values of each column according to their position in the file. The first column is always considered the timestamp column and the last column is always considered to be the column of anomaly indicators. Everything in between are the values of the channels.

---

## Preprocessing and splitting the dataset

The dataset can be split and processed on the `Preprocessing` panel:

<img src="media/final_preprocessing_panel.png" alt="Preprocessing panel" title="Preprocessing panel" width=900/>

### Preprocessing method selection

Three preprocessing methods can be selected (1). These **don't** apply to the [Auto Run](#auto-run) functions, but to everything else:

* **Raw Data**: Unprocessed data.
* **Standardize**: Set mean = 0 and standard deviation = 1.
* **Rescale [0, 1]**: Set maximum = 1 and minimum = 0.

**NOTE** The data in the `test` folder gets processed with the same parameters as for the `train` data (with the exception if no train data is used). All channels of multivariate datasets are preprocessed independently.

### Data preparation for Dynamic Switch

If the dataset is **univariate** and includes multiple files for testing, you can split the test set to use some of the files for testing the [Dynamic Switch](#dynamic-switch) mechanism.
To enable this, do the following:

1. Check the `Split Test Set for Dynamic Switch` checkbox (2).
2. Enter a value for the `Ratio` to determine its size.

### Use of anomalous validation set

An anomalous validation set can be used to calculate the static thresholds prior to testing the models. If it's not available or doesn't contain any anomalies, most of the static thresholds will be calculated last during testing.
To enable the anomalous validation set, do the following:

1. Check the `Use anomalous Validation Set` checkbox (3).
2. Enter a value for the `Ratio` to determine its size.

---

## Training and optimization

On the `Training` panel you can train or optimize a selection of models:

<img src="media/final_training_panel.png" alt="Training panel" title="Training panel" width=900/>

To do so, proceed as follows:

### Load/configure models

There are **three** ways to load a configuration of models (These are not trained yet, it's only the configuration that gets loaded):

* Click `Add` (1) on top of one of the three lists to add either a **deep-learning**, **Classic Machine Learning** or **Statistical** anomaly detection model. This opens a **new window**, allowing you to select a model and configure its parameters. Once configured, click `Add to Model Selection` to add the selected model to the list of models.
* Click `Add All` (1) to add a default configuration of all models.
* You can select multiple models from all lists and click `Export Config for Selection` (2) to store a configuration file on your computer.
This allows you to load a previous configuration of models at another time using the `Load from File` (2) button.
* To show the hyperparameters of a model, select it in the list, right-click and select `Show Model Parameters`. This wil show all parameters of the selected model on the right side of the window.

### Train models

To train models, do the following:

* Click `Train All` (4) to train all configured models within the respective list.
* Click `Train Selection` (4) to train all manually selected models within the respective list (Click on models to select them).
* Click `Train All` (6) at the bottom to train all configured models of all types.

**NOTE** All models **must** be trained to make them available on the [Detection](#detection) and [Simulink Detection](#simulink-detection) panels. If they don't require prior training, this step is still required (In this case it only adds the model to the list of trained models on the `Detection` panel)

Before training **deep-learning** models, you can configure the training process as follows:

* Check the `Parallel` (3) checkbox to enable parallel training of deep-learning models.
* Check the `Training Plots` (3) checkbox to enable graphical training plots.

### Optimize models

To optimize a **single model**, do the following:

1. Select **one** model.
2. Click the `Optimize` button (5) below the list. This opens a **new window**:

    <img src="media/final_optimization_single.png" alt="Single optimization" title="Single optimization" width=200/>

3. (optional) Uncheck the `Use Preconfigured Hyperparameter Range` checkbox and click the `Add` button. This opens a **new window** for defining ranges of hyperparameters:

    <img src="media/final_optimization_hyperparameters.png" alt="Optimization hyperparameters" title="Optimization hyperparameters" width=200/>

    Select and configure the parameter and press `Add` to add it to the list.
    Only these hyperparameters will be varied within the specified range during the optimization process.
4. Enter a value for the number of `Iterations` for the optimization function.
5. Select a `Score` you want to be improved.
6. Select a `Threshold`
7. To show training plots for deep-learning models, check the `Training Plots` checkbox.
8. Click `Run Optimization` to start the optimization process. This opens windows showing the progress of the bayesian optimization.
9. Once it's done, the model with the best configuration will be added to the list of models.

To optimize **multiple models** automatically, do the following:

1. Select the models within the lists.
2. Click `Optimize` (5) to open a **new window**. The `Optimize All` button (6) at the bottom of the panel can be used to optimize all configured models of all types.

    <img src="media/final_optimize_all.png" alt="Optimize all window" title="Optimize all window" width=200/>

3. Configure the optimization process by selecting a `Score`, a `Threshold` and check the `Training Plots` checkbox if you want to show plots for deep-learning models.
4. Click the `Run Optimization` button to optimize all models.
5. Once it's done, the models with the best configuration will be added to the list of models.

**NOTE** You need to train the optimized models before they're available on the [Detection](#detection) and [Simulink detection](#simulink-detection) panels.

---

## Detection

The offline anomaly detection using the models trained earlier (see [Training and optimization](#training-and-optimization)) is available on the `Detection` panel:

<img src="media/final_detection_panel.png" alt="Detection panel" title="Detection panel" width=900/>

### List of trained Models (1)

* All trained models appear in the **list of trained models**.
* These are **ranked** according to their detection performance. The metric used for ranking can be manually selected from the dropdown menu at the top of the list.
* Models can be selected within the list and **saved** by clicking the `Save selected Models` button.
* Trained models can be **loaded** directly into the platform via the `Import trained Models` button.

### Detection section

To **run a detection**, proceed as follows:

1. Select a file from the `Select faulty Data` dropdown menu (2).
2. Select a threshold from the `Threshold` dropdown menu (2). If you select the **dynamic** threshold, you can additionally configure its parameters (2).
3. Select models from the **list of trained models** and click `Selected Models` or click `All Models` (3) to start the detection process.
4. Once the detection is finished, the following results are are displayed in the windows below:
    * **Plots** (4) of the anomaly scores and detected anoamlies for the last model the detection was run for.
    * A **Table** (5) storing all scores for all models and the computational time of deep-learning models (time to make predictions for one subsequence)
    * A **Computation time** plot (6) showing the computational time of the models on the x-axis and the obtained scores on the y-axis.
    Using the `Metric Selection` button, one can choose what metrics should be displayed within the plot.

You can select another threshold or reconfigure the dynamic threshold. This will update the scores for the currently shown model in the **Plots** section (4). To run it again for all models, click the `All Models` button (3) again.

---

## Simulink Detection

The online detection simulation using Simulink is available on the `Simulink detection` panel:

<img src="media/final_simulink_detection_panel.png" alt="Simulink detection panel" title="Simulink detection panel" width=900/>

To **run the simulink detection**, proceed as follows:

1. Select models from the **list of trained models** (1). You can also import or save a selection of models within this list.
2. Select a file from the `Select faulty Data` dropdown menu and a threshold from the `Threshold` dropdown menu (2).
3. If you want Simulink to open when running a detection, check the `Open Model` (3) checkbox.
4. Click `Run Detection` (4) to start the online detection simulation. 

---

## Dynamic switch

The dynamic switch mechanism (model selection mechanism) can be trained and tested on the `Dynamic switch` panel:

<img src="media/final_dynamic_switch_panel.png" alt="Dynamic switch panel" title="Dynamic switch panel" width=900/>

The usage of the dynamic switch mechanism **requires** the following things:

* **Correct dataset**: A **Univariate** dataset with **multiple anomalous files** for testing. The `Split Test Set for Dynamic Switch` checkbox on the [Preprocessing](#preprocessing-and-splitting-the-dataset) panel must be checked.
* **Trained models**: Either configure and train models on the [Training](#training-and-optimization) panel or load trained models on the [Detection](#detection) panel.

To **train and test the dynamic switch**, proceed as follows:

1. Select a metric from the `Metric` dropdown menu (1). This will be used to compare the models during auto-labeling.
2. Select a threshold from the `Threshold` dropdown menu (2). This threshold will be used for all models.
3. Click the `Auto-label Dataset` button (3). This runs the detection for all models on all files of the test dataset (without the files for testing the dynamic switch).
4. Click the `Train Classifier` button (4) to train the deep calssification network. It learns to connect time series features with the correct labels determined in step 3.
5. Click the `Run Evaluations` button (5) to test the dynamic switch. All results including the scores obtained by all individual models will be displayed in the table.

---

## Auto run

This tool to automatically train and test models on single- or multi-entity datasets is available on the `Auto Run` panel:

<img src="media/final_auto_run_panel.png" alt="Auto Run panel" title="Auto Run panel" width=900/>

To use this function, proceed as follows:

1. Select the thresholds in the [Settings](#settings) of the platform
2. (optional) If the dynmaic threshold was selected, configure it in the [Settings](#settings).
3. Configure/load models on the [Training](#training-and-optimization) panel.
4. Select a dataset on the [Auto Run](#auto-run) panel by clicking the `Browse` (1) button.
5. Select a `Preprocessing Method` from the drop down menu (2).
6. Check the `Use anomalous Validtaion Set` checkbox (3) if you want to extract an anomalous validation set from the test set. Specifiy the `Ratio` to determine its size.
7. Enter a value for the `Fraction of Dataset to Use` field (4). This only determines how many subsets of a multi-entity dataset should be tested.
8. Check the `Train Parallel` checkbox (5) to enable parallel training of deep-learning models.
9. Check the `Training Plots` checkbox (6) to enable plots during training of deep-learning models.
10. Click `Run Evaluation` (7) to start the process. You can observe more details about the current state in the MATLAB command window.
11. Once it's done, all results are stored in a folder called *Auto_Run_Results* within the current MATLAB folder.

---

## Extending the platform

### The "options" struct

The platform recognizes a model/algorithm by its configuration. This configuration is stored in a struct with a single key called **"options"**.
The value of this key contains all relevant information. When adding a configured model to one of the lists of models on the [Training](#training-and-optimization) panel, the **ItemsData** property of that list (which is a struct array in this platform) gets extended by such a struct.

The following figure shows an example for the fully-connected autoencoder (FC AE):

```json
"options": {
    "type": "DNN",
    "model": "FC AE",
    "scoringFunction": "aggregated-errors",
    "modelType": "reconstructive",
    "label": "FC AE  (1)",
    "id": "FC_AE_1",
    "dataType": 1,
    "requiresPriorTraining": true,
    "isMultivariate": false,
    "outputsLabels": false,
    "hyperparameters": {
        "model": {
            "neurons": {
                "value": 32,
                "type": "integer"
            }
        },
        "data": {
            "windowSize": {
                "value": 100,
                "type": "integer"
            },
            "stepSize": {
                "value": 1,
                "type": "integer"
            }
        },
        "training": {
            "epochs": {
                "value": 50,
                "type": "integer"
            },
            "minibatchSize": {
                "value": 64,
                "type": "integer"
            },
                "ratioTrainVal": {
                "value": 1,
                "type": "real"
            }
        }
    }
}
```

Fields of the **options** struct:

**type**
The type of the model/algorithm. Must be one of: `"DNN"`, `"CML"`, `"S"`

**model**
The identifier for the model. This is used by the platform to recognize the model. It should only contain **letters** and the following characters: `-` `(` `)`.

**scoringFunction**
This field is only required for DL models. Its value changes how the anomaly scores are defined:

| Value | Description |
|-|-|
| aggregated-errors | The mean training reconstruction/prediction error gets subtracted from the channel-wise errors (Only for multivariate datasets). Afterwards, the root-mean-square is taken across channels. For univariate datasets, the errors are used directly. |
| channelwise-errors | The mean training reconstruction error gets subtracted from the channel-wise errors (Only for multivariate datasets). Nothing else is done. For univariate datasets, this is the same as the aggregated-errors scoring function. |
| gauss | The channelwise mean and standard deviation of the training error distribution is used to compute -log(1 - cdf("channelwise errors")) of the channel-wise errors to get channel-wise anomaly scores. Afterwards, the channelwise anomaly scores are added. |
| channelwise-gauss | The channelwise mean and standard deviation of the training error distribution is used to compute -log(1 - cdf("channelwise errors")) of the channel-wise errors to get channel-wise anomaly scores. |

**modelType**
This field is only required for DL models. Its value must be one of: `"predictive"`, `"reconstructive"`. It indicates whether the model produces prediction or reconstruction errors.

**dataType**
This field is only required if your model uses the data preparation function provided by the platform.
It's value must be one of: `1`, `2`, `3`. The number controls the shape of the data. The data is always split into subsequences of equal length using a sliding window. For the three different numbers, the data will be shaped as such:
| Data type | Univariate model | Multivariate model |
|-|-|-|
| **1** | `1 x D` cell array with `D` being the number of channels. For each channel a separate model of the same type will be trained (Only for deep-learning models). Each cell contains a `N x w` matrix with `w` being the window-size and `N` being the number of observations.| `1 x 1` cell array containing a `N x (w * d)` matrix with `N` being the number of observations, `w` the window size and `d` the number of channels. |
| **2** | `1 x D` cell array with `D` being the number of channels. For each channel a separate model of the same type will be trained (Only for deep-learning models). Each cell contains a `N x 1` cell array with `N` being the number of observations. Each cell is a matrix of size `1 x w` with `w` being the window-size. | `1 x 1` cell array containing a `N x 1` cell array with `N` being the number of observations. Each cell contains a matrix of size `d x w` with `d` being the number of channels and `w` being the window size. |
| **3** | `1 x D` cell array with `D` being the number of channels. For each channel a separate model of the same type will be trained (Only for deep-learning models). Each cell contains a `N x 1` cell array with `N` being the number of observations. Each cell is a matrix of size `w x 1` with `w` being the window-size. | NOT AVAILABLE! |

**label**
The label for the model. It's only displayed in the lists on the training panel. It **MUST** be the the same as the `model` field followed by **two whitespaces and a number in brackets**. Example: **FC AE &nbsp;(1)**. **This field gets automatically set by the platform and only needs to be specified in the `config_all.json` file located in the `tsad_platform > src > config` folder**.

**id**
The id is the same as the `label` field but with all non-letter characters being replaced by `_`. For multiple consecutive non-letter characters, only a single `_` must be insterted. This field is automatically set by the platform. Once the platform finished training all models, it creates a struct of trained models. The fieldnames of this struct are the **ids** specified in this field of the options struct.

**requiresPirorTraining**
If this is set to **false**, the model is trained on the data from the **train** folder. If it is set to **true**, the model doesn't get trained prior to testing.

**isMultivariate**
Set this to `true` if the model is suited for multivariate data. Otherwise set it to `false`. **(Only for deep-learning models: If it is set to `false` but the loaded dataset is multivariate, a separate model will be trained for each channel of the dataset.)**

**outputsLabels**
If your anomaly detection method doesn't output anomaly scores, but binary labes for each observation within the time series, set this field to `true` to bypass all thresholding methods. Otherwise it must be set to `false`.

**hyperparameters**
This field can contains all configurable hyperparameters for your model/algorithm. Its value is another struct array. The hyperparameters should be separated into three groups: **model**, **data** and **training** related hyperparameters, which are all separate fields within this struct. If you want to add a hyperparameter, specify its name as a new key within on of the aforementioned fields (model, data, training). It must contain two keys: **value** and **type**. The type is only required for the optimization algorithm of the platform. It must be one of: `"integer"`, `"real"`, `"categorical"`. Look at the example above for reference.

The file `config_all.json` contains the JSON representation of a MATLAB struct with separate fields for DNN, CML and statistical models. Each field's value is a struct array with individual "options" structs, as presented before. This file is used for loading the default configuration of models on the [Training](#training-and-optimization) panel using the `Add All` buttons:

```json
{
    "DNN_Models": [
        {
            "options": {

            }
        },
        {
            "options": {

            }

        }
    ],
    "CML_Models": [

    ],
    "S_Models": [

    ]
}
```

### Adding models

To add more models to the platform (deep-learning, classic machine learning and statistical), proceed as follows:

1. Define the `options` struct mentioned before. You can create a `.json` file as mentioned before to be able to load your model into the platform. Alternativeley, edit on of the following files: `ModelSelection_DNN.mlapp`, `ModelSelection_CML.mlapp`, `ModelSelection_S.mlapp`. Use other examples in those files as a guideline on how to add your model.
2. **(optional)** Edit the `conifg_optimization.json` file within the `tsad_platform > src > config` folder and define a range of hyperparameters. Look at the other examples in that file as reference.
3. Add the training and detection function calls to the source code of the platform. See [below](#add-deep-learning-anomaly-detection-models) for a detailed explanation.
4. If you require the data to be transformed in another way as provided by the platform, see [below](#optional-data-preparation) for more information.

#### Add deep-learning anomaly detection models

It's recommended to implement the deep-learning models using functions from MATLAB's deep-learning Toolbox. To do so, follow these steps:

1. **Define the layers**: Go to the folder `tsad_platform > src > models > deep_neural_networks` and open the file `getLayers.m`. Add a new option in the main *switch* statement for the name of your model:

    ```matlab
    switch options.model
        % Add your model here
        case 'Your model name'
            % Get hyperparameters from options
            neurons = options.hyperparameters.model.neurons.value;

            % Define layers
            layers = [featureInputLayer(numFeatures)
                fullyConnectedLayer(neurons))
                reluLayer()
                fullyConnectedLayer(numResponses)
                regressionLayer()];
            
            layers = layerGraph(layers);
    ```

2. **Define training options**: Go to the folder `tsad_platform > src > models > deep_neural_networks` and open the file `getOptions.m`. Add a new option in the main *switch* statement for the name of your model. Look at the example for more information:

    ```matlab
    switch options.model
     % Add your model here
        case 'Your model name'
            % Define different options depending on whether validation data is available
            if options.hyperparameters.training.ratioTrainVal.value == 1
                trainOptions = trainingOptions("adam", ...
                    "Plots", plots, ...
                    "MaxEpochs", options.hyperparameters.training.epochs.value, ...
                    "MiniBatchSize", options.hyperparameters.training.minibatchSize.value, ...
                    "InitialLearnRate", 0.001, ...
                    'Shuffle', "every-epoch",...
                    'ExecutionEnvironment', device);
            else
                trainOptions = trainingOptions("adam", ...
                    "Plots", plots, ...
                    "MaxEpochs", options.hyperparameters.training.epochs.value, ...
                    "MiniBatchSize", options.hyperparameters.training.minibatchSize.value, ...
                    "InitialLearnRate", 0.001, ...
                    'ExecutionEnvironment', device, ...
                    "ValidationData", {XVal, YVal}, ...
                    'Shuffle', "every-epoch",...
                    "ValidationFrequency", floor(numWindows / (3 * options.hyperparameters.training.minibatchSize.value)));
            end
    ```

    If you want **parallel training** to be available for your model, open the file `getOptionsForParallel.m`. Add a new option in the main *switch* statement for the name of your model. These options slightly differ from the ones above. Make sure to always add the `OutputFcn` parameter as shown below:

    ```matlab
    switch options.model
        % Add your model here
        case 'Your model name'
            % Similar as before but with the 'OutputFcn' parameter added and no `Plots` parameter
            if options.hyperparameters.training.ratioTrainVal.value == 1
                trainOptions = trainingOptions('adam', ...
                    'MaxEpochs', options.hyperparameters.training.epochs.value, ...
                    'MiniBatchSize', options.hyperparameters.training.minibatchSize.value, ...
                    'InitialLearnRate', 0.001, ...
                    'Shuffle', 'every-epoch',...
                    'OutputFcn', @(info) send(dataqueue, struct('experimentNumber', idx, 'info', info)));
            else
                trainOptions = trainingOptions('adam', ...
                    'MaxEpochs', options.hyperparameters.training.epochs.value, ...
                    'MiniBatchSize', options.hyperparameters.training.minibatchSize.value, ...
                    'InitialLearnRate', 0.001, ...
                    'ValidationData', {XVal, YVal}, ...
                    'Shuffle', 'every-epoch',...
                    'ValidationFrequency', floor(numWindows / (3 * options.hyperparameters.training.minibatchSize.value)), ...
                    'OutputFcn', @(info) send(dataqueue, struct('experimentNumber', idx, 'info', info)));
            end
    ```

If you want to add a network **without using the MATLAB deep-learning Toolbox**, proceed as follows:

1. **Add the training function call for you network**: Go to the folder `tsad_platform > src > models > deep_neural_networks` and open the file `trainDNN.m`. Add your model name within the main *switch* statement, then call your training function and save the trained network in the `Mdls` vairable. The `MdlInfos` variable is optional and can be left empty:

    ```matlab
    switch options.model
        % Add your model here
        case 'Your model name'
            Mdls = yourTrainFunction(XTrain, YTrain, XVal, YVal);
            MdlInfos = [];
    ```

2. **Add the detection call for your network**: Go to the folder `tsad_platform > src > detection` and open the file `detectWithDNN.m`. Add your model name within the main *switch* statement, then add your detection function call. Make sure to return anomaly scores (`anomalyScores`) and optionally the computational time (`compTimeOut`) of your model:

    ```matlab
    switch options.model
        % Add your model here
        case 'Your model'
            anomalyScores = detectWithYourModel(Mdl, XTest);

            % The compTimeOut variable should contain the computation time for a single subsequence. Set it to NaN if you don't need it to be computed
            compTimeOut = NaN;
    ```

#### Add classic machine learning or statistical anomaly detection algorithms

The process for adding these algorithms will only be explained for classic machine learning models, as it is the same for statistical models. Only the files differ which need to be modified. What file to use for what type of algorithm will be mentioned.

1. **Add the training function call**: This step is only required if your model requires prior training (if so, you **MUST** set the `requiresPriorTraining` field within the `options` struct to **true**, otherwise your model will never be trained).
 Go to the folder `tsad_platform > src > models > classic_machine_learning` and open the file `trainCML.m` (`trainS.m` within the `statistical` folder for statistical models). To train your model, add your model name to the main *switch* statement, then call your training function and save the trained model in the `Mdl` variable:

    ```matlab
    switch options.model
        % Add your model here
        case 'Your model name'
            Mdl = trainYourModel(XTrain);
    ```

2. **Add the detection function call**: Go to the folder `tsad_platform > src > detection` and open the file `detectWithCML.m` (`detectWithS.m` for statistical models). Add your model name within the main *switch* statement, then add your detection function call. Make sure to return anomaly scores and store them in the `anomalyScores` vairable:

    ```matlab
    switch options.model
        % Add your model here
        case 'Your model'
            anomalyScores = detectWithYourModel(Mdl, XTest);
            % If your model doesn't work with overlapping subsequences or you defined your own data preparation functions, add a return statement here. 
            % return;
    ```

#### (Optional) Data preparation

To prepare the data your own way, you can add your model to the main *switch* statements in the following files within the `tsad_platform > src > data` folder:

* **For deep neural networks**: `prepareDataTrain_DNN.m`, `prepareDataTest_DNN.m`.
* **For classic machine learning methods**: `prepareDataTrain_CML.m`, `prepareDataTest_CML.m`.
* **For statistical methods**: `prepareDataTrain_S.m`, `prepareDataTest_S.m`.
=======
    * `Deep Learning Toolbox`
3. The main `tsad_platform` folder and the `src` and `config` subfolders must be added to the MATLAB path.
4. Run the `TSADPlatform.mlapp` to start the platform or open it in `App Designer` for further development.

---

## How to use the platform

<img src="media/TSADPlatform_Quick_Demo.gif" alt="Quick Demo Mode 1" title="Quick Demo Mode 1" width=800/>

### Overview

1. Import, preprocess and transfrom a dataset on the `Dataset Preparation` panel.
2. Configure, train/optimize and test models on the `Training and Detection` panel.
3. Train and test a smart model-selection mechanism (`"Dynamic Switch"`) on the `Dynamic Switch` panel.

### Dataset preparation

For all following steps, got to the `Dataset Preparation panel`.

#### Load a dataset

To load a dataset proceed as follows:

1. Press `Browse` button or enter a path directly.
2. Select dataset from the drop-down menu.
3. Press `Load Data`.

A dataset is a folder with two subfolders called `train` and `test`. At least on of the folders must be available.
The folders contain an arbitrary amount of `CSV` files, which must be formatted as such:

| timestamp | value1 | value2 | is_anomaly |
|-----------|--------|--------|------------|
| 1         | 5      | 2      | 0          |
| 2         | 234    | 2      | 1          |
| 3         | 5      | 2      | 0          |

**NOTE** The column names don't need to be as shown here. The first column is always considered to be the timestamps and the last column is for the anomaly indicators (0=normal, 1=anomaly).



#### Preprocess the dataset

Following data preparation options are available:

* Select a `preprocessing method` from the dropdown menu.
* Select an `augmentation mode` and configure it.
* Configure the splitting of the `test set for thresholding` (used for computing supervised static thresholds).
* Configure the splitting of the test set for the `dynamic switch`.

### Loading and saving models 

For all following steps, got to the `Training and Detection panel`.

#### Load new models

* Press `Load Default` to load a default configuration of all implemented models.
* Press `Load Manually` to select and configure the models by hand.
* Press `Load from File` to load configured models from a file (see [Save configuration](#save-configuration)).

#### Save configuration

* Press `Export Config` to save a models configuration file, which can be loaded again.

#### Import models

* Press `Import Models` to load previously trained and stored models (see [Export models](#export-models)).

#### Export models

* Press `Export Models` to save trained models.

### Reconfiguring models

* Right-click a single model and select `View/Update Model Parameters` for reconfiguration.

### Deleting models

* To delete models, select and right-click models and press `Delete` or press `Clear All` at the bottom of the list.

### Train/optimize models

1. Configure the training process by enabling/disabling `Optimization` and `Training Plots`.
2. Press `Fit All` or `Fit Selection` to train/optimize all or just the selected models.
3. If you enabled optimization, you can further configure the `number of iterations`, the `metric` and the `threshold` to optimize in a popup window. Additionally you can open the `optimization config` file and reconfigure the parameters to be optimized.

### Run detection

1. Select which files to run the test on.
2. Select which models to run the test on.
3. Choose whether to `Get Computation Time` to compute the average computation time for a single window
4. Choose whether to `Update Thresholds Only`. This doesn't run the entire detection again, but `only applies the selected threshold to all previously selected models and files`.
5. Choose wheter to run the `Online Simulation` using Simulink (**CURRENTLY NOT IMPLEMENTED**).
6. Press `Run Detection` to start the anomaly detection on the test data.

### Evaluate results

You can:
* See plots and metrics to evaluate the detection performance of a single model.
* See tables of average scores and scores for the currently selected file for all models.
* See a plot of computation times and select the displayed metrics.
* Right-click a model and select `Show Detection` to display plots for that model.
* Select another threshold. This updates the applied threshold **only for the currently displayed model** in the plots. To apply the new threshold to all models, press `Run Detection` again (and configure it to be done for all models/files).

### Auto run

* This trains and tests all configured models on the selected dataset.

To start the `Auto Run`, proceed as follows:

1. Select a dataset and configure the dataset preparation/preprocessing.
2. Select/load models.
3. Press `Train & Test All` -> A popup window is shown
4. Select a folder to store the results (stored in `CSV` files).
5. If you previously checked the `optimize` checkbox, you can configure the optimization.
6. Pres `Start Auto Run`.

### Dynamic switch: A model selection mechanism

The dynamic switch is a model selection mechanism. It learns to select the optimal model for anomaly detection according to the current statistical time series features. It currently only works on separate files and cannot switch the applied model within a single time series.

#### Requirements

* A dataset with multiple test files

#### Train and test dynamic switch

1. Check the `Split Dataset for Dynamic Switch` checkbox on the dataset preparation panel.
2. Select, train and test models on all files.
3. Click `Train` on the dynamic switch panel to train the model selection mechanism.
4. Click `Evaluate` to test the dynamic switch.
5. Evaluate the results.

## Extending the platform

To add a new model, you must [create a model class](#create-model-class) and [create a model config](#create-model-config).
You can also [enable optimization](#enable-optimization) for your model.

### Create Model class

1. Navigate to the folder: `models/+models`.
2. Copy the `TSAD__MODEL_TEMPLATE` file and rename it to `TSAD_<your model name>`.
3. Open the file and rename the class as above
4. You **must** implement the `prepareDataTest` and `predict` functions.
5. You **can** implement the `prepareDataTrain` and `fit` functions if your model needs a training step.
6. You **can** implement the `getNetwork` function if you want the platform to be able to display the layers of your model.

### Create Model config

You **must** add your model to the `TSADConfig_models.json` file (within the `config` folder), otherwise the platform will not recognize it.

To do so simply add the following template to the file and configure it to your needs:

```json
"your model's class name": {
        "parameters": {
            "static": {
                "name": "model name used for displaying",
                "learningType": "learning type of your model. one of 'unsupervised', 'semi_supervised', 'supervised'",
                "outputType": "output type of your model. one of 'anomaly_scores', 'labels'",
                "className": "your model's class name"
            },
            "configurable": {
                "your custom parameter": {
                    "type": "one of 'real', 'integer',  'categorical'",
                    "value": ["array of possible values for categorical parameters (can be numeric array or string array). Upper and lower limit for real and integer parameters (numeric 2-element array)"],
                    "initialValue": "Default value for parameter, must be within defined 'value' range (see above)"
                }
            }
        }
    }
```

* All `static` parameters shown above are **mandatory**.
* You **can** add as many `configurable` parameters as you wish. These must all follow the shown template.

### Enable optimization

To enable optimization for your model, add it to the `TSADConfig_optimization.json` (within the `config` folder):

```json
"your model's class name": ["parameter1", "parameter2"]
```

Simply list the parameters you want to be optimizable by the platform.



## Known limitations, issues and possible future upgrades (Mostly relevant for developers)

* Simulink online detection simulation is not up to date and currently deactivated

---

## Appendix

### Thresholds

The thresholds are set as follows:

| Threshold | Description |
|-|-|
| best_..._f1_score | Calculates the best possible F1 score (either point-wise, event-wise, point-adjusted or composite). |
| top_k | Set threshold to detect the correct amount of anomalies as given by the labels. |
| gauss | Mean + 3 * Standard deviation of the anomaly scores for the testing data. |
| max_train | The maximum value of the anomaly scores for the training data. |
| dynamic | Unsupervised dynamic threshold. See [Dynamic threshold](#dynamic-threshold). |

### Scoring functions

The `scoring function` can be used to further transform the anomaly scores produced by a Model. This can include aggregation of channel-wise scores or further transformation.
The anomaly scores produced by a model must be as such: either 1 value for every timestamp or one value for every channel of the data at every timestamp.

Following scoring functions are currently available:

| Scoring Function | Description |
|-|-|
| none | Directly uses the scores produced by the model. If they are seperate for every channel of the data, the Root Mean Square is taken across channels |
| ewma / ewma_channlwise | (For non-channelwise version, the Root Mean Square is taken across the channels of the anomaly scores, then...) The Exponentially Weighted Moving Average is computed (seperately for every channel for the channelwise version). |
| normalized_errors / normalized_errors_channelwise | **Only for semi-supervised DNNs on multivariate data**: The mean training anomaly score gets subtracted from the channel-wise anomaly scores. Afterwards, the Root Mean Square is taken across channels (only for non-channelwise version). |
| multivariate_gauss | **Only for semi-supervised DNNs**: A multivariate gaussian distribution is fitted to the trainig anomaly scores and used to compute -log(1 - cdf) of the anomaly scores. **The max supported number of channels in the dataset is 25** |
| univariate_gauss / univariate_gauss_channelwise | **Only for semi-supervised DNNs**: The channel-wise mean and standard deviation of the training anomaly score distribution is used to compute -log(1 - cdf) of the channel-wise anomaly scores. Afterwards, the channel-wise anomaly scores are added (only for non-channelwise version). |

**NOTE** For the channel-wise scoring functions (labeled "channel-wise"), the output consits of anomaly scores for every channel of the dataset.
In this case, a common threshold gets applied across all channels during testing. A single observation only needs to be labeled as anomalous in one of the channels to be considered an anomaly.

#### Reconstruciton error type

The `reconstruction error type` defines how the errors are computed **for reconstructive deep-learning models**. Since there are multiple predicted values for every observation of the time series, a single value must be computed. Following methods to do this are available:

| Reconstruction Error Type | Description |
|-|-|
| pointwise | Calulates the point-wise absolute errors for each subsequence and then calculates the median error for each time step. This is done for each channel separately. |
| subsequencewise | Calulates the Root Mean Squared Errors (RMSE) for each subsequence and then calculates the mean for each time step. This is done for each channel separately. |
>>>>>>> 4606f0a840124cab970ece83ecf2ad15e8d6c0c1
