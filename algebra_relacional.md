# Álgebra Relacional
**Aluna:** Sophia Byernes Carvalho Duarte

---

Esse documento mostra, em álgebra relacional, as consultas que depois foram implementadas em SQL no arquivo de consultas. A notação usada segue o padrão visto em aula: σ para seleção, π para projeção, ⋈ para junção natural (ou junção com condição quando indicado), ⋈⟕ para junção externa à esquerda, γ para agrupamento com agregação, e ρ para renomear uma relação quando necessário.

---

## 1. Veículos aprovados em todos os testes de qualidade

Buscar o chassi e o status de todo veículo cujos registros em `Teste_Qualidade` indicam aprovação.

```
σ aprovado = true (Teste_Qualidade) ⋈ Veiculo
```

Em projeção, mostrando apenas as colunas relevantes:

```
π chassi, status ( σ aprovado = true (Teste_Qualidade) ⋈ chassi=chassi Veiculo )
```

Essa consulta corresponde a uma seleção simples seguida de junção, sem agregação.

---

## 2. Funcionários e a fábrica em que trabalham

Listar nome do funcionário, cargo e nome da fábrica correspondente, unindo três relações.

```
π nome, titulo, localizacao (
    Funcionario ⋈ id_cargo=id_cargo Cargo ⋈ id_fabrica=id_fabrica Fabrica
)
```

Aqui aparecem duas junções naturais encadeadas, equivalente ao uso de `INNER JOIN` duplo em SQL.

---

## 3. Veículos que nunca tiveram nenhum defeito registrado

Esse caso pede uma diferença de conjuntos, porque precisa identificar veículos que **não aparecem** em `Veiculo_Defeito`.

```
π chassi (Veiculo) − π chassi (Veiculo_Defeito)
```

O resultado é o conjunto de chassis presentes em `Veiculo` mas ausentes em `Veiculo_Defeito`, o que em SQL se traduz em uma junção externa à esquerda com filtro de nulos, ou em uma subconsulta com `NOT IN`.

---

## 4. Quantidade de veículos produzidos por fábrica

Consulta de agregação, agrupando por fábrica e contando os veículos associados através da cadeia fábrica → linha → lote → veículo.

```
γ id_fabrica; COUNT(chassi) (
    Fabrica ⋈ Linha_Montagem ⋈ Lote_Producao ⋈ Veiculo
)
```

O operador γ aqui representa o agrupamento (`GROUP BY`) com a função de agregação `COUNT` aplicada sobre o atributo `chassi`.

---

## 5. Peças cujo estoque está abaixo de um determinado limite, por fábrica

Combina seleção com junção, identificando peças com saldo crítico.

```
π nome_peca, localizacao, quantidade (
    σ quantidade < 50 (Estoque_Peca) ⋈ codigo_peca=codigo_peca Peca ⋈ id_fabrica=id_fabrica Fabrica
)
```

A seleção aplica o filtro de quantidade antes da junção, o que é equivalente em resultado a aplicar o filtro depois, mas representa melhor a ideia de filtrar primeiro o estoque crítico.

---

## 6. Concessionárias e o total faturado, incluindo as que nunca receberam veículo

Esse caso exige uma junção externa à esquerda, porque queremos manter todas as concessionárias no resultado, mesmo aquelas sem nenhum faturamento associado.

```
γ id_concessionaria; nome_loja; SUM(1) (
    Concessionaria ⋈⟕ id_concessionaria=id_concessionaria Faturamento
)
```

A junção externa preserva as concessionárias sem correspondência em `Faturamento`, que aparecem com valor nulo na contagem, equivalente ao comportamento de um `LEFT JOIN` com `COUNT` em SQL.

---

## 7. Clientes cuja garantia já está vencida

Aqui é necessária uma subconsulta para comparar a data de vencimento da garantia com a data atual, depois de unir cliente, venda e garantia.

```
π nome, cpf_cnpj, data_vencimento (
    Cliente ⋈ id_cliente=id_cliente Venda_Final ⋈ id_venda=id_venda (
        σ data_vencimento < CURRENT_DATE (Garantia)
    )
)
```

A seleção interna filtra as garantias já vencidas antes de unir com os dados do cliente e da venda, o que evita carregar registros de garantias ainda válidas na junção.

---

## 8. Modelos de veículo cuja produção está acima da média geral

Essa consulta usa uma subconsulta escalar para calcular a média de produção por modelo e depois filtrar apenas os modelos acima dela.

```
π id_modelo, total (
    γ id_modelo; COUNT(chassi) → total (
        Modelo ⋈ Versao ⋈ Veiculo
    )
) ▷ total > AVG(total) (
    γ id_modelo; COUNT(chassi) → total ( Modelo ⋈ Versao ⋈ Veiculo )
)
```

Essa é a consulta mais elaborada do conjunto, porque combina agregação, agrupamento e uma segunda agregação (a média) usada como critério de comparação, o que em SQL é implementado como uma subconsulta dentro do `HAVING` ou em uma CTE separada.

---

## Observação final

As oito consultas cobrem os principais operadores estudados: seleção, projeção, junção natural, junção externa, diferença de conjuntos, agrupamento com agregação e subconsultas correlacionadas. A tradução de cada uma para SQL está no arquivo de consultas (`consultas_montadora.sql`), mantendo a correspondência direta entre o operador relacional e a cláusula SQL equivalente.
