function fbnamef = fband_format(fbname,gpterm,longbb)

if nargin < 2, gpterm = [];    end
if nargin < 3, longbb = false; end

if     isempty(gpterm) || strcmpi(gpterm,'png')
	switch fbname
		case 'delta',  fbnamef = '{/Symbol d}';
		case 'theta',  fbnamef = '{/Symbol q}';
		case 'alpha',  fbnamef = '{/Symbol a}';
		case 'beta',   fbnamef = '{/Symbol b}';
		case 'lgamma', fbnamef = '{/Symbol g}_l';
		case 'hgamma', fbnamef = '{/Symbol g}_h';
		case 'BBAND',  if longbb, fbnamef = fbname; else, fbnamef = 'BB'; end
		otherwise,     fbnamef = fbname;
	end
elseif strcmpi(gpterm,'epsl')
	switch fbname
		case 'delta',  fbnamef = '$\\delta$';
		case 'theta',  fbnamef = '$\\theta$';
		case 'alpha',  fbnamef = '$\\alpha$';
		case 'beta',   fbnamef = '$\\beta$';
		case 'lgamma', fbnamef = '$\\gamma_l$';
		case 'hgamma', fbnamef = '$\\gamma_h$';
		case 'BBAND',  if longbb, fbnamef = fbname; else, fbnamef = 'BB'; end
		otherwise,     fbnamef = fbname;
	end
else
	fbnamef = fbname;
end
