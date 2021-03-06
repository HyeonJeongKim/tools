% I want to fit y = y_1 + y_0 exp(-x/X)
function [y0, X, y1] = exp_fit(x, y, plot_flag, test)

    if ~exist('test', 'var'), test = 0; end
    if ~exist('plot_flag', 'var'), plot_flag = 0; end

    if test
        test_exp_fit();
        return;
    end

    initGuess(1) = y(1);
    initGuess(2) = mean(x(:));
    initGuess(3) = y(1);
    opts = optimset('MaxFunEvals',1e5);
    [fit2,~,exitflag] = fminsearch(@(fit) fiterror(fit,x,y), ...
                                   initGuess,opts);

    y0 = fit2(1);
    X = fit2(2);
    y1 = fit2(3)

    if plot_flag
        figure;
        plot(x,y,'k*'); hold all
        plot(x,y1 + y0*exp(-x/X));
    end
end

function [E] = fiterror(fit,x,y)
    % x = (T0,H,a)
    y0 = fit(1); X = fit(2); y1 = fit(3);

    E = sum((y - y1 - y0 .* exp(-(x/X))).^2);
end

function [] = test_exp_fit()
    x = [0.02:0.05:5];
    X = 2;
    y0 = 2;
    y1 = 0.5;
    y = y1 + y0 * exp(-x/X) + rand(size(x)) .* y0/4;

    [yy,xx,y1] = exp_fit(x,y,1);

    disp(['y0 = ' num2str(yy) ' | Original = ' num2str(y0)]);
    disp(['X = ' num2str(xx) ' | Original = ' num2str(X)]);
end