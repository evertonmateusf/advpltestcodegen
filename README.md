# advpltestcodegen
Ferramenta de geração de casos de testes a partir de análise estática de códigos ADVPL.   

# Sobre o projeto
O propósito desse projeto é gerar casos de testes a partir de fontes ADVPL de forma automática e cobrindo o maior número de cenários possível.  
A ferramenta é desenvolvida em **Python** e usa o **ANTLR4** para realizar o parse dos fontes.  
Agradecimentos:
- [Everton de Souza Lima](https://github.com/oevertonsouza) - Manja muito de python e tem bastante influência na parte de gerar os fontes 
- [Izac](https://github.com/izacsc) - Fatecano, programadô bão que ajudou a resolver umas tretas do projeto 
- [Rodrigo Antonio Godinho da Silva](https://github.com/killerall) - Achei a gramática quase no jeito fuçando nos repositórios dele. Sem falar no plugin de ADVPL pro VsCode que ele fez que ajuda demais no dia-a-dia. 
## Tipos de casos de testes gerados:
[ X ] Gerar os arquivos básicos de caso de teste (TestCase, TestGroup e TestSuite)      
[ X ] Cobertura simples de linhas de WSCLIENT   
[ ] Cobertura simples de linhas de FUNCTION  
[ ] Cobertura simples de linhas de STATIC FUNCTION  
[ ] Cobertura simples de linhas de USER FUNCTION  
[ ] Cobertura simples de linhas de WEB FUNCTION  
[ ] Cobertura simples de linhas de CLASSES  
[ ] Analise de Valor Limite de variáveis em fontes WSCLIENT  
[ ] Analise de Valor Limite de variáveis em fontes FUNCTION  
[ ] Analise de Valor Limite de variáveis em fontes STATIC FUNCTION  
[ ] Analise de Valor Limite de variáveis em USER FUNCTION  
[ ] Analise de Valor Limite de variáveis em fontes WEB FUNCTION  
[ ] Analise de Valor Limite de variáveis em CLASSES  

## Estrutura de arquivos e pastas
- `\core`   
	Pasta principal da ferramenta
- `\core\codeGenerators`   
	Pasta que contem os geradores de código. Esses geradores são os responsáveis por criar os fontes *TestCase.prw.,*TestGroup.prw e *TestSuite.prw
- `\core\parser`   
	Pasta que contem a estrutura do parser dos fontes.   
	Arquivos importantes:
	- `\core\parser\bin\Advpl.g4`   
		Gramática da linguagem ADVPL. **Em evolução**   
		Uma vez alterado este fonte, é necessário gerar novamente os Lexers. Para gerar, utilize o arquivo `\core\parser\bin\gerarLexer.bat` 
	- `\core\parser\bin\AdvplKeyPrinter.py`   
		Classe que herda de AdvplListener e é responsável por interceptar a leitura do fonte. Para cada TOKEN identiticado pelo Lexer tem-se um método enter e exit que pode ser sobrescrito no keyPrinter. Utilizo estes métodos para montar os objetos que darão origem à lógica dos casos de teste.   
	- `\core\codeGenController.py`   
		Classe responsável por orquestrar a geração do código. Determina quais geradores será acionados.   
	- `\core\commandController.py`   
		Classe que determina os comandos da ferramenta. Aqui está o início da execução dos comandos startproject, build, etc.   
	- `\src`   
		Pasta dos fontes ADVPL.   
	- `\src\analise`   
		Pasta dos fontes ADVPL que serão analisados.   
	- `\src\test`   
		Pasta onde serão criados os fontes de testes.   
	- `\temp`   
		Pasta utilziada para criação de arquivos temporários durante a análise e geração dos casos de teste
	- `\templates`   
		Pasta com os templates dos fontes
	- `\advplcodegen.py`   
		Fonte inicial da aplicação

# Pré-requisitos

* Python 3 instalado (https://www.python.org/downloads/)
* Pip instalado - Execute o arquivo get-pip.py
* Baixar a ultima versão do antlr - https://www.antlr.org/download/antlr-4.8-complete.jar
* Instalar dependência do antlr - pip3 install antlr4-python3-runtime=4.8

# Configuração de Ambiente

1. Faça o clone do projeto.
2. Inicie o projeto com o comando `advplcodegen.py startproject`
# Executando a criação dos casos de teste

1. Adicione os fontes que devem ser analisados na pasta `\src\analise`
2. Execute o comando `advplcodegen.py build` para gerar os casos de teste na pasta `\src\test`
```
C:\prjs\advpltestcodegen>python advplcodegen.py build
[Thu Sep  3 16:31:25 2020]Lendo arquivo WsClient_WSPLCADWEB
[Thu Sep  3 16:31:25 2020]Fazendo parse do arquivo WsClient_WSPLCADWEB
[Thu Sep  3 16:31:35 2020]Analisando arquivo WsClient_WSPLCADWEB
[Thu Sep  3 16:31:35 2020]Gerando caso de teste do arquivo WsClient_WSPLCADWEB
[Thu Sep  3 16:31:35 2020]Gerando caso de teste para a classe WSPLCADWEB
[Thu Sep  3 16:31:35 2020]Deletando arquivos temporarios
[Thu Sep  3 16:31:35 2020]Deletando arquivos temporarios
```


# Lista de comandos

Para execução dos comandos acesse a arvore do projeto onde se encontra o fonte `advplcodegen.py`, todos os comandos partirão desse fonte.</br></br>

<b>Comando startproject</b><br>
Para iniciar um projeto.
</br>

```console
$ python advplcodegen.py startproject
```

Nota:<br>
Após a execução desse comando os diretório do projeto assim como suas libs serão criadas no diretório `\src`.

</br>
<b>Comano build</b></br>
Comando para gerar os fontes de teste.
</br>

```console
$ python advplcodegen.py build
```
O comando irá ler todos os fontes da pasta `\src\analise` e criará um testcase, testgroup e testsuite para cada fonte lido.

<br>
 Colabore com esse projeto, caso tenha algum problema no uso ou sugestão, #issue.
<br>


</br>
<b>Comano buildtemplatetests</b></br>
Comando para gerar os arquivos básicos de caso de teste (TestCase, TestGroup e TestSuite) com o mínimo que o desenvolvedor precisa para criar os casos de teste.
</br>

```console
$ python advplcodegen.py buildtemplatetests
```
O comando irá ler todos os fontes da pasta `\src\analise` e criará um testcase, testgroup e testsuite para cada fonte lido.


# Preparando os fontes para análise
**Fontes de Classes e WSCLIENT não devem passar por esse processo de preparação**  
Para fontes de Functions é indicado fazer um tratamento prévio nos fontes para retirar comentários e substituir INCLUDES como `DEFINE SBUTTON`, por exemplo, e outros que podem atrapalhar na análise. Para isso iremos utilizar a versão pré-processada do fonte (.ppx_prw) que o Appserver command line gera.  
1. Adicione os fontes que deverão ser analisados na pasta `\src\analise`
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
5. Deixe apenas os arquivos **`.ppx_prw`** na pasta `\src\analise`
6. Renomei os arquivos **`.ppx_prw`** para **`.prw`**
7. Gere os fontes de teste com o comando advplcodegen.py build
