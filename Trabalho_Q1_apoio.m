%% =======================================================================
%  Laboratorio de Controle Discreto - Questao 1 (script de APOIO)
%  Grupo: Luiz E. Passoni de Souza / Victor Damasceno Oliveira
%
%  OBS.: este script e apenas APOIO/conferencia (Matlab e permitido como
%  apoio). Os calculos a mao estao no .tex; aqui reproduzimos a
%  discretizacao ZOH por fracoes parciais e conferimos com o c2d.
%  Nao usa sisotool nem pidtune.
% =======================================================================
clear; clc; close all;

%% Parametros do motor (grupo)
Ra = 2;     La = 1;
Km = 0.05;  Kb = 0.05;
J  = 0.05;  b  = 0.5;

%% ---------------- Item (a): G(s) e malha fechada H(s) ----------------
% G(s) = Km / [ (La s + Ra)(J s + b) + Km*Kb ]
den2 = La*J;            % coef de s^2
den1 = La*b + Ra*J;     % coef de s^1
den0 = Ra*b + Km*Kb;    % coef de s^0

% Forma normalizada (dividindo por den2):  G(s) = Kn / (s^2 + an1 s + an0)
Kn  = Km/den2;          % = 1
an1 = den1/den2;        % = 12
an0 = den0/den2;        % = 20.05

Gs = tf(Kn, [1 an1 an0]);
fprintf('G(s) = %.4g / (s^2 + %.4g s + %.4g)\n', Kn, an1, an0);
fprintf('Polos de G(s): %s\n', mat2str(round(pole(Gs)',4)));

% Malha fechada, realimentacao unitaria (Td = 0)
Hs = feedback(Gs,1);
[~,denH] = tfdata(Hs,'v');
wn   = sqrt(denH(3));
zeta = denH(2)/(2*wn);
fprintf('\nH(s) = %.4g / (s^2 + %.4g s + %.4g)\n', Kn, denH(2), denH(3));
fprintf('wn = %.4f rad/s, zeta = %.4f', wn, zeta);
if zeta>=1, fprintf('  -> SUPERAMORTECIDO\n'); else, fprintf('  -> subamortecido\n'); end
fprintf('Polos de H(s): %s\n', mat2str(round(pole(Hs)',4)));

%% ---------------- Item (b): periodo de amostragem T ----------------
% Superamortecido (sem oscilacao): usa-se wn como referencia.
% 10 amostras no periodo natural 2*pi/wn  ->  T = (2*pi/wn)/10
Tcycle = 2*pi/wn;
T = floor((Tcycle/10)*1e4)/1e4;     % trunca p/ 4 casas (garante >= 10 amostras)
fprintf('\nPeriodo natural 2*pi/wn = %.4f s\n', Tcycle);
fprintf('T = %.4f s  ->  amostras por ciclo = %.4f  (>= 10)\n', T, Tcycle/T);

%% -------- Discretizacao de G(s) por ZOH: fracoes parciais (a mao) --------
% G(z) = (1 - z^-1) * Z{ G(s)/s }
% G(s)/s = A/s + B/(s-s1) + C/(s-s2)
p  = pole(Gs);  s1 = p(1);  s2 = p(2);
A  = Kn/(s1*s2);
B  = Kn/(s1*(s1-s2));
C  = Kn/(s2*(s2-s1));
ea = exp(s1*T);  eb = exp(s2*T);
fprintf('\nResiduos: A=%.5f  B=%.5f  C=%.5f  (A+B+C=%.2e)\n', A,B,C, A+B+C);
fprintf('e^{s1*T}=%.4f   e^{s2*T}=%.4f\n', ea, eb);

z = tf('z', T);
Gz_hand = minreal( A + B*(z-1)/(z-ea) + C*(z-1)/(z-eb) );
fprintf('\n--- G(z) por fracoes parciais (a mao) ---\n');  Gz_hand %#ok<NOPTS>

% Conferencia automatica
Gz_c2d = c2d(Gs, T, 'zoh');
fprintf('--- G(z) por c2d (zoh) - conferencia ---\n');      Gz_c2d %#ok<NOPTS>

fprintf('Ganho DC:  G(s=0) = %.5f   |   G(z=1) = %.5f\n', dcgain(Gs), dcgain(Gz_c2d));

%% ---------------- Item (d): comprovacao do numero de amostras ----------------
tfin = 3;
t  = 0:1e-4:tfin;     yc = step(Hs, t);     % resposta continua de H(s)
tk = 0:T:tfin;        yk = step(Hs, tk);    % amostras nos instantes kT

figure('Color','w');
plot(t, yc, 'b-', 'LineWidth', 1.3); hold on; grid on;
stairs(tk, yk, 'r-', 'LineWidth', 1.0);
plot(tk, yk, 'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k');
% linha vertical no periodo natural (use 'line' se sua versao nao tiver xline)
yl = ylim;
plot([Tcycle Tcycle], yl, 'k--');
text(Tcycle, yl(1)+0.1*range(yl), sprintf('  2\\pi/\\omega_n = %.3f s', Tcycle));
xlabel('t [s]'); ylabel('\omega(t)');
legend('H(s) continua','ZOH (segura)','amostras (kT)','Location','SouthEast');
title(sprintf('Comprovacao item (b): T = %.4f s  ->  %.2f amostras em 2\\pi/\\omega_n', ...
              T, Tcycle/T));

nciclo = Tcycle/T;
fprintf('\nAmostras por periodo natural (2*pi/wn)/T = %.4f  (criterio >= 10)\n', nciclo);
