%% =======================================================================
%  Laboratorio de Controle Discreto - Questao 3 (script de APOIO)
%  Grupo: Luiz E. Passoni de Souza / Victor Damasceno Oliveira
%
%  Simula o sistema HIBRIDO  D(z) -> ZOH -> G(s)  (como o Simulink da Q1),
%  monta as metricas (D(z)G(s)) e a resposta a perturbacao de carga Td.
%  APOIO/conferencia. Confirme os valores no Simulink (Tabela 2 do .tex).
% =======================================================================
clear; clc; close all;

%% Planta fisica (com entradas Va e Td)
Ra=2; La=1; Km=0.05; Kb=0.05; J=0.05; b=0.5; T=0.1369;
Ac=[-Ra/La -Kb/La; Km/J -b/J];  Bv=[1/La;0];  Bd=[0;-1/J];  Cc=[0 1];
nf=50; dtf=T/nf;                                   % integracao fina (intra-amostral)
Mf=expm([Ac*dtf Bv*dtf Bd*dtf; zeros(2,4)]);
Phif=Mf(1:2,1:2); Gvf=Mf(1:2,3); Gdf=Mf(1:2,4);
Md=expm([Ac*T Bv*T; zeros(1,3)]); Phi=Md(1:2,1:2); Gam=Md(1:2,3);  % p/ observador

%% Controladores (mesmos da Questao 2)
RLnum=34.2409*[1 -0.7808]; RLden=[1 -1];
Wnum =[69.8477 -100.0074 35.6626]; Wden=[1 -1.3481 0.3481];   % w-transform (PI cancela polo lento + lead)
Pnum =[95.476 -123.800 40.175]; Pden=[1 -1 0];
% Espaco de estados
zeta=0.7; sigma=4; wn=sigma/zeta; wd=wn*sqrt(1-zeta^2); zd=exp((-sigma+1j*wd)*T);
Phia=[Phi zeros(2,1); -T*Cc 1]; Gama=[Gam;0];
Kaug=ackm(Phia,Gama,[zd;conj(zd);exp(-3*sigma*T)]);
Lobs=ackm(Phi',Cc',[exp(-5*sigma*T);exp(-6*sigma*T)]).';
K12=Kaug(1:2); Kis=Kaug(3);

nome={'(a) LGR','(b) Transf. w','(c) PID','(d) Esp. estados'};

%% ---- Tabela 2: resposta ao degrau, D(z) x G(s) ----
fprintf('===== Tabela 2: D(z) em cascata com G(s) (saida continua) =====\n');
fprintf('%-16s %7s %7s %7s %7s %8s\n','Controlador','tr','ts','tp','Mp%','pico');
figure('Color','w'); hold on; grid on;
[t,y]=hyb_tf(RLnum,RLden,8,0,1e9,Phif,Gvf,Gdf,Cc,T,nf); plot(t,y,'LineWidth',1.2); pr(nome{1},t,y);
[t,y]=hyb_tf(Wnum, Wden, 8,0,1e9,Phif,Gvf,Gdf,Cc,T,nf); plot(t,y,'LineWidth',1.2); pr(nome{2},t,y);
[t,y]=hyb_tf(Pnum, Pden, 8,0,1e9,Phif,Gvf,Gdf,Cc,T,nf); plot(t,y,'LineWidth',1.2); pr(nome{3},t,y);
[t,y]=hyb_ss(8,0,1e9,Phif,Gvf,Gdf,Phi,Gam,Cc,T,nf,K12,Kis,Lobs); plot(t,y,'LineWidth',1.2); pr(nome{4},t,y);
yline(1.05,'k--'); yline(1,'k:');
legend(nome,'Location','SouthEast'); xlabel('t [s]'); ylabel('\omega(t)');
title('Q3a - resposta ao degrau (D(z) \times G(s))  -> salvar como resp_degrau_q3.png');

%% ---- Perturbacao de carga Td = degrau unitario em t=4s ----
fprintf('\n===== Perturbacao Td=1 em t=4s =====\n');
fprintf('%-16s %12s %14s\n','Controlador','desvio max','t recup (2%)');
figure('Color','w'); hold on; grid on; td0=4;
[t,y]=hyb_tf(RLnum,RLden,10,1,td0,Phif,Gvf,Gdf,Cc,T,nf); plot(t,y,'LineWidth',1.2); prd(nome{1},t,y,td0);
[t,y]=hyb_tf(Wnum, Wden, 10,1,td0,Phif,Gvf,Gdf,Cc,T,nf); plot(t,y,'LineWidth',1.2); prd(nome{2},t,y,td0);
[t,y]=hyb_tf(Pnum, Pden, 10,1,td0,Phif,Gvf,Gdf,Cc,T,nf); plot(t,y,'LineWidth',1.2); prd(nome{3},t,y,td0);
[t,y]=hyb_ss(10,1,td0,Phif,Gvf,Gdf,Phi,Gam,Cc,T,nf,K12,Kis,Lobs); plot(t,y,'LineWidth',1.2); prd(nome{4},t,y,td0);
legend(nome,'Location','SouthEast'); xlabel('t [s]'); ylabel('\omega(t)');
title('Q3b - rejeicao da perturbacao de carga T_d  -> salvar como resp_perturbacao.png');

%% ===================== funcoes locais =====================
function [ts,ys]=hyb_tf(num,den,tend,Td,tdist,Phif,Gvf,Gdf,Cc,T,nf)
    na=numel(den); nb=numel(num); ne=max(na,nb);
    eb=zeros(1,ne); ub=zeros(1,ne); x=[0;0]; ts=0; ys=0; nk=floor(tend/T);
    for k=0:nk-1
        y=Cc*x; e=1-y;
        eb=[e eb(1:end-1)];
        u=(num*eb(1:nb).' - den(2:end)*ub(1:na-1).')/den(1);
        ub=[u ub(1:end-1)];
        td=(k*T>=tdist)*Td;
        for i=1:nf
            x=Phif*x+Gvf*u+Gdf*td; ys(end+1)=Cc*x; ts(end+1)=ts(end)+T/nf; %#ok<AGROW>
        end
    end
end
function [ts,ys]=hyb_ss(tend,Td,tdist,Phif,Gvf,Gdf,Phi,Gam,Cc,T,nf,K12,Kis,Lobs)
    xhat=[0;0]; xi=0; x=[0;0]; ts=0; ys=0; nk=floor(tend/T);
    for k=0:nk-1
        y=Cc*x; u=-K12*xhat - Kis*xi; td=(k*T>=tdist)*Td;
        for i=1:nf
            x=Phif*x+Gvf*u+Gdf*td; ys(end+1)=Cc*x; ts(end+1)=ts(end)+T/nf; %#ok<AGROW>
        end
        xhat=Phi*xhat+Gam*u+Lobs.'*(y-Cc*xhat); xi=xi+T*(1-y);
    end
end
function pr(nome,t,y)
    yss=1; pk=max(y); Mp=max(0,(pk-yss)/yss*100); tp=t(find(y==pk,1));
    ts=t(end); for i=numel(y):-1:1, if abs(y(i)-yss)>0.02, ts=t(min(i+1,numel(t))); break; end; end
    i10=find(y>=0.1*yss,1); i90=find(y>=0.9*yss,1); tr=t(i90)-t(i10);
    fprintf('%-16s %7.3f %7.3f %7.3f %7.2f %8.4f\n',nome,tr,ts,tp,Mp,pk);
end
function prd(nome,t,y,td0)
    i0=find(t>=td0,1); seg=y(i0:end); tseg=t(i0:end);
    dev=1-min(seg); trec=tseg(end)-td0;
    for i=numel(seg):-1:1, if abs(seg(i)-1)>0.02, trec=tseg(min(i+1,numel(tseg)))-td0; break; end; end
    fprintf('%-16s %12.4f %14.3f\n',nome,dev,trec);
end
function K=ackm(Phi,Gam,poles)
    n=size(Phi,1); pc=poly(poles); phiP=zeros(n);
    for i=1:n+1, phiP=phiP+pc(i)*Phi^(n+1-i); end
    Mc=zeros(n); for i=1:n, Mc(:,i)=Phi^(i-1)*Gam; end
    e=zeros(1,n); e(end)=1; K=real(e/Mc*phiP);
end
