---
stepsCompleted: ["step-01-init", "step-02-discovery", "step-02b-vision", "step-02c-executive-summary", "step-03-success", "step-04-journeys", "step-05-domain", "step-06-innovation", "step-07-project-type", "step-08-scoping", "step-09-functional", "step-10-nonfunctional", "step-11-polish", "step-12-complete"]
inputDocuments: ["_bmad-output/brainstorming/brainstorming-session-2026-05-06.md"]
briefCount: 0
researchCount: 0
brainstormingCount: 1
projectDocsCount: 0
workflowType: 'prd'
classification:
  projectType: mobile_app
  domain: e-commerce
  complexity: medium
  projectContext: greenfield
---

# Product Requirements Document - madamejam

**Author:** Elton
**Date:** 2026-05-26

---

## Resumo Executivo

O madamejam é um aplicativo mobile dedicado a uma confeitaria artesanal baiana, criado para substituir o WhatsApp como canal de pedidos. A loja vende produtos perecíveis de alto valor simbólico (bolos, pudim, pão delícia) com entrega agendada para datas específicas — casamentos, aniversários, festas. A operação atual via mensagens gera perda de controle sobre encomendas, datas de entrega e pagamentos. O app resolve isso centralizando a jornada completa: catálogo, carrinho, pagamento confirmado e agendamento de entrega — com visibilidade de status de produção para o cliente e painel administrativo para a loja.

O público-alvo são dois: clientes que encomendam com datas fixas e a operadora da loja que precisa organizar produção, entregas e recebimentos. O produto é desenvolvido como solução interna desta loja — não uma plataforma genérica.

### O Que Torna Especial

O diferencial central é a **transparência de produção**: o cliente acompanha o status do próprio pedido (em produção, pronto, saiu para entrega) sem precisar perguntar. Isso resolve a ansiedade de compras com data crítica e reduz o volume de mensagens de acompanhamento para a loja.

Proposta de valor: *"Escolheu, pagou, recebeu. Simples, rápido e prático."*

### Classificação do Projeto

- **Tipo:** Aplicativo mobile (Android/iOS via Flutter)
- **Domínio:** E-commerce
- **Complexidade:** Média — dois perfis de usuário, fluxo de pagamento, agendamento de entrega, painel admin
- **Contexto:** Greenfield — construído do zero, sem legado

---

## Critérios de Sucesso

### Sucesso do Usuário

- Cliente finaliza pedido (catálogo → carrinho → pagamento → agendamento) sem nenhuma troca de mensagens com a loja
- Cliente acompanha status de produção do próprio pedido sem precisar perguntar
- Confirmação de pedido recebida imediatamente após pagamento aprovado pelo Stripe

### Sucesso do Negócio

- 100% dos pedidos processados pelo app — zero pedidos por WhatsApp
- Conciliação de pagamentos eliminada: Stripe consolida todos os recebimentos sem conferência manual
- Visão semanal de pedidos disponível para planejar compra de insumos
- Visão diária de pedidos disponível para organizar a produção do dia
- Volume atual de 20 pedidos/semana operado sem sobrecarga

### Sucesso Técnico

- Integração com Stripe confiável: aprovações, recusas e estornos tratados corretamente
- App funcional em iOS e Android a partir do mesmo código Flutter
- Atualização de status de produção reflete imediatamente para o cliente

### Resultados Mensuráveis

- **90 dias pós-lançamento:** migração completa do WhatsApp — 100% dos pedidos no app
- **90 dias pós-lançamento:** tempo médio de conclusão de pedido inferior a 5 minutos
- **Contínuo:** zero divergências entre pedidos registrados e pagamentos recebidos no Stripe

---

## Jornadas do Usuário

### Jornada do Cliente

1. Abre o app → navega no catálogo de produtos
2. Seleciona produto + variante/SKU + quantidade (app valida mínimo por item/SKU)
3. Adiciona ao carrinho → escolhe data de entrega (única por pedido)
4. Informa endereço de entrega → app valida cobertura da área antes do pagamento
5. Realiza pagamento via Stripe (cartão de crédito/débito)
6. Pedido confirmado apenas após aprovação do pagamento
7. Acompanha status de produção na tela do pedido:
   **Aguardando produção → Em produção → Pronto → Saiu para entrega → Entregue**

### Jornada da Admin (Loja)

1. Acessa painel admin (modo administrador no mesmo app)
2. Visualiza lista de pedidos da semana para planejar compra de insumos
3. Visualiza lista de pedidos do dia para organizar a produção
4. Abre detalhe do pedido: itens, cliente, endereço, valor, status de pagamento
5. Atualiza o status de produção de cada pedido conforme avança

---

## Modelo de Domínio

| Entidade | Atributos principais |
|---|---|
| **Produto** | nome, descrição, foto, ativo/inativo |
| **Variante/SKU** | nome, preço, quantidade mínima |
| **Pedido** | cliente, itens, data de entrega, endereço, status de pagamento, status de produção, total |
| **Item do Pedido** | produto, variante, quantidade, preço unitário |
| **Cliente** | nome, e-mail, telefone (cadastro obrigatório) |
| **Área de Cobertura** | lista de bairros/cidades atendidos |

**Status de produção (enum):**
`aguardando` → `em_producao` → `pronto` → `saiu_entrega` → `entregue`

**Regras de negócio centrais:**
- Um pedido = uma única data de entrega (duas datas = dois pedidos)
- Pedido confirmado apenas após pagamento aprovado pelo Stripe
- Endereço de entrega validado contra área de cobertura antes do checkout
- Fora da área de cobertura: bloqueio com mensagem clara (sem alternativa de retirada no MVP)
- Quantidade mínima validada por item/SKU no carrinho

---

## Requisitos Funcionais

### App do Cliente

**Catálogo**
- Listagem de produtos com foto, nome, descrição e preços
- Variantes/SKUs por produto (ex: pão delícia 500g, 1kg)
- Busca por nome de produto

**Carrinho**
- Adição de itens com seleção de variante e quantidade
- Validação de quantidade mínima por SKU ao adicionar
- Resumo do pedido com subtotal

**Checkout**
- Seleção de data de entrega (calendário, datas indisponíveis bloqueadas)
- Entrada e validação do endereço de entrega (cobertura)
- Pagamento via Stripe (cartão de crédito/débito)
- Tela de confirmação exibida apenas após pagamento aprovado

**Acompanhamento**
- Tela de status do pedido com progresso de produção
- Histórico de pedidos do cliente

**Conta**
- Cadastro e login obrigatórios (e-mail + senha)

### Painel Admin (Loja)

**Visão de pedidos**
- Lista de pedidos da semana atual agrupados por data de entrega (planejamento de insumos)
- Lista de pedidos do dia selecionado (planejamento de produção)
- Filtro por data

**Detalhe do pedido**
- Itens, variantes, quantidades
- Dados do cliente e endereço de entrega
- Valor total e status de pagamento (Stripe)
- Status de produção atual

**Gestão de produção**
- Atualização de status de produção por pedido (seleção do próximo estado)

**Cadastro de produtos**
- Criar e editar produtos com variantes, preços e quantidades mínimas
- Ativar/desativar produtos

**Configuração**
- Cadastro de bairros/cidades na área de cobertura
- Gerenciamento de datas indisponíveis para entrega

---

## Requisitos Não Funcionais

| Requisito | Especificação |
|---|---|
| **Plataforma** | Flutter — iOS e Android, único código-base |
| **Volume** | 20 pedidos/semana atual; arquitetura suporta crescimento sem reengenharia |
| **Pagamento** | Stripe exclusivamente; dados de cartão nunca trafegam pelo backend próprio (PCI via Stripe) |
| **Disponibilidade** | 99% — tolerável janela de manutenção noturna |
| **Performance** | Fluxo de pedido completo concluível em menos de 5 minutos |
| **Segurança** | Autenticação obrigatória para clientes e admin; painel admin protegido por papel (role) |

---

## Fora do Escopo — MVP

- Retirada na loja (entrega apenas no MVP)
- Checkout sem cadastro (guest checkout)
- Notificações push
- Cálculo de frete variável por distância
- Cupons e promoções
- Relatórios financeiros detalhados
- Histórico de clientes / CRM
- Pedido mínimo de carrinho (somente mínimo por item/SKU)

### Funcionalidades de Crescimento (Pós-MVP)

- Relatórios financeiros (receita por período, produto, canal)
- Histórico e perfil de clientes
- Cupons de desconto e promoções
- Notificações push (lembrete de entrega, atualização de produção)
- Painel admin expandido com métricas de operação

### Visão (Futuro)

- Programa de fidelidade
- Cardápio sazonal e produtos por encomenda especial
- Agendamento de produção assistido por capacidade vs. demanda
- Controle de estoque e insumos
