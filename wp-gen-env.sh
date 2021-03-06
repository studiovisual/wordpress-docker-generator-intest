#!/bin/bash

RED="\e[91m"
GREEN="\e[92m"
BLUE="\e[94m"
RESET="\e[0m"

if [ $# -lt 3 ]; then
    echo -e "$BLUE"
    echo 'Y8b Y8b Y888P                       888 888 88e'
    echo ' Y8b Y8b Y8P   e88 88e  888,8,  e88 888 888 888D 888,8,  ,e e,   dP"Y  dP"Y'
    echo '  Y8b Y8b Y   d888 888b 888 "  d888 888 888 88"  888 "  d88 88b C88b  C88b'
    echo '   Y8b Y8b    Y888 888P 888    Y888 888 888      888    888   ,  Y88D  Y88D'
    echo '    Y8P Y      "88 88"  888     "88 888 888      888     "YeeP" d,dP  d,dP'
    echo '    __              __                                                          __'
    echo '.--|  |.-----.----.|  |--.-----.----.______.-----.-----.-----.-----.----.---.-.|  |_.-----.----.'
    echo '|  _  ||  _  |  __||    <|  -__|   _|______|  _  |  -__|     |  -__|   _|  _  ||   _|  _  |   _|'
    echo '|_____||_____|____||__|__|_____|__|        |___  |_____|__|__|_____|__| |___._||____|_____|__|'
    echo '                                           |_____|'
    echo -e "${RESET}${RED}"
    echo ' _   _     _____  ____  __  _____      ____  _      __    _      ___   ___'
    echo '| | | |\ |  | |  | |_  ( (`  | |      | |_  | |    / /\  \ \  / / / \ | |_)'
    echo '|_| |_| \|  |_|  |_|__ _)_)  |_|      |_|   |_|__ /_/--\  \_\/  \_\_/ |_| \'
    echo -e "$RESET"
    echo
    echo 'Parâmetros esperados:'
    echo ' - título do projeto'
    echo ' - virtual host'
    echo ' - nome do banco'
    echo ' - versão do php (opcional)'
    echo
    echo "Exemplo de comando completo: ${0##*/} projeto-teste test.dev base-teste 5.6"
    echo 'Repositório do projeto: https://github.com/studiovisual/wordpress-docker-generator-intest'
    exit 0
fi

project_title=$1
virtual_host=$2
database_name=$3
php_version=`[ $4 ] && echo $4 || echo 'latest'`

echo -e "$BLUE"
echo 'A seguinte estrutura será criada neste diretório:'
echo " - $project_title"
echo ' |- public (raíz do apache do docker, com uma instalação wordpress limpa incluída)'
echo ' |- mysql (dados armazenados pelo mysql do docker)'
echo ' |- docker-compose.yml (gera os containeres do apache/php e do mysql e os relaciona)'
echo ''
echo 'Os seguintes containeres serão criados:'
echo " - $project_title-web (php/apache)"
echo "   - PHP $php_version"
echo "   - Diretório raíz do apache: /var/www/html"
echo "   - Virtual host: $virtual_host"
echo " - $project_title-db (mysql)"
echo "   - Nome do banco: $database_name"
echo -e "$RESET"

# Pede confirmação sobre a estrutura à ser criada
continue_process=''
while [ "$continue_process" = '' ] || [ "$continue_process" != 's' ] && [ "$continue_process" != 'n' ]; do
    echo -e "Digite ${GREEN}s$RESET para prosseguir ou ${RED}n$RESET para cancelar: \c"
    read continue_process
done

# Para a execução caso a opção selecionada foi 'n'
if [ "$continue_process" = 'n' ]; then
    echo -e "${RED}A operação foi cancelada!${RESET}"
    exit 0
fi

# Verifica a existência de um arquivo com o nome
# sugerido para ser o diretório raíz do site. Se
# sim, para o programa com status 1.
if [ -e $project_title ]; then
    echo -e "${RED}Um arquivo/diretório de nome $project_title já existe!${RESET}"
    exit 1
fi

# Gera a estrutura de arquivos e concede permissão
mkdir $project_title
cd $project_title
mkdir public
mkdir mysql
touch docker-compose.yml

# Popula docker-compose e adiciona os dados fornecidos no programa
cat /usr/bin/docker-compose-sample.yml > docker-compose.yml
sed -i "s/NOME-DO-PROJETO/$project_title/g" docker-compose.yml
sed -i "s/VIRTUAL-HOST/$virtual_host/g" docker-compose.yml
sed -i "s/BANCO/$database_name/g" docker-compose.yml
sed -i "s/PHP-VERSION/$php_version/g" docker-compose.yml

# Baixa a instalação vazia do wordpress automaticamente
cd public
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
mv wordpress/* .
rm -r wordpress
rm latest.tar.gz
cd ..

# Exibe estrutura de arquivos
echo -e "$GREEN"
echo 'Estrutura criada com sucesso:'
echo 'Local: /'
ls -la
echo 'Local: /public'
ls -la public
echo -e "$RESET"

if [ $(docker ps -a -q -f name="$project_title-web") ] || [ $(docker ps -a -q -f name="$project_title-db") ]; then
    echo -e "${RED}Já existem containeres com o mesmo nome da estrutura criada!${RESET}"
    exit 1
fi

chmod -R 777 .
docker-compose up -d

exit 0
