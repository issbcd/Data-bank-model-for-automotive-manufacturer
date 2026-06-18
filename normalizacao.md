# Normalização do Banco de Dados
**Aluna:** Sophia Byernes Carvalho Duarte

---

## Por que esse documento existe

Antes de chegar no modelo que está no script SQL, vale mostrar como o banco ficaria se a gente simplesmente jogasse tudo numa tabela só, sem se preocupar com chaves estrangeiras nem entidades separadas. Esse exercício ajuda a justificar por que o modelo final tem 31 tabelas em vez de duas ou três tabelas gigantes.

---

## Como ficaria o nosso projeto sem normalização

Imagina que alguém modelasse o controle de produção e venda de veículos da montadora numa única tabela chamada `Registro_Veiculo`, contendo tudo que precisa saber sobre um carro desde a fabricação até a venda. Ficaria parecido com isso:

| chassi | modelo | versao | cor | motor | fabrica | linha_montagem | funcionario_producao | etapas_concluidas | pecas_usadas | testes_realizados | defeitos | fornecedor_peca | concessionaria | cliente | telefone_cliente | data_venda |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ABC123 | Onix | LTZ | Branco | 1.0 Turbo | Fab. SP | Linha 2 | João Silva, Maria Souza | Pintura, Motor, Acabamento | Pneu x4, Bateria x1 | Freios (OK), Motor (OK) | Nenhum | Continental, Bosch | Carlos Veículos | Ana Paula | (82) 99999-0000 | 12/03/2026 |
| DEF456 | Onix | LT | Preto | 1.0 Turbo | Fab. SP | Linha 2 | João Silva | Pintura, Motor | Pneu x4 | Freios (OK) | Risco na porta | Continental | Carlos Veículos | Pedro Lima | (82) 98888-1111 | 15/03/2026 |

Esse formato parece prático no começo, mas quebra em vários pontos assim que a gente tenta consultar ou atualizar qualquer coisa.

### Problema 1: colunas multivaloradas

Os campos `funcionario_producao`, `etapas_concluidas`, `pecas_usadas`, `testes_realizados` e `defeitos` guardam mais de um valor dentro da mesma célula, separados por vírgula. Isso quebra a primeira forma normal, porque cada célula deveria conter um único valor atômico. Não tem como, por exemplo, contar quantos veículos passaram pelo teste de freios sem antes quebrar essa string toda vez que for consultar.

### Problema 2: dados que se repetem e dependem só de parte da chave

Se o chassi fosse a chave primária dessa tabela, dados como `fabrica`, `linha_montagem`, `fornecedor_peca` e `concessionaria` acabam se repetindo em várias linhas sempre que mais de um veículo passa pela mesma fábrica ou é vendido pela mesma concessionária. Isso é redundância pura: o nome da fábrica, o endereço da concessionária e o nome do fornecedor estão duplicados em cada linha que menciona esses dados, e qualquer atualização de endereço, por exemplo, exigiria atualizar todas as linhas correspondentes.

### Problema 3: dependências transitivas

O campo `telefone_cliente` depende do cliente, não do veículo. Mas como a tabela só tem o chassi como referência direta, o telefone do cliente fica amarrado a uma linha que na verdade representa um carro, não uma pessoa. Se o mesmo cliente comprar dois carros, o telefone dele vai aparecer duas vezes, e se ele mudar de telefone, vai ser preciso atualizar todas as ocorrências.

---

## Como o modelo final resolve cada um desses problemas

### Primeira Forma Normal (1FN)

Para eliminar as colunas multivaloradas, cada lista virou uma tabela própria com um relacionamento de chave estrangeira. `funcionario_producao` e `etapas_concluidas` deram origem à tabela `Producao_Veiculo`, que tem uma linha para cada etapa de cada veículo, referenciando o chassi, o funcionário e a etapa separadamente. `pecas_usadas` virou a tabela `Veiculo_Peca`, com uma linha por peça utilizada em cada chassi. `testes_realizados` virou `Teste_Qualidade`, e `defeitos` virou `Veiculo_Defeito`. Com isso, toda célula do banco guarda exatamente um valor, sem listas escondidas dentro de texto.

### Segunda Forma Normal (2FN)

Depois de separar as listas, ainda restava o problema de dados que dependiam só de parte de uma chave composta ou que se repetiam por estarem soltos numa tabela maior. `Fabrica`, `Fornecedor` e `Concessionaria` foram extraídos como entidades próprias, cada uma com sua própria chave primária. Em vez de a tabela `Veiculo` guardar o nome e endereço completos da fábrica em cada linha, ela guarda apenas o `id_fabrica`, que aponta para um único registro com esses dados. O mesmo vale para fornecedores e concessionárias. Isso elimina a repetição de dados que não dependiam do veículo em si, mas de outra entidade relacionada.

### Terceira Forma Normal (3FN)

Por fim, restavam as dependências transitivas, como o telefone do cliente amarrado ao veículo em vez de ao cliente. A tabela `Cliente` foi criada como entidade própria, e o telefone (junto com nome e CPF) passou a depender exclusivamente do `id_cliente`, não do chassi do veículo comprado. O mesmo raciocínio foi aplicado a `Cor` e `Motor`: como esses dados não dependem diretamente do veículo, mas são características reutilizáveis entre vários veículos, cada um ganhou sua própria tabela com chave primária independente, e `Veiculo` passou a apenas referenciar `id_cor` e `id_motor`.

O resultado é que, no modelo final, nenhuma coluna depende de algo que não seja a chave primária da própria tabela. Atualizar o endereço de uma fábrica, o telefone de um cliente ou a especificação de um motor exige alterar um único registro, e essa alteração se reflete automaticamente em todos os veículos relacionados, porque eles apenas referenciam aquele registro através de uma chave estrangeira.

---

## Resumo da evolução

A tabela única `Registro_Veiculo` viraria, depois da normalização, em entidades como `Veiculo`, `Modelo`, `Versao`, `Cor`, `Motor`, `Fabrica`, `Linha_Montagem`, `Funcionario`, `Producao_Veiculo`, `Etapa_Producao`, `Peca`, `Veiculo_Peca`, `Fornecedor`, `Teste_Qualidade`, `Tipo_Teste`, `Defeito`, `Veiculo_Defeito`, `Concessionaria`, `Cliente` e `Venda_Final`, entre outras. Cada uma guarda um conjunto de dados que depende exclusivamente da própria chave primária, e a ligação entre elas é feita por chaves estrangeiras. Esse processo é exatamente o que está implementado no script de criação das tabelas.
