%% Apply method of sliding window to a given time series
function tsdata_slided=tsdata2slided(tsdata, window_size,num_chan,tsdata_length)
num_window=floor(tsdata_length/window_size);%number of windows
tsdata_slided=zeros(num_chan,window_size,num_window);%create 3d array containing the whole ts_slided
if num_window<=1
    tsdata_slided=tsdata;
else
    for i=1:(num_window-1)
    tsdata_slided(:,:,i)=tsdata(:,i*window_size:(i+1)*window_size-1);%slide window along ts
    end
end
end 