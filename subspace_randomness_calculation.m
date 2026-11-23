clear;clc;

dims = 6; 
ndim = length(dims);
ma = 2; 
lower_bound=1+(ma-1)/sqrt(dims)-0.5;



%% %%%%%%%%%%%%%%%%%%%% 需要改的参数
npoints =[51];
eta=[1];
pp=linspace(0,1,npoints);
% % % % % % % mode=[1]; %0是理论分析探测效率、噪声阈值等，1是计算实验获得的随机数H
eta_exp=1;        
% betav=[1.174550079];      
% betavbar = [0.015454]; 
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Hmindv = zeros(ndim,npoints);       
Hminexp = zeros(3,ndim);            
    
for i = 1:ndim   
    dA = dims(i); 
    dB = dA;
    oa = dA; 
    Fax = zeros(dA,dA,oa,ma); 
    Id = eye(dA);
    for a = 1:dA
        Fax(:,:,a,2) = Id(:,a)*Id(a,:); % computational basis 
        Fax(:,:,a,1) = FourierMatrix(dA)*Fax(:,:,a,2)*FourierMatrix(dA)';         
    end
    for j = 1:npoints
        Hmindv(i,j) = RandomnessSteeringInequality(Fax,betav,pp(j),eta,0);  
    end
    Hminexp(1,i) = RandomnessSteeringInequality(Fax,betav(i)-betavbar(i),1,eta_exp,1);
    Hminexp(2,i) = RandomnessSteeringInequality(Fax,betav(i),1,eta_exp,1);
    Hminexp(3,i) = RandomnessSteeringInequality(Fax,betav(i)+betavbar(i),1,eta_exp,1);
end

% figure
hold  on
colours = ['r'; 'g'; 'b';'k'];
plot(pp,Hmindv)
% plot(eta_exp,Hminexp(1,i),strcat('x',colours(i)))
% plot(eta_exp,Hminexp(2,i),strcat('x',colours(i)))
% plot(eta_exp,Hminexp(3,i),strcat('x',colours(i)))
xlabel('Efficiency/PP','Interpreter','latex')
ylabel('$H_\mathrm{min}(x=1)$','Interpreter','latex')

%% 函数  需要凸优化 去https://cvxr.com/cvx/download/   下载，网上也有安装教程
function Hmin = RandomnessSteeringInequality(Fax,beta,p,eta,mode)

[dB,~,oa,ma] = size(Fax);   
PgObj = permute(repmat(eye(oa),[1,1,dB,dB]),[3,4,1,2])...
    .*repmat(eye(dB),[1,1,oa,oa]);

for i=1:dB
    PgObj(:,:,i,i)=PgObj(:,:,i,i);
end

cvx_begin sdp quiet
    variable sigaex(dB,dB,oa,oa,ma) hermitian semidefinite
    maximise real(sum(reshape(PgObj.*sigaex(:,:,:,:,1),1,[])))

    subject to
    if mode==0
         ma*(p*eta+eta*(1-p)/dB+(1-eta)/sqrt(dB))== real(sum(reshape(conj(Fax).*squeeze(sum(sigaex,4)),1,[])));
%         beta== real(sum(reshape(conj(Fax).*squeeze(sum(sigaex,4)),1,[])));

    elseif mode==1
        eta*beta+ma*(1-eta)/sqrt(dB)== real(sum(reshape(conj(Fax).*squeeze(sum(sigaex,4)),1,[])));
    else
        error('Wrong mode')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%根据模型改左边就行 p是各向同性态的噪声参数；eta是整体探测效率
    for x = 1:ma
        for x1 = 1:ma
            for e = 1:oa
                (sum(sigaex(:,:,:,e,x),3)) == (sum(sigaex(:,:,:,e,x1),3))
            end
        end
    end
    for x = 1:ma
        1 == trace(squeeze(sum(sum(sigaex(:,:,:,:,x),4),3)))
    end
cvx_end
Hmin = -log2(cvx_optval);
return
end