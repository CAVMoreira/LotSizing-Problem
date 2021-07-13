set Items;
set Weeks;
set WeeksLess;
set WeeksTotal;

set TTPlus within {Weeks,WeeksLess};
set IT within {Items,Weeks};

param d{IT}  >= 0;  #Procura
param c{IT}  >= 0;  #Capacidade Produtiva (Moldes)

param h{IT}; #Custo Fixo Armazenamento


param a{Items};  #Tempo de Produção por par
param b{Items};  #Tempo de Set-Up
param m{Items};  #Nº de Moldes
param B{Weeks};  #Tempo total disponivel (Capacidade total da máquina)

var x{Items,Weeks} integer; #Quantidade de produto i produzido na semana t
var st{Items,WeeksTotal} >= 0;    #Quantidade stock do propduto i na semana t
var y{Items,Weeks} binary;  #Confirmação de Set-Up do produto i na semana t

#Função Objetivo
minimize Total_Costs:
	    sum {(i,t) in IT} h[i,t]*st[i,t];
	    
#Restrições
    
subject to InitialStock {i in Items}:
	st[i,"Week 1"] = 0;
	
subject to ProductConservation {i in Items, (t,tless) in TTPlus}:
	x[i,t] + st[i,tless] = st[i,t] + d[i,t];
	
subject to ProductLimitation {(i,t) in IT}:
	x[i,t]*a[i] <= m[i]*c[i,t]*y[i,t]; 
	
subject to TotalCapacityLimitation {t in Weeks}:
	sum{i in Items} a[i]*x[i,t] + sum{i in Items} m[i]*b[i]*y[i,t] <= B[t];	 