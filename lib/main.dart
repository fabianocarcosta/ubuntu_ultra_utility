import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const UbuntuUltraApp());
}

class UbuntuUltraApp extends StatelessWidget {
  const UbuntuUltraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ubuntu Ultra Utility',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 11,
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/logo.png'),
          ),
          title: const Text('Ubuntu Ultra Utility v2.9'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.memory), text: 'RAM'),
              Tab(icon: Icon(Icons.smart_toy), text: 'Ollama'),
              Tab(icon: Icon(Icons.directions_boat), text: 'Docker'),
              Tab(icon: Icon(Icons.api), text: 'OpenClaw'),
              Tab(icon: Icon(Icons.terminal), text: 'IA CLIs'),
              Tab(icon: Icon(Icons.inventory_2), text: 'NPM Global'),
              Tab(icon: Icon(Icons.coffee), text: 'Java'),
              Tab(icon: Icon(Icons.code), text: 'Python'),
              Tab(icon: Icon(Icons.analytics), text: 'R & RStudio'),
              Tab(icon: Icon(Icons.computer), text: 'Sistema'),
              Tab(icon: Icon(Icons.info), text: 'Sobre'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RamManagerTab(),
            OllamaTab(),
            DockerTab(),
            ServiceTab(name: "OpenClaw", serviceCmd: "openclaw", installCmd: "npm install -g openclaw", sysName: "openclaw"),
            AILinuxCLIsTab(),
            NpmManagerTab(),
            SoftwareTab(name: "Java (OpenJDK 21)", pkg: "openjdk-21-jdk", cmd: "java"),
            SoftwareTab(name: "Python 3.13", pkg: "python3.13", cmd: "python3.13", ppa: "ppa:deadsnakes/ppa"),
            RAndRStudioTab(),
            SystemInfoAndCleanerTab(),
            AboutTab(),
          ],
        ),
      ),
    );
  }
}

// --- BASE PARA COMANDOS ---
abstract class CommandState<T extends StatefulWidget> extends State<T> {
  bool isLoading = false;
  String output = "";

  String _wrapCmd(String command) {
    return 'export NVM_DIR="\$HOME/.nvm"; [ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"; $command';
  }

  Future<ProcessResult> runCmd(String command, {bool asRoot = false}) async {
    setState(() { isLoading = true; output = "Processando..."; });
    try {
      final wrapped = _wrapCmd(command);
      final cmd = asRoot ? "pkexec bash -c '$wrapped'" : "bash -c '$wrapped'";
      final r = await Process.run('bash', ['-c', cmd]);
      setState(() => output = r.stdout.toString() + r.stderr.toString());
      return r;
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showMsg(String msg, bool ok) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: ok ? Colors.green : Colors.red));
  }
}

// 1. RAM
class RamManagerTab extends StatefulWidget { const RamManagerTab({super.key}); @override State<RamManagerTab> createState() => _RamManagerTabState(); }
class _RamManagerTabState extends CommandState<RamManagerTab> {
  int t = 0, u = 0; String cleanMsg = "";
  @override void initState() { super.initState(); _update(); }
  Future<void> _update() async {
    final lines = await File('/proc/meminfo').readAsLines();
    int total = int.parse(lines[0].replaceAll(RegExp(r'[^0-9]'), '')) ~/ 1024;
    int avail = int.parse(lines[2].replaceAll(RegExp(r'[^0-9]'), '')) ~/ 1024;
    setState(() { t = total; u = total - avail; });
  }
  @override Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Image.asset('assets/logo.png', height: 100),
      const SizedBox(height: 20),
      const Icon(Icons.memory, size: 80, color: Colors.blue),
      Text("Uso de RAM: $u MB / $t MB", style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: isLoading ? null : () async {
        final before = t - u; await runCmd('sync && echo 3 > /proc/sys/vm/drop_caches', asRoot: true); await _update();
        final freed = (t - u) - before; setState(() => cleanMsg = freed > 0 ? "Liberado: $freed MB" : "Já limpo!");
      }, child: const Text("LIMPAR RAM")),
      Text(cleanMsg, style: const TextStyle(color: Colors.green)),
    ]);
  }
}

// 2. OLLAMA
class OllamaTab extends StatefulWidget { const OllamaTab({super.key}); @override State<OllamaTab> createState() => _OllamaTabState(); } 
class _OllamaTabState extends CommandState<OllamaTab> {
  bool isInst = false, isRun = false;
  List<String> models = [];

  @override void initState() { super.initState(); _check(); }

  void _check() async {
    final w = await Process.run('which', ['ollama']);
    final pg = await Process.run('pgrep', ['-x', 'ollama']);
    setState(() { isInst = w.exitCode == 0; isRun = pg.exitCode == 0; });
    if (isInst) _loadModels();
  }

  void _loadModels() async {
    final r = await Process.run('ollama', ['list']);
    if (r.exitCode == 0) {
      final lines = r.stdout.toString().split('\n').skip(1);
      setState(() => models = lines.where((l) => l.trim().isNotEmpty).map((l) => l.split(RegExp(r'\s+'))[0]).toList());
    }
  }

  @override Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 20),
      Icon(isRun ? Icons.play_circle : Icons.stop_circle, size: 80, color: isRun ? Colors.green : Colors.red),
      const Text("Ollama Service", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Wrap(spacing: 10, children: [
        if (!isInst) 
          ElevatedButton.icon(
            onPressed: () async { await runCmd("curl -fsSL https://ollama.com/install.sh | sh", asRoot: true); _check(); }, 
            icon: const Icon(Icons.download), 
            label: const Text("INSTALAR OLLAMA"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          ),
        if (isInst) ...[
          ElevatedButton(onPressed: () async { await runCmd("systemctl start ollama", asRoot: true); _check(); }, child: const Text("START")),
          ElevatedButton(onPressed: () async { await runCmd("systemctl stop ollama", asRoot: true); _check(); }, child: const Text("STOP")),
        ]
      ]),
      const Divider(height: 40),
      const Text("Modelos Locais", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Expanded(
        child: models.isEmpty 
          ? const Center(child: Text("Nenhum modelo encontrado"))
          : ListView.builder(
              itemCount: models.length,
              itemBuilder: (c, i) => ListTile(
                leading: const Icon(Icons.psychology, color: Colors.blueAccent),
                title: Text(models[i]),
                trailing: IconButton(icon: const Icon(Icons.play_arrow), onPressed: () => runCmd("ollama run ${models[i]}"))
              )
            )
      ),
      IconButton(icon: const Icon(Icons.refresh), onPressed: _check),
    ]);
  }
}

// 3. DOCKER
class DockerTab extends StatefulWidget { const DockerTab({super.key}); @override State<DockerTab> createState() => _DockerTabState(); } 
class _DockerTabState extends CommandState<DockerTab> {
  bool isInst = false, isRun = false;
  List<String> containers = [];

  @override void initState() { super.initState(); _check(); }

  void _check() async {
    final w = await Process.run('docker', ['--version']);
    final st = await Process.run('systemctl', ['is-active', 'docker']);
    setState(() { isInst = w.exitCode == 0; isRun = st.stdout.toString().trim() == 'active'; });
    if (isInst && isRun) _loadContainers();
  }

  void _loadContainers() async {
    final r = await Process.run('docker', ['ps', '-a', '--format', '{{.Names}} ({{.Status}})',]);
    if (r.exitCode == 0) {
      setState(() => containers = r.stdout.toString().split('\n').where((l) => l.trim().isNotEmpty).toList());
    }
  }

  @override Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 20),
      Icon(isRun ? Icons.directions_boat : Icons.stop_circle, size: 80, color: isRun ? Colors.blue : Colors.red),
      const Text("Docker Engine", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Wrap(spacing: 10, children: [
        if (!isInst) 
          ElevatedButton.icon(
            onPressed: () async { await runCmd("apt-get update && apt-get install -y docker.io", asRoot: true); _check(); }, 
            icon: const Icon(Icons.download), 
            label: const Text("INSTALAR DOCKER"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
          ),
        if (isInst) ...[
          ElevatedButton(onPressed: () async { await runCmd("systemctl start docker", asRoot: true); _check(); }, child: const Text("START")),
          ElevatedButton(onPressed: () async { await runCmd("systemctl stop docker", asRoot: true); _check(); }, child: const Text("STOP")),
          ElevatedButton(onPressed: () async { await runCmd("systemctl restart docker", asRoot: true); _check(); }, child: const Text("RESTART")),
        ]
      ]),
      const Divider(height: 40),
      const Text("Containers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Expanded(
        child: containers.isEmpty 
          ? Center(child: Text(isInst ? "Nenhum container encontrado" : "Docker não instalado"))
          : ListView.builder(
              itemCount: containers.length,
              itemBuilder: (c, i) => ListTile(
                leading: Icon(Icons.view_agenda, color: containers[i].contains("Up") ? Colors.green : Colors.grey),
                title: Text(containers[i]),
                subtitle: const Text("Clique para reiniciar"),
                onTap: () async {
                  final name = containers[i].split(' ')[0];
                  await runCmd("docker restart $name", asRoot: true); _check();
                },
              )
            )
      ),
      if (isInst)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(onPressed: () => runCmd("docker system prune -f", asRoot: true), icon: const Icon(Icons.cleaning_services), label: const Text("Limpar Containers Parados")),
        ),
      IconButton(icon: const Icon(Icons.refresh), onPressed: _check),
    ]);
  }
}

// 4. SERVIÇOS (GENÉRICO)
class ServiceTab extends StatefulWidget {
  final String name, serviceCmd, installCmd, sysName;
  const ServiceTab({super.key, required this.name, required this.serviceCmd, required this.installCmd, required this.sysName});
  @override State<ServiceTab> createState() => _ServiceTabState();
}
class _ServiceTabState extends CommandState<ServiceTab> {
  bool isInst = false, isRun = false;
  @override void initState() { super.initState(); _check(); }
  void _check() async {
    final w = await Process.run('which', [widget.serviceCmd]);
    final pg = await Process.run('pgrep', ['-x', widget.sysName]);
    setState(() { isInst = w.exitCode == 0; isRun = pg.exitCode == 0; });
  }
  @override Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(isRun ? Icons.play_circle : Icons.stop_circle, size: 80, color: isRun ? Colors.green : Colors.red),
      Text(widget.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      Text(isRun ? "EM EXECUÇÃO" : "PARADO"),
      const SizedBox(height: 20),
      Wrap(spacing: 10, children: [
        if (!isInst) ElevatedButton(onPressed: () => runCmd(widget.installCmd, asRoot: true), child: const Text("INSTALAR")),
        if (isInst) ...[
          ElevatedButton(onPressed: () async { await runCmd("systemctl start ${widget.sysName} || ${widget.serviceCmd} start", asRoot: true); _check(); }, child: const Text("START")),
          ElevatedButton(onPressed: () async { await runCmd("systemctl stop ${widget.sysName} || ${widget.serviceCmd} stop", asRoot: true); _check(); }, child: const Text("STOP")),
          ElevatedButton(onPressed: () async { await runCmd("systemctl restart ${widget.sysName}", asRoot: true); _check(); }, child: const Text("RESTART")),
        ]
      ]),
      IconButton(icon: const Icon(Icons.refresh), onPressed: _check),
    ]);
  }
}

// 5. IA CLIs
class AILinuxCLIsTab extends StatefulWidget { const AILinuxCLIsTab({super.key}); @override State<AILinuxCLIsTab> createState() => _AILinuxCLIsTabState(); } 
class _AILinuxCLIsTabState extends CommandState<AILinuxCLIsTab> {
  final Map<String, List<String>> clis = {
    "Gemini CLI": ["gemini", "@google/gemini-cli"],
    "Claude Code": ["claude", "@anthropic-ai/claude-code"],
    "Cline": ["cline", "cline"],
    "Github Copilot": ["copilot", "@github/copilot"],
    "Codex": ["codex", "@openai/codex"],
    "Qwen Code": ["qwen", "@qwen-code/qwen-code"],
    "OpenCode": ["opencode", "opencode-ai"],
    "Pi": ["pi", "@mariozechner/pi-coding-agent"],
    "Droid": ["droid", "droid"],
  };

  Map<String, bool> instStatus = {};

  @override void initState() { super.initState(); _refresh(); }

  void _refresh() async {
    final wrap = 'export NVM_DIR="\$HOME/.nvm"; [ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"; ';
    final npmPrefixRes = await Process.run('bash', ['-c', '${wrap}npm config get prefix']);
    final npmBinDir = npmPrefixRes.stdout.toString().trim() + "/bin/";

    for (var entry in clis.entries) {
      final cmd = entry.value[0];
      final whichRes = await Process.run('bash', ['-c', '${wrap}which $cmd']);
      bool exists = whichRes.exitCode == 0;
      if (!exists) exists = await File(npmBinDir + cmd).exists();
      setState(() => instStatus[entry.key] = exists);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: clis.entries.map((e) => ListTile(
      leading: const Icon(Icons.terminal, color: Colors.cyanAccent),
      title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(instStatus[e.key] == true ? "✅ Instalado" : "❌ Não instalado"),
      trailing: ElevatedButton(
        onPressed: isLoading ? null : () async {
          await runCmd("npm install -g ${e.value[1]}", asRoot: true);
          _refresh();
        },
        child: Text(instStatus[e.key] == true ? "Atualizar" : "Instalar"),
      ),
    )).toList());
  }
}

// 6. NPM GLOBAL
class NpmManagerTab extends StatefulWidget { const NpmManagerTab({super.key}); @override State<NpmManagerTab> createState() => _NpmManagerTabState(); } 
class _NpmManagerTabState extends CommandState<NpmManagerTab> {
  List<String> pkgs = [];
  @override void initState() { super.initState(); _load(); }
  void _load() async {
    setState(() => isLoading = true);
    final wrap = 'export NVM_DIR="\$HOME/.nvm"; [ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"; ';
    final r = await Process.run('bash', ['-c', '${wrap}npm list -g --depth=0 --parseable']);
    setState(() {
      pkgs = r.stdout.toString().split('\n')
          .where((l) => l.isNotEmpty && l.contains('/node_modules/'))
          .map((l) => l.split('/').last)
          .toList();
      isLoading = false;
    });
  }
  @override Widget build(BuildContext context) {
    return Column(children: [
      const Padding(padding: EdgeInsets.all(12), child: Text("Pacotes NPM Instalados Globalmente", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      Expanded(
        child: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : ListView.builder(
              itemCount: pkgs.length, 
              itemBuilder: (c, i) => ListTile(
                leading: const Icon(Icons.folder_zip, color: Colors.orangeAccent),
                title: Text(pkgs[i]), 
                trailing: const Icon(Icons.check_circle, color: Colors.green)
              )
            )
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text("Sincronizar Lista")),
      ),
    ]);
  }
}

// 7. SOFTWARE
class SoftwareTab extends StatefulWidget {
  final String name, pkg, cmd;
  final String? ppa;
  const SoftwareTab({super.key, required this.name, required this.pkg, required this.cmd, this.ppa});
  @override State<SoftwareTab> createState() => _SoftwareTabState();
}
class _SoftwareTabState extends CommandState<SoftwareTab> {
  bool isInst = false;
  @override void initState() { super.initState(); _check(); }
  void _check() async { final r = await Process.run('which', [widget.cmd]); setState(() => isInst = r.exitCode == 0); }
  @override Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(widget.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Chip(label: Text(isInst ? "INSTALADO" : "NÃO ENCONTRADO"), backgroundColor: isInst ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2)),
      const SizedBox(height: 30),
      ElevatedButton(
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
        onPressed: isLoading ? null : () async {
          String c = "apt-get update && apt-get install -y ${widget.pkg}";
          if (widget.ppa != null) c = "add-apt-repository -y ${widget.ppa} && $c";
          await runCmd(c, asRoot: true); _check();
        }, 
        child: Text(isInst ? "REINSTALAR / ATUALIZAR" : "INSTALAR AGORA")
      ),
      IconButton(icon: const Icon(Icons.refresh), onPressed: _check),
    ]);
  }
}

// 8. R & RSTUDIO
class RAndRStudioTab extends StatefulWidget { const RAndRStudioTab({super.key}); @override State<RAndRStudioTab> createState() => _RAndRStudioTabState(); } 
class _RAndRStudioTabState extends CommandState<RAndRStudioTab> {
  String rsStatus = "Verificando...";
  @override void initState() { super.initState(); _check(); }
  void _check() async { final r = await Process.run('which', ['rstudio']); setState(() => rsStatus = r.exitCode == 0 ? "Instalado" : "Não encontrado"); }
  @override Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      ListTile(title: const Text("R Language"), subtitle: const Text("Versão estável via CRAN"), trailing: ElevatedButton(onPressed: () => runCmd('apt-get install -y r-base', asRoot: true), child: const Text("Instalar"))),
      const Divider(),
      ListTile(title: const Text("RStudio Desktop"), subtitle: Text("Status: $rsStatus"), trailing: ElevatedButton(onPressed: () => runCmd('wget -O /tmp/rstudio.deb https://download2.posit.co/rstudio-desktop/ubuntu22/amd64/rstudio-2024.12.0-356-amd64.deb && apt-get install -y /tmp/rstudio.deb', asRoot: true), child: const Text("Instalar"))),
    ]));
  }
}

// 9. SISTEMA
class SystemInfoAndCleanerTab extends StatefulWidget { const SystemInfoAndCleanerTab({super.key}); @override State<SystemInfoAndCleanerTab> createState() => _SystemInfoAndCleanerTabState(); } 
class _SystemInfoAndCleanerTabState extends CommandState<SystemInfoAndCleanerTab> {
  Map<String, String> info = {"SO": "...", "Kernel": "...", "Uptime": "..."};
  @override void initState() { super.initState(); _load(); }
  void _load() async {
    final os = await Process.run('lsb_release', ['-d']); final ker = await Process.run('uname', ['-r']); final upt = await Process.run('uptime', ['-p']);
    setState(() { info["SO"] = os.stdout.toString().split(':').last.trim(); info["Kernel"] = ker.stdout.toString().trim(); info["Uptime"] = upt.stdout.toString().trim(); });
  }
  @override Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      ...info.entries.map((e) => Card(child: ListTile(title: Text(e.key), trailing: Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold))))),
      const SizedBox(height: 20),
      ElevatedButton.icon(onPressed: () => runCmd("apt-get autoremove -y && apt-get clean && journalctl --vacuum-time=1d", asRoot: true), icon: const Icon(Icons.delete_sweep), label: const Text("LIMPEZA COMPLETA DO SISTEMA"), style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.all(15))),
    ]));
  }
}

// 10. SOBRE (DESENVOLVEDOR)
class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo.png', height: 150),
          const SizedBox(height: 20),
          const Text("Ubuntu Ultra Utility", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const Text("Versão 2.9 (PRO)", style: TextStyle(color: Colors.blueAccent)),
          const SizedBox(height: 30),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Desenvolvido por:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Fabiano (Ubuntu Power User)", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text("Objetivo:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Centralizar ferramentas de IA, Docker e", textAlign: TextAlign.center),
                  Text("Manutenção de Sistema no Ubuntu Linux.", textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text("© 2026 - Código Aberto", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
