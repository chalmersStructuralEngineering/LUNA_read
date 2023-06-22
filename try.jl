using JLD2
using FillOutliers
@load "./data.jld2" data
data_in = data.ch2
data_b = zeros(size(data_in))
for i = 1:size(data_in, 1)
    data_b[i, :] = filloutliers(data_in[i, :], "moving mean", 11)
end