function output = encodeLabels(data)
%ENCODELABELS Replace undefined pixels and one-hot encode a mask.

image = data{1};
labels = data{2};
labels(isundefined(labels)) = "background";
oneHotLabels = onehotencode(labels,3,'single');
output = {image,oneHotLabels};
end

