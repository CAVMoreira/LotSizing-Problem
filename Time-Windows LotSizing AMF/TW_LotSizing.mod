set Items;
set Weeks ordered;
set WeeksTotal;
set Moulds;
set Vehicles;
set WeeksTotalPlus;
set Orders;

set IOW within {Items,Orders}; #Juntar IOW ao IO
set IO within {Items,Orders};
set IOTGas within {Items,Orders,Weeks};

set MI within {Moulds,Items};
param M = 100000; #Big M


param MouldTime{Weeks}; #Capacidade de produção de um molde numa semana   23800  16680
param MouldTimeExtra{Weeks}; #Capacidade de produção de um molde numa semana 7120
param d{Items,Orders} >= 0, default 0;  #Procura
param EWeek{Items,Orders};
param LWeek{Items,Orders};

param h{Items}; #Custo Fixo Armazenamento
param w{Items}; #Custo Backlogging
param a{Items};  #Tempo de Produção por par
param b{Moulds};  #Tempo de Set-Up
param U{MI}; #Uso de Moldes
param B{Weeks};  #Tempo total (Capacidade total da máquina * 0,7)
param EB{Weeks}; #Tempo Extra 
param gas{Items,Orders,WeeksTotal} >= 0, default 0; #Qty de chegada de gáspeas

var e{Weeks} binary; #Ativação do tempo extra
var ms{Weeks} binary; #Ativação da semana
var y{Moulds,Weeks} binary;  #Ativação de Set-Up Time do produto i na semana t

var x{Items,Orders,Weeks} >= 0 integer; #Quantidade de produto i produzido na semana t
var st{Items,Orders,WeeksTotal} >= 0 integer; #Quantidade stock do propduto i na semana t
var r{Items,Orders,WeeksTotal} >= 0 integer; #Backlogging
var disp{Items,Orders,WeeksTotalPlus} >=0 integer; #Disponibilidade de gáspeas para o produto i na semana t (Item "i" pode ser substituido se existirem gaspeas usadas para mais
var D{Items,Orders,Weeks} >=0 integer;

#do que um sapato

#Função Objetivo
minimize Total_Costs:
	  sum {(i,o) in IO,t in Weeks} 2*r[i,o,t] + sum {(i,o) in IO,t in Weeks} st[i,o,t] + sum{t in Weeks} e[t]*500; 


#Restrições Iniciais
    
subject to InitialStock {(i,o) in IO}:
	st[i,o,0] = 0;

subject to InitialBacklog {(i,o) in IO}:
	r[i,o,0] = 0;

subject to FinalBacklog {(i,o) in IO}:
	r[i,o,last(Weeks)] = 0;
	
subject to InitialDisp {(i,o) in IO}:
	disp[i,o,0] = 0;
	
#Restrições de produção
	
subject to ProductConservation {(i,o) in IO, t in Weeks}:
	ms[t]*x[i,o,t] + (st[i,o,t-1] - r[i,o,t-1]) - D[i,o,t] = - r[i,o,t] + st[i,o,t]; 

subject to ProductLimitation {i in Items, t in Weeks}:
	sum{o in Orders} x[i,o,t]*a[i] <= sum{(m,ii) in MI: ii=i} (MouldTime[t]*y[m,t]*U[m,ii]+MouldTimeExtra[t]*e[t]*y[m,t]*U[m,ii]); 
	
subject to TotalCapacityLimitation {t in Weeks}:
	sum{(i,o) in IO} a[i]*x[i,o,t] + sum{m in Moulds} b[m]*y[m,t] <= B[t] + EB[t]*e[t]; 	

#Restrições Matéria-Prima
	
subject to UpperConservation {(i,o) in IO, t in WeeksTotal: t!=0}:
	gas[i,o,t-1] + disp[i,o,t-1] - x[i,o,t] = disp[i,o,t];	
	
#Restrições de Janelas Temporais

subject to 1D {(i,o) in IO,t in 1..EWeek[i,o]-1}:
	D[i,o,t] = 0;
	
subject to 2D {(i,o) in IO,t in LWeek[i,o]+1..last(Weeks)}:
	D[i,o,t] = 0;
	
subject to 3D {(i,o) in IO,t in EWeek[i,o]..LWeek[i,o]}:
	D[i,o,t] >= 0;	
	
subject to DemandVariation {(i,o) in IO}:
	sum{t in EWeek[i,o]..LWeek[i,o]} D[i,o,t] = d[i,o];	
