function [prediction, computationTime] = predictWithDNN(Mdl, XTest, getComputationTime)
%PREDICTWITHDNN Handles prediction and computation time measuring for DNNs

% Fixed random seed
rng("default");

% Comptime measure the computation time for a single subsequence.
computationTime = NaN;

% Make prediction
prediction = predict(Mdl, XTest);

% Get computation time
if getComputationTime
    iterations = min(500, size(XTest, 1));
    times = zeros(iterations, 1);
    for i = 1:iterations
        tStart = cputime;
        predict(Mdl, XTest(i, :));
        times(i, 1) = cputime - tStart;
    end
    computationTime = mean(times(~(times == 0)));
end
end