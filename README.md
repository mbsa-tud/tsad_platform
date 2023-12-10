# TSAD Platform Manual

A platform for evaluating time series anomaly detection (TSAD) methods which offers options to automatically train, test, compare and optimize them.

## Contents

1. [Getting started](#getting-started)
2. [Usage](#usage)
    * [Overview](#overview)
    * [Dataset preparation](#dataset-preparation)
        * [Loading a dataset](#loading-a-dataset-1)
        * [Preprocessing the dataset](#preprocessing-and-splitting-the-dataset-2)
    * [Training and optimization](#training-and-optimization)
        * [Load/configure models](#loadconfigure-models-1)
        * [Train and/or optimize models](#train-andor-optimize-models-2)
    * [Detection](#detection)
    * [Auto run](#auto-run)
    * [Dynamic switch](#dynamic-switch)
3. [Extending the platform](#extending-the-platform)
4. [Known limitations](#known-limitations-issues-and-possible-future-upgrades-mostly-relevant-for-developers)
5. [Appendix](#appendix)

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
3. Add the `tsad_platform` folder (the main folder of this repository) to the MATLAB path (without subfolders).
4. Add the `src` folder within the `tsad_platform` folder to the MATLAB path (with subfolders).
5. Add the `config` folder within the `tsad_platform` folder to the MATLAB path.
6. Open the `tsad_platform` folder with MATLAB.
7. Right-click the `TSADPlatform.mlapp` file and click `Run` to start the platform.

---

## How to use the platform

<img src="media/TSADPlatform_Quick_Demo.gif" alt="Quick Demo Mode 1" title="Quick Demo Mode 1" width=800/>

### Overview

what do different panels do

### Dataset preparation

### Train/optimize models

### Run detection

### Auto run

### Dynamic switch: A model selection mechanism


## Extending the platform

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