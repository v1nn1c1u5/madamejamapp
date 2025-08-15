# Madame Jam - Sistema de Gestão de Padaria

Sistema completo de gestão para padarias desenvolvido em Flutter com integração Supabase.

## 🚀 Como Executar o Projeto

### Pré-requisitos
- Flutter SDK 3.6.0+
- Dart 3.0+
- Conta ativa no Supabase

### 🔧 Configuração do Supabase

1. **Obtenha suas credenciais do Supabase:**
   - Acesse seu projeto no [Supabase Dashboard](https://supabase.com/dashboard)
   - Vá em Settings → API
   - Copie a `URL` e a `anon/public key`

2. **Execute o projeto com as variáveis de ambiente:**

```bash
# Método 1: Via linha de comando (Recomendado)
flutter run --dart-define=SUPABASE_URL=sua_url_aqui --dart-define=SUPABASE_ANON_KEY=sua_chave_aqui

# Método 2: Para desenvolvimento contínuo, crie um arquivo .env ou configure no VS Code
```

### 🔍 Troubleshooting - Problemas de Conexão

Se você estiver recebendo erros de conexão com o Supabase:

#### 1. Verifique as Credenciais
```bash
# Certifique-se de usar as credenciais corretas
flutter run --dart-define=SUPABASE_URL=https://seuprojeto.supabase.co --dart-define=SUPABASE_ANON_KEY=sua_chave_completa
```

#### 2. Teste a Conexão
O app incluí um botão "Testar Conexão" na tela de erro para verificar se a conexão com o banco está funcionando.

#### 3. Verifique o Status do Projeto Supabase
- Acesse o Supabase Dashboard
- Confirme que seu projeto está ativo
- Verifique se não há problemas de billing

#### 4. Logs de Debug
Execute em modo debug para ver logs detalhados:
```bash
flutter run --debug --dart-define=SUPABASE_URL=sua_url --dart-define=SUPABASE_ANON_KEY=sua_chave
```

## 📋 Funcionalidades

- **Dashboard Administrativo**: Métricas em tempo real
- **Gestão de Produtos**: CRUD completo com imagens
- **Gestão de Pedidos**: Acompanhamento de status
- **Base de Clientes**: Cadastro e histórico
- **Relatórios**: Análise de vendas e performance
- **Autenticação**: Sistema seguro com RLS

## 🏗️ Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada com inicialização Supabase
├── services/
│   ├── supabase_service.dart # Configuração e conexão Supabase
│   ├── bakery_service.dart   # Operações de banco específicas
│   └── auth_service.dart     # Autenticação
├── presentation/             # Telas da aplicação
└── core/                     # Configurações globais
```

## 🔐 Segurança

O projeto implementa:
- Row Level Security (RLS) no Supabase
- Autenticação baseada em JWT
- Políticas de acesso granulares
- Validação de dados no frontend e backend

## 🆘 Suporte

Se continuar enfrentando problemas:

1. Verifique se todas as tabelas existem no Supabase
2. Confirme se as políticas RLS estão configuradas
3. Teste a conexão diretamente no Supabase Dashboard
4. Verifique os logs do Flutter para erros específicos

## 📱 Plataformas Suportadas

- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

---

Para mais informações sobre configuração avançada, consulte a documentação do Supabase em [docs.supabase.com](https://docs.supabase.com).