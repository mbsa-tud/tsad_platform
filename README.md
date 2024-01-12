# TSAD Platform Manual

**A platform for evaluating time series anomaly detection (TSAD) methods.**

**Automatically train, test, compare and optimize many models or add your custom ones.**

---

## Getting started

1. Download this repository.
2. Install MATLAB Toolboxes:
    * `Simulink`
    * `Signal Processing Toolbox`
    * `DSP System Toolbox`
    * `Image Processing Toolbox`
    * `Econometrics Toolbox`
    * `Predictive Maintenance Toolbox`
    * `Statistics and Machine Learning Toolbox`
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
* Toggle usage of `anomalous validation set` (used for static thresholds).
* Toggle splitting of dataset for `dynamic switch`.

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
3. If you enabled optimization, you can further configure the `number of iterations`, the `threshold` and the `metric` to optimize in a popup window. Additionally you can open the `optimization config` file and reconfigure the parameters to be optimized.

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
3. Press `Auto Run All`.
4. Select a folder to store the results (stored in `CSV` files).

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
6. You **can** implement the `getLayers` function if you want the platform to be able to display the layers of your model.

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

The `scoring function` can be used to transform the anomaly scores produced by a Model (**channel-wise reconstruction/prediction errors for DL models**). This can include aggregation of channel-wise scores or further transformation.
These are currently **only used for deep-learning models**.

Following scoring functions are currently available:

| Scoring Function | Description |
|-|-|
| aggregated | The mean training anomaly score gets subtracted from the channel-wise anomaly scores. Afterwards, the Root Mean Square is taken across channels. **For univariate datasets nothing is done.** |
| channelwise | The mean training anomaly score gets subtracted from the channel-wise anomaly scores. **For univariate datasets nothing is done.** |
| gauss | A multivariate gaussian distribution is fitted to the trainig anomaly scores and used to compute -log(1 - cdf) of the anomaly scores. **The max supported number of channels in the dataset is 25** |
| gauss_aggregated | The channel-wise mean and standard deviation of the training anomaly score distribution is used to compute -log(1 - cdf) of the channel-wise anomaly scores. Afterwards, the channel-wise anomaly scores are added. |
| gauss_channelwise | The channel-wise mean and standard deviation of the training anomaly score distribution is used to compute -log(1 - cdf) of the channel-wise anomaly scores. |
| ewma | The Root Mean Square is taken across the channels of the anomaly scores before computing the Exponentially Weighted Moving Average. |

**NOTE** For the channel-wise scoring functions (labeled "channel-wise"), the output consits of anomaly scores for every channel of the dataset.
In this case, a common threshold gets applied across all channels during testing. A single observation only needs to be labeled as anomalous in one of the channels to be considered an anomaly.

#### Reconstruciton error type

The `reconstruction error type` defines how the errors are computed **for reconstructive deep-learning models**. Since there are multiple predicted values for every observation of the time series, a single value must be computed. Following methods to do this are available:

| Reconstruction Error Type | Description |
|-|-|
| median_pointwise_values | Calculates the median predicted value for each time step and then calculates the absolute errors for the entire time series. This is done for each channel separately. |
| median_pointwise_errors | Calulates the point-wise absolute errors for each subsequence and then calculates the median error for each time step. This is done for each channel separately. |
| mean_subsequence_rmse | Calulates the Root Mean Squared Errors (RMSE) for each subsequence and then calculates the mean for each time step. This is done for each channel separately. |