bin_path='/usr/bin'
script_name='wp-gen-env'
script_file="$bin_path/$script_name"
compose_sample='docker-compose-sample.yml'
compose_file="$bin_path/$compose_sample"

if [ -e $script_file ]; then
	echo 'Operações disponíveis:'
	echo '1 - Atualizar'
	echo '2 - Remover'
	echo

	# Pede confirmação sobre a estrutura à ser criada
	opcao=''
	while [ "$opcao" = '' ] || [ "$opcao" != '1' ] && [ "$opcao" != '2' ]; do
		echo 'Entre com uma das opções para prosseguir:'
		read opcao
	done

	if [ "$opcao" = '1' ]; then
		echo "O arquivo $script_name será atualizado no diretório $bin_path"
	else
		echo "O arquivo $script_name será removido do diretório $bin_path"
	fi
else
	echo "O arquivo $script_name será adicionado ao diretório $bin_path"
fi
echo 'Digite "s" para prosseguir ou "n" para cancelar:'

# Pede confirmação sobre a estrutura à ser criada
continue_process=''
while [ "$continue_process" = '' ] || [ "$continue_process" != 's' ] && [ "$continue_process" != 'n' ]; do
	echo 'Pressione "s" ou "n" para prosseguir:'
	read continue_process
done
# Para a execução caso a opção selecionada foi 'n'
if [ "$continue_process" = 'n' ]; then
	echo 'A operação foi cancelada!'
	exit 0
fi

if [ -e $script_file ]; then
	if [ "$opcao" = '1' ]; then
		sudo cp -rf $compose_sample $bin_path
		sudo cp -rf $script_name.sh $script_file
		sudo chmod +x $script_file
		echo "Comando $script_name atualizado com sucesso!"
	else
		sudo rm $compose_file
		sudo rm $script_file
		echo "Comando $script_name desinstalado com sucesso!"
	fi
else
	sudo cp $compose_sample $bin_path
	sudo cp $script_name.sh $script_file
	sudo chmod +x $script_file
	echo "Comando $script_name instalado com sucesso!"
fi
