function [Sa,Sc] = abspec(S)

	[n,~,h] = size(S);
	Sa = zeros(h,n);
	Sc = zeros(h,(n*(n-1))/2);
	k = 0;
	for i = 1:n
		Sa(:,i) = S(i,i,:);
		for j = i+1:n
			k = k+1;
			Sc(:,k) = abs(S(i,j,:));
		end
	end

end
