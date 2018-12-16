QCKOLT-remove
Script para remoção automatizada de seriais em lote nas OLTs Huawei
O QCKOLT-remove é um script que automatiza a remoção dos seriais de ONUs/ONTs cadastrados em OLTs HUAWEI. Ainda em fase de testes, mas já consegue efetuar a remoção segura nas OLTs MA5603T HUAWEI.


Requisitos
O script foi projetado para executar apenas no linux devido o mesmo utilizar outras ferramentas exclusivas do SO. Abaixo os pacotes necessários para execução:

expect
logsave
telnet


Editar arquivo
Antes da execução, é necessário adicionar os parâmetros de IP, Usuário e Senha do acesso TELNET. Essas configurações podem ser modificadas no inicio do arquivo "remove_OLT.sh". Campos: usuario="USUÁRIO"; senha="MINHA_SENHA"; IPOLTXYZ="acesso-olt-dinamico.sh 10.80.80.X";


Execução
Antes de efetuar a execução, insira no arquivo "seriais.txt" os seriais que deverão ser removidos.

Para executar o script, atribua permissão de execução nos arquivos da pasta: # chmod +x *.sh

Após isso, execute o arquivo "remove_OLT.sh": $ ./remove_OLT.sh


Adicionar mais OLTs
Por padrão, apenas uma OLT foi definida no menu, mas poderão ser adicionadas, criando novas variáveis e atribuindo seu IP conforme o exemplo abaixo: IPOLTNOVA="acesso-olt-dinamico.sh 100.50.230.32";

Também será necessário modificar no laço "while" as opções de "case", adicionando um número para a OLT seguinte. A variável $IPOLTXYZ deve ser modificada pela nova criada ($IPOLTNOVA). Os arquivos de LOG ("log_find-onu_OLT-XYZ_$data.txt"; "log_find-serviceport_OLT-XYZ_$data.txt"; "log_execute-remove_OLT-XYZ_$data.txt") segue o mesmo padrão, devendo ser alterado para corresponder a nova OLT atribuída.


LOGs
Os logs dos acessos serão gravados individualmente na pasta "logs" com a data da execução do script e todas as interações efetuadas.
