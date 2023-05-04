% Example vector of values
values = [4, 3, 7, 2, 6, 1, 5];

% Add the original index of each value as the first element in the value vector
n = length(values);

% Find the maximum and minimum values in the vector
maxVal = max(values);
minVal = min(values);

% Compute the distances of each value from the max and min values
distToMax = abs(values - maxVal);
distToMin = abs(values - minVal);
%instantiate vectors to hold the bin values
binToMax = zeros(1,n);
binToMin = zeros(1,n);
% Determine which bin each value belongs to based on the distances
for i = 1:n
    if distToMax(i) < distToMin(i)
        binToMax(i) = 1;
        binToMin(i) = 0;
    else
        binToMax(i) = 0;
        binToMin(i) = 1;
    end
end

% Compute the lengths of each bin (i.e., the number of values in each bin)
binToMaxLength = sum(binToMax);
binToMinLength = sum(binToMin);

% Get the bin value vector for the bin with the smallest number of values
if binToMaxLength < binToMinLength
    binValues = binToMax;
else
    binValues = binToMin;
end
%print out the binValues vector and the values that belong to that bin
disp(binValues)
disp(values(binValues == 1))

