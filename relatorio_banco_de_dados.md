# Relatório Técnico: Projeto Final de Banco de Dados
**Aluna:** Sophia Byernes Carvalho Duarte

---

## Introdução

Esse relatório descreve as decisões tomadas na modelagem do banco de dados para uma montadora de veículos. A ideia é explicar por que cada entidade existe, como os relacionamentos foram definidos e de onde vieram as regras de negócio. O modelo cobre o ciclo completo da empresa, da aquisição de peças até o pós-venda com o cliente final.

---

## Estrutura interna da empresa

A entidade `Montadora` guarda os dados gerais da empresa e serve de raiz para as `Fabrica`s, que são as unidades físicas onde a produção acontece. Cada fábrica tem `Setor`es próprios e `Funcionario`s alocados nela.

`Cargo` foi modelado como entidade separada porque carrega atributos que não fazem sentido ficar repetidos em cada funcionário, como nível de acesso. Se o nome ou as responsabilidades de um cargo mudarem, basta atualizar um registro. Em `Funcionario`, há três chaves estrangeiras: fábrica, setor e cargo, que refletem exatamente como um funcionário está posicionado dentro da empresa.

---

## Modelagem do produto

Existe uma hierarquia clara no produto que precisava estar representada no MER. `Categoria_Veiculo` agrupa os tipos gerais, como carros de passeio, utilitários e veículos elétricos. Cada categoria contém um ou mais `Modelo`s, e cada modelo tem uma ou mais `Versao`s. O `Veiculo` físico, identificado pelo número de chassi, está vinculado a uma versão específica por meio de uma chave estrangeira `id_versao`.

`Cor` e `Motor` são entidades independentes ligadas a `Veiculo` por chaves estrangeiras `id_cor` e `id_motor`. Essa decisão foi tomada para evitar redundância: se cor e motor fossem atributos de texto dentro de `Veiculo`, o mesmo valor "Rosa Perolado" ou "2.0 Turbo Flex" estaria repetido em centenas de linhas. Qualquer atualização nesses dados exigiria percorrer toda a tabela. Como entidades próprias, a informação existe em um único lugar e `Veiculo` apenas referencia o identificador correspondente.

O mesmo raciocínio se aplica a `Modelo` e `Versao`: ambos poderiam ter sido atributos de texto em `Veiculo`, mas isso impossibilitaria representar a hierarquia categoria-modelo-versão e geraria repetição dos mesmos valores em múltiplos registros. No modelo lógico, `Veiculo` não guarda o nome do modelo nem da versão diretamente, só a FK `id_versao`, que por sua vez referencia `Versao`, que referencia `Modelo`, que referencia `Categoria_Veiculo`.

---

## Suprimentos e estoque de peças

`Fornecedor` armazena as empresas que entregam componentes e matérias-primas. Cada `Peca` está associada a um fornecedor específico.

O relacionamento entre peças e veículos é muitos-para-muitos: um veículo usa várias peças, e a mesma peça pode ser usada em vários veículos. Isso é resolvido pela entidade `Veiculo_Peca`, que funciona como a lista de componentes de cada chassi, registrando quais peças foram utilizadas e em que quantidade. Sem essa tabela intermediária não seria possível rastrear o que compõe cada veículo produzido.

`Estoque_Peca` controla o saldo disponível de cada peça em cada fábrica separadamente. Fábricas em localidades diferentes mantêm estoques físicos distintos, então não faz sentido ter um saldo global.

---

## Linha de produção

`Linha_Montagem` existe dentro de uma fábrica. `Lote_Producao` agrupa os veículos fabricados nessa linha em um determinado período. Cada veículo pertence a um lote.

O histórico de fabricação de cada chassi é registrado em `Producao_Veiculo`, que associa o veículo a uma `Etapa_Producao`, ao funcionário responsável e ao horário. `Etapa_Producao` é uma entidade própria porque armazenar o nome da etapa como texto livre dentro de `Producao_Veiculo` criaria inconsistências: dois funcionários poderiam registrar a mesma etapa com nomes diferentes, o que dificulta qualquer consulta ou relatório posterior. Tendo a etapa como entidade, todos os registros referenciam o mesmo identificador.

---

## Qualidade

`Teste_Qualidade` registra cada teste aplicado em um veículo. Cada teste está associado a um `Tipo_Teste`, que é uma entidade separada pelos mesmos motivos de `Etapa_Producao`: padronizar os tipos existentes e permitir consultas por categoria de teste sem depender de comparação de strings.

Quando um defeito é identificado, ele vai para `Veiculo_Defeito`, que associa o chassi a um `Defeito` catalogado e registra se já foi resolvido. Para cada defeito em aberto, é necessário um registro correspondente em `Manutencao_Corretiva`. Um veículo só pode avançar para `Estoque_Veiculo` depois que todos os defeitos tiverem manutenção registrada e marcados como resolvidos.

---

## Logística e comercial

Após aprovação na qualidade, o veículo entra em `Estoque_Veiculo`, que registra a data de entrada do chassi no depósito de prontos. A partir daí, a montadora pode emitir um `Faturamento` para uma `Concessionaria`. A relação entre faturamento e chassi é de um para um: o mesmo veículo não pode ser faturado para dois destinos.

---

## Pós-venda

A `Venda_Final` representa o momento em que a concessionária vende o veículo a um `Cliente`. É a partir dessa data que a `Garantia` começa a valer, não da data do faturamento. Isso é importante porque o veículo pode ficar meses no estoque da concessionária antes de ser vendido, e a garantia não deveria correr nesse período.

Com garantia ativa, o veículo pode ser levado a `Revisao` em unidades de `Assistencia_Tecnica` credenciadas pela montadora. Cada revisão registra o chassi, a unidade responsável, a quilometragem e a data.

---

## Considerações finais

A maior parte das decisões de modelagem girou em torno da mesma questão: o que vira entidade e o que fica como atributo. A resposta foi criar entidades sempre que o dado se repete em múltiplos registros ou quando ele precisa de padronização. `Cor`, `Motor`, `Modelo` e `Versao` são os exemplos mais diretos disso: todos poderiam ser campos de texto em `Veiculo`, mas como entidades eliminam redundância, permitem manutenção centralizada e tornam o modelo mais normalizado.
