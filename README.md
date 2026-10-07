<div align="center">

<h1>NUX — CLI de administração Linux</h1>

<p>Ranlens Denck | Engenheiro Cloud | Especialista em Automações Linux</p>

<p>_"Construindo sistemas que não acordam pessoas de madrugada."_</p>

</div>

### Sobre

NUX é uma CLI de nível profissional para administração de sistemas Linux, construída em Go com arquitetura modular, parser de logs nativos e monitoramento de tentativas de ataque em tempo real.

### Screenshots — NUX em execução

<div align="center">

![NUX Dashboard](https://raw.githubusercontent.com/rsdenck/nux/main/docs/screenshots/dashboard.png) &
![NUX Disk](https://raw.githubusercontent.com/rsdenck/nux/main/docs/screenshots/disk.png) &
![NUX Network](https://raw.githubusercontent.com/rsdenck/nux/main/docs/screenshots/network.png) &
![NUX Services](https://raw.githubusercontent.com/rsdenck/nux/main/docs/screenshots/services.png) &
![NUX Security](https://raw.githubusercontent.com/rsdenck/nux/main/docs/screenshots/security.png) &
![NUX Attacks](https://raw.githubusercontent.com/rsdenck/nux/main/docs/screenshots/attacks.png)

</div>

*Capturas reais da TUI — cada aba do NUX MANAGER. As cores usam o tema RHEL Orange (acentos #ff8700, fundo escuro #2d1c0c).*

### Recursos principais

- **NUX MANAGER (TUI)**: interface em tela cheia para administrar o Linux — dashboard, serviços, processos, rede, disco, usuários, segurança e ataques ao vivo
- **Analyzer de tentativas em tempo real**: monitora SSH, NTP, SMB, NetBIOS, Telnet, FTP, SMTP, DNS, POP3, VNC e mais
- **Doctor completo**: verifica kernel, rede, segurança, storage e serviços
- **Hardening guiado** em `nux run`: cria usuário, gera chaves RSA 4096 via OpenSSL, desabilita login root por senha
- **Logs nativos Linux**: `journalctl -u <unit>` em systemd; fallback `tail -F /var/log/*` em distros sem systemd, com filtro por palavra-chave do serviço (evita falsos positivos)
- **Saída padronizada** no formato GCX (JSON/YAML) para automação e integração com ferramentas externas
- **Sem dependências de fail2ban** — tudo processado internamente

### Instalação

```bash
git clone https://github.com/rsdenck/nux
cd nux
go build ./cmd/nux
sudo cp nux /usr/local/bin/
```

### Quick start

```bash
# 1) Setup obrigatório (desbloqueia a CLI)
nux run

# 2) Abrir o NUX MANAGER (TUI completa de administração)
nux
#    (ou explicitamente: nux manager)

# 3) Saúde do sistema
nux doctor

# 4) Monitorar tentativas em tempo real
nux ssh view
nux ntp view

# 5) Snapshot estático
nux ssh view --once --tail 50
```

### NUX MANAGER (TUI)

Após o `nux run`, rodar `nux` sem argumentos abre o NUX MANAGER: uma TUI em tela cheia que administra o host inteiro, sem precisar decorar comandos.

Navegação: `tab` (ou `←`/`→`) troca de aba, `↑`/`↓` move a seleção e `enter` abre o item. `shift+tab` (ou `←`) abre a aba anterior. `esc` volta. `q` / `ctrl+c` sai.

| Aba          | O que mostra                                                 | O que `enter` faz                          |
|--------------|--------------------------------------------------------------|--------------------------------------------|
| DASHBOARD    | host, carga, memória, discos, serviços, ataques, alertas    | salta para a aba do item                   |
| SYSTEM       | SO, kernel, uptime, load, memória, swap, top processos        | `/proc` do processo, `free`, `vmstat`      |
| DISK         | filesystems com barras de uso + árvore do `lsblk`            | uso, inodes, maiores diretórios, smart     |
| NETWORK      | interfaces, IPs, MAC, portas em escuta (`ss -tulnp`)          | `ip addr`, rotas, estatísticas, dono da porta |
| SERVICES     | status de cada unidade systemd                                | **menu**: start, stop, restart, enable, disable, status, journal, dependências |
| PROCESSES    | top 20 processos por CPU                                      | `/proc`, fds abertos, linha de comando     |
| USERS        | contas locais e sessões ativas (`who`)                        | grupos, home, últimos logins, processos    |
| SECURITY     | postura (sshd, firewall, SELinux) + tentativas recentes      | a checagem e a **remediação sugerida**     |
| ATTACKS      | monitor ao vivo dos 10 protocolos, top IPs, eventos           | troca o protocolo ou mostra a linha do log |
| LOGS         | erros recentes do journal                                     | linha completa + histórico da unidade      |

### Teclas

```
navegação   tab /        proxima aba        shift+tab /      aba anterior
              ←           esquerda           →           direita
              ↑ ↓       mover a seleção    home / end    topo / fim
              pgup / pgdn pular 10 linhas   enter         abrir / executar
              esc         voltar            q / ctrl+c    sair

menus       ↑ ↓ escolhe · enter executa · esc fecha
              pgup / pgdn pula a lista · home / end topo / fim
 detalhe     ↑ ↓ rola · pgup / pgdn pula · home / end topo / fim · esc volta
 ajuda       ↑ ↓ rola · enter / esc fecha

 geral       f5 / r  recarrega a aba      p  liga/desliga auto-refresh
              m         menu NUX             f1 / ?  ajuda
              /         filtro incremental   esc limpa o filtro
```

Exemplo: `nux` → `tab` até SERVICES → `enter` no serviço → `enter` em *restart* → o comando roda e o resultado aparece numa tela rolável → `esc` volta.

> Sem `nux run` a TUI **nunca abre**: a CLI avisa `CLI BLOQUEADA` e pede o setup.

---

### `nux run` — Onboarding

```
Detecting Linux environment ......................... ✓
Detecting distribution ............................. ✓
...
SELECT ENVIRONMENT PROFILE
  1) Minimal
  2) Sysadmin
  3) DevOps
  4) Security
  5) Full
  6) Custom

SECURITY BOOTSTRAP  .--.   |o_o |  /   \  (\_.-.)/
Criar usuário administrador?
Gerar par de chaves privadas com openssl (RSA 4096)? [Y/n]
Desabilitar login root por senha no SSH? [Y/n]
```

### `nux doctor` — Diagnóstico

```
 NUX System Doctor
 ═══════════════════════════════════════════════════════
  SYSTEM
   Kernel             ✓ 5.14.0-687.48.1.el9_8.x86_64
   Architecture       ✓ x86_64
   Init system        ✓ systemd
   Filesystem         ✓

  NETWORK
   Default route      ✓
   DNS                ✓
   IPv4               ✓
   IPv6               ✓ sem IPv6

  SECURITY
   SELinux            ✓ enforcing
   Firewall           ✓ active
   SSH                ! 357 failed attempts
   Root login         ✓ disabled
   Password auth      ! enabled

  STORAGE
   /                  ✓ 78% used
   /var               ✓ 78% used
   /home              ✓ 78% used
   /etc               ✓ 78% used

  SERVICES
   systemd            ✓
   sshd               ✓
   chronyd            ✓ inactive
   firewalld          ✓

 ════════════════════════════════════════════════════════

 RESULT
   2 warnings
   0 critical issues
 Recommendation:
   nux security harden
```

### Analisador de Tentativas (TUI)

```bash
nux ssh view        # TUI ao vivo das tentativas SSH
nux ntp view        # TUI ao vivo do NTP
nux smb view        # SMB 445/TCP
nux telnet view     # Telnet 23/TCP
nux ftp view        # FTP 21/TCP
nux smtp view       # SMTP 25/TCP
nux dns view        # DNS 53
nux pop3 view       # POP3/POP3S 110/995
nux vnc view        # VNC 5900+
nux netbios view    # NetBIOS 139/TCP
```

Opções: `--once` (snapshot), `--tail N`, `--since "24 hours ago"`, `--refresh 2s`

### Arquitetura

```
cmd/nux/commands/
  manager.go            # NUX MANAGER (TUI) — abas, ações, filtro
  attempts.go           # nux <proto> view (TUI de tentativas)
  root.go               # ajuda, trava, atalhos -u/-a/-d
  run.go doctor.go ...  # demais comandos
internal/modules/
  attempts/             # analisador de logs nativos (parsers + TUI stream)
  manager/              # coleta de dados do host para a TUI
  audit/  ssh/  security/ ...
internal/tui/
  # raw mode, teclado, cores, alt screen
internal/output/
  # GCX format (JSON/YAML/table)
internal/vault/
  # config criptografada ~/.nux
```

### Por que `journalctl` + fallback de arquivo?

O NUX lê **logs nativos do Linux** diretamente — sem dependência de ferramentas externas. Em sistemas systemd usa `journalctl -u <unit>`; em distros sem systemd (Alpine/OpenRC) cai automaticamente para `tail -F /var/log/{messages,secure,syslog,xferlog,maillog}` com filtro por palavra-chave do serviço (evita falsos positivos).

### Testes

```bash
go test ./...
go vet ./cmd/nux/commands/
go build ./cmd/nux
```

### Releases & Versionamento

```bash
git tag v0.6.0
git push origin v0.6.0
goreleaser release --clean
```

### Contribuir

Veja [CONTRIBUTING.md](CONTRIBUTING.md). Issues e PRs são bem-vindos em https://github.com/rsdenck/nux

### Licença

MIT — ver [LICENSE](LICENSE).