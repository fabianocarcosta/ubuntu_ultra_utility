# Documentação de Uso - Ubuntu Ultra Utility v2.9

O **Ubuntu Ultra Utility** é uma ferramenta centralizada para desenvolvedores e entusiastas do Ubuntu Linux, focada em automação de manutenção, gerenciamento de containers, serviços de IA e configuração de ambiente de desenvolvimento.

---

## 🚀 Instalação

Você pode instalar o aplicativo utilizando um dos formatos gerados:

### 1. Pacote .DEB (Nativo)
```bash
sudo apt update
sudo apt install ./ubuntu_ultra_utility_1.0.0_amd64.deb
```

### 2. AppImage (Portátil)
1. Clique com o botão direito no arquivo `Ubuntu_Ultra_Utility.AppImage`.
2. Vá em **Propriedades > Permissões** e marque **Permitir execução**.
3. Dê um clique duplo para abrir.

---

## 🛠️ Funcionalidades principais

O aplicativo é dividido em abas intuitivas para facilitar o acesso às ferramentas:

### 1. Gerenciador de RAM (RAM)
- **Monitoramento:** Visualize em tempo real o uso de memória RAM (Usado vs Total).
- **Limpeza Inteligente:** Clique em **LIMPAR RAM** para liberar caches do sistema (`drop_caches`). *Requer senha de administrador.*

### 2. Gerenciador Ollama (Ollama)
- **Serviço:** Instale, inicie ou pare o serviço do Ollama diretamente pela interface.
- **Modelos Locais:** Liste todos os modelos baixados e execute-os com um clique.

### 3. Gerenciador Docker (Docker)
- **Engine:** Verifique o status do Docker e instale-o caso não esteja presente.
- **Containers:** Liste todos os containers (ativos e inativos), reinicie containers específicos ou faça uma limpeza geral de containers parados.

### 4. IA CLIs (IA CLIs)
- Central de instalação para as principais interfaces de linha de comando de IA:
  - Gemini CLI, Claude Code, GitHub Copilot, Cline, e mais.
- Verifique quais já estão instaladas e atualize-as facilmente.

### 5. OpenClaw (OpenClaw)
- Gerenciamento simplificado do serviço OpenClaw (Instalação via NPM, Start, Stop e Restart).

### 6. Linguagens e Ferramentas (Java, Python, NPM)
- **Java:** Instalação rápida do OpenJDK 21.
- **Python:** Instalação do Python 3.13 (via PPA deadsnakes).
- **NPM Global:** Liste e sincronize todos os seus pacotes Node.js instalados globalmente.

### 7. Ciência de Dados (R & RStudio)
- Instale a linguagem R (base-cran) e o RStudio Desktop com scripts de automação que lidam com downloads e dependências.

### 8. Sistema e Limpeza (Sistema)
- **Informações:** Veja versão do SO, versão do Kernel e Uptime do sistema.
- **Limpeza Profunda:** Executa uma faxina completa no sistema:
  - `apt autoremove` e `apt clean`.
  - Limpeza de logs do sistema (`journalctl`) com mais de 1 dia.

---

## 🔐 Segurança e Permissões

Muitas funções do aplicativo (como limpeza de RAM e instalação de pacotes) utilizam o comando `pkexec`. 
- Uma janela de autenticação do sistema aparecerá solicitando sua senha de usuário para realizar operações que exigem privilégios de `root`.
- O aplicativo **não armazena sua senha**.

---

## 👨‍💻 Sobre o Desenvolvedor
Desenvolvido por **Fabiano (Ubuntu Power User)**.
O **Ubuntu Ultra Utility** é um software de código aberto focado em produtividade para a comunidade Linux.

---
© 2026 - Ubuntu Ultra Utility Project