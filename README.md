# TSAD Platform Manual

A platform for time series anomaly detection.

## Getting Started

1. Download the TSAD Platform repository from `https://github.com/AdrianWolf1999/tsad_platform.git`.
2. Install MATLAB Toolboxes:
    * `Simulink`
    * `Signal Processing Toolbox`
    * `DSP System Toolbox`
    * `Image Processing Toolbox`
    * `Econometrics Toolbox`
    * `Predictive Maintenance Toolbox`
    * `Statistics and Machine Learning Toolbox`
    * `Deep Learning Toolbox`
3. Add the `tsad_platform` folder (the main folder of this repository) to the MATLAB path (without subfolders).
4. Add the `src` folder within the `tsad_platform` folder to the MATLAB path (with subfolders).
5. Add the `config` folder within the `tsad_platform` folder to the MATLAB path.
6. Open the `tsad_platform` folder with MATLAB.
7. Open the `TSADPlatform.mlapp` file with MATLAB App Designer (double click on it).
8. Click the `Run` icon on the top of the App Designer window to start the platform.

---

## Overview

On the top of the platform you will find the `Settings` menu and six different `Panels`:

<img src="media/final_panels.png" alt="Panels" title="Panels" width=600/>

In the [Settings](#settings) you can control the following things:

* [Threshold Selection](#threshold-selection): What thresholds to enable within the platform.
* [Dynamic Threshold](#dynamic-threshold): The default configuration for the dynamic threshold.
* [Enable/Disable Parallel Mode](#parallel-mode): Whether to train parallel.

The platform offers **two different modes** to test time series anomaly detection methods. The workflows are as such:

**MODE 1: Manually train and test models:**

1. Import and process a dataset on the [Dataset Preparation](#dataset-preparation) panel.
2. Configure, train and optimize models on the [Training](#training-and-optimization) panel.
3. Test the models on the [Detection](#detection) and [Simulink Detection](#simulink-detection) panels.
4. (optional) Configure, train and test the dynamic switch mechanism on the [Dynamic Switch](#dynamic-switch) panel (only possible for datasets with multiple files for testing).

**MODE 2: Automatically train and test models on single- or multi-entity datasets:**

1. Configure models on the [Training](#training-and-optimization) panel.
2. Configure and start the auto-run function on the [Auto Run](#auto-run) panel.

Further details can be found below.

---

## Settings

You can find the platform settings in the top left corner.

### Threshold selection

The selection of thresholds controls which thresholds are calculated by the platform.
Only the selected ones are used during the auto-evaluation on the `Auto Run` panel (Mode 2).

To select thresholds, proceed as follows:

1. Click `Settings > Threshold Selection` to open the threshold selection window.

    <img src="media/final_threshold_selection.png" alt="Threshold selection settings" title="Threshold selection settings" width=260/>

2. Select the desired thresholds.
3. Click `Save` to save the new selection.

The thresholds are used to convert anomaly scores produced by an anomaly detection model/algorithm into binary labels and are set as follows:

| Threshold | Description |
|-|-|
| Best F1 Score thresholds | Calculates the best possible F1 score on either the anomalous validation set or the test set directly (depending on wether a anomalous validation set is used or not) |
| topK | Set threshold to detect the correct amount of anomalies as given by the labels. This is done either on the anomalous validation set or the test set |
| Mean + 4 * Std | Mean + 4 * Std of the anomaly scores of either the anomalous validation set or the test set. If the anomaly score output of a model (after a optional scoring function is applied) still has multiple channels, the average mean and average standard deviation across channels are used instead. |
| Mean + 4 * Std (Train) | Mean + 4 * Std of the anomaly scores of the training set. If the anomaly score output of a model (after a optional scoring function is applied) still has multiple channels, the average mean and average standard deviation across channels are used instead. |
| Max Train Anomaly Score | The maximum value of the anomaly score when running the detection on the training data |
| 0.5 | 0.5 |
| Dynamic | Unsupervised dynamic threshold. See [Dynamic threshold](#dynamic-threshold) |
| Custom | Can be implemented individually for a specific model. If none is specified, its value is set to 0.5 (See [Add custom threshold](#optional-custom-threshold)) |

### Dynamic threshold

These options control the default parameters for the dynmaic threshold, which can also be configured on the `Detection` panel. To update their values, proceed as follows:

1. Click `Settings > Dynamic Threshold` to open the dynamic threshold settings window.

    <img src="media/final_settings_dynamic_threshold.png" alt="Dynamic threshold settings" title="Dynamic threshold settings" width=200/>

2. Configure the parameters (1).
3. Click `Save` (2) to save the new parameters.

### Enable/Disable Parallel Mode

To enable/disable parallel training, click on `Settings` and then `Enable Parallel Mode` (or `Disable Parallel Mode` if it's already active).

---

## Dataset preparation

A dataset can be loaded and processed on the `Dataset Preparation` panel:

<img src="media/final_dataset_panel.png" alt="Data panel" title="Data panel" width=900/>

### Loading a dataset (1)
1. Click `Browse` to select a folder from your computer or enter a path manually.
2. Click `Load Data` to import the selected dataset.


The **format** of a dataset must be as such:

* It contains at least one of the following folders: a `train` folder containing training data and a `test` folder containing testing data.
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

### Preprocessing and splitting the dataset (2)

#### Preprocessing method selection

Three `Preprocessing Methods` can be selected. These **don't** apply to the [Auto Run](#auto-run) functions, but to everything else:

* **Rescale [0, 1]**: Set maximum = 1 and minimum = 0.
* **Standardize**: Set mean = 0 and standard deviation = 1.
* **Raw Data**: Unprocessed data.


**NOTE** The data in the `test` folder gets processed with the same parameters as for the `train` data (with the exception if no train data is used). All channels of multivariate datasets are preprocessed independently.

#### Data augmentation

You can choose to further transform your data in various ways by selecting an `Augmentation Mode`.

#### Dataset splitting

##### Data preparation for Dynamic Switch

*INFO: If the dataset  includes multiple files for testing, you can split the test set to use some of the files for testing the [Dynamic Switch](#dynamic-switch) mechanism.*

To enable this, do the following:

1. Check the `Split Test Set for Dynamic Switch` checkbox.
2. Enter a value for the `Ratio` to determine its size.

##### Use of anomalous validation set

*INFO: An anomalous validation set can be used to calculate the static thresholds prior to testing the models. In order to do this, the test set will be split to obtain an anomalous validation set and a test set. If no anomalous validation set is used, or it doesn't contain any anomalies, most of the static thresholds will be calculated last during testing.*

To enable the anomalous validation set, do the following:

1. Check the `Use anomalous Validation Set` checkbox.
2. Enter a value for the `Ratio` to determine its size.

---

## Training and optimization

On the `Training` panel you can train or optimize a selection of models:

<img src="media/final_training_panel.png" alt="Training panel" title="Training panel" width=900/>

To do so, proceed as follows:

### Load/configure models (1)

There are **three** ways to load a configuration of models (These are not trained yet, it's only the configuration that gets loaded):

* Click `Quick Load all Models` to load a default configuration of all implemented models. 
* Click `Add Model Manually` to configure models by hand. This opens a **new window**, allowing you to select a model and configure its parameters. Once configured, click `Add to Model Selection` to add the selected model to the list of models.
* You can click `Export Config` to store a configuration file for the configured models on your computer.
This allows you to load a previous configuration of models at another time using the `Load from File` button.
* To show the hyperparameters of a model, select it in the list, right-click and select `Show Model Parameters`. This wil show all parameters of the selected model on the right side of the window (3).

### Train and/or optimize models (2)

#### Train models

To train models, do the following:

* Click `Train All` to train all configured models.
* Click `Train Selection` to train all manually selected models (Click on models to select them).

**NOTE** All models **must** be trained to make them available on the [Detection](#detection) and [Simulink Detection](#simulink-detection) panels. If they don't require prior training, this step is still required (In this case it only adds the model to the list of trained models on the `Detection` panel)

Before training, you can configure the training process as follows:
* Check the `Training Plots` checkbox to enable graphical training plots (Currently only for deep-learning models).

#### Optimize models

To optimize models, do the following:

1. Select the models within the list and click `Optimize Selection` or just click `Optimize All` to open a **new window**.

    <img src="media/final_optimization_window.png" alt="Optimization window" title="Optimization window" width=200/>

2. (optional) Click `Open Optimization Config` to edit the optimization config `.json` file. This file defines the ranges of hyperparameters to optimize. Just look at examples in the file on how to edit this file.
3. Configure the optimization process by selecting a `Score`, a `Threshold` and check the `Training Plots` checkbox if you want to show plots for deep-learning models.
4. Click the `Run Optimization` button to optimize all models.
5. Once it's done, the optimized models will appear on the [Detection](#detection) and [Simulink Detection](#simulink-detection) panels.

---

## Detection

The anomaly detection using the models trained earlier (see [Training and optimization](#training-and-optimization)) is available on the `Detection` panel:

<img src="media/final_detection_panel.png" alt="Detection panel" title="Detection panel" width=900/>

### Running a detection

#### List of trained Models (1)

* All trained models appear in the **list of trained models**. If it's empty, no detection can be run.
* These models are **ranked** according to their detection performance. The metric used for ranking can be manually selected from the dropdown menu at the bottom of the list.
* Models can be **exported** by clicking the `Export trained Models` button. These trained models can be **loaded** directly into the platform via the `Import trained Models` button.

#### Data and threshold selection (2)
1. Select a file from the `Select faulty Data` dropdown menu.
2. Select a threshold from the `Threshold` dropdown menu. If you select the **dynamic** threshold, you can additionally configure its parameters.

#### Run detection (3)
Select models from the **list of trained models** and click `Run for selected Models` or `Run for all Models` to start the detection process.
#### Observe results (4)

Once the detection is finished, the following results are are displayed in the windows below:
* **Plots** of the anomaly scores and detected anoamlies for the last model the detection was run for.
* A **Table** storing all scores for all models and the computational time of deep-learning models (time to make predictions for one subsequence)
* A **Computation time** plot showing the  average computational time of the models for a single subsequence on the x-axis and the obtained scores on the y-axis.
Using the `Metric Selection` button, one can choose what metrics should be displayed within this plot.

You can select another threshold or reconfigure the dynamic threshold. This will update the scores for the currently shown model in the **Plots** section (4). To run the detection again for all models using the new threshold (and/or new data file if another one was selected), click the `Run for all Models` button (3) again.

**NOTE** If you want to observe the detection of another model, just right-click on it in the list of trained models (1) and select `Show Detection`. If you already ran the detection for that model, the scores and plots will be displayed directly. Otherwise run the detection for the selected model again.

---

## Simulink Detection

**NOTE The simulink detection isn't fully functional at this point**

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

### Requirements

The usage of the dynamic switch mechanism **requires** the following things:

* **Correct dataset**: A dataset with **multiple anomalous files** for testing. 
* The **Split Test Set for Dynamic Switch** checkbox on the [Preprocessing](#preprocessing-and-splitting-the-dataset) panel must be checked. The testing data for the dynamic switch can be observed in section (3).
* **Trained models**: Either configure and train models on the [Training](#training-and-optimization) panel or load trained models on the [Detection](#detection) panel.

### Run dynamic switch

To **train and test the dynamic switch**, proceed as follows:

#### Configure, train and test dynamic switch (1)

1. Select a metric from the `Metric` dropdown menu. This will be used to compare the models during auto-labeling.
2. Select a threshold from the `Threshold` dropdown menu. This threshold will be used for all models.
3. Click the `Auto-label Dataset` button. This runs the detection for all models on all files of the test dataset (without the files for testing the dynamic switch).
4. Click the `Train Classifier` button to train the deep calssification network. It learns to connect time series features with the correct labels determined in step 3.
5. Click the `Run Evaluations` button to test the dynamic switch.

#### Observe results (2), (4)
All results including the scores obtained by all individual models will be displayed in the table (4). You can see the best models for the training data of the dynamic switch and the predictions it made for the testing data (2).

---

## Auto run

Automatically train and test models on single- or multi-entity datasets on the `Auto Run` panel:

<img src="media/final_auto_run_panel.png" alt="Auto Run panel" title="Auto Run panel" width=900/>

### Running automated training and detection

To use this function, proceed as follows:

#### Prequisites

1. Select the thresholds in the [Settings](#settings) of the platform
2. (optional) If the dynamic threshold was selected, configure it in the [Settings](#settings).
3. Configure/load models on the [Training](#training-and-optimization) panel (don't train them yet).

#### Configure and start auto run (1)

1. Select a dataset on the [Auto Run](#auto-run) panel by clicking the `Browse` button.
2. Configure the data preparation similar to Mode 1.
3. Click `Run Evaluation` to start the process. You can observe more details about the current state in the MATLAB command window.

#### Observe results (2)
Once the evaluation is done, all results are stored in a folder called *Auto_Run_Results* within the current MATLAB folder (This folder includes subfolders for the results for each selected threshold). The average scores for each model for the first threshold are displayed in the table (2).

---

## Extending the platform

### The "modelOptions" struct

The platform recognizes a model/algorithm by its configuration. This configuration is stored in a struct with a single key called **`modelOptions`**.
The value of this key contains all relevant information. When adding a configured model to one of the lists of models on the [Training](#training-and-optimization) panel, the **ItemsData** property of that list (which is a struct array in this platform) gets extended by such a struct.

The following figure shows an example for the fully-connected autoencoder (FC AE):

```json
"modelOptions": {
    "type": "deep-learning",
    "name": "FC AE",
    "modelType": "reconstructive",
    "dataType": 1,
    "requiresPriorTraining": true,
    "calcThresholdsOn": "anomalous-validation-data",
    "isMultivariate": false,
    "outputsLabels": false,
    "hyperparameters": {
        "neurons": {
            "value": 32,
            "type": "integer"
        },
        "windowSize": {
            "value": 100,
            "type": "integer"
        },
        "stepSize": {
            "value": 1,
            "type": "integer"
        },
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
        },
            "scoringFunction": {
            "value": "aggregated-errors",
            "type": "categorical"
        }
    }
}
```

Fields of the **modelOptions** struct (and if they're required or not):

#### type
**- mandatory -**
The type of the model/algorithm. Must be one of: `"deep-learning"`, `"classic-machine-learning"`, `"statistics"`

#### name
**- mandatory -**
The unique name of the model. This is used by the platform to recognize the model. It should only contain **letters** and the following characters: `-` `(` `)`.

#### modelType
**- optional -**
This field is only required for deep-learning models using the standard deep-learning functions probided by the platform. Its value must be one of: `"predictive"`, `"reconstructive"`. It indicates whether the model produces prediction or reconstruction errors.

#### dataType
**- optional -**
This field is only required if your model uses the data preparation function provided by the platform (and for classic ML and Statistical models the [useSubsequences](#usesubsequences) field is set to true).
Its value must be one of: `1`, `2`, `3`. The number controls the shape of the data. The data is always split into subsequences of equal length using a sliding window. The window-size (and step-size for training if your model requires prior training) must be defined in the [hyperparameters](#hyperparameters) field (see below). Look at the file `config > tsad_platform_config_all.json` for reference.
For the three different numbers, the data will be shaped as such:
| Data type | Univariate model | Multivariate model |
|-|-|-|
| **1** | `1 x D` cell array with `D` being the number of channels. For each channel a separate model of the same type will be trained. Each cell contains a `N x w` matrix with `w` being the window-size and `N` being the number of observations.| `1 x 1` cell array containing a `N x (w * d)` matrix with `N` being the number of observations, `w` the window size and `d` the number of channels. |
| **2** | `1 x D` cell array with `D` being the number of channels. For each channel a separate model of the same type will be trained. Each cell contains a `N x 1` cell array with `N` being the number of observations. Each cell is a matrix of size `1 x w` with `w` being the window-size. **NOTE: For predictive dl models, the YTrain data is no cell array** | `1 x 1` cell array containing a `N x 1` cell array with `N` being the number of observations. Each cell contains a matrix of size `d x w` with `d` being the number of channels and `w` being the window size. |
| **3** | `1 x D` cell array with `D` being the number of channels. For each channel a separate model of the same type will be trained. Each cell contains a `N x 1` cell array with `N` being the number of observations. Each cell is a matrix of size `w x 1` with `w` being the window-size. **NOTE: For predictive dl models, the YTrain data is a cell array, unlike for dataType 2** | `1 x 1` cell array containing a `N x 1` cell array with `N` being the number of observations. Each cell contains a matrix of size `w x d` with `d` being the number of channels and `w` being the window size. |

#### requiresPriorTraining
**- mandatory -**
If this is set to **false**, the model is trained on the data from the **train** folder. If it is set to **true**, the model doesn't get trained on data from the train folder prior to testing.
**NOTE** If this field is set to true, you can also set the [calcThresholdsOn](#calcthresholdson) field below.

#### calcThresholdsOn
**- optional -**
This field is optional and only has an effect if the [requiresPriorTraining]() field is set to true.
Its value can be either `"anomalous-validation-data"` or `"training-data"`. This determines what dataset to use to calculate the static threholds. If the selected option is `"anoamlous-validation-data"`, but no anomalous validation data is available, the thresholds will be calculated during testing. If you don't specify this field or set its value to anything except the two options, the thresholds are always set during testing and not during training.

#### isMultivariate
**- mandatory -**
Its value can be `true` or `false` according to the dimensionality of your model. See field [dataType](#datatype) above for more information on the effect on the data preparation. **If it is set to `false` but the loaded dataset is multivariate, a separate model will be trained for each channel of the dataset.**

#### outputsLabels
**- mandatory -**
If your anomaly detection method doesn't output anomaly scores, but binary labes for each observation of the time series, set this field to `true` to bypass all thresholding methods. Otherwise it must be set to `false`.

#### useSubsequences
**- optional -**
This field is only required for **non** deep-learning models which use the standard data preparation functions provided by the platform.
If it is set to `true`, the dataset will be split into overlapping subsequences (See field [dataType](#datatype) above), otherwise the data is used directly.

#### hyperparameters
**- optional -**
This field can contain all configurable hyperparameters for your model/algorithm. If you want to add a hyperparameter, specify its name as a new key within this field. It must contain two keys: **value** and **type**. The type is only required for the optimization algorithm of the platform. It must be one of: `"integer"`, `"real"`, `"categorical"`. Look at the example [above](#the-modeloptions-struct) for reference.

You can then use these hyperparameters in the data preparation, model training and detection functions to modify your model.
See Chapter [adding models](#adding-models) for some examples.

One hyperparamter that must be mentioned is the `scoringFunction`:
It is optional for all models. Its value changes how the anomaly scores are defined. If your model defines its own scoring function, don't add this field to the hyperparameters.

| Value | Description |
|-|-|
| aggregated-errors | The mean training reconstruction/prediction error gets subtracted from the channel-wise errors (Only for multivariate datasets). Afterwards, the root-mean-square is taken across channels. For univariate datasets, the errors are used directly. |
| channelwise-errors | The mean training reconstruction error gets subtracted from the channel-wise errors (Only for multivariate datasets). Nothing else is done. For univariate datasets, this is the same as the aggregated-errors scoring function. |
| gauss | A multivariate gaussian distribution is fitted to the trainig errors and used to compute -log(1 - cdf) to get the anomaly scores. **The max supported number of channels in the dataset is 25** |
| aggregated-gauss | The channelwise mean and standard deviation of the training error distribution is used to compute -log(1 - cdf("channelwise errors")) of the channel-wise errors to get channel-wise anomaly scores. Afterwards, the channelwise anomaly scores are added. |
| channelwise-gauss | The channelwise mean and standard deviation of the training error distribution is used to compute -log(1 - cdf("channelwise errors")) of the channel-wise errors to get channel-wise anomaly scores. |

For the channel-wise scores, a common threshold gets applied accross all channels during testing. A single observation only needs to be labeled as anomalous in one of the channels to be considered an anomaly.

### Configuration file

The file `tsad_platform > config > tsad_platform_config_all.json` contains the JSON representation of a MATLAB struct with a single field called models. Its value is a struct array with individual `modelOptions` structs, as presented before. This file is used for loading the default configuration of models on the [Training](#training-and-optimization) panel using the `Add All` buttons:

```json
{
    "models": [
        {
            "modelOptions": {

            }
        },
        {
            "modelOptions": {

            }

        }
    ]
}
```

### Adding models

To add more models to the platform (deep-learning, classic machine learning and statistical), proceed as follows:

1. Define the `modelOptions` struct mentioned before. You can create a `.json` file (use the `tsad_platform_config_all.json` file as reference or add your model to this file directly) as mentioned above to be able to load your model into the platform. Alternativeley, edit the `ModelSelection.mlapp` file within the `src > pupup_apps` folder. Use other examples in those files as a guideline on how to add your model.
2. Add the training and detection function calls to the source code of the platform. See [below](#add-deep-learning-anomaly-detection-models) for a detailed explanation.
3. (optional) Enable optimization for your model: [Enable optimization](#optional-enable-optimization-for-your-model).
4. (optional) If you require the data to be transformed in another way as provided by the platform, see [below](#optional-data-preparation) for more information.
5. (optional) Add a custom threshold: [Add custom threshold](#optional-custom-threshold).

**NOTE** The process for deep-learning and other models (E.g. classic machine-learning (and statistical) models) slightly differs.
See [Add deep-learning anomaly detection models](#add-deep-learning-anomaly-detection-models) and [Add other models](#add-other models) for more information.

#### Add deep-learning anomaly detection models

It's recommended to implement the deep-learning models using functions from MATLAB's Deep Learning Toolbox and using the data preparation methods provided by the platform (this data preparation mode is enabled by default and nothing needs to be done other than adding the `dataType` field to the `modelOptions` struct (see [above](#the-modeloptions-struct))). To add a new DL model, follow these steps:

1. **Define the layers**: Go to the folder `tsad_platform > src > models_and_training > deep_learning` and open the file `getLayers.m`. Add a new option in the main *switch* statement for the name of your model:

    ```matlab
    switch modelOptions.name
        % Add your model here
        case 'Your model name'
            % Get hyperparameters from options
            neurons = modelOptions.hyperparameters.neurons.value;

            % Define layers
            layers = [featureInputLayer(numFeatures)
                fullyConnectedLayer(neurons)
                reluLayer()
                fullyConnectedLayer(numResponses)
                regressionLayer()];
            
            layers = layerGraph(layers);
    ```

2. **Define training options**: Go to the folder `tsad_platform > src > models_and_training > deep_learning` and open the file `getTrainOptions.m`. Add a new option in the main *switch* statement for the name of your model. If you don't add your model here, default training options will be used. Look at the example for more information:

    ```matlab
    switch modelOptions.name
     % Add your model here
        case 'Your model name'
            % Define different options depending on whether validation data is available
            if modelOptions.hyperparameters.ratioTrainVal.value == 0
                trainOptions = trainingOptions('adam', ...
                    'Plots', plots, ...
                    'MaxEpochs', modelOptions.hyperparameters.epochs.value, ...
                    'MiniBatchSize', modelOptions.hyperparameters.minibatchSize.value, ...
                    'GradientThreshold', 1, ...
                    'InitialLearnRate', modelOptions.hyperparameters.learningRate.value, ...
                    'Shuffle', 'every-epoch',...
                    'ExecutionEnvironment', device);
            else
                trainOptions = trainingOptions('adam', ...
                    'Plots', plots, ...
                    'MaxEpochs', modelOptions.hyperparameters.epochs.value, ...
                    'MiniBatchSize', modelOptions.hyperparameters.minibatchSize.value, ...
                    'GradientThreshold', 1, ...
                    'InitialLearnRate', modelOptions.hyperparameters.learningRate.value, ...
                    'Shuffle', 'every-epoch', ...
                    'ExecutionEnvironment', device, ...
                    'ValidationData', {XVal, YVal}, ...
                    'ValidationFrequency', floor(numWindows / (3 * modelOptions.hyperparameters.minibatchSize.value)));
            end
    ```

**Optional** You can also add all the training and detection function call for your network manually. In that case you don't have to add your model to the files mentioned above. To do so proceed as follows:

1. **Add the training function call for you network**: Go to the folder `tsad_platform > src > models_and_training > deep_learning` and open the file `train_DL.m`. Add your model name within the main *switch* statement, then call your training function and save the trained network in the `Mdl` vairable. The `MdlInfo` variable is optional and can be left empty:

    ```matlab
    switch modelOptions.name
        % Add your model here
        case 'Your model name'
            Mdl = yourTrainFunction(XTrain, YTrain, XVal, YVal);
            MdlInfo = [];
    ```

2. **Add the detection call for your network**: Go to the folder `tsad_platform > src > detection` and open the file `detectWith_DL.m`. Add your model name within the main *switch* statement, then add your detection function call. Make sure to return anomaly scores (`anomalyScores`) and optionally the computational time (`compTime`, Should be for a single subsequence) of your model:

    ```matlab
    switch modelOptions.name
        % Add your model here
        case 'Your model name'
            anomalyScores = detectWithYourModel(Mdl, XTest);

            % The compTime variable should contain the computation time for a single subsequence. Set it to NaN if you don't need it to be computed
            compTime = NaN;
    ```

#### Add other models

The process for adding models other than deep-learning models is as follows:

1. **Add the training function call**: This step is only required if your model requires prior training (if so, you **MUST** set the `requiresPriorTraining` field within the `modelOptions` struct to **true**, otherwise your model will never be trained).
 Go to the folder `tsad_platform > src > models_and_training > other` and open the file `train_Other.m`. To train your model, add your model name to the main *switch* statement, then call your training function and save the trained model in the `Mdl` variable:

    ```matlab
    switch modelOptions.name
        % Add your model here
        case 'Your model name'
            Mdl = trainYourModel(XTrain);
    ```

2. **Add the detection function call**: Go to the folder `tsad_platform > src > detection` and open the file `detectWith_Other.m`. Add your model name within the main *switch* statement, then add your detection function call. Make sure to return anomaly scores (`anomalyScores`) and optionally the computational time (`compTime`, Should be for a single subsequence) of your model:

    ```matlab
    switch modelOptions.name
        % Add your model here
        case 'Your model name'
            anomalyScores = detectWithYourModel(Mdl, XTest);

            % The compTime variable should contain the computation time for a single subsequence. Set it to NaN if you don't need it to be computed
            compTime = NaN;
    ```

#### (Optional) Enable optimization for your model

To enable the built-in optimization for your model, open the file `tsad_platform > config > tsad_platform_config_optimization.json`.
Add your model name as a new key. Then name the hyperparameters you want to optimize as new keys within this new field. Only hyperparameters which are defined in the `hyperparameters` field of the `modelOptions` struct of your model can be optimized. See the following example for the `FC AE` for reference:

```json
{
    "FC AE": {
        "neurons": {
            "value": [4, 128],
            "type": "integer"
        },
        "windowSize": {
            "value": [10, 120],
            "type": "integer"
        }
    }
}
```

The `value` must be an array with two values being the lower and upper bounds of the hyperparameter.

For `categorical` hyperparameters, the value is an array of strings containing the possible values.

The `type` must be one of `"integer"`, `"real"`, `"categorical"`.

#### (Optional) Data preparation

To prepare the data your own way, you can add your model name to the main *switch* statements in the following files within the `tsad_platform > src > data_preparation` folder:

* **For deep neural networks**: `prepareDataTrain_DNN.m`, `prepareDataTest_DNN.m`.
* **For classic machine learning methods**: `prepareDataTrain_CML.m`, `prepareDataTest_CML.m`.
* **For statistical methods**: `prepareDataTrain_S.m`, `prepareDataTest_S.m`.

**NOTE** If you do so, you must also call your own training and prediction functions as described above. Otherwise it might lead to errors as the platform doesn't recognize your data.

#### (Optional) Custom Threshold

To add a custom static threshold, open the file `tsad_platform > src > thresholds > calcStaticThreshold.m`. In line `50` add your model name and store your custom threshold in the `thr` variable.

```matlab
case "custom"
        switch modelName
            case "Your model name"
                % Add your custom threshold here
            otherwise
                thr = 0.5;
        end
```

## Known limitations, issues and possible future upgrades (Mostly relevant for developers)

1. The network architecture of the `TCN AE` requires the sequence length/window size to be divisible by 4. This might be fixed in the future.
2. Optimize the threshold calcucation (in file computeBestFScoreThreshold.m). It can be slow, especially for larger datasets, as it checks the F-Score for every single unique anomaly score value of the used time series (either anomalous validation set or test set). An upper bound of threshold values to check could be implemented to counter this issue.
3. The simulink detection doesn't implement the different data preparation methods and scoring functions for the different deep-learning models, which makes it non-functional in many cases. The functionality of using a univariate model on multivariate datasets, where a separate model is trained for each channel of the dataset, must be implemented aswell. This feature already exists in the normal detection mode (It can be enabled by setting the `isMultivariate` field to `false` for a model).
4. (Maybe irrelevant?) The step-size for the detection process is always set to 1 and can't be adjusted.
5. (Maybe irrelevant?) The forecast horizon for DL models is always set to 1 and can't be adjusted.
6. Network architectures of DL models could be checked in more detail or updated.
7. Check on startup of the platform whether all required folders are on the matlab path to avoid errors later on.
8. Add more models (The platform lacks for example in statistical models. Classic ML oder DL models like a Convolutional Autoencoder or a LSTM Autoencoder could also be added).
9. Save intermediate results during auto run. This allows to save some results even when a longer running process crashes.
10. On some datasets, the training of some DL models can occasionally get stuck. The reasons for this might be further investigated in the future.

**NOTE** The entire platform is quite large at this point and not all functions, data manipulation and app interaction steps could be tested in every way. New errors can always occur and be fixed in the future.
