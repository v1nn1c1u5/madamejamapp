---
stepsCompleted: [1, 2]
inputDocuments: []
session_topic: 'App mobile para loja (bolos, pudim, pão delícia) com área admin e jornada cliente: catálogo, carrinho, pagamento e agendamento de entrega'
session_goals: 'Lista de funcionalidades para o MVP com fluxos de UX (cliente e loja)'
selected_approach: 'ai-recommended'
techniques_used: ['Question Storming', 'Role Playing', 'SCAMPER Method']
ideas_generated: []
context_file: ''
---

# Brainstorming Session Results

**Facilitator:** Elton
**Date:** 2026-05-06

## Visão geral da sessão

**Tema:** App mobile para uma loja que vende bolos, pudim e pão delícia (referência regional Bahia), com área administrativa para pedidos, datas de entrega, pagamentos e clientes; e app do cliente para consultar itens, montar carrinho, pagar e agendar entrega.

**Objetivos:** Definir lista de funcionalidades do MVP alinhada a fluxos de UX.

### Contexto

_Nenhum arquivo de contexto externo; escopo acordado na conversa._

### Configuração da sessão

Facilitação em PT-BR; foco em exploração geradora antes de organizar entregáveis finais; divergência por domínios (produto, UX, operação, negócio) para evitar ideias repetidas em sequência.

## Seleção de técnicas

**Abordagem:** Técnicas recomendadas pela IA  
**Contexto da análise:** App mobile para loja (dois lados: cliente e admin), entrega com data, pagamentos e catálogo de produtos frescos/perecíveis regionais.

**Técnicas escolhidas:**

- **Question Storming:** Mapear o espaço do problema com perguntas antes de “soluções” — reduz risco de MVP com fluxos errados (pagamento, disponibilidade, janela de entrega).
- **Role Playing:** Gerar funcionalidades e fios de UX a partir de vozes (cliente, loja, produção) — evita MVP genérico de e-commerce.
- **SCAMPER:** Cortar, fundir e priorizar o que emergiu — traduz exploração em lista enxuta para o primeiro release.

**Racional (IA):** Objetivo explícito de **lista de MVP + fluxos** pede primeiro **clareza do que não sabemos**, depois **empatia por papel**, por fim **lentes de modificação** para escopo.

## Execução — Question Storming (encerrado para transição)

**Temas explorados (perguntas levantadas, sem fechar respostas de negócio):** entrega fim de semana; pagamento antecipado vs na entrega; frete; retirada; validade/fabricação; pedido mínimo; painel admin (volume dia/semana/mês, embalagem, estoque, atrasos, reagenda/cancelamento, fases de produção, itens faltantes em pedido misto, dados de entrega); capacidade por tipo de produto; lista por horário e tipo (entrega/retirada); definição de “pago”; falha de entrega; estorno; cancelamento com gates; autorizado vs capturado (visão cliente vs loja); segunda tentativa e taxa; ausência e registro de motivo para estorno.

**Próxima técnica:** Role Playing.

### Role Playing — decisões já tomadas (lente cliente)

- Um pedido = **uma única data** de entrega (duas datas ⇒ dois pedidos).
- **Diferencial:** acompanhamento do **status de produção** (confiança).
- Cliente vê **“Pedido confirmado”** apenas **após confirmação do pagamento** (sem expor autorizado vs capturado).
- Não cadastrado: **endereço/área** (estado, cidade, bairros atendidos) **antes do pagamento** para validar cobertura.
- Busca “pão delícia” lista **vários SKUs** (variantes).
- Sistema valida **quantidade/valor mínimo por produto e/ou SKU** no carrinho.

_(Pendências anotadas na facilitação: pedido mínimo de carrinho vs só por item; bloqueio total vs oferta de retirada fora da área; conta vs convidado.)_
