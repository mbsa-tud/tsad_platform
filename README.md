# A platform for time-series anomaly detection and evaluation using Matlab and Simulink

This platform allows users to evaluate the performance of the detection process according to multiple variables, such as the dataset, preprocessing method, DNN type and architecture, training related hyperparameters, different threshold methods and evaluation metrics. It also has the ability to generate the corresponding detection tools for consequent online detection.

------

## Prerequisites

- Matlab and Simulink
- Matlab's Deep Learning Toolbox 


## Platform content

- 3 datasets from different Cyber-Physical System (CPS) domains, 2 of them generated from Simulink models (UAV and AVS) and one base on a real-world scenario (SwAT).
- Different preprocessing methods (standardizing, rescaling and usage of raw data).
- 2 network types, one for reconstruction and one for prediction.
- Different DNN architectures for each network type and ability to tune some training and network related and hyperparameters.
- 2 different thresholding methods for detection, supervised and unsupervised.
- Offline detection window for both detection methods with visual display of results. 
- The offline detection performance is reported with the traditional statistical metrics for machine learning (recall, precision and F1 score).
- Two Simulink models (one for each DNN type) to simulate the online detection using the supervised thresholding method.


## Instructions for use of the platform (with image examples using AVS dataset)

1. Select a dataset between UAV, AVS and SWaT.
2. According to the selected dataset, choose a scenario or sensor.
3. Select a preprocessing method and network type. 
4. Tune hyperparameters and train the DNN, editable hyperparameters are: 
  - Network architecture based on DNN type (GRU, LSTM, Hybrid CNN-LSTM, fully connected)
  - #Hidden units in a single LSTM or GRU layer
  - #Filters in the convulutional layers
  - #Neurons in the first fully connected layer
  - Window lookback size
  - Validation data ratio
  - #Epochs
  - Minibatch size
5. According to the selected dataset, choose the faulty data and proceed with online or offline detection. 


|1. Select a dataset | 2. Choose a scenario | 3. Select a method |
|:---:|:---:|:---:|
|<img src="https://user-images.githubusercontent.com/89462219/181745985-bfe4ae32-1205-46d0-a5f4-7830e66dc328.png" width="200"> | <img src="https://user-images.githubusercontent.com/89462219/181746611-10ba0af9-bdb4-4f29-b409-03f7108660d3.png" width="200"> | <img src="https://user-images.githubusercontent.com/89462219/181746782-5fa12237-91cb-40e7-b234-ab1347719f83.png" width="200"> |


|4. Config a network | 5. Choose detection |
|:---:|:---:|
|<img src="https://user-images.githubusercontent.com/89462219/181747017-948b19f9-3651-4afa-a3bd-6ebc434fb5d8.png" width="300"> | <img src="https://user-images.githubusercontent.com/89462219/181748929-10cc8462-9246-459b-8652-c6dad77d6881.png" width="150">|



**Offline detection**
<img src="https://user-images.githubusercontent.com/89462219/181749622-cbaa6c59-5adc-4f03-b44c-6514b607dcec.png">
On the offline detection window, both detection methods are displayed as well as their performance reported as statistical metrics. 

- On the left graphs, the detected anomalies are highlighted in red and the true anomalies in green.
- The middle graphs display the residual values and the threshold. All values above the threshold are flagged as anomalous.
- The top part represents the unsupervised thresholding mand the bottom part the supervised thresholding.
- The anomaly padding, window size and z-range can be changed for the unsupervised detection method. The results are updated dynamically.

**Online detection simulation with supervised thresholding method**
<img src="https://user-images.githubusercontent.com/89462219/181750633-b0f31072-e9b5-4590-a040-e0dc5ea5d1d3.png">
Based on the type of the trained network, either the prediction or reconstruction block will be used. The main Simulink model is the same for both network types (see Fig. above). The detection block automatically takes the trained network and the window length as mask parameters.
  The scope blocks on the main model display the faulty data with highlighted true anomalies and found anomalies.

| Labeled anomalies | Found anomalies |
|:---:|:---:|
| <img src="https://user-images.githubusercontent.com/89462219/181752619-32d74839-2bca-4cb1-ba56-5c8766523b1c.png" alt="Trulli" style="width:50%"> | <img src="https://user-images.githubusercontent.com/89462219/181752387-db92d980-e0d1-4667-91b6-f280d2052be0.png" alt="Trulli" style="width:50%"> |






