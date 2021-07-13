set Items;
set Weeks;
set WeeksLess;
set WeeksTotal;
set Moulds;


set TTPlus within {Weeks,WeeksLess};
set IT within {Items,Weeks};
set MI within {Moulds,Items};
set ITT within {Items,Weeks,WeeksLess};

param d{IT}  >= 0;  #Procura
param c{IT}  >= 0;  #Capacidade Produtiva (Moldes)
param g{IT}; #Entrega "Prevista" de gáspeas

param h{IT}; #Custo Fixo Armazenamento
param w{IT}; #Custo Backlogging

param a{Items};  #Tempo de Produção por par
param b{Moulds};  #Tempo de Set-Up

param U{Moulds,Items}; #Uso de Moldes
param B{Weeks};  #Tempo total disponivel (Capacidade total da máquina)



var x{Items,Weeks} >= 0 integer; #Quantidade de produto i produzido na semana t
var st{Items,WeeksTotal} >= 0 integer;    #Quantidade stock do propduto i na semana t
var y{Moulds,Weeks} binary;  #Confirmação de Set-Up do produto i na semana t
var r{Items,WeeksTotal} >= 0 integer; #Backlogging
var disp{Items,WeeksTotal} >=0 integer; #Disponibilidade de gáspeas para o produto i na semana t (Item "i" pode ser substituido se existirem gaspeas usadas para mais
#do que um sapato

#Função Objetivo
minimize Total_Costs:
	    sum {(i,t) in IT} h[i,t]*st[i,t] + sum {(i,t) in IT} w[i,t]*r[i,t] + sum {m in Moulds, t in Weeks} y[m,t];
	    
#Restrições
    
subject to InitialStock {i in Items}: #mudar semanas para vaalores numericos
	st[i,"Week 0"] = 0;

subject to InitialBacklog {i in Items}:
	r[i,"Week 0"] = 0;

subject to FinalBacklog {i in Items}:
	r[i,"Week 12"] = 0;
	
subject to InitialDisp {i in Items}:
	disp[i,"Week 0"] = 0;
	
subject to ProductConservation {(i,t,tless) in ITT}:
	x[i,t] + st[i,tless] + r[i,t] =  d[i,t] + r[i,tless] + st[i,t]; 

subject to UpperConservation {(i,t,tless) in ITT}:
	disp[i,tless] + g[i,t] - x[i,t] + r[i,t]= disp[i,t];	

subject to UpperLimitation {(i,t) in IT}:
	x[i,t] <= disp[i,t];

subject to ProductLimitation {(i,t) in IT}:
	x[i,t]*a[i] <= sum{(m,ii) in MI: ii=i} 31500*y[m,t]*U[m,ii]; #Deixar parametro #Adicionar tempo de set-up à esquerda
	
subject to TotalCapacityLimitation {t in Weeks}:
	sum{i in Items} a[i]*x[i,t] + sum{m in Moulds} b[m]*y[m,t] <= B[t]; 	