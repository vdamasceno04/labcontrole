%% =======================================================================
%  Laboratorio de Controle Discreto - Questao 2 (script de APOIO)
%  Grupo: Luiz E. Passoni de Souza / Victor Damasceno Oliveira
%
%  Projeta os 4 controladores de velocidade D(z) e simula a malha fechada.
%  APOIO/conferencia. NAO usa sisotool/pidtune. Specs: Mp<=5%, Ts<2s, ess<=1%.
% =======================================================================
clear; clc; close all;

%% Planta
Ra=2; La=1; Km=0.05; Kb=0.05; J=0.05; b=0.5; T=0.1369;
den2=La*J; den1=La*b+Ra*J; den0=Ra*b+Km*Kb;
Kn=Km/den2; an1=den1/den2; an0=den0/den2;     % G(s)=Kn/(s^2+an1 s+an0)
Gs=tf(Kn,[1 an1 an0]);  Gz=c2d(Gs,T,'zoh');
fprintf('G(z):'); Gz %#ok<NOPTS>
zeta_min=-log(0.05)/sqrt(pi^2+log(0.05)^2);
fprintf('zeta_min(Mp<=5%%)=%.4f\n',zeta_min);

%% ===== (a) LUGAR DAS RAIZES :  D(z)=K(z-zc)/(z-1) =====
zeta=0.7; sigma=3.8; wn=sigma/zeta; wd=wn*sqrt(1-zeta^2); zd=exp((-sigma+1j*wd)*T);
Gzd=evalfr(Gz,zd);
ang=-180-rad2deg(angle(Gzd))+rad2deg(angle(zd-1)); ang=mod(ang+180,360)-180;
zc=real(zd)-imag(zd)/tand(ang);  K=abs(zd-1)/(abs(zd-zc)*abs(Gzd));
Da=tf(K*[1 -zc],[1 -1],T);
fprintf('\n(a) LGR: zd=%.4f%+.4fi |G|=%.4f angG=%.2f zc=%.4f K=%.4f\n',real(zd),imag(zd),abs(Gzd),rad2deg(angle(Gzd)),zc,K); Da %#ok<NOPTS>
figure('Color','w'); rlocus((tf([1 -zc],[1 -1],T))*Gz); hold on; zgrid;
plot(real([zd conj(zd)]),imag([zd conj(zd)]),'rs','MarkerSize',9,'LineWidth',1.5);
title('(Q2a) Lugar das raizes: (z-z_c)/(z-1) G(z)   -> salvar como rlocus_a.png');

%% ===== (b) TRANSFORMADA w : PI (cancela polo lento) + AVANCO =====
Gw = d2c(Gz,'tustin');                 % planta no plano w
pw = pole(Gw); [~,ix]=max(real(pw)); zi=-real(pw(ix));   % zero do PI cancela polo lento
zeta=0.7; PMreq=atand(2*zeta/sqrt(-2*zeta^2+sqrt(1+4*zeta^4)));
wgc=4.5;
Dpi=tf([1 zi],[1 0]);
faseGPI=rad2deg(angle( evalfr(Gw,1j*wgc)*evalfr(Dpi,1j*wgc) ));
phimax=PMreq-(180+faseGPI)+10;
alpha=(1-sind(phimax))/(1+sind(phimax)); wz=wgc*sqrt(alpha); wp=wgc/sqrt(alpha);
Dlead=tf([1/wz 1],[1/wp 1]);
Kw=1/abs( evalfr(Gw,1j*wgc)*evalfr(Dpi,1j*wgc)*evalfr(Dlead,1j*wgc) );
Dw=Kw*Dpi*Dlead;  Db=c2d(Dw,T,'tustin');
fprintf('\n(b) W: zi(cancela polo lento)=%.4f wgc=%.2f PMreq=%.2f faseG*PI=%.2f phimax=%.2f alpha=%.4f wz=%.4f wp=%.4f Kw=%.4f\n',...
        zi,wgc,PMreq,faseGPI,phimax,alpha,wz,wp,Kw); Db %#ok<NOPTS>
figure('Color','w'); margin(Dw*Gw); grid on;
title('(Q2b) Bode de L(w)=D(w)G(w) [margem de fase]  -> salvar como bode_w.png');

%% ===== (c) PID =====
zeta=0.95; sigma=2.5; p3=5*sigma; wn=sigma/zeta;
des=conv([1 2*sigma wn^2],[1 p3]);
Kd=(des(2)-an1)/Kn; Kp=(des(3)-an0)/Kn; Ki=des(4)/Kn;
q2=Kp+Ki*T/2+Kd/T; q1=-Kp+Ki*T/2-2*Kd/T; q0=Kd/T;
Dc=tf([q2 q1 q0],[1 -1 0],T);
fprintf('\n(c) PID: Kp=%.4f Ki=%.4f Kd=%.4f | q=[%.4f %.4f %.4f]\n',Kp,Ki,Kd,q2,q1,q0); Dc %#ok<NOPTS>

%% ===== (d) ESPACO DE ESTADOS =====
Ac=[-Ra/La -Kb/La; Km/J -b/J]; Bc=[1/La;0]; Cc=[0 1];
Md=expm([Ac*T Bc*T; zeros(1,3)]); Phi=Md(1:2,1:2); Gam=Md(1:2,3);
Phia=[Phi zeros(2,1); -T*Cc 1]; Gama=[Gam;0];
zeta=0.7; sigma=4; wn=sigma/zeta; wd=wn*sqrt(1-zeta^2); zd=exp((-sigma+1j*wd)*T);
Kaug=ackm(Phia,Gama,[zd;conj(zd);exp(-3*sigma*T)]);
Lobs=ackm(Phi',Cc',[exp(-5*sigma*T);exp(-6*sigma*T)]).';
fprintf('\n(d) SS: Phi=[%.4f %.4f;%.4f %.4f] Gam=[%.4f;%.4f]\n',Phi(1,1),Phi(1,2),Phi(2,1),Phi(2,2),Gam(1),Gam(2));
fprintf('     Kaug=[%.4f %.4f %.4f] L=[%.4f;%.4f]\n',Kaug(1),Kaug(2),Kaug(3),Lobs(1),Lobs(2));
K12=Kaug(1:2); Kis=Kaug(3);
Acl=[Phi-Gam*K12 -Gam*Kis; -T*Cc 1]; Bcl=[0;0;T]; Ccl=[Cc 0];
SSd=ss(Acl,Bcl,Ccl,0,T);

%% ===== Simulacao e metricas (D(z) x G(z)) =====
sys={feedback(Da*Gz,1),feedback(Db*Gz,1),feedback(Dc*Gz,1),SSd};
nome={'(a) LGR','(b) Transf. w','(c) PID','(d) Esp. estados'};
figure('Color','w'); hold on; grid on;
fprintf('\n===== Metricas D(z)G(z) =====\n%-16s %7s %7s %7s %7s %7s\n','Controlador','Mp(%)','Ts(s)','Tr(s)','Tp(s)','ess(%)');
for i=1:4
    [y,t]=step(sys{i},8); plot(t,y,'LineWidth',1.3); si=stepinfo(sys{i});
    fprintf('%-16s %7.2f %7.3f %7.3f %7.3f %7.3f\n',nome{i},si.Overshoot,si.SettlingTime,si.RiseTime,si.PeakTime,abs(1-dcgain(sys{i}))*100);
end
yline(1.05,'k--'); yline(1,'k:'); legend(nome,'Location','SouthEast');
xlabel('t [s]'); ylabel('\omega'); title('Q2 - resposta ao degrau (D(z) \times G(z))');

%% ===== Ackermann manual (local function) =====
function K=ackm(Phi,Gam,poles)
    n=size(Phi,1); pc=poly(poles); phiP=zeros(n);
    for i=1:n+1, phiP=phiP+pc(i)*Phi^(n+1-i); end
    Mc=zeros(n); for i=1:n, Mc(:,i)=Phi^(i-1)*Gam; end
    e=zeros(1,n); e(end)=1; K=real(e/Mc*phiP);
end
