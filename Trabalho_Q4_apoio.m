%% =======================================================================
%  Laboratorio de Controle Discreto - Questao 4 / bonus (script de APOIO)
%  Grupo: Luiz E. Passoni de Souza / Victor Damasceno Oliveira
%
%  Controle de POSICAO. Planta Gth(s)=G(s)/s (Tipo 1 -> ess=0 sem integrador
%  no controlador). Projeta um lead D(z)=K(z-zc)/(z-pc) para sobrepasso minimo.
%  NAO usa sisotool/pidtune.
% =======================================================================
clear; clc; close all;

Ra=2; La=1; Km=0.05; Kb=0.05; J=0.05; b=0.5; T=0.1369;

%% Planta de posicao
Gth_s = tf(1,[1 12 20.05 0]);        % 1/(s^3+12 s^2+20.05 s)
Gth_z = c2d(Gth_s,T,'zoh');
fprintf('Gth(z):'); Gth_z %#ok<NOPTS>
fprintf('Polos de Gth(z): %s\n', mat2str(round(pole(Gth_z).',4)));

%% Projeto lead: zc cancela polo lento; angulo -> pc; modulo -> K
zc=0.7598; zeta=0.98; sigma=1.5;
wn=sigma/zeta; wd=wn*sqrt(1-zeta^2);
zd=exp((-sigma+1j*wd)*T);
Gd=evalfr(Gth_z,zd);
ang_pc = rad2deg(angle(zd-zc)) + rad2deg(angle(Gd)) + 180;   % cond. de angulo
ang_pc = mod(ang_pc+180,360)-180;
pc = real(zd) - imag(zd)/tand(ang_pc);
K  = abs(zd-pc)/(abs(zd-zc)*abs(Gd));
D  = tf(K*[1 -zc],[1 -pc],T);
fprintf('\nzd=%.4f%+.4fi  |Gth(zd)|=%.4f angGth=%.2f deg  pc=%.4f  K=%.4f\n',...
        real(zd),imag(zd),abs(Gd),rad2deg(angle(Gd)),pc,K);
fprintf('D(z) = %.4f (z-%.4f)/(z-%.4f)\n',K,zc,pc); D %#ok<NOPTS>

%% Malha fechada e metricas (D(z) x Gth(z))
CL = feedback(D*Gth_z,1);
fprintf('Polos de MF: %s\n', mat2str(round(pole(CL).',4)));
si = stepinfo(CL);
fprintf('D(z)Gth(z): Mp=%.3f%%  Ts=%.3f s  Tr=%.3f s  ess=%.4f\n',...
        si.Overshoot, si.SettlingTime, si.RiseTime, abs(1-dcgain(CL)));

%% Verificacao no continuo (D(z) -> ZOH -> Gth(s))  via integracao fina
Ac=[-Ra/La -Kb/La 0; Km/J -b/J 0; 0 1 0]; Bv=[1/La;0;0]; Cc=[0 0 1];
nf=60; dtf=T/nf; Mf=expm([Ac*dtf Bv*dtf; zeros(1,4)]); Phif=Mf(1:3,1:3); Gvf=Mf(1:3,4);
[bz,az]=tfdata(D,'v'); na=numel(az); nb=numel(bz); ne=max(na,nb);
eb=zeros(1,ne); ub=zeros(1,ne); x=[0;0;0]; ts=0; ys=0; nk=floor(8/T);
for k=0:nk-1
    y=Cc*x; e=1-y; eb=[e eb(1:end-1)];
    u=(bz*eb(1:nb).' - az(2:end)*ub(1:na-1).')/az(1); ub=[u ub(1:end-1)];
    for i=1:nf, x=Phif*x+Gvf*u; ys(end+1)=Cc*x; ts(end+1)=ts(end)+dtf; end %#ok<AGROW>
end
yss=ys(end); Mp=max(0,(max(ys)-yss)/yss*100);
fprintf('D(z)Gth(s) [continuo]: Mp=%.3f%%  yss=%.4f\n',Mp,yss);

%% Graficos
figure('Color','w'); rlocus(tf([1 -zc],[1 -pc],T)*Gth_z); zgrid;
title('(Q4) Lugar das raizes: (z-z_c)/(z-p_c) G_\theta(z)');

figure('Color','w'); step(CL,8); grid on; hold on; plot(ts,ys,'--','LineWidth',1.2);
legend('D(z)G_\theta(z) (discreto)','D(z)G_\theta(s) (continuo)','Location','SouthEast');
xlabel('t [s]'); ylabel('\theta');
title('Q4 - resposta ao degrau de posicao (M_p=0%)  -> salvar como resp_posicao.png');
