
num_duct_now = 1;
% while num_duct_now < num_duct + 1
clc; clear all;

load('set_up_for_airduct.mat')
delete('set_up_for_airduct.mat')
load('duct_all.mat')
delete('duct_all.mat')

length_duct_now = duct_all(1, num_duct_now);
length_duct_end = duct_all(1, end);
X = ['now starting', num2str(num_duct_now), 'th', 'and length is',num2str(length_duct_now), '.ends at', num2str(length_duct_end)];
disp(X)
disp('loaded set_up_for_airduct.mat')

%%%%



%%%%

duct_all(2 : end, num_duct_now) = T_all(:, 3 + 17);
num_duct_now = num_duct_now + 1;
save('duct_all.mat', 'duct_all')
% end
    
    
%% 사용할 행렬들의 기본 세팅
wich_node = 17;
M=zeros(N_node,N_node);
S=zeros(N_node,N_node);
f=zeros(N_node,1);
BCT=zeros(1,N_node);

%% M, S matrix

x=room_input;

    for i=1:N_ele
         N=zeros(2,1); 
         N(1,1)=x(i,2); N(2,1)=x(i,3);
         
         A=x(i,4); U=x(i,5); L=x(i,6); CAP=x(i,7);
         Me=CAP*A*L*1/2*[1,0;0,1];
         
         if x(i,8)==1
             Se=U*A*[1,-1;-1,1];
             
         elseif x(i,8)==2
             Se=U*CAP*[1,-1;-1,1];
         end
     
         for g=1:2; h=1:2;
             M(N(g,1),N(h,1))=M(N(g,1),N(h,1))+Me(g,h);
             S(N(g,1),N(h,1))=S(N(g,1),N(h,1))+Se(g,h);
         end
    end
    
for i=1:max(size(BCN))
    M(BCN(1,i),BCN(1,i))=0;
    S(BCN(1,i),:)=0;
    S(BCN(1,i),BCN(1,i))=1;
end

M_indoorair=zeros(N_node,N_node);
M_indoorair(17,17)=1.29*1000/3600*3*3*5;
M=M+M_indoorair;
f=f+BCT';

for i=1:N_node
    if BCT(1,i)==0
        BCT(1,i)=T0_all;
    end
end

T0=BCT;

clearvars x;

%% Solar radiation(A * SHGC)
    ASHGC=zeros(10,1);
    for j=1 : N_ele_all
        %%% south
        if room_input(j,2:3)==[south,0]
                ASHGC(1,1)=room_input(j,4)*room_input(j,5);
        end
         %%% east
         if room_input(j,2:3)==[east,0]
                ASHGC(2,1)=room_input(j,4)*room_input(j,5);
        end
        %%% north
         if room_input(j,2:3)==[north,0]
                ASHGC(3,1)=room_input(j,4)*room_input(j,5);
        end
        %%% west
        if room_input(j,2:3)==[west,0]
                ASHGC(4,1)=room_input(j,4)*room_input(j,5);
        end
        %%% ceiling
        if room_input(j,2:3)==[ceiling,0]
                ASHGC(5,1)=room_input(j,4)*room_input(j,5);
        end
         %%%window
         %%% southwind
        if room_input(j,2:3)==[southwind,0]
                ASHGC(6,1)=room_input(j,4)*room_input(j,5);
        end
         %%% eastwind
         if room_input(j,2:3)==[eastwind,0]
                ASHGC(7,1)=room_input(j,4)*room_input(j,5);
        end
        %%% northwind
        if room_input(j,2:3)==[northwind,0]
                ASHGC(8,1)=room_input(j,4)*room_input(j,5);
        end
        %%% westwind
        if room_input(j,2:3)==[westwind,0]
                ASHGC(9,1)=room_input(j,4)*room_input(j,5);
        end
        %%% ceilingwind
        if room_input(j,2:3)==[ceilingwind,0]
                ASHGC(10,1)=room_input(j,4)*room_input(j,5);
        end
    end
    
disp('M, S, f matrix is done ...')
%% warmup
T_preheating1=zeros(24*30,N_node);
T_preheating2=zeros(24*30,N_node);

tspan=[0:1];

T01=T0;
T02=T0;

if D1-30*24<0
    D01=N_weather+D1-30*24+1;
    for i=1:30*24-D1
        f(16,1)=weather(D01+i-1,4);
        [t,T]=unsteady(tspan,T01,M,S,f);
        T01=T(end,:);
        T_preheating1(i,:)=T01;
    end
    T02=T_preheating1(30*24-D1,:);
    for i=1:D1
        f(16,1)=weather(i,4);
        [t,T]=unsteady(tspan,T02,M,S,f);
        T02=T(end,:);
        T_preheating2(i,:)=T02;
    end
end
if D1-30*24>0
    for i=1:30*24
        f(16,1)=weather(D1-30*24+1,4);
        [t,T]=unsteady(tspan,T01,M,S,f);
        T01=T(end,:);
        T_preheating2(i,:)=T01;
    end
end
T00=T_preheating2(end,:);

disp('warmed up !')
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% nodes info
info_duct = zeros(N_node + duct_length * 2, N_node + duct_length * 2, 1);

%% making of M, S, f_ult
M_ult = zeros(N_node + duct_length * 2, N_node + duct_length * 2);
S_ult = zeros(N_node + duct_length * 2, N_node + duct_length * 2);
f_ult = zeros(N_node + duct_length * 2, 1);

M_unit = zeros(5, 5);
S_unit = zeros(5, 5);
f_unit = zeros(5, 5);

%% making of M_unit
M_unit(1, 1) = m_airduct;
for i = 2 : 5
    M_unit(i, i) = m_soil;
end

%%%%%%%%%% M_unit의 갯수를 2개로 바꿔야 함.
%% making of S_unit

duct_conv = 1;
duc_wall_cond = 1;
duct_vent_rate = 1;

for i = 2 : 5
    x(1, 1) = 1;
    x(2, 1) = i;
    s_e = duct_conv * [1, -1; -1, 1];
    for j = 1 : 2, k = 1 : 2;
        S_unit(x(j, 1), x(k, 1)) = S_unit(x(j, 1), x(k, 1)) + s_e(x(j, 1), x(k, 1));
    end
end

%% f_unit is zeros
%% making of M, S, f_ult
M_ult(1 : N_node, 1 : N_node) = M;
S_ult(1 : N_node, 1 : N_node) = S;
f_ult(1 : N_node, 1) = f;
N_node_all = N_node + (duct_length * 5);
%% M_ult
for i = 1 : length_num_now
    start_numbers = zeros(1, duct_length);
    start_numbers(1, i) = (N_node + 1) + (i - 1) * 5;
    x = start_numbers;
    M_ult(x : x + 4, x : x + 4) = M_unit;
    S_ult(x : x + 4, x : x + 4) = S_unit;
    f_ult(x : x + 4, x : x + 4) = f_unit;
    T_0 = T0_all * zeros(1, N_node_all));
    T_0(1, 1 : N_node) = T00;
    T_all = zeros(N_weather, 3 + N_node_all);
    T_all(:, 1 : 3) = weather(:, 1 : 3);
end

%% solve ode23t
tspan=[0:1];
for i=1:N_weather
    f(16,1)=weather(i,4);
    
    %%% update solarradiation
    f(south,1)=ASHGC(1,1)*weather(i,5);
    f(east,1)=ASHGC(2,1)*weather(i,6);
    f(north,1)=ASHGC(3,1)*weather(i,7);
    f(west,1)=ASHGC(4,1)*weather(i,8);
    f(ceiling,1)=ASHGC(5,1)*weather(i,9);
    if southwind ~= 0
        f(southwind,1)=ASHGC(6,1)*weather(i,5);
    end
    if eastwind ~= 0
    f(eastwind,1)=ASHGC(7,1)*weather(i,6);
    end
    if northwind ~= 0
    f(northwind,1)=ASHGC(8,1)*weather(i,7);
    end
    if westwind ~= 0
    f(westwind,1)=ASHGC(9,1)*weather(i,8);
    end
    if ceilingwind ~= 0
    f(ceilingwind,1)=ASHGC(10,1)*weather(i,9);
    end
    
    [t,T]=unsteady(tspan,T_0, M_ult, S_ult, f_ult);
    
    T_0 = T(end,:);
    T_all(i, 4 : 3 + N_node_all)=T00;
    
    if i == round(N_weather * 1/10)
        disp('ODE is 10% solved ...')
    end
    
    if i == round(N_weather * 1/5)
        disp('ODE is 20% solved ...')
    end
    
    if i == round(N_weather * 3/10)
        disp('ODE is 30% solved ...')
    end
    
    if i == round(N_weather * 2/5)
        disp('ODE is 40% solved ...')
    end
    
    if i == round(N_weather * 5/10)
        disp('ODE is 50% solved ...')
    end
    
    if i == round(N_weather * 3/5)
        disp('ODE is 60% solved ...')
    end
    
    if i == round(N_weather * 7/10)
        disp('ODE is 70% solved ...')
    end
    
    if i == round(N_weather * 4/5)
        disp('ODE is 80% solved ...')
    end
    
    if i == round(N_weather * 9/10)
        disp('ODE is 90% solved ...')
    end
    
    if i == round(N_weather * 5/5)
        disp('ODE is 100% solved ...')
    end
    
    end

%% result
load('basic_T_all.mat')
disp('result comparing')
T_diff = basic_T_all(:, 17 + 3) - T_all(2 : end, 17 + 3);
T_diff_all(:, length_num_now) = T_all(:, 17 + 3);


%% defining the effeciency

cost_airduct = (digging_per_unit + unit_cost) * duct_length;
effi = zeros(1, num_length);
effi(1,length_num_now) = 1 / cost_airduct * sum(T_diff(D1 : D2, 1));

%% end of the while loop
    %%%%%
    save('length_all_effi.mat', 'length_all', 'effi')
    length_num_now = length_num_now + 1;
    if length_num_now > num_length
        length_done = 1;
    end
end