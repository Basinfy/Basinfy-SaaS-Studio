<p align="right">
  <strong>🇧🇷 Português (Brasil)</strong> | <a href="README.en.md">🇺🇸 English</a>
</p>

<p align="center">
  <img src="docs/assets/banner.png" alt="Basinfy SaaS Studio Banner" width="100%" />
</p>

# Basinfy SaaS Studio

<p align="center">
  <strong>Estúdio Autônomo de Engenharia de Software e SaaS para Claude Code, Cursor, Antigravity e Agentes de IA</strong><br>
  <em>Transforme sua sessão de IA em uma agência completa de desenvolvimento com 49 agentes especializados, 74 fluxos de trabalho e 28 gates de governança.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Arquitetura-Multi--Agente_%26_Multi--LLM-6366f1.svg" alt="Arquitetura" />
  <img src="https://img.shields.io/badge/Agentes_Especializados-49_Especialistas-10b981.svg" alt="Agentes" />
  <img src="https://img.shields.io/badge/Comandos_Slash-74_Comandos_(/saas--*)-3b82f6.svg" alt="Comandos" />
  <img src="https://img.shields.io/badge/Director_Gates-28_Gates_Formais-f59e0b.svg" alt="Gates" />
  <img src="https://img.shields.io/badge/Fases_do_Pipeline-7_Etapas_de_Engenharia-ec4899.svg" alt="Fases" />
  <img src="https://img.shields.io/badge/Linguagens-Python_•_TypeScript_•_Go_•_Node-3776ab.svg" alt="Linguagens" />
  <img src="https://img.shields.io/badge/Stacks-FastAPI_•_Next.js_•_Django_•_Postgres_•_Docker-8b5cf6.svg" alt="Stacks" />
</p>

---

## 💡 O que é o Basinfy SaaS Studio na Prática?

Em termos práticos: **ele transforma sua ferramenta de IA (Claude Code, Cursor, Antigravity, Windsurf, Cline) em uma equipe completa e autônoma de desenvolvimento de software.**

Em vez de você ter que ficar digitando prompts soltos como *"crie uma tela de login"*, *"agora crie o backend"*, *"agora conecte o Stripe"* e torcer para o código não quebrar:

1. **Ele assume papéis reais de uma empresa de tecnologia**:
   Você não conversa com um modelo genérico. Você tem à sua disposição uma hierarquia com **49 profissionais especializados**:
   - Um **Diretor de Produto** (`product-director`) que valida se sua ideia de SaaS faz sentido comercial e define o modelo de monetização.
   - Um **Diretor Técnico** (`technical-director`) que desenha a arquitetura mestre, o banco de dados e as fronteiras da API.
   - Um **Líder de Engenharia** (`lead-engineer`) que audita a qualidade do código e refatora dívidas técnicas.
   - Um **Líder de QA** (`qa-lead`) que garante testes unitários, testes de integração e testes E2E.
   - **Especialistas dedicados** em Next.js, FastAPI, Supabase, Tailwind, Stripe, Docker, AWS e Segurança.

2. **Ele segue um processo de engenharia ponta a ponta**:
   O estúdio conduz seu projeto por 7 fases com 74 comandos práticos (`/saas-*`):
   - **Quer tirar uma ideia do papel?** Digite `/saas-start` e o estúdio entrevista você, sugere stacks e cria a fundação do projeto.
   - **Quer especificar funcionalidades?** Digite `/saas-design-system` e ele gera especificações técnicas (PRDs) completas.
   - **Quer codificar uma funcionalidade?** Digite `/saas-dev-story [ID]` e o especialista constrói o código com testes automatizados e segurança.
   - **Quer revisar o código?** Digite `/saas-code-review` e `/saas-security-audit` para encontrar bugs, falhas de segurança e injeções antes de ir pro ar.
   - **Quer lançar?** Digite `/saas-release-checklist` e ele audita variáveis de ambiente, DNS, banco de dados e gateways de pagamento.

3. **Ele nunca destrói seu código silenciosamente**:
   Toda ação segue um protocolo estrito de colaboração: ele sempre pergunta antes de escrever ou alterar arquivos (`"Posso escrever isso no arquivo X?"`), mostra o rascunho e só aplica as mudanças com sua aprovação explícita.

4. **Funciona tanto para projetos novos quanto para repositórios existentes**:
   - **Começando do zero?** Cria toda a estrutura, arquitetura, design tokens e banco de dados prontos para escalar.
   - **Já tem um projeto em andamento?** Injeta os agentes e workflows no repositório sem alterar nenhuma linha do seu código atual, analisa em que estágio seu projeto está e te ajuda a evoluir a partir dali.

---

## 🚀 Instalação Rápida via NPX (Universal Multi-LLM)

Instale e ative o **Basinfy SaaS Studio** com um único comando — com **zero dependências externas** e inicialização instantânea (< 1s). Compatível nativamente com **Claude Code**, **Cursor**, **Antigravity / Gemini CLI**, **Windsurf**, **Cline**, **Continue.dev** e **GitHub Copilot**.

### 1. Instalação Global (Recomendado)
Torne todos os **49 agentes** e **74 comandos `/saas-*`** disponíveis globalmente em **qualquer projeto ou pasta do seu computador**:

```bash
# Instalação global para TODAS as ferramentas de IA da sua máquina:
npx github:Basinfy/Basinfy-SaaS-Studio all --global

# Ou instale globalmente apenas para a sua ferramenta favorita:
npx github:Basinfy/Basinfy-SaaS-Studio claude --global
npx github:Basinfy/Basinfy-SaaS-Studio antigravity --global
npx github:Basinfy/Basinfy-SaaS-Studio cursor --global
npx github:Basinfy/Basinfy-SaaS-Studio windsurf --global
```

> **Como funciona a instalação global:** A CLI detecta o diretório central do seu sistema operacional (`~/.claude/`, `~/.gemini/config/skills/`, `~/.cursor/`, etc.) e injeta os agentes e as skills diretamente. A partir desse momento, qualquer novo terminal ou projeto aberto reconhece os comandos imediatamente!

### 2. Instalação Local no Projeto & Scaffolding
Crie um novo projeto SaaS do zero ou injete o estúdio em um repositório existente:

```bash
# Assistente guiado interativo (faz perguntas e configura o ambiente):
npx github:Basinfy/Basinfy-SaaS-Studio

# Criar um novo projeto SaaS completo em uma pasta (ex: ./meu-saas-app):
npx github:Basinfy/Basinfy-SaaS-Studio all --target ./meu-saas-app

# Injetar o Estúdio de IA em um projeto existente (Next.js, FastAPI, Node) sem sobrescrever código:
npx github:Basinfy/Basinfy-SaaS-Studio all --mode inject
```

### Matriz de Plataformas Suportadas:

| Plataforma / Ferramenta | Caminho Global | Configurações Locais | Comandos Slash & Regras |
| :--- | :--- | :--- | :--- |
| **Claude Code** | `~/.claude/` | `.claude/`, `CLAUDE.md`, `project.yaml` | 74 skills (`/saas-*`), 49 agentes, 28 gates |
| **Antigravity / Gemini** | `~/.gemini/config/skills/` | `GEMINI.md`, `.agents/skills/`, MCP | Todas as 74 skills + hierarquia de agentes |
| **Cursor** | `~/.cursor/rules/` | `.cursor/rules/saas-studio.mdc`, `.cursorrules` | Contexto completo do estúdio e fluxos de trabalho |
| **Windsurf** | `~/.codeium/windsurf/` | `.windsurf/rules/saas-studio.md`, `.windsurfrules` | Regras completas de engenharia e SOPs |
| **Cline / Roo-Code** | - | `.clinerules` | Instruções operacionais para agentes autônomos |
| **Continue.dev** | - | `.continue/rules.md` | Contexto e regras padronizadas de prompt |
| **Copilot & Devin** | - | `.github/`, `.devin/`, `AGENTS.md` | Convenções abertas do Agentic Standard |

---

## 📑 Sumário

1. [O que é o Basinfy SaaS Studio na Prática?](#-o-que-é-o-basinfy-saas-studio-na-prática)
2. [Instalação Rápida via NPX (Universal Multi-LLM)](#-instalação-rápida-via-npx-universal-multi-llm)
3. [Visão Executiva](#-visão-executiva)
4. [Stacks & Tecnologias Suportadas](#-stacks--tecnologias-suportadas)
5. [Arquitetura do Estúdio](#-arquitetura-do-estúdio)
6. [SOPs Determinísticos de Engenharia de Software](#-sops-determinísticos-de-engenharia-de-software)
7. [A Hierarquia dos 49 Agentes](#-a-hierarquia-dos-49-agentes)
8. [O Pipeline de Software em 7 Fases](#-o-pipeline-de-software-em-7-fases)
9. [Os 74 Comandos Slash (`/saas-*`)](#-os-74-comandos-slash-saas-)
10. [Director Gates & Controle de Qualidade](#-director-gates--controle-de-qualidade)
11. [Segurança Empresarial & Perímetro Defensivo](#-segurança-empresarial--perímetro-defensivo)
12. [Deploy em Nuvem & Publicação de Ponta a Ponta](#-deploy-em-nuvem--publicação-de-ponta-a-ponta)
13. [Configuração & Resolução Dupla (`project.yaml`)](#-configuração--resolução-dupla-projectyaml)
14. [Guia de Início Rápido & Workflows da Primeira Sessão](#-guia-de-início-rápido--workflows-da-primeira-sessão)
15. [Descoberta Inteligente de Código & Protocolo Dinâmico Basinfy](#-descoberta-inteligente-de-código--protocolo-dinâmico-basinfy)
16. [Verificação Automatizada & Autocura](#-verificação-automatizada--autocura)

---

## ⚡ Visão Executiva

O **Basinfy SaaS Studio** é uma arquitetura corporativa de orquestração multi-agente que transforma ferramentas de IA em uma agência completa e autônoma de desenvolvimento de software. Desenvolvido especificamente para aplicações web modernas, plataformas SaaS B2B/B2C, APIs robustas e microsserviços em nuvem, ele substitui a codificação desestruturada por **processos determinísticos de engenharia de software**.

### Pilares Arquiteturais Fundamentais:
- **Governança Hierárquica em 3 Tiers**: Visão estratégica gerenciada por Diretores Claude Opus; liderança técnica e de produto conduzida por Líderes Claude Sonnet; e execução técnica por 38 agentes especialistas.
- **Protocolo Estrito de Colaboração**: Toda mutação crítica obedece ao fluxo `Pergunta -> Opções -> Decisão -> Rascunho -> Aprovação`. Nenhuma alteração silenciosa ou destrutiva sem confirmação expressa do desenvolvedor.
- **28 Director Gates Formais**: Transições de fase exigem aprovações formais com vereditos técnicos padronizados (`READY / CONCERNS / NOT READY`, `SOUND / LEAKY BOUNDARIES`, etc.).
- **Namespace Sem Conflitos (`/saas-*`)**: Todos os 74 comandos utilizam o prefixo `/saas-`, permitindo coexistência perfeita com outras extensões e comandos do seu ambiente.
- **Controles de Segurança de Nível Corporativo**: Hooks de pre-commit bloqueiam vazamentos de credenciais e segredos de API, exigem PostgreSQL Row Level Security (RLS) e validam assinaturas criptográficas de webhooks do Stripe com payload bruto.
- **Checkpointing Durável de Sessão**: O arquivo `production/session-state/active.md` opera como uma máquina de estado persistente, imune a compactações de contexto, quedas ou reinicializações.
- **Indexação Semântica Inteligente com Basinfy**: Roteamento prioritário de busca de código pelo grafo de importações e bacias de dependência antes de recorrer a buscas cegas por grep/rg.

---

## 💻 Stacks & Tecnologias Suportadas

O **Basinfy SaaS Studio** não é limitado a uma única tecnologia. Ele é uma plataforma **multi-linguagem e multi-stack** com 38 especialistas de execução cobrindo os ecossistemas mais utilizados no mercado:

| Categoria | Tecnologias Principais Suportadas | Agentes Especialistas Dedicados |
| :--- | :--- | :--- |
| 🐍 **Python Ecosystem** | **Python 3.11+**, **FastAPI**, **Django**, **Flask**, **SQLAlchemy**, **Alembic**, **Pydantic**, **Celery**, **Pytest** | `python-backend-specialist`, `fastapi-specialist`, `backend-engineer` |
| 🌐 **TypeScript & Node** | **Next.js 14+** (App Router / Server Actions), **React**, **Node.js**, **Express**, **Fastify**, **NestJS**, **Vue/Nuxt**, **SvelteKit** | `nextjs-specialist`, `react-specialist`, `frontend-engineer`, `backend-engineer` |
| 🦫 **Go (Golang)** | **Go 1.22+**, **Gin**, **Chi**, **Fiber**, microsserviços de alta concorrência e Goroutines | `go-specialist`, `backend-engineer` |
| 🗄️ **Bancos de Dados & ORMs** | **PostgreSQL**, **Supabase**, **Neon**, **MySQL**, **MongoDB**, **Redis**, **Prisma**, **Drizzle**, **SQLAlchemy** | `database-architect`, `supabase-specialist`, `prisma-drizzle-specialist` |
| 🔒 **Auth & Segurança** | **Supabase Auth**, **Clerk**, **NextAuth / Auth.js**, **WorkOS**, RBAC, Row Level Security (RLS) | `auth-security-specialist`, `appsec-engineer` |
| 💳 **Billing & Pagamentos** | **Stripe**, **Paddle**, **LemonSqueezy**, Webhooks com verificação criptográfica de payload bruto | `billing-engineer`, `pricing-economist` |
| ☁️ **Nuvem, Infra & Filas** | **Docker**, **Kubernetes**, **AWS** (ECS, Lambda, S3, RDS), **Cloudflare** (Workers, D1, R2), **Vercel**, **Redis / Celery / BullMQ** | `docker-k8s-specialist`, `aws-specialist`, `cloudflare-specialist`, `queue-worker-specialist`, `devops-engineer` |
| 🤖 **Inteligência Artificial** | **OpenAI API**, **Anthropic Claude**, **LangChain**, **LlamaIndex**, embeddings e RAG | `ai-engineer` |

> **Configurável no seu `project.yaml`:** Você escolhe a sua combinação favorita de frontend, backend, banco e nuvem (ex: *Python + FastAPI + PostgreSQL* ou *Next.js + Supabase + Stripe* ou *Go + Docker + AWS*). O estúdio aciona automaticamente os agentes especialistas correspondentes à sua escolha!

---


## 🏛 Arquitetura do Estúdio

O estúdio opera como um sistema integrado com 8 motores mecânicos complementares:

```mermaid
flowchart TD
    subgraph ConfigLayer["1. Contratos & Configuração"]
        CM["CLAUDE.md / GEMINI.md<br/>(Protocolo de Colaboração & Checkpoints)"]
        PY["project.yaml<br/>(Fonte Única de Verdade da Equipe)"]
        PLY["project.local.yaml<br/>(Sobrescritas Locais do Desenvolvedor)"]
        YH["yaml-helper.sh<br/>(Resolução Dupla & Deep Merge)"]
    end

    subgraph AgentLayer["2. Hierarquia de Agentes (49 Especialistas)"]
        T1["Tier 1: Diretores Estratégicos<br/>(Opus / MaxTurns: 30)"]
        T2["Tier 2: Líderes de Departamento<br/>(Sonnet / MaxTurns: 25)"]
        T3["Tier 3: Especialistas de Execução<br/>(Sonnet / MaxTurns: 20)"]
    end

    subgraph SkillLayer["3. Motor de Habilidades (74 Comandos /saas-*)"]
        SK["Skills Canônicas & Avaliações Shell (!)<br/>Subpastas references/ dedicadas"]
    end

    subgraph GateLayer["4. Governança Formal (28 Director Gates)"]
        DG["Critérios Estritos de Aceite & Vereditos Objetivos<br/>Checklist de Transição de Fases"]
    end

    subgraph HookLayer["5. Perímetro Defensivo (18 Hooks Bash)"]
        HK["Pre-Commit (Anti-Vazamento de Segredos, Validação YAML/JSON)<br/>Write-Guard, Post-Checkout & Statusline"]
    end

    subgraph RuleLayer["6. Regras de Código (14 Scoped Rules)"]
        RL["PostgreSQL RLS, Next.js Server Actions,<br/>Webhooks Stripe com Raw Body, Acessibilidade WCAG"]
    end

    subgraph ScriptLayer["7. Utilitários Operacionais (35 Scripts)"]
        SC["ts-parse-check, prd-structure-check,<br/>project-coherence, state-management"]
    end

    subgraph StateLayer["8. Memória Durável de Sessão"]
        SS["production/session-state/active.md<br/>production/session-logs/<br/>.claude/agent-memory/"]
    end

    ConfigLayer --> AgentLayer
    AgentLayer --> SkillLayer
    SkillLayer --> GateLayer
    GateLayer --> HookLayer
    HookLayer --> RuleLayer
    RuleLayer --> ScriptLayer
    ScriptLayer --> StateLayer
```

---

## 🧠 SOPs Determinísticos de Engenharia de Software

O estúdio impõe Procedimentos Operacionais Padrão (SOPs) que garantem a previsibilidade e a rastreabilidade do desenvolvimento:

### 1. O Loop Colaborativo de 5 Etapas
Toda alteração de arquitetura, criação de funcionalidade, decisão técnica ou escrita de arquivo segue o ciclo obrigatório:
1. **Pergunta (`Question`)**: Esclarecer o escopo, requisitos de negócio e restrições técnicas.
2. **Opções (`Options`)**: Apresentar de 2 a 3 alternativas estruturadas destacando vantagens, desvantagens e impacto na complexidade.
3. **Decisão (`Decision`)**: O usuário escolhe a abordagem desejada.
4. **Rascunho (`Draft`)**: O agente elabora a especificação, o código ou o plano de testes.
5. **Aprovação (`Approval`)**: O agente solicita confirmação explícita antes de persistir em disco:
   > *"Posso salvar as alterações no arquivo `[caminho_do_arquivo]`?"*

### 2. Protocolo de Proteção contra Escritas Silenciosas
- É estritamente proibido sobrescrever arquivos de configuração fundamentais (`package.json`, `project.yaml`, `tsconfig.json`) sem consentimento explícito.
- O utilitário `write-guard.sh` intercepta tentativas de mutação cega e notifica os hooks de governança.

### 3. Checkpointing Durável de Sessão
- Toda ação crítica e avanço de sprint é registrado em `production/session-state/active.md`.
- Se a janela de contexto do modelo atingir o limite ou o terminal for reiniciado, o agente lê `active.md` imediatamente para restaurar o estado mental exato do estúdio.

---


## 🔄 Auto-Updater do Estúdio (Sincronização com GitHub)

O Basinfy SaaS Studio conta com um sistema de **Auto-Update contínuo** que garante que seu ambiente sempre tenha as skills, agentes e correções mais recentes lançadas no repositório GitHub, **sem jamais alterar seu código de negócio ou configurações locais**.

### 1. Atualização via CLI (NPX ou Node)
Para atualizar o projeto atual ou a instalação global a qualquer momento:
```bash
# Atualizar o projeto atual (preserva seu código em src/ e configs):
npx github:Basinfy/Basinfy-SaaS-Studio update

# Atualizar a instalação global (~/.claude, ~/.gemini, ~/.cursor):
npx github:Basinfy/Basinfy-SaaS-Studio update --global
```

### 2. Atualização via Hook / Terminal
No terminal do projeto, execute:
```bash
bash .claude/hooks/update-check.sh apply
```

### 3. Atualização Automática no Início de Sessão
No seu `project.yaml` ou `project.local.yaml`, configure o comportamento de atualização:
```yaml
updates:
  check: true     # true | false — checa atualizações no início de cada sessão
  auto: "prompt"  # "prompt" (avisa quando houver novidade) | true (atualiza silenciosamente) | false
```
- **Modo `"prompt"` (Padrão)**: Quando um commit ou release mais recente for detectado no GitHub, uma linha informativa surge no início da sessão com o comando de atualização.
- **Modo `true`**: Ao iniciar a sessão, se houver nova versão, os agentes, skills, hooks e regras são atualizados automaticamente em segundo plano.
- **Garantia de Segurança**: O atualizador **NUNCA** modifica seus arquivos em `src/`, `app/`, `project.yaml`, `project.local.yaml` ou credenciais em `.env*`.

---

## 👥 A Hierarquia dos 49 Agentes

O estúdio é organizado em 3 camadas de especialização que espelham uma empresa moderna de SaaS:

### Tier 1 — Diretores Estratégicos (Claude Opus / MaxTurns: 30)
- **`product-director`**: Guarda a visão do produto, ICP (Ideal Customer Profile), UVP, posicionamento de mercado e escopo estratégico.
- **`technical-director`**: Define e protege a arquitetura mestre, limites de API, escalabilidade, segurança e ADRs fundamentais.
- **`delivery-producer`**: Orquestra marcos de entrega (MVP, Beta, GA), velocidade das sprints, capacidade da equipe e gestão de riscos.

### Tier 2 — Líderes de Departamento (Claude Sonnet / MaxTurns: 20-25)
- **`lead-product-manager`**: Responsável pelas PRDs, especificações funcionais e critérios de aceite.
- **`lead-engineer`**: Conduz revisões de código, audita padrões de engenharia e gerencia dívida técnica.
- **`design-system-director`**: Guarda os tokens semânticos, consistência visual no Tailwind e componentes shadcn/ui.
- **`growth-director`**: Gerencia estratégias de ativação, SEO técnico, funis de conversão e mecânicas virais.
- **`ux-content-strategist`**: Define o tom de voz do produto, microcopy, mensagens de erro e e-mails transacionais.
- **`qa-lead`**: Constrói a estratégia da pirâmide de testes (Unitários, Integração, E2E) e aprovação de releases.
- **`release-manager`**: Gerencia versionamento semântico (SemVer), feature flags, migrações e rollbacks.
- **`localization-lead`**: Responsável por internacionalização (i18n), tabelas de tradução e layouts RTL.

### Tier 3 — Especialistas de Execução Técnica (38 Agentes)
- **Frontend & UI**: `frontend-engineer`, `nextjs-specialist`, `react-specialist`, `tailwind-shadcn-specialist`, `ui-motion-designer`, `accessibility-auditor`.
- **Backend & APIs**: `backend-engineer`, `fastapi-specialist`, `python-backend-specialist`, `go-specialist`, `queue-worker-specialist`, `realtime-websockets-specialist`.
- **Banco de Dados & Armazenamento**: `database-architect`, `supabase-specialist`, `prisma-drizzle-specialist`.
- **Segurança & Pagamentos**: `appsec-engineer`, `auth-security-specialist`, `billing-engineer`, `pricing-economist`.
- **Infraestrutura, DevOps & Cloud**: `cloud-infra-engineer`, `devops-engineer`, `docker-k8s-specialist`, `cloudflare-specialist`, `aws-specialist`, `sre-observability-engineer`.
- **Qualidade, Pesquisa & Suporte**: `qa-manual-tester`, `web-perf-analyst`, `data-telemetry-engineer`, `rapid-prototyper`, `onboarding-specialist`, `customer-success-ops`, `technical-writer`, `api-integrations-specialist`, `dev-tools-engineer`, `user-flow-architect`, `ux-designer`, `ai-engineer`.

---

## 🔄 O Pipeline de Software em 7 Fases

O ciclo de vida de desenvolvimento é estruturado em uma esteira contínua com portas de qualidade obrigatórias:

```
[1. Conceito] ──> [2. Arquitetura] ──> [3. Planejamento] ──> [4. Fundação] ──> [5. Sprints] ──> [6. Hardening] ──> [7. Lançamento]
      │                   │                     │                   │               │               │                │
 Gate DP-Phase       Gate TD-Phase         Gate QL-Story       Gate LE-Phase   Gate DS-Phase   Gate Sec-Audit    Gate Release-Ready
```

1. **Fase 1 — Conceito & Validação**: Ideação estruturada, definição de personas, análise de concorrentes e modelo de precificação.
2. **Fase 2 — Arquitetura & Especificações**: Criação de PRDs detalhadas, diagramas C4, esquemas relacionais de banco e ADRs formais.
3. **Fase 3 — Planejamento de Sprints**: Decomposição em épicos, quebra em user stories rastreáveis e estimativas de esforço.
4. **Fase 4 — Fundação & Setup da Infraestrutura**: Setup de repositório, CI/CD, banco de dados Supabase, autenticação e tokens de design.
5. **Fase 5 — Sprints de Funcionalidades**: Implementação orientada a testes (TDD), políticas de RLS e validação por story-done.
6. **Fase 6 — Hardening, Carga & Auditoria de Segurança**: Varredura OWASP Top 10, testes de estresse de API, profiling de Core Web Vitals.
7. **Fase 7 — Lançamento & Publicação em Nuvem**: Checklist pré-voo, implantação em produção, monitoramento pós-lançamento e suporte operacional.

---

## 🛠 Os 74 Comandos Slash (`/saas-*`)

Todas as habilidades contam com namespace único e não conflitante:

### 🚀 Onboarding & Diagnóstico
- `/saas-start`: Assistente guiado de primeira sessão para configurar o estúdio e stack.
- `/saas-help`: Navegador do catálogo de fluxos recomendando próximas ações baseadas no estado atual.
- `/saas-setup-stack`: Configura frontend, backend, banco de dados, auth e billing no `project.yaml`.
- `/saas-project-stage-detect`: Audita um repositório existente para identificar em qual das 7 fases ele se encontra.
- `/saas-onboard`: Gera documentação de onboarding para novos desenvolvedores ou agentes.
- `/saas-settings`: Visualiza e ajusta parâmetros de configuração do estúdio.

### 💡 Descoberta & Produto
- `/saas-brainstorm`: Explora ideias de SaaS, ICP, propostas de valor únicas e matrizes competitivas.
- `/saas-prototype`: Constrói protótipos funcionais rápidos para validação de hipóteses.
- `/saas-pricing-audit`: Analisa estratégias de monetização, tiers de assinatura e elasticidade de preços.
- `/saas-map-features`: Decompõe a visão do produto em módulos funcionais e grafos de dependência.
- `/saas-usability-test`: Elabora roteiros de testes de usabilidade e coleta de feedback de usuários.

### 📐 Arquitetura & Design de Sistema
- `/saas-create-architecture`: Gera o blueprint mestre de arquitetura (C4, limites de serviço, banco de dados).
- `/saas-architecture-decision`: Cria ADRs (Architecture Decision Records) estruturadas com prós e contras.
- `/saas-architecture-review`: Realiza auditoria cruzada entre PRDs e decisões de arquitetura.
- `/saas-design-system`: Cria a especificação completa de design system e componentes da aplicação.
- `/saas-design-tokens`: Define tokens semânticos no Tailwind (cores, espaçamento, tipografia, bordas).
- `/saas-design-review`: Audita interfaces construídas em relação aos tokens de design e usabilidade.
- `/saas-ux-design`: Cria especificações detalhadas de telas, jornadas e fluxos de navegação.
- `/saas-ux-review`: Valida padrões de interação, acessibilidade e microcopy de telas.
- `/saas-review-all-prds`: Varredura holística de todas as PRDs para evitar contradições de produto.
- `/saas-quick-design`: Especificação ágil e pontual para micro-funcionalidades.
- `/saas-reverse-document`: Constrói documentação técnica e PRDs a partir de código legado já existente.
- `/saas-propagate-design-change`: Propaga mudanças de especificações para ADRs e user stories afetadas.

### 📋 Planejamento & Gestão de Sprints
- `/saas-create-control-manifest`: Compila regras mandatórias das ADRs em um checklist executável.
- `/saas-create-epics`: Transforma especificações de arquitetura em épicos organizados.
- `/saas-create-stories`: Decompõe um épico em user stories implementáveis com critérios formais de aceite.
- `/saas-sprint-plan`: Planeja o backlog da sprint considerando velocidade e capacidade da equipe.
- `/saas-sprint-status`: Fornece um snapshot executivo do andamento e riscos da sprint em tempo real.
- `/saas-milestone-review`: Avaliação de marco (MVP, Beta, GA) com recomendação de go/no-go.
- `/saas-retrospective`: Retrospectiva da sprint com aprendizados e pontos de melhoria contínua.
- `/saas-estimate`: Estima esforço de tarefas com base em complexidade, riscos e dependências.
- `/saas-scope-check`: Monitora escopo contra o plano original para evitar inchaço de requisitos.

### 💻 Desenvolvimento & Engenharia
- `/saas-dev-story`: Implementa uma user story guiada por testes automatizados e critérios de aceite.
- `/saas-story-readiness`: Verifica se uma story possui todos os requisitos para iniciar o desenvolvimento.
- `/saas-story-done`: Valida se a story cumpre 100% dos critérios e registra as evidências de teste.
- `/saas-code-review`: Revisão rigorosa de código verificando SOLID, segurança, manutenibilidade e performance.
- `/saas-tech-debt`: Mapeia, categoriza e prioriza dívidas técnicas na base de código.
- `/saas-hotfix`: Fluxo emergencial para resolução e deploy rápido de bugs críticos em produção.
- `/saas-vertical-slice`: Constrói uma fatia vertical completa (UI + API + DB) para validação de ponta a ponta.

### 🛡 Qualidade, Testes & Segurança
- `/saas-test-setup`: Configura frameworks de teste (Vitest, Jest, Playwright, Pytest) e pipelines de CI.
- `/saas-test-helpers`: Gera utilitários, fábricas de dados (factories) e mocks padronizados.
- `/saas-qa-plan`: Elabora o plano completo de testes da sprint cobrindo fluxos críticos.
- `/saas-smoke-check`: Executa testes de fumaça essenciais para validação rápida de builds.
- `/saas-regression-suite`: Mapeia cobertura de regressão para garantir estabilidade pós-modificações.
- `/saas-test-evidence-review`: Audita a qualidade e a veracidade das asserções nos testes escritos.
- `/saas-test-flakiness`: Identifica testes intermitentes em logs de CI e orienta a correção.
- `/saas-security-audit`: Varredura completa de segurança (OWASP Top 10, injeção, CSRF, RLS, CVEs).
- `/saas-perf-profile`: Mede latências de API, tempos de resposta e Core Web Vitals.
- `/saas-load-test`: Executa testes de estresse em rotas de API, conexões de banco e filas assíncronas.
- `/saas-content-audit`: Audita e verifica consistência de dados e conteúdos estruturados.
- `/saas-consistency-check`: Varredura cruzada para detectar divergências entre código, schemas e PRDs.
- `/saas-asset-audit`: Audita ativos estáticos, fontes, ícones e otimizações de imagens.
- `/saas-asset-spec`: Define especificações técnicas para ativos gráficos e mídias do produto.

### 🚢 Release, Publicação & Pós-Lançamento
- `/saas-gate-check`: Avalia formalmente se o projeto cumpre os requisitos para avançar de fase.
- `/saas-release-checklist`: Checklist técnico completo pré-deployment em ambiente de produção.
- `/saas-launch-checklist`: Checklist de lançamento de produto (marketing, docs, suporte, tracking).
- `/saas-post-launch-monitor`: Protocolo de monitoramento pós-lançamento, métricas de erro e telemetria.
- `/saas-changelog`: Gera changelogs automáticos a partir do histórico de commits e entregas da sprint.
- `/saas-patch-notes`: Redige notas de atualização amigáveis direcionadas aos usuários finais.
- `/saas-localize`: Extrai strings, organiza dicionários de tradução e valida layouts internacionais.
- `/saas-bug-report`: Cria relatórios padronizados de bugs com passos para reprodução e severidade.
- `/saas-bug-triage`: Triagem e repriorização de bugs abertos no backlog.

### 👥 Orquestração de Equipes Multidisciplinares
- `/saas-team-core-feature`: Orquestra time completo para desenvolver uma funcionalidade central.
- `/saas-team-auth-access`: Orquestra especialistas para implementar fluxos de login, RBAC e sessões.
- `/saas-team-billing`: Orquestra engenheiros para checkout Stripe, planos recorrentes e webhooks.
- `/saas-team-content`: Orquestra time para CMS, blog, landing pages e SEO técnico.
- `/saas-team-ui`: Orquestra designers e devs frontend para construção de telas e fluxos.
- `/saas-team-polish`: Orquestra time de performance, refinamento visual e micro-animações.
- `/saas-team-qa`: Orquestra ciclo intensivo de testes automatizados e manuais.
- `/saas-team-release`: Orquestra o time de DevOps, SRE e release manager para subida em produção.
- `/saas-team-growth`: Orquestra time de growth para funis, eventos de telemetria e conversão.

### 🔧 Manutenção do Estúdio
- `/saas-adopt`: Realiza auditoria brownfield em projetos existentes para adoção do estúdio.
- `/saas-skill-test`: Testa a conformidade estrutural e comportamental das skills.
- `/saas-skill-improve`: Loop contínuo de autocura e refinamento das habilidades do estúdio.

---

## 🚦 Director Gates & Controle de Qualidade

As transições de fase exigem aprovação formal em 28 Director Gates divididos por área:

- **Diretoria de Produto (7 Gates)**: `dp-phase-gate`, `dp-scope-assessment`, `dp-epic-readiness`, `dp-sprint-readiness`, `dp-milestone-review`, `pd-prd-alignment`, `pd-usability-review`.
- **Diretoria Técnica (8 Gates)**: `td-phase-gate`, `td-architecture-review`, `td-adr-review`, `td-api-boundary`, `td-stack-risk`, `td-feasibility`, `td-control-manifest`, `td-change-impact`.
- **Liderança de Engenharia (2 Gates)**: `le-code-review`, `le-feasibility`.
- **Diretoria de Design System (4 Gates)**: `ds-phase-gate`, `ds-design-tokens`, `ds-component-audit`, `ds-branding-ui`.
- **Qualidade & QA (2 Gates)**: `ql-story-ready`, `ql-test-coverage`.
- **Conteúdo & UX (2 Gates)**: `uxc-copy-consistency`, `pd-messaging-tone`.

---

## 🔒 Segurança Empresarial & Perímetro Defensivo

O estúdio incorpora mecanismos proativos de segurança em todas as camadas de código:

1. **Varredura Ativa de Segredos (Pre-Commit)**: Bloqueia chaves privadas, tokens JWT, chaves de API (`sk_live_`, `AIzaSy`, `ghp_`) antes que entrem no controle de versão.
2. **PostgreSQL Row Level Security (RLS) Mandatório**: Nenhuma tabela com dados de usuário é criada sem políticas estritas de isolamento por `auth.uid()`.
3. **Webhooks Criptográficos Seguros**: Webhooks do Stripe, Paddle ou LemonSqueezy devem obrigatoriamente ler o corpo bruto da requisição (`rawBody`) para verificar a assinatura criptográfica antes de processar eventos.
4. **Proteção contra Injeção e Validação com Zod**: Validação estrita de entradas em todas as rotas e Server Actions.

---

## 🚀 Deploy em Nuvem & Publicação de Ponta a Ponta

O estúdio suporta pipelines prontos para as principais plataformas em nuvem:

- **Vercel / Next.js**: Otimizado para Edge Middleware, Server Actions e ISR.
- **Cloudflare Workers & Pages**: Latência ultra-baixa com CDN global.
- **AWS / Docker / Kubernetes**: Conteinerização multi-stage e orquestração escalável.
- **Supabase / PostgreSQL**: Migrações versionadas, backups automáticos e RLS auditado.

---

## ⚙️ Configuração & Resolução Dupla (`project.yaml`)

O estúdio adota o modelo de resolução dupla de configuração:
- `project.yaml`: Configurações oficiais compartilhadas por toda a equipe (versionado no Git).
- `project.local.yaml`: Sobrescritas específicas da máquina do desenvolvedor local (ignorado no Git).

```yaml
# Exemplo de project.yaml
project:
  name: "Meu SaaS Inc"
  tier: "production"
  slug: "meu-saas"

stack:
  frontend: "nextjs-app-router"
  styling: "tailwind-shadcn"
  backend: "nextjs-server-actions"
  database: "supabase-postgresql"
  auth: "supabase-auth"
  billing: "stripe"
  cloud: "vercel"

modes:
  review_mode: "solo"      # solo | team | strict
  strict_gates: true       # exige passagem obrigatória por gates
```

---

## 🚀 Guia de Início Rápido & Tutoriais Práticos

O **Basinfy SaaS Studio** pode ser utilizado em dois cenários fundamentais: criando um novo produto de software a partir do zero ou potencializando um projeto já existente com governança autônoma e 49 agentes especializados.

---

### 🟢 Tutorial 1: Criando um Novo Projeto SaaS do Zero (Greenfield)

Siga este passo a passo para construir um SaaS pronto para produção, com arquitetura sólida, documentação, testes e esteira de lançamento:

#### 1. Criar o Projeto com a CLI do Estúdio
Execute no terminal para gerar o scaffold completo da arquitetura e das ferramentas de IA:
```bash
# Cria uma nova pasta com toda a infraestrutura do estúdio
npx github:Basinfy/Basinfy-SaaS-Studio all --target ./meu-novo-saas

# Acesse o diretório do projeto
cd meu-novo-saas
```

#### 2. Abrir na sua Ferramenta de IA Favorita
Inicie a sessão no Claude Code, Cursor, Antigravity ou Windsurf:
```bash
# Para Claude Code:
claude

# Para Cursor / Windsurf:
cursor .
# ou: windsurf .
```

#### 3. Iniciar o Assistente de Onboarding
No chat ou terminal da IA, digite o comando mestre de inicialização:
```bash
/saas-start
```
O assistente analisará seu ambiente, fará perguntas sobre a visão do produto e preparará as configurações iniciais em `project.yaml`.

#### 4. Definir Conceito, ICP e Stack Tecnológica
Explore e consolide o posicionamento do seu software:
```bash
# 1. Brainstorming de proposta de valor, ICP e diferenciais competitivos:
/saas-brainstorm

# 2. Configurar a stack oficial (Next.js, FastAPI, Supabase, Tailwind, Stripe):
/saas-setup-stack
```

#### 5. Projetar a Arquitetura e o Design System
Antes de escrever código de produção, construa as especificações determinísticas:
```bash
# 1. Definir tokens semânticos de cores, tipografia e espaçamento no Tailwind:
/saas-design-tokens

# 2. Gerar o blueprint mestre de arquitetura (C4, limites de serviço, banco de dados):
/saas-create-architecture

# 3. Elaborar as PRDs (Product Requirement Documents) funcionais:
/saas-design-system
```

#### 6. Planejar e Executar Sprints de Desenvolvimento
Transforme as especificações em código testado e verificado:
```bash
# 1. Decompor a arquitetura em épicos e user stories:
/saas-create-epics
/saas-create-stories

# 2. Planejar o backlog da sprint inicial:
/saas-sprint-plan

# 3. Desenvolver uma história guiada por testes (TDD):
/saas-dev-story SAAS-101

# 4. Validar critérios de aceite e registrar evidências:
/saas-story-done SAAS-101
```

#### 7. Auditoria de Segurança e Lançamento
Valide todos os gates de qualidade antes de publicar:
```bash
# 1. Varredura de segurança OWASP, RLS no banco e análise de dependências:
/saas-security-audit

# 2. Avaliação formal do Director Gate para release:
/saas-gate-check

# 3. Execução do checklist pré-voo para publicação em produção:
/saas-release-checklist
```

---

### 🟡 Tutorial 2: Usando em um Repositório Já Existente (Brownfield)

Se você já possui uma aplicação em andamento (ex: um repositório Next.js, FastAPI, React, Node ou Python), você pode injetar o estúdio com total segurança, **sem sobrescrever nenhum código ou arquivo existente da sua aplicação**:

#### 1. Entrar na Pasta do seu Projeto Atual
```bash
cd /caminho/para/meu-projeto-existente
```

#### 2. Injetar o SaaS Studio no Modo Seguro (`--mode inject`)
Execute o comando com a flag de injeção brownfield:
```bash
npx github:Basinfy/Basinfy-SaaS-Studio all --mode inject
```
> **Segurança Garantida:** O modo `inject` adiciona apenas as pastas de inteligência e agentes (`.claude/`, `.cursor/`, `.agents/`, regras e templates), preservando 100% o seu `package.json`, seu código em `src/` ou `app/`, suas dependências e configurações prévias.

#### 3. Detectar a Fase Atual do seu Projeto
Abra sua ferramenta de IA (`claude`, `cursor`, etc.) e rode o detector de maturidade:
```bash
/saas-project-stage-detect
```
O estúdio escaneará sua base de código existente e identificará em qual das 7 fases o projeto se encontra (ex: *Fundação*, *Feature Sprints*, *Hardening*).

#### 4. Fazer a Auditoria de Adoção e Engenharia Reversa
Integre seu código existente à governança do estúdio:
```bash
# 1. Auditoria formal de compatibilidade com o estúdio:
/saas-adopt

# 2. Gerar documentação técnica e PRDs a partir do código já construído:
/saas-reverse-document
```

#### 5. Desenvolver Novas Funcionalidades com o Estúdio
A partir de agora, use os 49 agentes para acelerar novas entregas no seu projeto:
```bash
# Especificar rapidamente uma nova funcionalidade:
/saas-quick-design

# Implementar a nova história com TDD e boas práticas:
/saas-dev-story SAAS-NOVA-FEATURE

# Revisão de código arquitetural profunda:
/saas-code-review
```

#### 6. Auditar Segurança e Dívida Técnica Existente
Eleve o padrão de qualidade do seu código legado:
```bash
# Mapear e priorizar dívidas técnicas da base de código:
/saas-tech-debt

# Identificar vulnerabilidades, vazamentos de segredos e falhas de banco:
/saas-security-audit
```

---

### 📊 Comparativo Rápido dos Cenários

| Necessidade | Comando de Instalação | Primeiro Comando na IA | Objetivo Central |
| :--- | :--- | :--- | :--- |
| **Projeto Novo (Do Zero)** | `npx github:Basinfy/Basinfy-SaaS-Studio all --target ./app` | `/saas-start` | Criar um SaaS completo da ideação ao deploy com arquitetura perfeita |
| **Projeto Existente (Adição)** | `npx github:Basinfy/Basinfy-SaaS-Studio all --mode inject` | `/saas-project-stage-detect` | Adicionar 49 agentes e 74 fluxos sem alterar o código atual da aplicação |
| **Instalação Global na Máquina** | `npx github:Basinfy/Basinfy-SaaS-Studio all --global` | `/saas-help` | Ter todos os comandos `/saas-*` disponíveis em qualquer pasta do PC |

---

## 🔍 Descoberta Inteligente de Código & Protocolo Dinâmico Basinfy

O **Basinfy SaaS Studio** possui inteligência adaptativa integrada para reconhecimento de ambiente:

### 1. Detecção Automática e Transparente
Antes de realizar qualquer busca, leitura de arquivos ou análise de símbolos, os 49 agentes e as 74 skills do estúdio verificam automaticamente:
- Se a pasta `.basinfy/` existe na raiz do repositório, ou
- Se as ferramentas MCP (`basinfy_session_start`, `basinfy_search`, `basinfy_locate`, `basinfy_prepare_edit`, `basinfy_read`, `basinfy_impact`, etc.) ou a CLI `basinfy` estão disponíveis no ambiente.

### 2. Com Basinfy Instalado (`.basinfy/` detectado)
Quando o Basinfy está presente, o estúdio ativa imediatamente o **Protocolo Basinfy de Indexação Inteligente**:
- **Busca de Símbolos & Funções**: Utiliza `basinfy_prepare_edit` ou `basinfy_locate` para obter a definição exata, verificações de gate e grafo de dependências em uma única chamada.
- **Leitura & Busca de Seções**: Utiliza `basinfy_search` e `basinfy_read` com briefings L1/L2 condensados, sem necessidade de paginação manual por linha ou regex `^#`.
- **Criação de Novos Arquivos**: Executa `basinfy_prepare_create` antes de gerar novos módulos para respeitar limites arquiteturais.
- **Análise de Impacto & Blast Radius**: Executa `basinfy_impact` ou `basinfy_orbit` antes de refatorações críticas.
- **Economia de Contexto**: Reduz drasticamente o consumo de tokens e elimina leituras cegas de arquivos inteiros.

### 3. Fallback Suave (Sem Basinfy instalado)
Se o usuário ainda não possui o Basinfy configurado no projeto (a pasta `.basinfy/` não existe):
- O estúdio **não falha nem emite erros** — ele chaveia de forma 100% transparente para as ferramentas padrão da IDE/LLM (`Grep`, `ripgrep`, `Glob`, `Read`).
- Qualquer usuário final pode instalar e utilizar o estúdio imediatamente em qualquer projeto ou máquina sem nenhuma dependência obrigatória.

---

## 🧪 Verificação Automatizada & Autocura

O estúdio conta com uma suíte de testes de integridade que audita todos os componentes em tempo real:

```bash
# Executar a suíte de auditoria completa:
python studio-tests/verify-integrity.py
```

A suíte verifica:
- Presença e sintaxe de todos os 49 agentes e 74 skills `/saas-*`.
- Ausência de termos legados ou referências a outros repositórios.
- Funcionamento comportamental dos scripts bash de governança.
- Conformidade dos 28 Director Gates e templates de PRD.

---

## 📄 Licença

Distribuído sob a licença **MIT**. Veja `LICENSE` para mais informações.
Desenvolvido e mantido pela **Basinfy Community**.
