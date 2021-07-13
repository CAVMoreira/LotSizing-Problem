set Items;
set Weeks;
set WeeksTotal;
set Moulds;
set Vehicles;
set WeeksTotalPlus;
set Orders;


set IOT within {Items,Orders,Weeks};
set MI within {Moulds,Items};


param MouldTime = 31500; #Capacidade de produção de um molde numa semana
param M = 100000; #Big M

param d{Items,Orders,Weeks}  >= 0, default 0;  #Procura
param h{Items}; #Custo Fixo Armazenamento
param w{Items}; #Custo Backlogging
param a{Items};  #Tempo de Produção por par
param b{Moulds};  #Tempo de Set-Up
param U{MI}; #Uso de Moldes
param B{Weeks};  #Tempo total (Capacidade total da máquina * 0,8)
param EB{Weeks}; #Tempo Extra 
param c{Vehicles}; #Capacidade do Veiculo
param lt{Vehicles}; #Lead time de chegada da encomenda consoante o veiculo
param u{Vehicles}; #Custo fixo de utilização de um veiculo

var g{Items,WeeksTotalPlus} >=0 integer; #Chegada das gáspeas do item i na semana t
var z{Vehicles,WeeksTotal} binary; #Ativação do veiculo
var ord{Items,Orders,Vehicles,WeeksTotal} >=0 integer; #Quantidade de produto i transportado no veiculo v e encomendado na semana t 
var x{Items,Orders,Weeks} >= 0 integer; #Quantidade de produto i produzido na semana t
var st{Items,Orders,WeeksTotal} >= 0 integer;    #Quantidade stock do propduto i na semana t
var y{Moulds,Weeks} binary;  #Ativação de Set-Up do produto i na semana t
var r{Items,Orders,WeeksTotal} >= 0 integer; #Backlogging
var disp{Items,Orders,WeeksTotal} >=0 integer; #Disponibilidade de gáspeas para o produto i na semana t (Item "i" pode ser substituido se existirem gaspeas usadas para mais
#do que um sapato

#Função Objetivo
minimize Total_Costs:
	   sum {i in Items,o in Orders,t in Weeks} h[i]*st[i,o,t] + sum {i in Items,o in Orders,t in Weeks} w[i]*r[i,o,t] +  sum {t in Weeks, v in Vehicles} z[v,t]*u[v];#sum {m in Moulds, t in Weeks} y[m,t] +
	    
#Restrições Iniciais
    
subject to InitialStock {i in Items,o in Orders}:
	st[i,o,0] = 0;

subject to InitialBacklog {i in Items,o in Orders}:
	r[i,o,0] = 0;

subject to FinalBacklog {i in Items,o in Orders}:
	r[i,o,6] = 0;
	
subject to InitialDisp {i in Items,o in Orders}:
	disp[i,o,0] = 0;
	
subject to InitialOrd {i in Items,v in Vehicles,o in Orders}: 
	ord[i,o,v,0] = 0;

#Restrições de produção
	
subject to ProductConservation {i in Items,o in Orders, t in Weeks}:
	x[i,o,t] + st[i,o,t-1] + r[i,o,t] =  d[i,o,t] + r[i,o,t-1] + st[i,o,t]; 

subject to ProductLimitation {i in Items, t in Weeks}:
	sum{o in Orders} x[i,o,t]*a[i] <= sum{(m,ii) in MI: ii=i} MouldTime*y[m,t]*U[m,ii]; 
	
subject to TotalCapacityLimitation {t in Weeks}:
	sum{i in Items, o in Orders} a[i]*x[i,o,t] + sum{m in Moulds} b[m]*y[m,t] <= B[t] + EB[t]; 	

#Restrições Matéria-Prima
	
subject to UpperConservation {i in Items,o in Orders, t in Weeks}:
	disp[i,o,t-1] - x[i,o,t] = disp[i,o,t];	
	


#Restrições das encomendas

#subject to VehicleCapacityLimitation {t in WeeksTotal,v in Vehicles}:
#	 sum{i in Items, o in Orders} ord[i,o,v,t] <= c[v]; 

#subject to VehicleActivation {t in WeeksTotal,v in Vehicles}:
#	 sum{i in Items,o in Orders} ord[i,o,v,t] <= z[v,t]*M;

#subject to UpperConservation {i in Items,o in Orders, t in Weeks}:
#	sum{v in Vehicles} ord[i,o,v,max(t-lt[v],0)] + disp[i,o,t-1] - x[i,o,t] = disp[i,o,t];	
	
	
	
#Restrições de Preferencia

#subject to OrderPreference {o in Orders: o = 1}:
#	sum{t in Weeks,i in Items} r[i,o,t] <= sum{t in Weeks,i in Items} x[i,o,t]*0;	#Possivel de adicionar um novo parametro para cada order
