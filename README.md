# advplcodegen
Framework de geração de códigos ADVPL orientado a objetos.

# Sobre o projeto
O propósito desse projeto é gerar casos de testes a partir de fontes ADVPL de forma automática e cobrindo o maior número de cenários possível.

# Compatibilidade / Ambientes homologados

* Python 3x 

# Pré-requisitos

* Python 3 instalado (https://www.python.org/downloads/)
* Pip instalado - Execute o arquivo get-pip.py
* Baixar a ultima versão do antlr - https://www.antlr.org/download/antlr-4.8-complete.jar
* Instalar dependência do antlr - pip3 install antlr4-python3-runtime=4.8
* Gerar Lexer ADVPL - antlr-4.8-complete.jar -Dlanguage=Python3 C:\prjs\advpltestcodegen\core\parser\bin\Advpl.g4

# Configuração de Ambiente

1. Faça o clone do projeto.
2. Inicie o projeto com o comando advplcodegen.py startproject

# Preparando os fontes para análise
É indicado fazer um tratamento prévio nos fontes para retirar comentários e substituir INCLUDES como `DEFINE SBUTTON`, por exemplo, e outros que podem atrapalhar na análise. Para isso iremos utilizar a versão pré-processada do fonte (.ppx_prw) que o Appserver command line gera.  
1. Adicione os fontes que deverão ser analisados na pasta /src/analise
2. Compile os fontes utilizando o appserver command line (disponível a partir da versão 17.3.0.9) com o parâmetro **`-nodelfiles`**
```console
appserver.exe -compile -files="C:\prjs\advpltestcodegen\src\analise" -includes="C:\Protheus\include" -env=base_congelada_local_dic_banco_x64 -nodelfiles -authorization="C:\Protheus\autoriza.aut" -src=C:\prjs\advpltestcodegen\src\analise
```
3. Edite o arquivo **`.ppx_prw`**, retire as linhas iniciadas com **#line**
4. Nas funções que possuem mais de um comando `Default`, o pré-processamento adiciona um ponto-e-virgula a mais no final das linhas. Deve-se tirá-lo como no exemplo abaixo:
>Versão original
```console
Static Function TagMensagem(cSequen,cCodOpe)
	Local cTagMsg			:=	"" 
	Local cTagFormCont	:=	""
	Default cSequen		:= "" 
	Default cCodOpe		:= ""
```
>Versão após pré-processamento
```console
Static Function TagMensagem(cSequen,cCodOpe)
	Local cTagMsg			:=	""
	Local cTagFormCont	:=	""
	cSequen := If( cSequen == nil, "", cSequen ) ;
	cCodOpe := If( cCodOpe == nil, "", cCodOpe ) ;
```
>Versão ajustada
```console
Static Function TagMensagem(cSequen,cCodOpe)
	Local cTagMsg			:=	""
	Local cTagFormCont	:=	""
	cSequen := If( cSequen == nil, "", cSequen )
	cCodOpe := If( cCodOpe == nil, "", cCodOpe )
```
5. Deixe apenas os arquivos **`.ppx_prw`** na pasta `\analise`
6. Renomei os arquivos **`.ppx_prw`** para **`.prw`**
7. Gere os fontes de teste com o comando advplcodegen.py build

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

