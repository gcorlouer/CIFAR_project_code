function lp = lastpart(path)

% Return everything after last file separator (because 'fileparts' is shtoopid)

n = strlength(path);
k = findstr(path,filesep);

if isempty(k) % no file seperators
	lp = path;
elseif k(end) == n
	if isscalar(k)
		lp = path(1:end-1);
	else
		lp = path(k(end-1)+1:end-1);
	end
else
	lp = path(k(end)+1:end);
end
