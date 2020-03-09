function imfile = print_fig(figfile,imtype,viewit)

if nargin < 3 || isempty(viewit), viewit = false; end

% Print .fig file to pdf, svg, png, jpeg, etc.

ispdf = false;
issvg = false;
global rasviewer pdfviewer svgviewer
switch lower(imtype);
	case 'pdf', ispdf = true; imviewer = pdfviewer;
	case 'svg', issvg = true; imviewer = svgviewer;
	otherwise, imviewer = rasviewer;
end

imfile = '';

[fpath,~,ext] = fileparts(figfile);

if isempty(ext) % append '.fig'
	figfile = [figfile '.fig'];
end

global cffigdir
if isempty(fpath) % no leading directory, assume 'cffigdir'
	figfile = fullfile(cffigdir,figfile);
end

try, openfig(figfile,'invisible'); catch problem
	fprintf('Failed to open figure file ''%s'' (%s)\n',figfile,problem.identifier);
	return
end

[figpath,figname] = fileparts(figfile);
imfile = fullfile(figpath,[figname '.' imtype]);
fprintf('\nImage file: ''%s''\n\n',imfile);

pstr = ['-d' imtype];
if ispdf | ispdf % vector graphics
	pos = get(gcf,'Position');
	set(gcf,'PaperSize',pos([3 4])/32);
	print(imfile,pstr,'-bestfit');
else             % assume raster format
	print(imfile,pstr,'-r0');
end

if viewit
	[status,result] = system([imviewer ' ' imfile ' &']);
	assert(~status,result);
end
