# Normalização do Banco de Dados
**Aluna:** Sophia Byernes Carvalho Duarte

Este documento tem como objetivo apresentar a justificativa para a estrutura final do banco de dados, detalhando o processo de normalização aplicado ao escopo do projeto.

Para fins de demonstração, caso o sistema da montadora fosse projetado em uma única tabela centralizada (ex: `Registro_Veiculo`), os dados se comportariam da seguinte forma:

| chassi | modelo | versao | cor | fabrica | linha | funcionario | etapas | pecas | defeitos | fornecedor | concessionaria | cliente | data_venda |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ABC123 | Onix | LTZ | Branco | Fab SP | Linha 2 | Joao, Maria | Pintura, Motor | Pneu, Bateria | Nenhum | Bosch | Carlos Veiculos | Ana | 12/03/2026 |

Essa estrutura desnormalizada apresentaria diversos problemas de integridade e anomalias de atualização, resolvidos através das Formas Normais:

### 1. Eliminação de Atributos Multivalorados (1FN)
A tabela ilustrativa contém atributos como `funcionario`, `etapas`, e `pecas` armazenando múltiplos valores separados por vírgula. Isso fere as regras da Primeira Forma Normal (1FN) e inviabiliza consultas eficientes (como a totalização de peças consumidas). A solução adotada foi a criação de tabelas associativas e de histórico. A entidade `Producao_Veiculo` foi criada para registrar a relação entre o veículo, a etapa concluída e o funcionário responsável, enquanto `Veiculo_Peca` gerencia a relação muitos-para-muitos entre veículos e seus componentes.

### 2. Remoção de Dependências Parciais e Redundâncias (2FN)
O segundo problema estrutural é a repetição de dados corporativos. Dados referentes à fábrica, fornecedores e concessionárias se repetiriam a cada novo veículo produzido ou vendido. Além de consumir espaço desnecessário, qualquer alteração cadastral exigiria a atualização de múltiplas linhas. Para adequação à Segunda Forma Normal (2FN), `Fabrica`, `Fornecedor` e `Concessionaria` foram isoladas como entidades próprias. A tabela de veículos passou a referenciar apenas o identificador (`id_fabrica`).

### 3. Eliminação de Dependências Transitivas (3FN)
Por fim, a estrutura centralizada mantinha dependências que não tinham relação direta com a chave primária (o chassi). O telefone e o CPF do cliente dependem exclusivamente do próprio cliente, e não do veículo que ele adquiriu. O mesmo princípio se aplica às características de `Cor` e `Motor`. Para atingir a Terceira Forma Normal (3FN), o cliente foi isolado na tabela `Cliente`, e as especificações técnicas ganharam tabelas de domínio próprias. 

O resultado é um modelo distribuído onde qualquer atualização cadastral é realizada em uma única tupla, preservando a integridade referencial de todo o banco de dados.
