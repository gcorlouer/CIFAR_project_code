%% Apply method of sliding window to some time series data
function ts_data_slided=tsdata2slided(tsdata, window_size,num_chan,tsdata_length)
num_window=floor(tsdata_length/window_size);%number of windows
ts_data_slided=zeros(num_chan,window_size,num_window);%create 3d array containing the whole ts_slided
if num_window<=1
    ts_data_slided=tsdata;
else
    for i=1:(num_window-1)
    ts_data_slided(:,:,i)=tsdata(:,i*window_size:(i+1)*window_size-1);%slide window along ts
    end
end
end 