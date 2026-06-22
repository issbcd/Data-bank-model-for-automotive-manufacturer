# Relatório de Modelagem: Montadora Automotiva
**Aluna:** Sophia Byernes Carvalho Duarte

## Visão Geral
Este relatório descreve as decisões técnicas tomadas durante a modelagem lógica do banco de dados para a montadora. O modelo busca abranger o ciclo produtivo completo, desde a recepção de peças de fornecedores até o acompanhamento de pós-venda e garantias.

## Estrutura Organizacional e Recursos Humanos
A entidade central é a `Montadora`, da qual derivam as `Fabricas`. Internamente, as fábricas são segmentadas em setores, onde os funcionários estão alocados. A entidade `Cargo` foi modelada de forma independente para evitar a redundância de atributos como nomenclatura e nível de acesso. Essa separação facilita manutenções futuras, como reajustes salariais baseados na categoria profissional.

## Especificação de Produtos
O catálogo de veículos segue uma estrutura hierárquica estrita: Categoria -> Modelo -> Versão. O `Veiculo` físico, identificado unicamente por seu chassi, está vinculado diretamente à sua versão. Atributos como Cor e Motor foram estabelecidos como entidades de domínio separadas e referenciadas via chaves estrangeiras. O armazenamento direto dessas informações em formato de texto geraria alta redundância e dificultaria a padronização das consultas.

## Produção e Gestão de Suprimentos
A relação entre componentes e veículos é do tipo muitos-para-muitos, sendo resolvida por meio da tabela associativa `Veiculo_Peca`. O controle de estoque (`Estoque_Peca`) foi modelado de forma descentralizada, vinculado a cada fábrica específica, garantindo que o gerenciamento de insumos reflita a realidade física de cada unidade produtiva. O avanço físico do chassi na linha de montagem é historiado na tabela `Producao_Veiculo`, garantindo a rastreabilidade de operadores e horários.

## Controle de Qualidade
Ao fim da montagem, os veículos são submetidos à entidade `Teste_Qualidade`. Inconformidades detectadas geram registros na tabela `Veiculo_Defeito`. A regra de negócio principal estipula que o veículo não pode ser transferido para o estoque de produtos acabados até que possua um registro correspondente em `Manutencao_Corretiva`, atestando a resolução da falha.

## Comercialização e Pós-Venda
Após aprovação, o veículo é disponibilizado para `Faturamento` às concessionárias. É importante notar que o prazo de garantia só é ativado mediante a inserção de um registro na tabela `Venda_Final`, vinculando o chassi a um cliente específico. Este desenho evita a depreciação do tempo de garantia durante o período em que o veículo permanece no pátio da concessionária, permitindo um controle preciso das revisões em assistências técnicas credenciadas.
