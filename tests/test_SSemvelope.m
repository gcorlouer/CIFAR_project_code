% Test SS modeling envelope
tol = 1e-5 ;
lag = 10;
envelope_test = envelope;
drop_col = [];
envelope_test(drop_col,:) = [];
autocov = tsdata_to_autocov(X,lag);
G = autocov(:,:,1);
rg = rank(G, tol);
lambdas = eig(G);
[Q,R,P] = qr(G,0);
s = svd(G);