# advplcodegen
Framework de geração de códigos ADVPL orientado a objetos.

# Sobre o projeto
O propósito desse projeto é gerar casos de testes a partir de fontes ADVPL de forma automática e cobrindo o maior número de cenários possível.

# Compatibilidade / Ambientes homologados

* Python 3x 

# Pré-requisitos

* Python 3 instalado (https://www.python.org/downloads/)
* Pip instalado - Execute o arquivo get-pip.py
* Biblioteca PyMsSql instalada - pip install pymssql
* Base de dados e ambiente de desenvolvimento (ADVPL) protheus configurados.

# Configuração de Ambiente

* 1 - Faça o clone do projeto.
* 2 - Inicie o projeto com o comando advplcodegen.py startproject
* 3 - Adicione os fontes que deverão ser analisados na pasta /src/analise
* 4 - Gere os fontes de teste com o comando advplcodegen.py build

# Comandos e criação do projeto ADVPL.

Para execução dos comandos acesse a arvore do projeto onde se encontra o fonte advplcodegen.py, todos os comandos partirão desse fonte.</br></br>

<b>Comando startproject</b><br>
Para iniciar um projeto.
</br>

```console
$ advplcodegen.py startproject
```

Nota:<br>
Após a execução desse comando os diretório do projeto assim como suas libs deverão ser criadas em SRC.


</br>
<b>Comano build</b></br>
Comando para gerar os fontes de teste.
</br>

```console
$ advplcodegen.py build
```

<br>
 Colabore com esse projeto, caso tenha algum problema no uso ou sugestão, #issue.
<br>

