---
stepsCompleted: [1, 2, 3, 4]
inputDocuments: ["_bmad-output/planning-artifacts/prd.md", "_bmad-output/planning-artifacts/architecture.md", "_bmad-output/brainstorming/brainstorming-session-2026-05-06.md"]
workflowType: 'epics-and-stories'
project_name: 'madamejam'
user_name: 'Elton'
date: '2026-06-13'
---

# Madame Jam - Epic Breakdown

## Overview

Este documento decompõe os requisitos do PRD e as decisões da Arquitetura do Madame Jam em épicos e histórias implementáveis. Os épicos estão organizados por valor de usuário, cada um entregando funcionalidade completa e habilitando os seguintes sem depender deles.

## Requirements Inventory

### Functional Requirements

- **FR1:** Cliente se cadastra com e-mail e senha
- **FR2:** Cliente faz login e recupera senha
- **FR3:** Cliente navega no catálogo de produtos com foto, descrição e preço
- **FR4:** Cliente visualiza variantes/SKUs de um produto (preço e quantidade mínima)
- **FR5:** Cliente busca produto por nome
- **FR6:** Admin cadastra e edita produtos com variantes, preços e quantidades mínimas
- **FR7:** Admin ativa/desativa produtos no catálogo
- **FR8:** Cliente adiciona item ao carrinho selecionando variante e quantidade
- **FR9:** Sistema valida quantidade mínima por SKU ao adicionar ao carrinho
- **FR10:** Cliente seleciona data de entrega única por pedido (datas bloqueadas indisponíveis)
- **FR11:** Cliente informa endereço e o sistema valida a área de cobertura antes do pagamento
- **FR12:** Admin gerencia a área de cobertura (estado, cidade, bairros)
- **FR13:** Admin gerencia datas bloqueadas para entrega
- **FR14:** Cliente paga com cartão de crédito/débito via Stripe
- **FR15:** Cliente paga via PIX (QR Code e copia-e-cola) via Stripe
- **FR16:** Pedido confirmado exibido somente após pagamento aprovado
- **FR17:** Cliente acompanha o status de produção do pedido em tempo real
- **FR18:** Cliente consulta seu histórico de pedidos
- **FR19:** Admin visualiza pedidos da semana (planejamento de insumos)
- **FR20:** Admin visualiza pedidos do dia (planejamento de produção)
- **FR21:** Admin abre o detalhe do pedido (itens, cliente, endereço, valor, status de pagamento)
- **FR22:** Admin atualiza o status de produção de cada pedido

### NonFunctional Requirements

- **NFR1:** App Flutter único para iOS e Android
- **NFR2:** Suportar 20 pedidos/semana com margem de crescimento sem reengenharia
- **NFR3:** Stripe exclusivo; dados de cartão nunca trafegam pelo backend próprio (PCI via Stripe)
- **NFR4:** Disponibilidade de 99%
- **NFR5:** Fluxo de pedido completo concluível em menos de 5 minutos
- **NFR6:** Autenticação obrigatória; painel admin protegido por role

### Additional Requirements

_Da Arquitetura (greenfield):_

- Setup inicial do projeto Flutter com Supabase SDK, Riverpod, go_router e flutter_stripe
- Supabase Edge Functions: `create-payment-intent`, `create-pix-payment`, `stripe-webhook`, `validate-delivery-zone`
- Row Level Security (RLS) habilitado em todas as tabelas
- Realtime via PostgreSQL Changes para status de produção
- Supabase Storage (bucket público) para imagens de produtos
- Role admin via `app_metadata.role` no JWT (não alterável pelo cliente)

### UX Design Requirements

- **UX-DR1:** Design system com paleta champagne/bege (`#C4A882`), off-white (`#F5F0EA`), carvão (`#2C2C2C`); tipografia serifada (títulos) + sans-serif (corpo)
- **UX-DR2:** Componentes reutilizáveis com identidade da loja; uso da mascote 3D em onboarding, estados vazios e confirmações
- **UX-DR3:** Fluxo de checkout que conduz o cliente à finalização em poucos cliques, com CTA sempre visível
- **UX-DR4:** Catálogo como vitrine — imagens de produtos em destaque

### FR Coverage Map

- FR1 → Epic 1 (cadastro)
- FR2 → Epic 1 (login/recuperação)
- FR3 → Epic 2 (navegação catálogo)
- FR4 → Epic 2 (variantes/SKUs)
- FR5 → Epic 2 (busca)
- FR6 → Epic 2 (admin cadastro produtos)
- FR7 → Epic 2 (admin ativa/desativa)
- FR8 → Epic 3 (adicionar ao carrinho)
- FR9 → Epic 3 (validação mínimo)
- FR10 → Epic 3 (data de entrega)
- FR11 → Epic 3 (validação cobertura)
- FR12 → Epic 3 (admin área cobertura)
- FR13 → Epic 3 (admin datas bloqueadas)
- FR14 → Epic 4 (cartão)
- FR15 → Epic 4 (PIX)
- FR16 → Epic 4 (confirmação pós-pagamento)
- FR17 → Epic 5 (status realtime cliente)
- FR18 → Epic 5 (histórico cliente)
- FR19 → Epic 5 (admin visão semanal)
- FR20 → Epic 5 (admin visão diária)
- FR21 → Epic 5 (admin detalhe pedido)
- FR22 → Epic 5 (admin atualiza status)

## Epic List

### Epic 1: Fundação Técnica & Acesso
Estabelece o esqueleto do app (Flutter + Supabase + design system) e permite que clientes se cadastrem, façam login e que o admin acesse a área protegida. Ao final, há um app navegável com autenticação funcional e identidade visual aplicada.
**FRs covered:** FR1, FR2 | **NFRs:** NFR1, NFR6 | **UX-DR:** UX-DR1, UX-DR2

### Epic 2: Catálogo de Produtos
Permite que o admin cadastre e gerencie produtos com variantes e que o cliente navegue, busque e visualize o catálogo como vitrine. Ao final, a loja tem um catálogo real e o cliente consegue explorar tudo que está à venda.
**FRs covered:** FR3, FR4, FR5, FR6, FR7 | **UX-DR:** UX-DR4

### Epic 3: Carrinho, Agendamento & Área de Entrega
Permite que o cliente monte o carrinho (com validação de mínimos), escolha a data de entrega e tenha o endereço validado contra a cobertura — e que o admin configure zonas e datas bloqueadas. Ao final, o cliente tem um pedido pronto e validado, aguardando apenas o pagamento.
**FRs covered:** FR8, FR9, FR10, FR11, FR12, FR13 | **NFR:** NFR5

### Epic 4: Pagamento & Confirmação
Permite que o cliente pague via cartão ou PIX pelo Stripe e receba a confirmação do pedido somente após a aprovação. Ao final, a loja recebe pagamentos consolidados sem conciliação manual.
**FRs covered:** FR14, FR15, FR16 | **NFR:** NFR3 | **UX-DR:** UX-DR3

### Epic 5: Acompanhamento & Gestão de Pedidos
Permite que o cliente acompanhe o status de produção em tempo real e veja seu histórico, e que o admin organize a operação (visão semanal/diária, detalhe e atualização de status). Ao final, o ciclo completo de pedido — do pagamento à entrega — é gerenciável.
**FRs covered:** FR17, FR18, FR19, FR20, FR21, FR22 | **NFR:** NFR2, NFR4

---

## Epic 1: Fundação Técnica & Acesso

Estabelecer a base técnica do app e o acesso autenticado de clientes e admin.

### Story 1.1: Configuração do projeto Flutter e Supabase

As a desenvolvedor,
I want o projeto Flutter inicializado com Supabase, Riverpod, go_router e o design system base,
So that exista uma fundação consistente sobre a qual todas as features serão construídas.

**Acceptance Criteria:**

**Given** um repositório Flutter greenfield
**When** o projeto é configurado
**Then** o cliente Supabase é inicializado com variáveis de ambiente (URL e anon key)
**And** Riverpod está configurado como gerenciador de estado
**And** go_router está configurado com rotas base e suporte a guards por role
**And** o tema do app reflete a paleta (champagne/bege/off-white/carvão) e as tipografias serifada/sans-serif (UX-DR1)

### Story 1.2: Cadastro de cliente com e-mail e senha

As a cliente,
I want me cadastrar com e-mail e senha,
So that eu possa fazer pedidos na loja.

**Acceptance Criteria:**

**Given** um cliente não cadastrado na tela de cadastro
**When** ele informa nome, e-mail, telefone e senha válidos
**Then** uma conta é criada no Supabase Auth
**And** um registro correspondente é criado na tabela `customers`
**And** o cliente é autenticado e direcionado à tela inicial
**Given** um e-mail já cadastrado
**When** o cliente tenta se cadastrar
**Then** uma mensagem clara informa que o e-mail já está em uso

### Story 1.3: Login e recuperação de senha

As a cliente,
I want fazer login e recuperar minha senha,
So that eu acesse minha conta com segurança.

**Acceptance Criteria:**

**Given** um cliente cadastrado
**When** ele informa e-mail e senha corretos
**Then** ele é autenticado e direcionado à tela inicial
**Given** credenciais inválidas
**When** o cliente tenta logar
**Then** uma mensagem de erro clara é exibida sem revelar qual campo falhou
**Given** um cliente que esqueceu a senha
**When** ele solicita recuperação informando o e-mail
**Then** o Supabase Auth envia o e-mail de redefinição de senha

### Story 1.4: Acesso protegido da área admin por role

As a operadora da loja,
I want acessar uma área administrativa restrita ao meu perfil,
So that apenas eu gerencie pedidos e produtos.

**Acceptance Criteria:**

**Given** um usuário com `app_metadata.role = 'admin'` no JWT
**When** ele faz login
**Then** a navegação exibe as rotas administrativas
**Given** um cliente comum (sem role admin)
**When** ele tenta acessar uma rota admin
**Then** o go_router bloqueia o acesso e redireciona para a área do cliente (NFR6)

---

## Epic 2: Catálogo de Produtos

Permitir que o admin gerencie o catálogo e o cliente o explore como vitrine.

### Story 2.1: Admin cadastra e edita produtos com variantes

As a operadora da loja,
I want cadastrar e editar produtos com suas variantes, preços e quantidades mínimas,
So that o catálogo reflita o que a loja vende.

**Acceptance Criteria:**

**Given** o admin autenticado na gestão de produtos
**When** ele cria um produto com nome, descrição e uma ou mais variantes (nome, preço, quantidade mínima)
**Then** os registros são salvos nas tabelas `products` e `skus`
**And** o produto fica disponível para edição posterior
**Given** um produto existente
**When** o admin edita seus dados ou variantes
**Then** as alterações são persistidas e refletidas no catálogo do cliente

### Story 2.2: Admin gerencia imagens do produto

As a operadora da loja,
I want adicionar imagens aos produtos,
So that o catálogo funcione como vitrine atrativa (UX-DR4).

**Acceptance Criteria:**

**Given** um produto existente
**When** o admin faz upload de uma ou mais imagens
**Then** as imagens são armazenadas no Supabase Storage (bucket público)
**And** as URLs são salvas em `product_images` com ordem de exibição
**Given** uma imagem cadastrada
**When** o admin a remove
**Then** ela deixa de aparecer no catálogo

### Story 2.3: Admin ativa e desativa produtos

As a operadora da loja,
I want ativar e desativar produtos,
So that eu controle o que está disponível para venda sem excluir o cadastro.

**Acceptance Criteria:**

**Given** um produto cadastrado
**When** o admin o desativa
**Then** o produto deixa de aparecer no catálogo do cliente
**And** o cadastro é preservado para reativação futura

### Story 2.4: Cliente navega no catálogo

As a cliente,
I want navegar pelos produtos com foto, descrição e preço,
So that eu descubra o que posso encomendar.

**Acceptance Criteria:**

**Given** produtos ativos cadastrados
**When** o cliente abre o catálogo
**Then** os produtos ativos são listados com imagem, nome e preço a partir de
**And** produtos inativos não aparecem
**Given** um produto sem imagem
**When** ele é exibido
**Then** um placeholder com a identidade da loja é mostrado (UX-DR2)

### Story 2.5: Cliente visualiza detalhe e variantes do produto

As a cliente,
I want ver o detalhe de um produto e suas variantes,
So that eu escolha a opção certa (ex: tamanho/peso) antes de comprar.

**Acceptance Criteria:**

**Given** um produto no catálogo
**When** o cliente abre o detalhe
**Then** a descrição completa, imagens e variantes com preço e quantidade mínima são exibidas (FR4)

### Story 2.6: Cliente busca produto por nome

As a cliente,
I want buscar produtos pelo nome,
So that eu encontre rapidamente o que quero (ex: "pão delícia").

**Acceptance Criteria:**

**Given** o catálogo com produtos ativos
**When** o cliente digita um termo de busca
**Then** os produtos cujo nome corresponde ao termo são exibidos
**And** uma busca por "pão delícia" retorna todas as variantes/SKUs relacionadas

---

## Epic 3: Carrinho, Agendamento & Área de Entrega

Permitir montar o pedido validado (itens, data, cobertura) e configurar as regras de entrega.

### Story 3.1: Admin gerencia área de cobertura

As a operadora da loja,
I want cadastrar os bairros/cidades atendidos,
So that apenas pedidos de áreas que conseguimos entregar sejam aceitos.

**Acceptance Criteria:**

**Given** o admin na configuração de entrega
**When** ele adiciona estado, cidade e bairros atendidos
**Then** os registros são salvos em `delivery_zones`
**And** ficam disponíveis para a validação de cobertura no checkout

### Story 3.2: Admin gerencia datas bloqueadas

As a operadora da loja,
I want bloquear datas em que não há entrega,
So that o cliente não agende para um dia indisponível.

**Acceptance Criteria:**

**Given** o admin na configuração de entrega
**When** ele bloqueia uma data
**Then** o registro é salvo em `blocked_dates`
**And** a data fica indisponível no seletor de data do cliente

### Story 3.3: Cliente adiciona itens ao carrinho com validação de mínimo

As a cliente,
I want adicionar produtos ao carrinho escolhendo variante e quantidade,
So that eu monte meu pedido respeitando os mínimos da loja.

**Acceptance Criteria:**

**Given** um produto com variante selecionada
**When** o cliente informa a quantidade e adiciona ao carrinho
**Then** o item é incluído com o preço unitário da variante
**Given** uma quantidade abaixo do mínimo do SKU
**When** o cliente tenta adicionar
**Then** o sistema bloqueia e informa a quantidade mínima exigida (FR9)
**And** o carrinho exibe o subtotal atualizado

### Story 3.4: Cliente seleciona data de entrega

As a cliente,
I want escolher uma data de entrega para o pedido,
So that eu receba no dia que preciso.

**Acceptance Criteria:**

**Given** um carrinho com itens
**When** o cliente abre o seletor de data
**Then** datas bloqueadas e datas passadas aparecem indisponíveis
**And** apenas uma data pode ser selecionada por pedido (FR10)

### Story 3.5: Cliente informa endereço e valida cobertura

As a cliente,
I want informar meu endereço de entrega e saber se é atendido,
So that eu só prossiga ao pagamento se a entrega for possível.

**Acceptance Criteria:**

**Given** um carrinho com data selecionada
**When** o cliente informa o endereço de entrega
**Then** a Edge Function `validate-delivery-zone` verifica contra `delivery_zones`
**And** se a área é atendida, o cliente avança para o pagamento
**Given** um endereço fora da cobertura
**When** a validação ocorre
**Then** o checkout é bloqueado com mensagem clara (sem opção de retirada no MVP) (FR11)

---

## Epic 4: Pagamento & Confirmação

Permitir o pagamento via Stripe (cartão e PIX) e confirmar o pedido apenas após aprovação.

### Story 4.1: Pagamento com cartão via Stripe

As a cliente,
I want pagar com cartão de crédito/débito,
So that eu finalize a compra de forma rápida (UX-DR3).

**Acceptance Criteria:**

**Given** um pedido validado pronto para pagamento
**When** o cliente escolhe pagar com cartão
**Then** a Edge Function `create-payment-intent` cria o PaymentIntent no Stripe e retorna o `client_secret`
**And** o `flutter_stripe` coleta os dados do cartão e confirma o pagamento
**And** os dados do cartão nunca trafegam pelo backend próprio (NFR3)
**Given** um cartão recusado
**When** o pagamento falha
**Then** uma mensagem clara é exibida e o pedido permanece com `payment_status = pending`

### Story 4.2: Pagamento via PIX via Stripe

As a cliente,
I want pagar via PIX,
So that eu use o meio de pagamento mais comum no Brasil.

**Acceptance Criteria:**

**Given** um pedido validado pronto para pagamento
**When** o cliente escolhe PIX
**Then** a Edge Function `create-pix-payment` cria o PaymentIntent PIX e retorna QR Code e código copia-e-cola
**And** o app exibe o QR Code e o código para o cliente
**Given** o cliente concluiu o pagamento no banco
**When** o Stripe processa o PIX
**Then** o status do pedido é atualizado automaticamente (sem ação manual do cliente)

### Story 4.3: Confirmação do pedido após pagamento aprovado

As a cliente,
I want ver a confirmação do pedido somente quando o pagamento for aprovado,
So that eu tenha certeza de que minha encomenda foi aceita.

**Acceptance Criteria:**

**Given** um pagamento iniciado (cartão ou PIX)
**When** o Stripe confirma a aprovação via webhook
**Then** a Edge Function `stripe-webhook` atualiza `orders.payment_status = 'paid'`
**And** o pedido recebe `production_status = 'aguardando'`
**And** via Supabase Realtime o app exibe a tela de "Pedido confirmado" (FR16)
**Given** um pagamento não aprovado
**When** o cliente aguarda
**Then** nenhuma confirmação é exibida e o pedido não entra na fila de produção

---

## Epic 5: Acompanhamento & Gestão de Pedidos

Permitir o acompanhamento em tempo real pelo cliente e a gestão operacional pelo admin.

### Story 5.1: Cliente acompanha status de produção em tempo real

As a cliente,
I want acompanhar o status de produção do meu pedido,
So that eu saiba em que etapa ele está sem precisar perguntar.

**Acceptance Criteria:**

**Given** um pedido confirmado
**When** o cliente abre a tela de acompanhamento
**Then** o status atual é exibido na linha do tempo (aguardando → em_producao → pronto → saiu_entrega → entregue)
**Given** o admin altera o status
**When** a mudança é persistida
**Then** via Supabase Realtime o app do cliente reflete o novo status em segundos sem recarregar (FR17)

### Story 5.2: Cliente consulta histórico de pedidos

As a cliente,
I want ver meus pedidos anteriores,
So that eu acompanhe e repita encomendas.

**Acceptance Criteria:**

**Given** um cliente com pedidos
**When** ele abre o histórico
**Then** seus pedidos são listados com data de entrega, itens, valor e status
**And** por RLS o cliente vê apenas os próprios pedidos (FR18)

### Story 5.3: Admin visualiza pedidos da semana

As a operadora da loja,
I want ver os pedidos da semana,
So that eu planeje a compra de insumos com antecedência.

**Acceptance Criteria:**

**Given** o admin na visão semanal
**When** ele abre a tela
**Then** os pedidos pagos da semana são agrupados por data de entrega
**And** os itens consolidados auxiliam o planejamento de insumos (FR19)

### Story 5.4: Admin visualiza pedidos do dia

As a operadora da loja,
I want ver os pedidos de um dia específico,
So that eu organize a produção daquele dia.

**Acceptance Criteria:**

**Given** o admin na visão diária
**When** ele seleciona uma data
**Then** os pedidos com entrega naquela data são listados com itens e status de produção (FR20)

### Story 5.5: Admin abre o detalhe do pedido

As a operadora da loja,
I want abrir o detalhe completo de um pedido,
So that eu tenha todas as informações para produzir e entregar.

**Acceptance Criteria:**

**Given** um pedido na lista
**When** o admin abre o detalhe
**Then** são exibidos itens e variantes, dados do cliente, endereço, valor total e status de pagamento (FR21)

### Story 5.6: Admin atualiza o status de produção

As a operadora da loja,
I want atualizar o status de produção de cada pedido,
So that o cliente acompanhe o progresso em tempo real.

**Acceptance Criteria:**

**Given** um pedido pago
**When** o admin avança o status (ex: aguardando → em_producao)
**Then** o novo status é persistido em `orders.production_status`
**And** a mudança dispara a atualização em tempo real no app do cliente (FR22, integra Story 5.1)
**Given** uma transição inválida (ex: pular etapas)
**When** o admin tenta aplicá-la
**Then** o sistema só permite avançar para o próximo estado válido na sequência
