%% Bamboo chair loadcase classification (ME 780 DA3, University of Waterloo, 2021)
% Plain-script version of LifeCycleNN.mlx so the code is readable on GitHub.
% Trains a pattern-recognition network (7 inputs -> 10 tansig -> 4 softmax)
% to classify the loadcase on a bamboo chair, then evaluates it on the
% training set and on the two unseen test loadcases.
%
% Requires the Deep Learning Toolbox. Run from the repository root.

rng(0, 'twister');   % added in cleanup so results are repeatable

%% Load data
trainData = readtable('trainData.xlsx');
testData  = readtable('testData.xlsx');

size(trainData.Category)
head(trainData)

%% Create the network
net = patternnet;                         % default: one hidden layer of 10 neurons
net.trainParam.epochs = 2000;
net.performParam.regularization = 0.01;
% Default random split of the training data: 70% train / 15% validation / 15% test

%% Prepare data
xTrain = trainData{:, vartype("numeric")}';
xTest  = testData{:,  vartype("numeric")}';

train_state = categorical(trainData.Category);
yTrain = dummyvar(train_state)';
test_state = categorical(testData.Category);
labels = categories(train_state)

%% Train
net = train(net, xTrain, yTrain);
view(net)

%% Evaluate
scores      = net(xTest);
scoresTrain = net(xTrain);

[~, yNum]      = max(scores);
[~, yNumTrain] = max(scoresTrain);
yPred      = categorical(yNum,      1:numel(labels), labels)';
yPredTrain = categorical(yNumTrain, 1:numel(labels), labels)';

accuracy      = 100*nnz(test_state  == yPred)/numel(yPred)
accuracyTrain = 100*nnz(train_state == yPredTrain)/numel(yPredTrain)

figure
confusionchart(test_state, yPred, "RowSummary", "row-normalized", "Normalization", "row-normalized");
title("Test data, accuracy: " + string(accuracy))

figure
confusionchart(train_state, yPredTrain, "RowSummary", "row-normalized", "Normalization", "row-normalized");
title("Training data, accuracy: " + string(accuracyTrain))
