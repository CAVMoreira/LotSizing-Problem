set Items;
set Weeks;
set WeeksTotal;
set Moulds;
set Vehicles;
set WeeksTotalPlus;
set Orders;

set TTPlus within {Weeks,WeeksLess};
set IT within {Items,Weeks};
set IOT within {Items,Orders,Weeks}
set MI within {Moulds,Items};


param d{IT}  >= 0;  #Procura
#param g{IT}; #Entrega "Prevista" de gáspeas

param h{IT}; #Custo Fixo Armazenamento
param w{IT}; #Custo Backlogging

param a{Items};  #Tempo de Produção por par
param b{Moulds};  #Tempo de Set-Up

param U{Moulds,Items}; #Uso de Moldes
param B{Weeks};  #Tempo total disponivel (Capacidade total da máquina)

#param e{Items}; #Custo de produção da gaspea 
param c{Vehicles}; #Capacidade do Veiculo
param lt{Vehicles}; #Lead time de chegada da encomenda consoante o veiculo
param u{Vehicles}; #Custo fixo de utilização de um veiculo
param MouldTime = 31500;
param M= 100000;

var g{Items,WeeksTotalPlus} >=0 integer; #Chegada das gáspeas do item i na semana t
var z{Vehicles,WeeksTotal} binary; #Ativação do veiculo
var ord{Items,Vehicles,WeeksTotal} >=0 integer; #Quantidade de produto i transportado no veiculo v e encomendado na semana t 
var x{Items,Weeks} >= 0 integer; #Quantidade de produto i produzido na semana t
var st{Items,WeeksTotal} >= 0 integer;    #Quantidade stock do propduto i na semana t
var y{Moulds,Weeks} binary;  #Ativação de Set-Up do produto i na semana t
var r{Items,WeeksTotal} >= 0 integer; #Backlogging
var disp{Items,WeeksTotal} >=0 integer; #Disponibilidade de gáspeas para o produto i na semana t (Item "i" pode ser substituido se existirem gaspeas usadas para mais
#do que um sapato

#Função Objetivo
minimize Total_Costs:
	    sum {(i,t) in IT} h[i,t]*st[i,t] + sum {(i,t) in IT} w[i,t]*r[i,t] + sum {m in Moulds, t in Weeks} y[m,t] + sum {t in Weeks, v in Vehicles} z[v,t]*u[v];
	    
#Restrições
    
subject to InitialStock {i in Items}:
	st[i,0] = 0;

subject to InitialBacklog {i in Items}:
	r[i,0] = 0;

subject to FinalBacklog {i in Items}:
	r[i,12] = 0;
	
subject to InitialDisp {i in Items}:
	disp[i,0] = 0;
	
subject to InitialOrd {i in Items,v in Vehicles}: #Nova
	ord[i,v,0] = 0;
	
subject to ProductConservation {(i,t) in IT}:
	x[i,t] + st[i,t-1] + r[i,t] =  d[i,t] + r[i,t-1] + st[i,t]; 

subject to UpperConservation {(i,t) in IT}:
	disp[i,t-1] + g[i,t] - x[i,t] + r[i,t]= disp[i,t] ;	

subject to UpperLimitation {(i,t) in IT}:
	x[i,t] <= disp[i,t];

subject to ProductLimitation {(i,t) in IT}:
	x[i,t]*a[i] <= sum{(m,ii) in MI: ii=i} MouldTime*y[m,t]*U[m,ii]; 
	
subject to TotalCapacityLimitation {t in Weeks}:
	sum{i in Items} a[i]*x[i,t] + sum{m in Moulds} b[m]*y[m,t] <= B[t]; 	
	
#Restrições das encomendas

subject to VehicleCapacityLimitation {t in WeeksTotal,v in Vehicles}:
	 sum{i in Items} ord[i,v,t] <= c[v]; 

subject to VehicleActivation {t in WeeksTotal,v in Vehicles}:
	 sum{i in Items} ord[i,v,t] <= z[v,t]*M; #Definir o M
	 
subject to UpperArrival {(i,t) in IT}:#Nova
	 g[i,t] = sum{v in Vehicles} ord[i,v,max(t-lt[v],0)]; 
	 