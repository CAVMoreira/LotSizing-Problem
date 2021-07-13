set Items;
set Weeks;
set WeeksTotal;
set Moulds;
set Orders;


set IOT within {Items,Orders,Weeks};
set IOTGas within {Items,Orders,Weeks};
set MI within {Moulds,Items};


param MouldTime = 23800; #Capacidade de produção de um molde numa semana   23800     16680
param M = 100000; #Big M

param d{Items,Orders,Weeks}  >= 0, default 0;  #Procura
#param p{Items}; #Custo Fixo produção
param h{Items}; #Custo Fixo Armazenamento
param w{Items}; #Custo Backlogging
param a{Items};  #Tempo de Produção por par
param b{Moulds};  #Tempo de Set-Up
param U{MI}; #Uso de Moldes
param B{Weeks};  #Tempo total (Capacidade total da máquina * 0,7)




var y{Moulds,Weeks} binary;  #Ativação de Set-Up Time do produto i na semana t
var x{Items,Orders,Weeks} >= 0 integer; #Quantidade de produto i produzido na semana t
var st{Items,Orders,WeeksTotal} >= 0 integer;    #Quantidade stock do propduto i na semana t
var r{Items,Orders,WeeksTotal} >= 0 integer; #Backlogging

#Função Objetivo
minimize Total_Costs:
	  sum {i in Items,o in Orders,t in Weeks} 1*r[i,o,t] + sum{t in Weeks} e[t]*500 +sum{t in Weeks} ms[t]*100*(t*t); 

#Restrições Iniciais
    
subject to InitialStock {i in Items,o in Orders}:
	st[i,o,0] = 0;

subject to InitialBacklog {i in Items,o in Orders}:
	r[i,o,0] = 0;

subject to FinalBacklog {i in Items,o in Orders}:
	r[i,o,last(Weeks)] = 0;
	
subject to InitialDisp {i in Items,o in Orders}:
	disp[i,o,0] = 0;
	
#Restrições de produção
	
subject to ProductConservation {i in Items,o in Orders, t in Weeks}:
	x[i,o,t] + st[i,o,t-1] + r[i,o,t] =  d[i,o,t] + r[i,o,t-1] + st[i,o,t]; 

subject to ProductLimitation {i in Items, t in Weeks}:
	sum{o in Orders} x[i,o,t]*a[i] <= sum{(m,ii) in MI: ii=i} (MouldTime*y[m,t]*U[m,ii]); 
	
subject to TotalCapacityLimitation {t in Weeks}:
	sum{i in Items, o in Orders} a[i]*x[i,o,t] + sum{m in Moulds} b[m]*y[m,t] <= B[t]; 	

	

