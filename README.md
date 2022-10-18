# TSAD Platform Manual
A platform for time series anomaly detection.

## How To
### Manual Options
The manual workflow for training and testing TSAD methods is as such:
1. Threshold selection
2. Data selection
3. Preprocessing method selection
4. Model selection/configuration
5. Training or Optimization
6. Detection & Evaluation

Only the first **four panels** of the platform are used for these options:
* Data panel
* Preprocessing panel
* Training panel
* Detection panel


#### Threshold selection
Click `Settings > Thresholds` and select the thresholds you want the platform to compute. The following thresholds can be selected:

| Threshold         | Available for     |
|--------------|-----------|
| Best F1 Score (point-wise) | all      |
| Best F1 Score (event-wise) | all      |
| Best F1 Score (point-adjusted) | all      |
| Best F1 Score (composite) | all      |
| Best F1 Score (point-wise, parametric) | just DL models      |
| Best F1 Score (event-wise, parametric) | just DL models      |
| Best F1 Score (point-adjusted, parametric) | just DL models      |
| Best F1 Score (composite, parametric) | just DL models      |
| Top-k | all |
| Mean + 4 * Std| just DL models |
| Dynamic | all |

* The selection of thresholds controls which thresholds are calculated by the platform.
* The **dynamic** threshold will always be available for any detection being done on the `Detection Panel`.
The checkbox only controls if it shall be used during the `Auto Training and Evaluation` on the `Auto Run` panel.

#### Data Interface
1. On the `Data` panel, click `Browse` to select a folder from the computer or paste the path to the forlder directly into the text-field.
2. Click `Load Data` to import the selected dataset.

The **format** of a dataset must be as such:
* It contains a folder called `test` (mandatory) and a folder called `train` (optional for unsupervised anomaly detection methods).
* Each folder contains an arbitrary amount of **CSV** files with the following format:

| timestamp | value1 | value2 | is_anomaly |
|-|-|-|-|
|1|1.2345|0.223|0|
|2|1.2566|0.111|0|
|3|-1.3111|0|1|

**Timestamp**: The equally spaced timestamps. Can be increasing numeric values or common datatime strings.
**Values**: The values for the individual channels of the dataset. For univariate data there is just one value-column.
**is_anomaly**: The anomaly indicators for each observation. 1 = anomaly, 0 = fault-free.

**Note!** The column-names don't need to be as presented. The platfrom interprets the values of each column according to their position in the file. The first column is always considered the timestamp column and the last column is always considered to be the column of anomaly indicators. Everything in between are the values of the channels.


#### Preprocessing
Three preprocessing methods can be selected. These only apply to the training and detection being run on the `Training` and `Detection` panels. All other functions of the platform have their own preprocessing-method selection option.

| Preprocessing Method | Description |
|-|-|
| Raw Data | Unprocessed data |
| Standardize | The data gets standardized to have a mean of 0 and standard deviation of 1 |
| Rescale [0, 1] | The data gets rescaled to fix it's maximum to 1 and minimum to 0.|

**Note!** The data in the `test` folder gets processed with the same parameters as for the `train` data (with the exception if no train data is used). All channels of multivariate datasets are preprocessed independently.

#### Training

#### Optimization
#### Detection
### Automated Options
#### Auto Hyperparameter Optimization
#### Auto Training and Evaluation
### Dynamic Switch
#### Workflow

## Source Code
### The "options" struct
The platform recognizes a model/algorithm by it's configuration. This configuration is stored in a struct with a single key called **"options"**.
The value of this key contains all relevant information. When adding a configured model to one of the lists of models on the training panel, the **ItemsData** property of that list (which is a struct array in this platform) gets extended by such a struct.

The following figure shows an example for the fully-connected autoencoder (FC AE):
```json
"options": {
    "type": "DNN",
    "model": "FC AE",
    "label": "FC AE  (1)",
    "id": "FC_AE_1",
    "modelType": "Reconstructive",
    "dataType": 1,
    "trainOnAnomalousData": false,
    "calcThresholdLast": true,
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

The files `config_all.json` and `config_for_testing.json` contain the JSON representation of a MATLAB struct with separate fields for DNN, CML and statistical models. Each field's value is a struct array with individual "options" structs, as presented before:
```json
{
    "DNN_Models": [
        {
            "options": {
                ...
            }
        },
        {
            "options": {
                ...
            }

        }
    ],
    "CML_Models": [
        ...
    ],
    "S_Models": [
        ...
    ]
}
```


The value of the **options** key is also a struct with the following fields:

**type**
The type of the model/algorithm. Must be one of: **DNN**, **CML**, **S**

**model**
The identifier for the model. This is used by the platform to recognize the model. It should only contain **letters** and the following characters: `-`, `(`, `)`.

**label**
The label for the model. It is only displayed on the lists on the training panel. It **MUST** be the the same as the `model` field followed by **two whitespaces and a number in brackets**. Example: **FC AE &nbsp;(1)**. This field get's automatically set by the platform and only needs to be specified in the *"config_all.json"* file.

**id**
The id is the same as the `label` field but with all non-letter character being replaced by `_`. For multiple consecutive non-letter characters, only a single `_` must be insterted. This field is automatically set by the platform, **BUT** when running test using a configuration file, it must be manually set. Once the platform finished training all models, it creates a struct of trained models. The fieldnames of this struct are the **ids** specified in this field of the options struct.

**modelType**
This field is only required for DL models. It's value must be one of: `"Predictive"`, `"Reconstructive"`. It indicates whether the model produces prediction- or reconstruction errors.

**dataType**
This field is only required for DL models. It's value must be one of: `1`, `2`, `3`. The number controls the shape of the data for the DL model. In all cases, the split data will be stored in a `1 x C` cell array, with c being the number of channels in the dataset. The data is always split into subsequences of equal length using a sliding window. For the three different numbers, the data will be shaped as such:
| Value | Data shape |
|-|-|
| **1** |`w x N` matrix with `w` being the window-size and `N` being the number of observations.|
| **2** | `N x 1` cell array with `N` being the number of observations. Each cell is a matrix of size `1 x w` with `w` being the window-size. |
| **3** | `N x 1` cell array with `N` being the number of observations. Each cell is a matrix of size `w x 1` with `w` being the window-size. |

**trainOnAnomalousData**
If this is set to **false**, the model is trained on the data from the **train** folder. If it is set to **true**, the model gets traied on the anomalous validation set from the **test** folder.

**calcThresholdLast**
If this is set to **false**, the static thresholds are set on the anomalous validation set. If it is set to **true**, they are calculated after the anomaly scores are computed on the test data.

**hyperparameters**
This field can contains all configurable hyperparameters for your model/algorithm. It's value is another struct array. The hyperparameters should be separated into three groups: **model**, **data** and **training** related hyperparameters, which are all separate fields within this struct. If you want to add a hyperparameter, specify it's name as a new key within on of the aforementioned fields (model, data, training). It must contain two keys: **value** and **type**. The type is only required for the optimization algorithm of the platform. It must be one of: `"integer"`, `"real"`, `"categorical"`.




### Overall Structure

