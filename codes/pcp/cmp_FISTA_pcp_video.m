clear all
close all
clc
%%
load lobby.mat;

mov = output.mov(1:1:end, 1:1:160, :);
clear output;

[n1,n2,n3] = size(mov);

f = zeros(n1*n2, n3);
for i=1:n3
    frame = mov(:,:, i);
    f(:, i) = frame(:);
end
f = rescale(f, 0,1);

n = size(f);
%% parameters
para.mu1 = 1/sqrt(max(n)); % weight of sparse S
para.mu2 = 2; % weight of low rank L

para.beta = 1; % cocoercivity of the gradient

para.f = f;
para.n = n;

para.tol = 1e-10; % stopping criterion
para.maxits = 1e5; % max # of iteration

GradF = @(x) - ((f-x) - svt(f-x, para.mu2));
ProxJ = @(x, t) wthresh(x, 's', t);
% %
% [xs, xl, its, ek] = func_tFB_pcp(para, GradF, ProxJ);
%% FISTA-Mod
fprintf(sprintf('performing FISTA-Mod...\n'));

r = 4;

p = 1/1;
q = 1/1;

[xs1,xl1, its1, ek1] = func_FISTA_Mod(para, GradF, ProxJ, p,q,r);

p = 1/5;
q = 1/1;

[xs2,xl2, its2, ek2] = func_FISTA_Mod(para, GradF, ProxJ, p,q,r);

%%
p = 1/30;
q = 1/10;

[xs3,xl3, its3, ek3] = func_FISTA_Mod(para, GradF, ProxJ, p,q,r);

fprintf('\n');
%% plot
linewidth = 1;

axesFontSize = 8;
labelFontSize = 8;
legendFontSize = 8;

resolution = 300; % output resolution
output_size = 300 *[10, 8]; % output size

%%%%%% relative error

figure(100), clf;
set(0,'DefaultAxesFontSize', axesFontSize);
set(gcf,'paperunits','centimeters','paperposition',[-0.1 -0.17 output_size/resolution]);
set(gcf,'papersize',output_size/resolution-[0.85 0.5]);

grey1 = [0.3,0.3,0.3];
p1 = semilogy(ek1, 'Color',grey1, 'LineWidth',linewidth);
hold on,

blue1 = [0.12,0.48,1.0];
p2 = semilogy(ek2, 'Color',blue1, 'LineWidth',linewidth);
blue2 = [0.9,0.0,0.0];
p3 = semilogy(ek3, 'Color',blue2, 'LineWidth',linewidth);

grid on;
ax = gca;
ax.GridLineStyle = '--';

% v = axis;
axis([1 length(ek1)+0 1e-7 1e2]);
ytick = [1e-7, 1e-4, 1e-1, 1e2];
set(gca, 'yTick', ytick);

ylb = ylabel({'$\|x_{k}-x_{k-1}\|$'}, 'FontSize', labelFontSize,...
    'FontAngle', 'normal', 'Interpreter', 'latex');
set(ylb, 'Units', 'Normalized', 'Position', [-0.1, 0.5, 0]);
xlb = xlabel({'\vspace{-1.0mm}';'$k$'}, 'FontSize', labelFontSize,...
    'FontAngle', 'normal', 'Interpreter', 'latex');
set(xlb, 'Units', 'Normalized', 'Position', [1/2, -0.055, 0]);

lg = legend([p1, p2, p3], 'FISTA-BT',...
    'FISTA-Mod, $p = \frac{1}{5}, q = {1}$',...
    'FISTA-Mod, $p = \frac{1}{30}, q = \frac{1}{10}$');
set(lg,'FontSize', 10);
set(lg, 'Interpreter', 'latex');
%
pos = get(lg, 'Position');
set(lg, 'Position', [pos(1)-0.125, pos(2)-0.075, pos(3:4)]);
pos_ = get(lg, 'Position');
legend('boxoff');


epsname = sprintf('cmp_fista_pcp.png');
print(epsname, '-dpng');
%% print images

kk = 30;

resolution = 300; % output resolution
output_size = 300 *[8, 8]; % output size

figure(101), clf;
set(0,'DefaultAxesFontSize', axesFontSize);
set(gcf,'paperunits','centimeters','paperposition',[-1.015 -1.13 output_size/resolution]);
set(gcf,'papersize',output_size/resolution-[1.74 2.49]);

imgsc(reshape(f(:,kk), n1,n2));

epsname = sprintf('original-frame.png');
print(epsname, '-dpng');


figure(102), clf;
set(0,'DefaultAxesFontSize', axesFontSize);
set(gcf,'paperunits','centimeters','paperposition',[-1.015 -1.13 output_size/resolution]);
set(gcf,'papersize',output_size/resolution-[1.74 2.49]);

imgsc(reshape(xs3(:,kk), n1,n2));

epsname = sprintf('sparse-component.png');
print(epsname, '-dpng');

figure(103), clf;
set(0,'DefaultAxesFontSize', axesFontSize);
set(gcf,'paperunits','centimeters','paperposition',[-1.015 -1.13 output_size/resolution]);
set(gcf,'papersize',output_size/resolution-[1.74 2.49]);

imgsc(reshape(xl3(:,kk), n1,n2));

epsname = sprintf('lowrank-component.png');
print(epsname, '-dpng');