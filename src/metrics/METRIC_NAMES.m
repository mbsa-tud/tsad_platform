function metricNames = METRIC_NAMES()
%METRIC_NAMES Returns all metric names used by the tsad platform

metricNames = ["F1 Score (pointwise)"; ...
                "F1 Score (eventwise)"; ...
                "F1 Score (point-adjusted)"; ...
                "F1 Score (composite)"; ...
                "F0.5 Score (pointwise)"; ...
                "F0.5 Score (eventwise)"; ...
                "F0.5 Score (point-adjusted)"; ...
                "F0.5 Score (composite)"; ...
                "Precision (pointwise)"; ...
                "Precision (eventwise)"; ...
                "Precision (point-adjusted)"; ...
                "Recall (pointwise)"; ...
                "Recall (eventwise)"; ...
                "Recall (point-adjusted)"; ...
                "AUC"];
end