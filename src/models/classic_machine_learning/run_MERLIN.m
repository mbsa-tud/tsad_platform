function [distances, indices, lengths] = run_MERLIN(T, MinL, MaxL, K)

sumnan = sum(isnan(T));
if( sumnan> 0)
    error('Time series contains %d NaN value(s). Please handle and retry.',sumnan);
end
for i = 1:length(T)-MinL+1
   if std(T(i:i+MinL-1)) == 0
       error( "There is region so close to constant that the results will be unstable. Delete the constant region or try again with a MinL longer than the constant region.");
   end
end
numLengths = MaxL - MinL + 1;
distances = -1 * inf(numLengths, K);
indices = zeros(numLengths, K);
lengths = MinL:MaxL;

times = zeros(numLengths, K); % for debugging
misses = -1 * ones(numLengths, K); % for debugging

exclusionIndices = [];
kMultiplier = 1;

r = 2 * sqrt(MinL);
for ki = 1:K
    while distances(1,ki) < 0
        tic;
        [distances(1,ki), indices(1,ki)] = DRAG_topK(T, lengths(1), r*kMultiplier, exclusionIndices);
        if ki == 1
            r = r * 0.5;
        else
           kMultiplier = kMultiplier * 0.95; 
        end
        misses(1, ki) = misses(1, ki) + 1;
        
    end
    times(1, ki) = toc;
    exclusionIndices = [exclusionIndices, indices(1,ki)];
end

for i = 2:5
    if i > numLengths
        return;
    end
    exclusionIndices = [];
    kMultiplier = 1;
    r =  distances(i-1, 1) * 0.99;
    for ki = 1:K
        tic;
        
        while distances(i, ki) < 0
           [distances(i, ki), indices(i, ki)] = DRAG_topK(T, lengths(i), r*kMultiplier, exclusionIndices);
           
           if ki == 1
                r = r * 0.99;
           else
                kMultiplier = kMultiplier * 0.95; 
           end
           misses(i, ki) = misses(i, ki) + 1;
        end
        times(i, ki) = toc;
        exclusionIndices = [exclusionIndices, indices(i,ki)];
    end
end

if numLengths < 6
    return
end
for i = 6:numLengths
    exclusionIndices = [];
    kMultiplier = 1;
    m = mean(distances(i-5:i-1, 1));
    s = std(distances(i-5:i-1, 1));
    r = m - 2 * s;
    for ki = 1:K
        tic;
        
        while distances(i, ki) < 0
            [distances(i, ki), indices(i, ki)] = DRAG_topK(T, lengths(i), r*kMultiplier, exclusionIndices);
            r = r * 0.99;
            if ki == 1
                r = r * 0.99;
            else
                kMultiplier = kMultiplier * 0.95; 
            end
            misses(i, ki) = misses(i, ki) + 1;
        end

        times(i, ki) = toc;
        exclusionIndices = [exclusionIndices, indices(i,ki)];
    end
end
end

function [disc_dist, disc_loc] = DRAG_topK(TS, L, r, exclusionIndices)
% This implements discord discovery as described in 
%
% Yankov, Keogh, et al
% Disk Aware Discord Discovery: Finding Unusual Time Series in Terabyte Sized
% Datasets
%
% Inputs
% TS: time series
% L: subsequence length
% r: range parameter
%
% Outputs
% disc_dist: top discord distance
% disc_loc: starting index of the top discord in the time series TS
% disc_nnloc: location of the nearest neighbor of the top discord, 
%             (not necessarily a discord itself)


if ~isvector(TS)
    error('Expected a 1D input for time series');
elseif isrow(TS)
    TS = transpose(TS);
end

if floor(length(TS)/2) < L || L < 4
    error('Subsequence length parameter must be in the range of 4 < L <= floor(length(TS)/2).');
end

min_separation = L;

% compute normalization constants
mu = movmean(TS, [0 L-1], 'Endpoints', 'discard');
sig = movstd(TS, [0 L-1], 1, 'Endpoints', 'discard');
subseqcount = length(TS) - L + 1;

% Matlab lacks a "set". The closest container type is containers.Map.

% Algorithm 2: Candidates Selection Phase
C = containers.Map(1, (TS(1 : L) - mu(1))./ sig(1), 'UniformValues', false);

for i = 2 : subseqcount
    Si = (TS(i : i + L - 1) - mu(i)) ./ sig(i);
    cands = C.keys;
    isCand = true;
    for j = 1 : length(cands)
        if abs(cands{j} - i) < min_separation
            continue;
        end
        d = norm(Si - C(cands{j}));
        if d < r
            C.remove(cands{j}); 
            isCand = false;
            break;
        end
    end
    if isCand
        C(i) = Si; % line 12, Algorithm 2 using map rather than set
    end
end

cands = C.keys;
for ci = 1:length(C.keys)
   for ei = 1:length(exclusionIndices)
      if abs(exclusionIndices(ei) - cands{ci}) <= L
          C.remove(cands(ci));
          break;
      end
   end
end

if isempty(C)
    fprintf('Failure: The r parameter of %d was too large for the algorithm to work, try making it smaller\n', r);
    disc_dist = -inf;
    disc_loc = 0;
    return
end


% Algorithm 1: Discord Refinement Phase
cand_nndists2 = containers.Map(C.keys, inf(length(C), 1), 'UniformValues', true);
cand_nn_pos = containers.Map(C.keys, NaN(length(C), 1), 'UniformValues', true);
r2 = r^2;

% I diverge from the pseudocode in the paper here. First, I have to use 
% squared distances for correctness reasons in order to avoid taking a 
% square root at every step where we check against best so far. Second,
% I had to change the way elements are removed from the candidate set, or
% rather I had to change the loop tracking variable. If elements are 
% removed from an array while iterating over that same array, it will 
% result in skipped elements in almost any environment. Instead I'm 
% iterating over a copy of its hash keys, which remains constant over 
% the inner 2 loops. Elements are still progressively removed from the 
% candidate set.

for i = 1 : subseqcount
    if isempty(C)
        break;
    end
    keys = C.keys;
    Si = (TS(i : i + L - 1) - mu(i)) ./ sig(i);
    for j = 1 : length(keys)
        if abs(i - keys{j}) < min_separation
            continue;
        end
        dist2 = 0;
        candidx = keys{j};
        Candj = C(candidx);
        nndist2 = cand_nndists2(candidx); 
        for k = 1 : L
            dist2 = dist2 + (Si(k) - Candj(k))^2;
            if dist2 >= nndist2
                break;
            end
        end
        if dist2 < r2
            C.remove(candidx);
            cand_nndists2.remove(candidx);
            cand_nn_pos.remove(candidx);
            continue;
        elseif  dist2 < cand_nndists2(candidx)  
            cand_nndists2(candidx) = dist2;
            cand_nn_pos(candidx) = i;
        end
    end    
end

if isempty(C)
    fprintf('Failure: The r parameter of %d was too large for the algorithm to work, try making it smaller\n', r);
    disc_dist = -inf;
    disc_loc = 0;
%     disc_nnloc = [];
else
    % Scan to find the top discord among candidates
    disc_dist2 = 0;
    disc_loc = NaN;
    keys = cand_nndists2.keys;
    for i = 1 : length(cand_nndists2)
        if cand_nndists2(keys{i}) > disc_dist2
            disc_dist2 = cand_nndists2(keys{i});
            disc_loc = keys{i};
        end
    end
    disc_dist = sqrt(disc_dist2);
    disc_nnloc = cand_nn_pos(disc_loc);
    fprintf('The top discord of length %d is at %d, with a discord distance of %.2f. Its nearest neighbor is at %d\n', L, disc_loc, disc_dist, disc_nnloc);
end

end

function [matrixProfile, matrixProfileIdx, motifsIdx, discordsIdx] = mpx_patched4(timeSeries, minlag, subseqlen)
% matrixProfile - distance between each subsequence timeSeries(i : i + subseqLen - 1) 
%                 for i = 1 .... length(timeSeries) - subseqLen + 1, with the condition
%                 that the nearest neighbor of the ith subsequence is at least minlag steps
%                 away from it.
% 
% matrixProfileIdx - If matrixProfileIdx(i) == j, then |i - j| >= minlag
%                    and MatrixProfile(i) == norm(zscore(subseq(i), 1) - norm(zscore(subseq(j), 1));
%
% motifsIdx - A 10 x 3 matrix containing the indices of the top motifs and
%             their neighbors. The first two entries in each column
%             indicate a pair. The remaining entries in that column are their 
%             neighbors. This implementation picks motifs from best to
%             worst. It picks neighbors using a greedy strategy with an
%             excluded region applied after each pick to all subsequent
%             choices of motifs and neighbors. Outliers are picked first,
%             followed by the top motif and its neighbors, followed by the
%             second and third motifs in the same manner. This avoids
%             picking outliers as motifs on short time series.
%
%             The distance between a motif and its neighbor must be less than
%             two times the distance between a motif and its nearest
%             neighbor. This is not strict enough to guarantee any causal
%             relation, and in cases of weak matches, neighbors may vary
%             independently from the first pair (that is they may be
%             uncorrelated).
%
% discordsIdx - A 3 x 1 colum indicating the furthest outliers by maximal
%               normalized euclidean distance. These are chosen prior to
%               motifs in the current implementation.
%               
%

% Code and update formulas are by Kaveh Kamgar.  
% GUI and top k motif critera are based on but not identical to some code
% by Michael Yeh. Implementation details are specified above.
% The suggested use of the fourier transform to compute Euclidean Distance based on normalized 
% cross correlation is influenced by a suggested implementation by Abdullah Mueen. 
%
% Additional References
% Yan Zhu, et al, Matrix Profile II: Exploiting a Novel Algorithm and GPUs to break the one Hundred Million Barrier for Time Series Motifs and Join
% Zachary Zimmerman, et al, Scaling Time Series Motif Discovery with GPUs: Breaking the Quintillion Pairwise Comparisons a Day Barrier. (pending review)
% Philippe Pebay, et al, Formulas for Robust, One-Pass Parallel Computation of Covariances and Arbitrary-Order Statistical Moments
% Takeshi Ogita, et al, Accurate Sum and Dot Product

subcount = length(timeSeries) - subseqlen + 1;

% difference equations have 0 as their first entry here to simplify index
% calculations slightly. Alternatively, it's also possible to swap this to the last element
% and reorder the comparison step (or omit on the last step). This is a
% special case when comparing a single time series to itself. The more general
% case with time series A,B can be computed using difference equations for
% each time series.

if nargin ~= 3
    error('incorrect number of input arguments');
elseif ~isvector(timeSeries)
    error('first argument must be a 1D vector');
elseif ~(isfinite(subseqlen) && floor(subseqlen) == subseqlen) || (subseqlen < 2) || (subcount < 2) 
    error('subsequence length must be an integer value between 2 and the length of the timeSeries');
end

transposed_ = isrow(timeSeries);
if transposed_
    timeSeries = transpose(timeSeries);
end

nanmap = find(~isfinite(movsum(timeSeries, [0 subseqlen-1], 'Endpoints', 'discard')));
nanIdx = find(isnan(timeSeries));
timeSeries(nanIdx) = 0;
% We need to remove any NaN or inf values before computing the moving mean,
% because it uses an accumulation based method. We add additional handling
% elsewhere as needed.


mu = moving_mean(timeSeries, subseqlen);
mus = moving_mean(timeSeries, subseqlen - 1);
%t = tic();
invnorm = zeros(subcount, 1);

% movstd wasn't sufficient to prevent errors around constant or nearly constant regions
% This is safer, since we can reliably skip them
for i = 1 : subcount
    invnorm(i) = 1 ./ norm(timeSeries(i : i + subseqlen - 1) - mu(i));
end

invnorm(nanmap) = NaN;
invnorm(~isfinite(invnorm)) = NaN;
% This method requires more arrays, and it seems to be marginally worse
% at times. It isn't impacted as much by cancellation though.
dr_bwd = [0; timeSeries(1 : subcount - 1) - mu(1 : subcount - 1)];
dc_bwd = [0; timeSeries(1 : subcount - 1) - mus(2 : subcount)];
dr_fwd = timeSeries(subseqlen : end) - mu(1 : subcount);
dc_fwd = timeSeries(subseqlen : end) - mus(1 : subcount);
matrixProfile = repmat(-1, subcount, 1);
matrixProfile(nanmap) = NaN;
matrixProfileIdx = NaN(subcount, 1);

for diag = minlag + 1 : subcount
    cov_ = sum((timeSeries(diag : diag + subseqlen - 1) - mu(diag)) .* (timeSeries(1 : subseqlen) - mu(1)));
    for row = 1 : subcount - diag + 1
        col = diag + row - 1;
        if row > 1
            cov_ = cov_ - dr_bwd(row) * dc_bwd(col) + dr_fwd(row) * dc_fwd(col);
        end
        corr_ = cov_ * invnorm(row) * invnorm(col);
        if corr_ > matrixProfile(row)
            matrixProfile(row) = corr_;
            matrixProfileIdx(row) = col;
        end
        if corr_ > matrixProfile(col)
            matrixProfile(col) = corr_;
            matrixProfileIdx(col) = row;
        end
    end
end


% updated to pick outliers independent of motifs
% this means they might overlap or whatever. Compute more of them if you
% need to in order to avoid this. The other methods introduce bias. 
[discordsIdx] = findDiscords(matrixProfile, minlag);

[motifsIdx] = findMotifs(timeSeries, mu, invnorm, matrixProfile, matrixProfileIdx, subseqlen, minlag);


% Max caps anything that rounds inappropriately. This does hide potential
% issues at times. Safer methods can be used in data with extremely high
% variance that may lead to truncation or extremely low variance that may
% lead to cancellation. Folding mean calculations into accumulation and
% using compensated arithmetic for rolling means helps mitigate this
% problem.
matrixProfile = sqrt(max(0, 2 * subseqlen * (1 - matrixProfile), 'includenan'));
% We don't make a copy earlier or at this point, because this usually does nothing.
timeSeries(nanIdx) = NaN;
mpgui.launchGui(timeSeries, mu, invnorm, matrixProfile, motifsIdx, discordsIdx, subseqlen);

if transposed_  % matches the profile and profile index but not the motif or discord index to the input format
    matrixProfile = transpose(matrixProfile);
    matrixProfileIdx = transpose(matrixProfileIdx);
end

end


function [discordIdx] = findDiscords(matrixProfile, exclusionLen)
% This function assumes a correlation based implementation of matrixProfile
% and that any excluded regions have been set to NaN, nothing else.

% Changed on 1/29/20
% Making motif discovery and discord discovery co-dependent introduces odd
% issues. I am avoiding any sharing of excluded regions at this point,
% since it's not clear which should come first. Computing 3 or k or
% whatever motifs prior to discords was definitely not correct, but I'm not
% sure this is a better idea.

discordCount = 3;
discordIdx = zeros(discordCount, 1);
[~, idx] = sort(matrixProfile);

for i = 1 : discordCount
    f = find(isfinite(matrixProfile(idx)) & (matrixProfile(idx) > -1), 1);
    if isempty(f) || (matrixProfile(f) == -1)
        discordIdx(i : end) = NaN;
        break;
    end
    discordIdx(i) = idx(f);
    exclRangeBegin = max(1, discordIdx(i) - exclusionLen + 1); 
    exclRangeEnd = min(length(matrixProfile), discordIdx(i) + exclusionLen - 1);
    matrixProfile(exclRangeBegin : exclRangeEnd) = NaN;
end
end


function [motifIdxs, matrixProfile] = findMotifs(timeSeries, mu, invnorm, matrixProfile, profileIndex, subseqLen, exclusionLen)
% This is adapted match the output of some inline code written by Michael Yeh
% to find the top k motifs in a time series. Due to some bug fixes I applied, the two
% may return slightly different results, although they almost always agree on the top 2 motif pairs. 


% +2 allows us to pack the original motif pair with its neighbors.
% Annoyingly if it's extended, matlab will pad with zeros, leading to some
% rather interesting issues later.
motifCount = 3;
radius = 2;
neighborCount = 10;

motifIdxs = NaN(neighborCount + 2, motifCount);
% This formula just happens to work pretty well in picking time vs frequency based
% methods for optimal execution time. Feel free to change. It's a little
% skewed in favor of ffts, because in the current version of Matlab (2019),
% the implementation of conv2 does not to take advantage of simd
% optimization, based on my informal timing tests and various comparisons.
% 
if subseqLen < maxNumCompThreads * 128
   crosscov = @(idx) conv2(timeSeries, (timeSeries(idx + subseqLen - 1 : -1 : idx) - mu(idx)) .* invnorm(idx), 'valid');
else
   padLen = 2^nextpow2(length(timeSeries));
   crosscov = @(idx) ifft(fft(timeSeries, padLen) .* conj(fft((timeSeries(idx : idx + subseqLen - 1) - mu(idx)) .* invnorm(idx), padLen)), 'symmetric');
end

for i = 1 : motifCount
    [corr_, motIdx] = max(matrixProfile);
    % -1 means this is maximally negatively correlated and was therefore
    % never updated
    if ~isfinite(corr_) || corr_ == -1 
        break;
    end
    % order subsequence motif pair as [time series index of 1st appearance, time series index of 2nd appearance]
    motifIdxs(1 : 2, i) = [min(motIdx, profileIndex(motIdx)), max(motIdx, profileIndex(motIdx))];
    [corrProfile] = crosscov(motIdx);
    corrProfile = min(1, corrProfile(1 : length(timeSeries) - subseqLen + 1) .* invnorm, 'includenan');
    % This uses correlation instead of normalized Euclidean distance, because it's easier to work with and involves fewer operations.
    
    corrProfile(isnan(matrixProfile)) = NaN;
    if exclusionLen > 0
        for j = 1 : 2
            exclRangeBegin = max(1, motifIdxs(j, i) - exclusionLen + 1); 
            exclRangeEnd = min(length(matrixProfile), motifIdxs(j, i) + exclusionLen - 1);
            corrProfile(exclRangeBegin : exclRangeEnd) = NaN;
        end
    end
    
    for j = 3 : neighborCount + 2
        [neighborCorr, neighbor] = max(corrProfile);
        % If you want to put a reasonable global bound on it, 
        % set the if statement to also skip anything where neighborCorr <= 0 as well.
        % This was reverted to match earlier code, which did not enforce such a restriction.
        % 
        if  ~isfinite(neighborCorr) || ((1 - neighborCorr) >= radius * (1 - corr_)) 
            break;
        end
        motifIdxs(j, i) = neighbor;
        if exclusionLen > 0
            exclRangeBegin = max(1, neighbor - exclusionLen + 1); 
            exclRangeEnd = min(length(matrixProfile), neighbor + exclusionLen - 1);
            corrProfile(exclRangeBegin : exclRangeEnd) = NaN;
        end
    end
    % Matlab allows NaNs to be ignored from min/max calculations by default, so this
    % is a Matlab specific way to iteratively add excluded ranges of elements. 
    matrixProfile(isnan(corrProfile)) = NaN;
end
end


function [ res ] = moving_mean(a,w)
% moving mean over sequence a with window length w
% based on Ogita et. al, Accurate Sum and Dot Product

% A major source of rounding error is accumulated error in the mean values, so we use this to compensate. 
% While the error bound is still a function of the conditioning of a very long dot product, we have observed 
% a reduction of 3 - 4 digits lost to numerical roundoff when compared to older solutions.

res = zeros(length(a) - w + 1, 1);
p = a(1);
s = 0;

for i = 2 : w
    x = p + a(i);
    z = x - p;
    s = s + ((p - (x - z)) + (a(i) - z));
    p = x;
end

res(1) = p + s;

for i = w + 1 : length(a)
    x = p - a(i - w);
    z = x - p;
    s = s + ((p - (x - z)) - (a(i - w) + z));
    p = x;
    
    x = p + a(i);
    z = x - p;
    s = s + ((p - (x - z)) + (a(i) - z));
    p = x;
    
    res(i - w + 1) = p + s;
end

res = res ./ w;

end