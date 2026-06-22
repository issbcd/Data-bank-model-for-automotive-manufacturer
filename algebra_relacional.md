# Álgebra Relacional Aplicada
**Aluna:** Sophia Byernes Carvalho Duarte

Este documento detalha as expressões de álgebra relacional que fundamentam as consultas SQL desenvolvidas para o projeto. As operações estão descritas utilizando os operadores relacionais padrão.

**1. Veículos aprovados em todos os testes de qualidade**
A consulta realiza uma seleção baseada no status de aprovação e, em seguida, executa uma junção natural com os dados do veículo.
π chassi, status ( σ aprovado = true (Teste_Qualidade) ⋈ Veiculo )

**2. Relação de funcionários e suas respectivas fábricas**
A projeção exige uma junção tripla para relacionar as chaves estrangeiras presentes na tabela de funcionários com as tabelas de domínio.
π nome, titulo, localizacao ( Funcionario ⋈ Cargo ⋈ Fabrica )

**3. Veículos sem histórico de defeitos na linha de montagem**
A operação mais adequada para este cenário é a diferença de conjuntos, subtraindo os chassis que constam nos registros de falhas do total de veículos produzidos.
π chassi (Veiculo) − π chassi (Veiculo_Defeito)

**4. Volume de produção agrupado por fábrica**
Utiliza-se o operador de agrupamento (γ) para contabilizar os veículos produzidos, necessitando de junções ao longo de toda a hierarquia de produção.
γ id_fabrica; COUNT(chassi) ( Fabrica ⋈ Linha_Montagem ⋈ Lote_Producao ⋈ Veiculo )

**5. Identificação de peças com estoque em nível crítico**
A seleção filtra previamente as quantidades inferiores a 50 unidades, realizando posteriormente as junções para recuperar a nomenclatura da peça e a localização da fábrica.
π nome_peca, localizacao, quantidade ( σ quantidade < 50 (Estoque_Peca) ⋈ Peca ⋈ Fabrica )

**6. Relatório de faturamento por concessionária (incluindo unidades sem vendas)**
Para garantir que lojas sem faturamento registrado não sejam omitidas do resultado, aplica-se o operador de junção externa à esquerda (⋈⟕).
γ id_concessionaria, nome_loja; SUM(1) ( Concessionaria ⋈⟕ Faturamento )

**7. Clientes com prazo de garantia expirado**
A seleção filtra as datas de vencimento anteriores à data corrente antes de executar as junções para obtenção dos dados cadastrais do proprietário.
π nome, cpf_cnpj, data_vencimento ( Cliente ⋈ Venda_Final ⋈ (σ data_vencimento < CURRENT_DATE (Garantia)) )

**8. Modelos com índice de produção superior à média global**
Esta consulta apresenta maior complexidade, exigindo o cálculo prévio da média total de produção para utilizá-la como critério de seleção na relação agrupada.
π id_modelo, total (
  γ id_modelo; COUNT(chassi) → total (Modelo ⋈ Versao ⋈ Veiculo)
) ▷ total > AVG(total)
