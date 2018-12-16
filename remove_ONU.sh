#!/bin/bash
usuario="raphael";
senha="4t0m0s";
senha2="R@ph@3L1";
Login="$usuario $senha"
Login2="$usuario $senha2"
IPVRD="acesso-olt-dinamico.sh 10.80.80.6";
IPBMA="acesso-olt-dinamico.sh 10.80.80.10";
IPROM="acesso-olt-dinamico.sh 10.80.80.2";
IPPOR="acesso-olt-dinamico.sh 10.80.80.14";
IPQUA="acesso-olt-dinamico.sh 10.80.80.18";
file_base="acesso-olt.txt";
file_dinamic="acesso-olt-dinamico.sh";
input_serials="./seriais.txt";
file_output="./acesso-olt-dinamico.sh";
echo "" >> $file_output;
file_input="./logs/log_remocao.txt";
SlinhaR(){
	linhaR='\r"';
	echo $linhaR >> $file_output;
}
SlinhaR2(){
	linhaR='send "\r"';
	echo $linhaR >> $file_output;
}
SlinhaQ(){
	linhaQ='send "q\r"';
	echo $linhaQ >> $file_output;
}
Squit(){
	comquit='send "quit\r"';
	echo 'expect "*(config)#*"' >> $file_output;
	echo 'send "quit\r"' >> $file_output;
	echo 'expect "*#*"' >> $file_output;
	echo 'send "quit\r"' >> $file_output;
	echo 'sleep 1' >> $file_output;
	echo 'sleep 1' >> $file_output;
	echo 'expect "*n]:*"' >> $file_output;
	echo "sleep 1" >>  $file_output;
	echo 'send -- "y \r"' >> $file_output;
	echo 'sleep 1' >> $file_output;
}
#MOSTRAR INFORMAÇÃO DOS SERIAIS
find_onu_status(){
	cat $file_base > $file_dinamic;
	echo "" >> $input_serials;
	while read -r line
	do
	    linha="$line";
	    fos='send "'$(echo "display ont info by-sn "$linha);
	    echo $fos >> $file_output; SlinhaR;
	    echo 'expect "*(config)#"' >> $file_output; SlinhaQ;
	done < "$input_serials"
	Squit;
	cat $input_serials > "./logs/seriais.txt";
	echo "" > $input_serials;
	echo -e "---------- FIM 'find_onu_status' ----------";
}
#LEITURA DO SERVICE PORT
find_service_port(){
	cat $file_base > $file_dinamic;
	echo "" >> $file_output;
	while read -r line
	do
	    linha="$line"
	    serial=${linha:22:16}
	    case "$linha" in
	    	*F/S/P*)
				dsp='send "'$(echo "$linha" | awk -F' ' '{print "display service-port port " $3}');
				echo $dsp >> $file_output; SlinhaR;
				;;
			*ONT-ID*)
				dsp='send "'$(echo "$linha" | awk -F' ' '{print "ont " $3}');
				echo $dsp >> $file_output; SlinhaR;SlinhaR2;
				echo 'sleep 1' >> $file_output;
				;;
	        SN*:*)
				v1=$serial; v1='';
				;;
	        *);;
	    esac
	done < "$file_input"
	Squit;
	#cat $file_output;
	echo "" > $file_input;
	echo -e "---------- FIM 'find_service_port' ----------";
}
#CRIAR COMANDOS PARA APAGAR O INDEX E A ONU NA INTERFACE
create_command(){
	cat $file_base > $file_dinamic;
	echo "" >> $file_output;
	x=0;
	
	while read -r line
		do
		    linha="$line"
		    Sundo=''; Sinterface=''; Sdelete='';
		    case "$linha" in
			*common*)
  			Sundo='send "'$(echo $linha | awk -F' ' '{print "undo service-port " $1}');
  			echo $Sundo >> $file_output; SlinhaR; SlinhaR2;
  			echo 'expect "*)#";' >> $file_output;
  			Sinterface='send "'$(echo $linha | awk -F' ' '{print "interface " $4 " " $5}');
  			echo $Sinterface >> $file_output; SlinhaR; SlinhaR2;
  			Sdelete='send "'$(echo $linha | awk -F'/' '{print $3}' | awk -F' ' '{print "ont delete " $1 " " $2}');
  			echo $Sdelete >> $file_output; SlinhaR; SlinhaR2;
  			echo 'expect "*)#";' >> $file_output;
  			echo 'send "quit\r"' >> $file_output;
  			echo 'sleep 1' >> $file_output;
  			;;
	    esac
	done < "$file_input"
	Squit;
	echo -e "---------- FIM 'create_command' ----------";
}
while true; do
    data=$(date +%d-%m-%Y_%H:%M:%S);
    echo -e "$data \nDIGITE O NUMERO DA OLT DA QUAL DESEJA EFETUAR CONEXÃO:";
    echo -e "\n1 - VOLTA REDONDA\n2 - BARRA MANSA\n3 - BELA ROMA\n4 - PORTO REAL\n5 - QUATIS\n6 - PE VR\n0 - SAIR\n";
    read -p "ESCOLHA: " x;
    echo "----------------------------------------------------------";
    case $x in
        0) break ;;
        SAIR) break;;
        sair) break;;
        1)	echo "" > ./logs/log_remocao.txt;
			find_onu_status;
			logsave ./logs/log_remocao.txt expect $IPVRD $Login;
			cp ./logs/log_remocao.txt ./logs/log_find-onu_OLT-VRD_$data.txt;
			find_service_port; sleep 2;
			logsave ./logs/log_remocao.txt expect $IPVRD $Login;
			cp ./logs/log_remocao.txt ./logs/log_find-serviceport_OLT-VRD_$data.txt;
			create_command; sleep 2;
			logsave ./logs/log_remocao.txt expect $IPVRD $Login;
			cp ./logs/log_remocao.txt ./logs/log_execute-remove_OLT-VRD_$data.txt;
			echo -e "---------- FIM!!! ----------";
			;;
        2)  echo "" > ./logs/log_remocao.txt;
			find_onu_status;
			logsave ./logs/log_remocao.txt expect $IPBMA $Login
			cp ./logs/log_remocao.txt ./logs/log_find-onu_OLT-BMA_$data.txt;
			find_service_port; sleep 2;
			logsave ./logs/log_remocao.txt expect $IPBMA $Login
			cp ./logs/log_remocao.txt ./logs/log_find-serviceport_OLT-BMA_$data.txt;
			create_command; sleep 2;
			logsave ./logs/log_remocao.txt expect $IPBMA $Login
			cp ./logs/log_remocao.txt ./logs/log_execute-remove_OLT-BMA_$data.txt;
			echo -e "---------- FIM!!! ----------";
			;;
        3)  echo "" > ./logs/log_remocao.txt;
			find_onu_status;
			logsave ./logs/log_remocao.txt expect $IPROM $Login;
			cp ./logs/log_remocao.txt ./logs/log_find-onu_OLT-ROM_$data.txt;
			find_service_port; sleep 2;
			logsave ./logs/log_remocao.txt expect $IPROM $Login
			cp ./logs/log_remocao.txt ./logs/log_find-serviceport_OLT-ROM_$data.txt;
			create_command; sleep 2;
			logsave ./logs/log_remocao.txt expect $IPROM $Login
			cp ./logs/log_remocao.txt ./logs/log_execute-remove_OLT-ROM_$data.txt;
			echo -e "---------- FIM!!! ----------";
			;;
		4)	echo "" > ./logs/log_remocao.txt;
			find_onu_status;
			logsave ./logs/log_remocao.txt expect $IPPOR $Login;
			cp ./logs/log_remocao.txt ./logs/log_find-onu_OLT-POR_$data.txt;
			find_service_port; sleep 2;
			logsave ./logs/log_remocao.txt expect $IPPOR $Login;
			cp ./logs/log_remocao.txt ./logs/log_find-serviceport_OLT-POR_$data.txt;
			create_command; sleep 2;
			logsave ./logs/log_remocao.txt expect $IPPOR $Login;
			cp ./logs/log_remocao.txt ./logs/log_execute-remove_OLT-POR_$data.txt;
			echo -e "---------- FIM!!! ----------";
			;;
		5)	echo "" > ./logs/log_remocao.txt;
			find_onu_status;
			logsave ./logs/log_remocao.txt expect $IPQUA $Login;
			cp ./logs/log_remocao.txt ./logs/log_find-onu_OLT-QUA_$data.txt;
			find_service_port; sleep 2;
			logsave ./logs/log_remocao.txt expect $IPQUA $Login;
			cp ./logs/log_remocao.txt ./logs/log_find-serviceport_OLT-QUA_$data.txt;
			create_command; sleep 2;
			logsave ./logs/log_remocao.txt expect $IPQUA $Login;
			cp ./logs/log_remocao.txt ./logs/log_execute-remove_OLT-QUA_$data.txt;
			echo -e "---------- FIM!!! ----------";
			;;
        *) echo -e "OPÇÃO DIGITADA NÃO EXISTE\n----------------------------------------------------------\n" ;;
    esac
done