x = linspace(-4,4,1000)';
y1 = nrmpdf(x);
y2 = txpdf(x,lam);
gp_qplot(x,[y1 y2]);


function y = nrmpdf(x)

	y = (1/sqrt(2*pi))*exp(-(x.^2)/2);

end

function y = txpdf(x,lam)

	lamsq = lam*lam;
	p = x >= 0;
	n = x <  0;
	y = zeros(size(x));
	y(p)  = (1/sqrt(2*pi))*exp(-(((exp( lam*x(p))-1).^2)/(2*lamsq)) + lam*x(p));
	y(n)  = (1/sqrt(2*pi))*exp(-(((exp(-lam*x(n))-1).^2)/(2*lamsq)) - lam*x(n));

end
