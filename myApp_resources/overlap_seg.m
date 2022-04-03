function [fp, fn, tp] = overlap_seg(expected, observed)
trueAnoms = find(expected == 1);
anoms = find(observed == 1);

anomSegs = find_cons_sequences(anoms);
trueAnomsSegs = find_cons_sequences(trueAnoms);

 tp = 0;
        fn = 0;
        anomsCopy = anomSegs;
        for i = 1:size(trueAnomsSegs,1)
            found = false;
            for j = 1:size(anomSegs,1)
                a = intersect(trueAnomsSegs{i,1}, anomSegs{j,1});                
                if ~isempty(a)
                    if ~found
                        found = true;
                        tp = tp+1;
                    end
%                     tp = tp+1;
                    k = 1;
                    while k <= size(anomsCopy,1)
                        if isequal(anomsCopy{k},anomSegs{j})
                            anomsCopy(k) = [];
                        end
                        k = k+1;
                    end
                end
            end
            if ~found
                fn = fn+1;
            end
        end
    
    
        fp = max(size(anomsCopy,1)-1,0);
% anoms = find(observed == 1);
% anomSegs = cell(0,1);
% trueAnoms = find(expected == 1);
% if ~isempty(trueAnoms)
%     trueAnomsSegs = cell(0,1);
%     idxA = find(diff(anoms) ~= 1);
%     idxTr = find(diff(trueAnoms) ~= 1);
%     if isempty(idxTr)
%         idxTr(1)=find(trueAnoms == trueAnoms(end));
%     end
%     if ~isempty(idxA)
%         anomSegs{1,1} = anoms(1:idxA(1));
%         % trueAnomsSegs{1,1} = anoms(1:idxTr(1));
%         trueAnomsSegs{1,1} = trueAnoms(1:idxTr(1));
%         for i = 2:length(idxA)-1
%             seg = anoms(idxA(i-1)+1:idxA(i));
%             if length(seg) > 1
%                 anomSegs = [anomSegs;seg];
%             end
%         end
%         for i = 2:length(idxTr)-1
%             seg = trueAnoms(idxTr(i-1)+1:idxTr(i));
%             if length(seg) > 1
%                 trueAnomsSegs = [trueAnomsSegs; seg];
%             end
%         end
%         tp = 0;
%         fn = 0;
%         anomsCopy = anomSegs;
%         for i = 1:size(trueAnomsSegs,1)
%             found = false;
%             for j = 1:size(anomSegs,1)
%                 a = intersect(trueAnomsSegs{i,1}, anomSegs{j,1});                
%                 if ~isempty(a)
%                     if ~found
%                         found = true;
% %                         tp = tp+1;
%                     end
%                     tp = tp+1;
%                     k = 1;
%                     while k <= size(anomsCopy,1)
%                         if isequal(anomsCopy{k},anomSegs{j})
%                             anomsCopy(k) = [];
%                         end
%                         k = k+1;
%                     end
%                 end
%             end
%             if ~found
%                 fn = fn+1;
%             end
%         end
%     
%     if size(anomsCopy,1) >= 1
%         fp = size(anomsCopy,1)-1;
%     else
%         fp = 0;
%     end
%     else
%         tp = 0; fp = 1; fn = 1;
%     end
% else
%     tp = 0; fp = 1; fn = 1;
% end

end
