classdef repetitionLayer < nnet.layer.Layer & nnet.layer.Formattable
    properties
        % Define any properties that the layer needs
        SequenceLength  % The length of the sequence to replicate
    end
    
    methods
        function layer = repetitionLayer(sequenceLength, name)
            % Constructor function to create the layer
            layer.Name = name;
            layer.Description = "Repetition layer for replicating latent vector across sequence";
            layer.SequenceLength = sequenceLength;
        end
        
        function Z = predict(layer, X)
            % Forward pass to replicate the input latent vector across the sequence length
            % X: Input latent vector of size [latentDim, batchSize]
            % Z: Output replicated sequence of size [latentDim, batchSize, SequenceLength]
        
            % Replicate the input X across the sequence length
            Z = repmat(X, [1, 1, layer.SequenceLength]);
            Z = dlarray(Z, "CBT");
        end
    end
end
