# 🎯 Dojo Pokédex Full Stack (1 heure)

## 📋 Objectif
Créer une application CRUD complète pour gérer un Pokédex avec :
- Backend : Web API .NET avec Swagger + SQLite
- Frontend : Angular
- Environnement : GitPod/Codespaces

---

## 🔰 Phase 0 : Comprendre l'écosystème .NET (10 min - lecture avant le dojo)

### Qu'est-ce que .NET ?
**.NET** est une plateforme de développement créée par Microsoft, similaire à **Java/JVM** :

| Concept | .NET | Java | Explication |
|---------|------|------|-------------|
| Plateforme | .NET SDK | JDK (Java Development Kit) | Outils pour compiler et exécuter |
| Runtime | CLR (Common Language Runtime) | JVM (Java Virtual Machine) | Environnement d'exécution |
| Compilateur | Roslyn (C#) | javac | Transforme le code en bytecode |
| Gestionnaire de paquets | NuGet | Maven/Gradle | Gère les dépendances |
| Fichier de projet | `.csproj` | `pom.xml`/`build.gradle` | Configuration du projet |
| Commandes CLI | `dotnet` | `mvn`/`gradle` | Outils en ligne de commande |

### Installation Portable de .NET SDK 8.0 sur Debian 12 (Code-Server)

**Environnement cible :** Code-Server sur Debian 12 Linux x64

#### ⚠️ Pourquoi portable et pas de script install.sh ?
- ✅ Plus de contrôle sur le dossier d'installation
- ✅ Pas de droits sudo nécessaires
- ✅ Installation persistante dans `/home/coder`
- ✅ Facile à comprendre (pas de magie de script)
- ✅ Compatible avec les limitations Code-Server

#### 📥 Étape 1 : Télécharger la version portable

```bash
# Se placer dans le dossier utilisateur
cd /home/coder

# Télécharger le SDK .NET 8.0 portable pour Linux x64 (environ 280 MB)
# Version : 8.0.403 (consultez https://dotnet.microsoft.com/download/dotnet pour la dernière)
wget -q https://download.visualstudio.microsoft.com/download/pr/8f6c0ce2-cbbd-4c26-b6fe-2e8c02cfb9d4/6e9d5e0b0a6e2f4e5c3c6b0c4f3e6a8b/dotnet-sdk-8.0.403-linux-x64.tar.gz

# Vérifier le téléchargement
ls -lh dotnet-sdk-8.0.403-linux-x64.tar.gz
```

**📝 Explication du lien de téléchargement :**
- Format : `dotnet-sdk-8.0.X-linux-x64.tar.gz`
- `8.0.X` : Version majeure.mineure.patch
- `linux-x64` : Pour système 64-bit Debian/Linux
- `.tar.gz` : Archive compressée (pas d'installateur MSI/PKG)

#### 📂 Étape 2 : Créer le dossier d'installation

```bash
# Créer le répertoire où vivra .NET
mkdir -p /home/coder/.dotnet

# Vérifier
ls -la /home/coder/ | grep dotnet
```

#### 🗜️ Étape 3 : Extraire l'archive

```bash
# Extraire dans le dossier .dotnet
# Cela simule une installation sans installer de package système
tar -xzf dotnet-sdk-8.0.403-linux-x64.tar.gz -C /home/coder/.dotnet

# Vérifier le contenu
ls -la /home/coder/.dotnet/
# Résultat attendu :
# - sdk/
# - shared/
# - packs/
# - dotnet (exécutable)
```

**📝 Ce que contient l'archive :**
- `sdk/8.0.403/` : Compilateur et outils (comme javac)
- `shared/` : Runtime .NET partagé (comme le JRE)
- `packs/` : Paquets de runtime supplémentaires
- `dotnet` : Exécutable principal

#### 🧹 Étape 4 : Nettoyer l'archive

```bash
# Supprimer le fichier .tar.gz pour libérer l'espace
rm dotnet-sdk-8.0.403-linux-x64.tar.gz

# Vérifier l'espace utilisé
du -sh /home/coder/.dotnet/
# Résultat attendu : ~800 MB (SDK complet)
```

#### 🔧 Étape 5 : Configurer les variables d'environnement

**Temporairement (pour la session actuelle) :**
```bash
# Ajouter .dotnet au PATH
export DOTNET_ROOT=/home/coder/.dotnet
export PATH=$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH

# Désactiver la télémétrie Microsoft (optionnel mais recommandé)
export DOTNET_CLI_TELEMETRY_OPTOUT=1
```

**Définitivement (ajouter à ~/.zshrc_custom) :**

> **ℹ️ Info :** Code-Server utilise Zsh par défaut. Pour éviter de perdre votre configuration personnalisée lors des mises à jour, utilisez `.zshrc_custom` au lieu de `.zshrc`.

```bash
# Ouvrir ou créer le fichier custom
nano ~/.zshrc_custom

# Ajouter ces lignes à la fin du fichier
# ============= .NET Configuration =============
export DOTNET_ROOT=/home/coder/.dotnet
export PATH=$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH
export DOTNET_CLI_TELEMETRY_OPTOUT=1
# ============================================

# Sauvegarder : Ctrl+O, Entrée, Ctrl+X
```

**S'assurer que .zshrc_custom est chargé :**
```bash
# Vérifier que ~/.zshrc inclut le fichier custom
cat ~/.zshrc | grep zshrc_custom

# Si absent, ajouter à ~/.zshrc
echo 'source ~/.zshrc_custom' >> ~/.zshrc
```

**Recharger la configuration :**
```bash
source ~/.zshrc_custom
```

#### ✅ Étape 6 : Vérifier l'installation

```bash
# Vérifier que dotnet est accessible
which dotnet
# Résultat : /home/coder/.dotnet/dotnet

# Afficher la version
dotnet --version
# Résultat : 8.0.403

# Informations complètes
dotnet --info
# Affiche le SDK, Runtime, et l'architecture
```

**Sortie attendue :**
```
.NET SDK 8.0.403 (Standalone)

Runtime Identifier:     linux-x64
Base Path:              /home/coder/.dotnet/sdk/8.0.403

Environment variables:
DOTNET_ROOT           /home/coder/.dotnet
```

### Gérer plusieurs versions de .NET

Si vous avez besoin de plusieurs versions :

```bash
# Créer des dossiers séparés
mkdir -p /home/coder/.dotnet-6.0
mkdir -p /home/coder/.dotnet-7.0
mkdir -p /home/coder/.dotnet-8.0

# Télécharger et extraire dans chaque dossier

# Ajouter à ~/.zshrc_custom des alias pour chaque version
cat >> ~/.zshrc_custom << 'EOF'

# ============= Multi-version .NET Aliases =============
alias dotnet8="/home/coder/.dotnet-8.0/dotnet"
alias dotnet7="/home/coder/.dotnet-7.0/dotnet"
alias dotnet6="/home/coder/.dotnet-6.0/dotnet"
# =====================================================
EOF

source ~/.zshrc_custom

# Utiliser
dotnet8 --version  # 8.0.403
dotnet7 --version  # 7.0.x
```

**Alternative avec global.json :**
```bash
# Créer un fichier global.json à la racine du projet
cat > global.json << 'EOF'
{
  "sdk": {
    "version": "8.0.403",
    "rollForward": "latestMinor"
  }
}
EOF

# .NET utilisera cette version pour ce projet
```

### Configuration Code-Server pour Installation Automatique

Créer `.devcontainer/devcontainer.json` pour Code-Server :

```json
{
  "name": "Pokedex Dojo - .NET + Angular",
  "image": "codercom/code-server:latest",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "18"
    }
  },
  "postCreateCommand": "bash .devcontainer/setup.sh",
  "forwardPorts": [5000, 4200],
  "portsAttributes": {
    "5000": {
      "label": "Backend API",
      "onAutoForward": "notify"
    },
    "4200": {
      "label": "Frontend Angular",
      "onAutoForward": "openPreview"
    }
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-dotnettools.csharp",
        "ms-dotnettools.csdevkit",
        "angular.ng-template",
        "esbenp.prettier-vscode",
        "ms-azuretools.vscode-docker"
      ],
      "settings": {
        "dotnet.defaultSolution": "backend/PokedexApi/PokedexApi.csproj"
      }
    }
  },
  "remoteEnv": {
    "DOTNET_ROOT": "/home/coder/.dotnet",
    "PATH": "/home/coder/.dotnet:/home/coder/.dotnet/tools:${containerEnv:PATH}",
    "DOTNET_CLI_TELEMETRY_OPTOUT": "1"
  }
}
```

Créer `.devcontainer/setup.sh` :

```bash
#!/bin/bash
set -e

echo "🚀 Setting up Pokedex Dojo environment..."

# ====== Install .NET SDK portable ======
if [ ! -f "/home/coder/.dotnet/dotnet" ]; then
  echo "📦 Installing .NET SDK 8.0..."
  cd /home/coder
  
  wget -q https://download.visualstudio.microsoft.com/download/pr/8f6c0ce2-cbbd-4c26-b6fe-2e8c02cfb9d4/6e9d5e0b0a6e2f4e5c3c6b0c4f3e6a8b/dotnet-sdk-8.0.403-linux-x64.tar.gz
  mkdir -p /home/coder/.dotnet
  tar -xzf dotnet-sdk-8.0.403-linux-x64.tar.gz -C /home/coder/.dotnet
  rm dotnet-sdk-8.0.403-linux-x64.tar.gz
  
  echo "✅ .NET SDK installed"
else
  echo "✅ .NET SDK already installed"
fi

# ====== Configure Zsh ======
if ! grep -q "DOTNET_ROOT" ~/.zshrc_custom 2>/dev/null; then
  echo "🔧 Configuring Zsh..."
  cat >> ~/.zshrc_custom << 'ZSHCONFIG'

# ============= .NET Configuration =============
export DOTNET_ROOT=/home/coder/.dotnet
export PATH=$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH
export DOTNET_CLI_TELEMETRY_OPTOUT=1
# ============================================
ZSHCONFIG

  echo 'source ~/.zshrc_custom' >> ~/.zshrc
  echo "✅ Zsh configured"
fi

# ====== Restore dependencies ======
echo "📚 Restoring backend dependencies..."
cd /workspace/backend/PokedexApi
dotnet restore

echo "📚 Installing frontend dependencies..."
cd /workspace/frontend/pokedex-front
npm install

echo "✅ All dependencies installed"
echo "🎉 Setup complete! Ready to start the dojo."
```

### Gérer plusieurs versions de .NET

```bash
# Lister les versions installées
ls -la /home/coder/.dotnet/sdk/
# Résultat :
# 8.0.403/
# 7.0.410/

# Utiliser une version spécifique via global.json
cat > /project/global.json << 'EOF'
{
  "sdk": {
    "version": "8.0.403"
  }
}
EOF

# Vérifier quelle version est active
dotnet --version  # Affiche 8.0.403
```

### Variables d'environnement importantes

```bash
# Afficher le chemin d'installation
echo $DOTNET_ROOT
# Résultat : /home/coder/.dotnet

# Afficher le PATH
echo $PATH
# Doit contenir /home/coder/.dotnet

# Dossier de cache NuGet
export NUGET_PACKAGES=/home/coder/.nuget/packages

# Désactiver la télémétrie
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Logs détaillés de build
export DOTNET_CLI_VERBOSITY=detailed

# Voir toutes les variables d'environnement .NET
env | grep DOTNET
```

### Qu'est-ce que NuGet ?

**NuGet** est le gestionnaire de paquets de .NET, équivalent à **Maven Central** ou **npm** :

| NuGet (.NET) | Maven (Java) | npm (JavaScript) |
|--------------|--------------|------------------|
| `dotnet add package` | `mvn dependency:add` | `npm install` |
| `nuget.org` | `mvnrepository.com` | `npmjs.com` |
| `.csproj` | `pom.xml` | `package.json` |
| Packages stockés dans `~/.nuget/packages` | `~/.m2/repository` | `node_modules` |

#### Commandes NuGet essentielles
```bash
# Ajouter un package
dotnet add package Newtonsoft.Json
dotnet add package Newtonsoft.Json --version 13.0.1

# Restaurer les packages
dotnet restore

# Lister les packages installés
dotnet list package

# Lister les packages obsolètes
dotnet list package --outdated

# Mettre à jour un package
dotnet add package Newtonsoft.Json --version 13.0.3
```

### Commandes .NET essentielles (comparaison Java)

| Tâche | .NET | Java (Maven) | Explication |
|-------|------|--------------|-------------|
| **Compiler** | `dotnet build` | `mvn compile` | Compile le code source |
| **Compiler (Release)** | `dotnet build -c Release` | `mvn compile -Pproduction` | Mode optimisé |
| **Exécuter** | `dotnet run` | `mvn exec:java` | Compile et exécute |
| **Tester** | `dotnet test` | `mvn test` | Lance les tests unitaires |
| **Publier** | `dotnet publish` | `mvn package` | Crée un package déployable |
| **Nettoyer** | `dotnet clean` | `mvn clean` | Supprime les fichiers compilés |
| **Restaurer deps** | `dotnet restore` | `mvn dependency:resolve` | Télécharge les dépendances |

#### Détail des commandes importantes

**1. `dotnet build`** - Compiler le projet
```bash
dotnet build                    # Mode Debug par défaut
dotnet build -c Release         # Mode Release (optimisé)
dotnet build --no-restore       # Sans restaurer les packages
dotnet build -v detailed        # Mode verbose
```

**2. `dotnet run`** - Compiler et exécuter
```bash
dotnet run                      # Lance l'application
dotnet run --project ./MyApp    # Spécifier le projet
dotnet run -- arg1 arg2         # Passer des arguments
```

**3. `dotnet publish`** - Créer un package de déploiement
```bash
dotnet publish -c Release -o ./publish    # Publier en Release
dotnet publish --self-contained true      # Inclure le runtime
dotnet publish -r linux-x64               # Pour Linux 64-bit
```

**4. `dotnet watch`** - Rechargement automatique (comme nodemon)
```bash
dotnet watch run    # Redémarre à chaque modification
```

### Structure d'un projet .NET

```
MonProjet/
├── MonProjet.csproj          ← Fichier de configuration (comme pom.xml)
├── Program.cs                ← Point d'entrée (comme Main.java)
├── appsettings.json          ← Configuration (comme application.properties)
├── Controllers/              ← Contrôleurs REST
├── Models/                   ← Entités/DTOs
├── Services/                 ← Logique métier
├── bin/                      ← Fichiers compilés (comme target/)
│   ├── Debug/
│   └── Release/
└── obj/                      ← Fichiers intermédiaires (comme .class)
```

### Le fichier `.csproj` expliqué

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <!-- Version du framework -->
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <!-- Dépendances -->
  <ItemGroup>
    <PackageReference Include="Microsoft.EntityFrameworkCore.Sqlite" Version="8.0.0" />
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.5.0" />
  </ItemGroup>
</Project>
```

**Comparaison avec pom.xml (Maven) :**
```xml
<!-- Java/Maven équivalent -->
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
        <version>3.2.0</version>
    </dependency>
</dependencies>
```

### Gérer plusieurs versions de .NET

**.NET** utilise un système de **SDK** multiples, comme Java avec plusieurs versions de JDK :

```bash
# Lister toutes les versions installées
dotnet --list-sdks
# Résultat possible :
# 6.0.420 [C:\Program Files\dotnet\sdk]
# 7.0.410 [C:\Program Files\dotnet\sdk]
# 8.0.100 [C:\Program Files\dotnet\sdk]

# Lister les runtimes
dotnet --list-runtimes
```

#### Fichier `global.json` - Fixer une version (comme .java-version)
Créer un fichier `global.json` à la racine du projet :
```json
{
  "sdk": {
    "version": "8.0.100",
    "rollForward": "latestMinor"
  }
}
```

**Comparaison avec Java :**
- `global.json` ≈ `.sdkmanrc` ou variable `JAVA_HOME`
- .NET charge automatiquement la version spécifiée

### Variables d'environnement importantes

```bash
# Afficher le chemin d'installation de .NET
echo $DOTNET_ROOT  # Linux/Mac
echo %DOTNET_ROOT% # Windows

# Personnaliser le dossier des packages NuGet
export NUGET_PACKAGES="$HOME/.nuget/packages"

# Niveau de log pour le build
export DOTNET_CLI_TELEMETRY_OPTOUT=1  # Désactiver la télémétrie
```

### Qu'est-ce que NuGet ?

**NuGet** est le gestionnaire de paquets de .NET, équivalent à **Maven Central** ou **npm** :

| NuGet (.NET) | Maven (Java) | npm (JavaScript) |
|--------------|--------------|------------------|
| `dotnet add package` | `mvn dependency:add` | `npm install` |
| `nuget.org` | `mvnrepository.com` | `npmjs.com` |
| `.csproj` | `pom.xml` | `package.json` |
| Packages stockés dans `~/.nuget/packages` | `~/.m2/repository` | `node_modules` |

#### Commandes NuGet essentielles
```bash
# Ajouter un package (comme Maven dependency)
dotnet add package Newtonsoft.Json
dotnet add package Newtonsoft.Json --version 13.0.1

# Restaurer les packages (comme mvn clean install)
dotnet restore

# Lister les packages installés
dotnet list package

# Rechercher un package
dotnet search EntityFramework

# Supprimer un package
dotnet remove package Newtonsoft.Json

# Mettre à jour tous les packages
dotnet list package --outdated
dotnet add package <PackageName> --version <NewVersion>
```

### Commandes .NET essentielles (comparaison Java)

| Tâche | .NET | Java (Maven) | Explication |
|-------|------|--------------|-------------|
| **Compiler** | `dotnet build` | `mvn compile` | Compile le code source |
| **Compiler (Release)** | `dotnet build -c Release` | `mvn compile -Pproduction` | Mode optimisé |
| **Exécuter** | `dotnet run` | `mvn exec:java` | Compile et exécute |
| **Tester** | `dotnet test` | `mvn test` | Lance les tests unitaires |
| **Publier** | `dotnet publish` | `mvn package` | Crée un package déployable |
| **Nettoyer** | `dotnet clean` | `mvn clean` | Supprime les fichiers compilés |
| **Restaurer deps** | `dotnet restore` | `mvn dependency:resolve` | Télécharge les dépendances |

#### Détail des commandes importantes

**1. `dotnet build`** - Compiler le projet
```bash
dotnet build                    # Mode Debug par défaut
dotnet build -c Release         # Mode Release (optimisé)
dotnet build --no-restore       # Sans restaurer les packages
dotnet build -v detailed        # Mode verbose
```

**2. `dotnet run`** - Compiler et exécuter
```bash
dotnet run                      # Lance l'application
dotnet run --project ./MyApp    # Spécifier le projet
dotnet run -- arg1 arg2         # Passer des arguments
```

**3. `dotnet publish`** - Créer un package de déploiement
```bash
dotnet publish -c Release -o ./publish    # Publier en Release
dotnet publish --self-contained true      # Inclure le runtime
dotnet publish -r linux-x64               # Pour Linux 64-bit
dotnet publish -r win-x64                 # Pour Windows 64-bit
```

**4. `dotnet watch`** - Rechargement automatique (comme nodemon)
```bash
dotnet watch run    # Redémarre à chaque modification
```

### Structure d'un projet .NET

```
MonProjet/
├── MonProjet.csproj          ← Fichier de configuration (comme pom.xml)
├── Program.cs                ← Point d'entrée (comme Main.java)
├── appsettings.json          ← Configuration (comme application.properties)
├── Controllers/              ← Contrôleurs REST
├── Models/                   ← Entités/DTOs
├── Services/                 ← Logique métier
├── bin/                      ← Fichiers compilés (comme target/)
│   ├── Debug/
│   └── Release/
└── obj/                      ← Fichiers intermédiaires (comme .class)
```

### Le fichier `.csproj` expliqué

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <!-- Version du framework (comme <java.version>11</java.version>) -->
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <!-- Dépendances (comme <dependencies> dans pom.xml) -->
  <ItemGroup>
    <PackageReference Include="Microsoft.EntityFrameworkCore.Sqlite" Version="8.0.0" />
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.5.0" />
  </ItemGroup>
</Project>
```

**Comparaison avec pom.xml (Maven) :**
```xml
<!-- Java/Maven équivalent -->
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
        <version>3.2.0</version>
    </dependency>
</dependencies>
```

---

## 🚀 Phase 1 : Configuration initiale (5 min)

### Prérequis dans GitPod (Debian 12)

**Installation rapide pour le dojo (copy-paste) :**

```bash
# 1. Installer .NET SDK portable
cd /home/coder
wget -q https://download.visualstudio.microsoft.com/download/pr/8f6c0ce2-cbbd-4c26-b6fe-2e8c02cfb9d4/6e9d5e0b0a6e2f4e5c3c6b0c4f3e6a8b/dotnet-sdk-8.0.403-linux-x64.tar.gz
mkdir -p /home/coder/.dotnet
tar -xzf dotnet-sdk-8.0.403-linux-x64.tar.gz -C /home/coder/.dotnet
rm dotnet-sdk-8.0.403-linux-x64.tar.gz

# 2. Configurer le PATH
export DOTNET_ROOT=/home/coder/.dotnet
export PATH=$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# 3. Persister dans .bashrc
echo 'export DOTNET_ROOT=/home/coder/.dotnet' >> ~/.bashrc
echo 'export PATH=$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH' >> ~/.bashrc
echo 'export DOTNET_CLI_TELEMETRY_OPTOUT=1' >> ~/.bashrc
source ~/.bashrc

# 4. Vérifier
dotnet --version
```

### Vérifier les prérequis

```bash
# Vérifier .NET
dotnet --version  # Doit afficher 8.0.403

# Vérifier Node.js (GitPod le fournit)
node --version    # v18+
npm --version
```

### Créer la structure du projet

```bash
# Créer les dossiers
mkdir -p pokedex-app/{backend,frontend}
cd pokedex-app
```

---

## 🔧 Phase 2 : Backend .NET (25 min)

### Étape 1 : Créer le projet API (3 min)
```bash
cd backend

# Créer un nouveau projet Web API
# Équivalent Java : mvn archetype:generate -DarchetypeArtifactId=maven-archetype-webapp
dotnet new webapi -n PokedexApi

cd PokedexApi

# Ajouter les packages NuGet nécessaires
# Équivalent Java : ajouter <dependency> dans pom.xml
dotnet add package Microsoft.EntityFrameworkCore.Sqlite
dotnet add package Microsoft.EntityFrameworkCore.Design

# Restaurer les packages (télécharger les dépendances)
# Équivalent Java : mvn dependency:resolve
dotnet restore
```

**📝 Explication des commandes :**

- `dotnet new webapi` : Crée un projet Web API à partir d'un template
  - Templates disponibles : `console`, `classlib`, `webapi`, `mvc`, `blazor`
  - Voir tous les templates : `dotnet new list`
  
- `-n PokedexApi` : Nom du projet (crée le dossier et le fichier `.csproj`)

- `dotnet add package` : Ajoute une dépendance NuGet
  - `Microsoft.EntityFrameworkCore.Sqlite` : ORM + driver SQLite (comme Hibernate + JDBC)
  - `Microsoft.EntityFrameworkCore.Design` : Outils de migration (comme Flyway)

**🔍 Vérifier les packages installés :**
```bash
dotnet list package
# Résultat :
# Microsoft.EntityFrameworkCore.Sqlite    8.0.0
# Microsoft.EntityFrameworkCore.Design    8.0.0
```

### Étape 2 : Créer le modèle Pokemon (2 min)
Créer `Models/Pokemon.cs` :
```csharp
namespace PokedexApi.Models
{
    public class Pokemon
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public int Level { get; set; }
        public string? ImageUrl { get; set; }
    }
}
```

### Étape 3 : Configurer le DbContext (3 min)
Créer `Data/PokedexContext.cs` :
```csharp
using Microsoft.EntityFrameworkCore;
using PokedexApi.Models;

namespace PokedexApi.Data
{
    public class PokedexContext : DbContext
    {
        public PokedexContext(DbContextOptions<PokedexContext> options) 
            : base(options) { }

        public DbSet<Pokemon> Pokemons { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Données initiales
            modelBuilder.Entity<Pokemon>().HasData(
                new Pokemon { Id = 1, Name = "Pikachu", Type = "Electric", Level = 25 },
                new Pokemon { Id = 2, Name = "Bulbasaur", Type = "Grass/Poison", Level = 15 },
                new Pokemon { Id = 3, Name = "Charmander", Type = "Fire", Level = 18 }
            );
        }
    }
}
```

### Étape 4 : Configurer Program.cs (3 min)
Modifier `Program.cs` :
```csharp
using Microsoft.EntityFrameworkCore;
using PokedexApi.Data;

var builder = WebApplication.CreateBuilder(args);

// Services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// SQLite Database
builder.Services.AddDbContext<PokedexContext>(options =>
    options.UseSqlite("Data Source=pokedex.db"));

// CORS pour Angular
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAngular",
        policy => policy.WithOrigins("http://localhost:4200")
                       .AllowAnyMethod()
                       .AllowAnyHeader());
});

var app = builder.Build();

// Middleware
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAngular");
app.UseAuthorization();
app.MapControllers();

// Créer la base de données au démarrage
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<PokedexContext>();
    context.Database.EnsureCreated();
}

app.Run();
```

### Étape 5 : Créer le contrôleur CRUD (8 min)
Créer `Controllers/PokemonsController.cs` :
```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PokedexApi.Data;
using PokedexApi.Models;

namespace PokedexApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PokemonsController : ControllerBase
    {
        private readonly PokedexContext _context;

        public PokemonsController(PokedexContext context)
        {
            _context = context;
        }

        // GET: api/Pokemons
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Pokemon>>> GetPokemons()
        {
            return await _context.Pokemons.ToListAsync();
        }

        // GET: api/Pokemons/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Pokemon>> GetPokemon(int id)
        {
            var pokemon = await _context.Pokemons.FindAsync(id);

            if (pokemon == null)
                return NotFound();

            return pokemon;
        }

        // POST: api/Pokemons
        [HttpPost]
        public async Task<ActionResult<Pokemon>> PostPokemon(Pokemon pokemon)
        {
            _context.Pokemons.Add(pokemon);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetPokemon), new { id = pokemon.Id }, pokemon);
        }

        // PUT: api/Pokemons/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutPokemon(int id, Pokemon pokemon)
        {
            if (id != pokemon.Id)
                return BadRequest();

            _context.Entry(pokemon).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!PokemonExists(id))
                    return NotFound();
                throw;
            }

            return NoContent();
        }

        // DELETE: api/Pokemons/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePokemon(int id)
        {
            var pokemon = await _context.Pokemons.FindAsync(id);
            if (pokemon == null)
                return NotFound();

            _context.Pokemons.Remove(pokemon);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool PokemonExists(int id)
        {
            return _context.Pokemons.Any(e => e.Id == id);
        }
    }
}
```

### Étape 6 : Lancer le backend (2 min)
```bash
# Compiler et lancer (en mode Watch - rechargement auto)
dotnet watch run

# OU simplement compiler puis exécuter
dotnet build    # Compilation (équivalent: mvn compile)
dotnet run      # Exécution (équivalent: mvn exec:java)
```

**📝 Comprendre les modes de compilation :**

```bash
# Mode Debug (par défaut) - avec symboles de debug
dotnet run
# Équivalent Java : mvn exec:java

# Mode Release - optimisé pour production
dotnet run -c Release
# Équivalent Java : mvn exec:java -Pproduction

# Build sans exécuter
dotnet build
# Crée les DLL dans : bin/Debug/net8.0/

# Nettoyer les fichiers compilés
dotnet clean
# Équivalent Java : mvn clean
```

**🔍 Observer les résultats :**
- L'API démarre sur un port (ex: `http://localhost:5000`)
- Une base de données `pokedex.db` est créée automatiquement
- Swagger est disponible sur `/swagger`

**Ouvrir Swagger :** `http://localhost:5000/swagger` (ou le port affiché dans le terminal)

**Variables d'environnement utiles :**
```bash
# Changer le port (si conflit)
export ASPNETCORE_URLS="http://localhost:5001"
dotnet run

# Mode de développement
export ASPNETCORE_ENVIRONMENT=Development
```

**✅ Checkpoint** : Tester les endpoints dans Swagger
1. GET `/api/Pokemons` - Doit retourner les 3 Pokémons initiaux
2. Essayer POST pour créer un nouveau Pokémon

---

## 🎨 Phase 3 : Frontend Angular (25 min)

### Étape 1 : Créer le projet Angular (3 min)
```bash
cd ../../frontend
ng new pokedex-front --routing --style=css
cd pokedex-front
```

### Étape 2 : Créer le modèle et service (5 min)
```bash
ng generate interface models/pokemon
ng generate service services/pokemon
```

Modifier `src/app/models/pokemon.ts` :
```typescript
export interface Pokemon {
  id: number;
  name: string;
  type: string;
  level: number;
  imageUrl?: string;
}
```

Modifier `src/app/services/pokemon.service.ts` :
```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Pokemon } from '../models/pokemon';

@Injectable({
  providedIn: 'root'
})
export class PokemonService {
  private apiUrl = 'http://localhost:5000/api/Pokemons';

  constructor(private http: HttpClient) { }

  getAll(): Observable<Pokemon[]> {
    return this.http.get<Pokemon[]>(this.apiUrl);
  }

  getById(id: number): Observable<Pokemon> {
    return this.http.get<Pokemon>(`${this.apiUrl}/${id}`);
  }

  create(pokemon: Pokemon): Observable<Pokemon> {
    return this.http.post<Pokemon>(this.apiUrl, pokemon);
  }

  update(id: number, pokemon: Pokemon): Observable<any> {
    return this.http.put(`${this.apiUrl}/${id}`, pokemon);
  }

  delete(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`);
  }
}
```

### Étape 3 : Configurer HttpClient (2 min)
Modifier `src/app/app.config.ts` :
```typescript
import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient()
  ]
};
```

### Étape 4 : Créer le composant liste (10 min)
```bash
ng generate component components/pokemon-list
```

Modifier `src/app/components/pokemon-list/pokemon-list.component.ts` :
```typescript
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Pokemon } from '../../models/pokemon';
import { PokemonService } from '../../services/pokemon.service';

@Component({
  selector: 'app-pokemon-list',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './pokemon-list.component.html',
  styleUrls: ['./pokemon-list.component.css']
})
export class PokemonListComponent implements OnInit {
  pokemons: Pokemon[] = [];
  newPokemon: Pokemon = { id: 0, name: '', type: '', level: 1 };
  editingPokemon: Pokemon | null = null;

  constructor(private pokemonService: PokemonService) {}

  ngOnInit(): void {
    this.loadPokemons();
  }

  loadPokemons(): void {
    this.pokemonService.getAll().subscribe(data => {
      this.pokemons = data;
    });
  }

  addPokemon(): void {
    this.pokemonService.create(this.newPokemon).subscribe(() => {
      this.loadPokemons();
      this.newPokemon = { id: 0, name: '', type: '', level: 1 };
    });
  }

  editPokemon(pokemon: Pokemon): void {
    this.editingPokemon = { ...pokemon };
  }

  updatePokemon(): void {
    if (this.editingPokemon) {
      this.pokemonService.update(this.editingPokemon.id, this.editingPokemon)
        .subscribe(() => {
          this.loadPokemons();
          this.editingPokemon = null;
        });
    }
  }

  deletePokemon(id: number): void {
    if (confirm('Supprimer ce Pokémon ?')) {
      this.pokemonService.delete(id).subscribe(() => {
        this.loadPokemons();
      });
    }
  }

  cancelEdit(): void {
    this.editingPokemon = null;
  }
}
```

Modifier `src/app/components/pokemon-list/pokemon-list.component.html` :
```html
<div class="container">
  <h1>🎮 Mon Pokédex</h1>

  <!-- Formulaire d'ajout -->
  <div class="add-form">
    <h2>Ajouter un Pokémon</h2>
    <input [(ngModel)]="newPokemon.name" placeholder="Nom" />
    <input [(ngModel)]="newPokemon.type" placeholder="Type" />
    <input [(ngModel)]="newPokemon.level" type="number" placeholder="Niveau" />
    <button (click)="addPokemon()">Ajouter</button>
  </div>

  <!-- Liste des Pokémons -->
  <div class="pokemon-grid">
    <div *ngFor="let pokemon of pokemons" class="pokemon-card">
      <div *ngIf="editingPokemon?.id !== pokemon.id">
        <h3>{{ pokemon.name }}</h3>
        <p>Type: {{ pokemon.type }}</p>
        <p>Niveau: {{ pokemon.level }}</p>
        <button (click)="editPokemon(pokemon)">Modifier</button>
        <button (click)="deletePokemon(pokemon.id)" class="delete">Supprimer</button>
      </div>

      <div *ngIf="editingPokemon?.id === pokemon.id" class="edit-form">
        <input [(ngModel)]="editingPokemon.name" />
        <input [(ngModel)]="editingPokemon.type" />
        <input [(ngModel)]="editingPokemon.level" type="number" />
        <button (click)="updatePokemon()">Sauvegarder</button>
        <button (click)="cancelEdit()">Annuler</button>
      </div>
    </div>
  </div>
</div>
```

Modifier `src/app/components/pokemon-list/pokemon-list.component.css` :
```css
.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

h1 {
  text-align: center;
  color: #ff0000;
}

.add-form {
  background: #f0f0f0;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 30px;
}

.add-form input {
  margin: 5px;
  padding: 8px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.pokemon-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
}

.pokemon-card {
  border: 2px solid #ffcb05;
  border-radius: 8px;
  padding: 15px;
  background: white;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

button {
  margin: 5px;
  padding: 8px 15px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  background: #3b4cca;
  color: white;
}

button.delete {
  background: #ff0000;
}

button:hover {
  opacity: 0.8;
}
```

### Étape 5 : Configurer le routage (2 min)
Modifier `src/app/app.component.ts` :
```typescript
import { Component } from '@angular/core';
import { PokemonListComponent } from './components/pokemon-list/pokemon-list.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [PokemonListComponent],
  template: '<app-pokemon-list></app-pokemon-list>',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'pokedex-front';
}
```

### Étape 6 : Lancer le frontend (1 min)
```bash
# Lancer en mode développement (rechargement automatique)
ng serve

# OU spécifier le port
ng serve --port 4200

# Mode production (build optimisé)
ng build --configuration production
# Fichiers générés dans : dist/pokedex-front/
```

**📝 Commandes Angular essentielles :**

```bash
# Compilation sans serveur
ng build
# Équivalent .NET : dotnet build

# Tests unitaires
ng test
# Équivalent .NET : dotnet test

# Analyse de code
ng lint

# Créer un nouveau composant/service
ng generate component mon-composant
ng generate service mon-service
# Raccourcis : ng g c / ng g s
```

**Ouvrir l'application :** `http://localhost:4200`

**✅ Checkpoint final** : Tester le CRUD complet
1. Créer un nouveau Pokémon via le formulaire
2. Voir la mise à jour dans la liste
3. Modifier un Pokémon existant
4. Supprimer un Pokémon
5. Vérifier dans Swagger que les données sont bien en base

---

## 🎉 Phase 4 : Tests et démo (5 min)

### Tests à effectuer :
1. ✅ Créer un nouveau Pokémon
2. ✅ Voir la liste des Pokémons
3. ✅ Modifier un Pokémon existant
4. ✅ Supprimer un Pokémon
5. ✅ Vérifier dans Swagger que les données sont bien en base

### Points clés appris :
- Architecture full stack moderne
- API REST avec .NET et Entity Framework
- Frontend réactif avec Angular
- Communication HTTP entre front et back
- CRUD complet avec base de données

---

## 🚨 Troubleshooting rapide

**Erreur CORS** : Vérifier que le backend autorise `http://localhost:4200`

**Port occupé** : Modifier dans `Properties/launchSettings.json` (backend) ou `angular.json` (frontend)

**Base de données** : Supprimer `pokedex.db` et relancer le backend pour recréer

**HttpClient non trouvé** : Vérifier l'import dans `app.config.ts`

**Erreur de compilation .NET** :
```bash
# Nettoyer et recompiler
dotnet clean
dotnet restore
dotnet build
```

**Problème de version .NET** :
```bash
# Vérifier la version du SDK
dotnet --list-sdks

# Créer un global.json si nécessaire
dotnet new globaljson --sdk-version 8.0.100
```

**Problème NuGet** :
```bash
# Nettoyer le cache NuGet (comme mvn clean install -U)
dotnet nuget locals all --clear

# Restaurer avec verbose pour voir les erreurs
dotnet restore -v detailed
```

---

## 📊 Récapitulatif des commandes par technologie

### .NET Backend
| Commande | Description | Équivalent Java |
|----------|-------------|-----------------|
| `dotnet new webapi` | Créer un projet | `mvn archetype:generate` |
| `dotnet add package X` | Ajouter une dépendance | Modifier `pom.xml` |
| `dotnet restore` | Télécharger les dépendances | `mvn dependency:resolve` |
| `dotnet build` | Compiler | `mvn compile` |
| `dotnet run` | Compiler + Exécuter | `mvn exec:java` |
| `dotnet watch run` | Auto-reload | `mvn spring-boot:run` |
| `dotnet test` | Tests unitaires | `mvn test` |
| `dotnet publish` | Package production | `mvn package` |
| `dotnet clean` | Nettoyer | `mvn clean` |

### Angular Frontend
| Commande | Description |
|----------|-------------|
| `ng new` | Créer un projet |
| `ng serve` | Lancer en dev |
| `ng build` | Compiler |
| `ng test` | Tests unitaires |
| `ng generate` (ou `ng g`) | Générer composants/services |

---

## 🎓 Concepts clés à retenir

### Architecture 3-tiers
```
┌─────────────┐      HTTP/REST      ┌─────────────┐      Entity      ┌──────────┐
│   Angular   │ ←─────────────────→ │  .NET API   │ ←──Framework───→ │  SQLite  │
│  (Frontend) │      JSON           │  (Backend)  │      (ORM)       │   (BDD)  │
└─────────────┘                     └─────────────┘                  └──────────┘
```

### Comparaison .NET vs Java

| Aspect | .NET | Java |
|--------|------|------|
| **Langage** | C# | Java |
| **Runtime** | CLR | JVM |
| **ORM** | Entity Framework | Hibernate/JPA |
| **Web Framework** | ASP.NET Core | Spring Boot |
| **Injection Dépendances** | Built-in | Spring/CDI |
| **Gestionnaire paquets** | NuGet | Maven/Gradle |
| **Fichier config** | `.csproj` | `pom.xml` |
| **Annotations** | Attributes `[HttpGet]` | Annotations `@GetMapping` |

### Entity Framework = Hibernate
```csharp
// .NET - Entity Framework
public class Pokemon { 
    public int Id { get; set; }  // Propriété auto
}
```

```java
// Java - JPA/Hibernate
@Entity
public class Pokemon {
    @Id
    @GeneratedValue
    private int id;
    
    public int getId() { return id; }  // Getters/Setters
}
```

---

## 📚 Pour aller plus loin
- Ajouter une recherche par nom/type
- Implémenter la pagination
- Ajouter des images de Pokémons
- Utiliser une vraie API Pokémon externe
- Déployer l'application

**Bravo ! Vous avez créé votre première application full stack ! 🎊**

---

## 🐋 Bonus 1 : Déploiement avec Docker (15 min)

### Pourquoi Docker ?
Docker permet d'empaqueter l'application avec toutes ses dépendances, garantissant qu'elle fonctionne identiquement partout (comme un JAR exécutable avec le JRE inclus).

### Structure des fichiers Docker
```
pokedex-app/
├── backend/
│   ├── PokedexApi/
│   └── Dockerfile.backend
├── frontend/
│   ├── pokedex-front/
│   └── Dockerfile.frontend
├── docker-compose.yml
└── .dockerignore
```

### 1. Dockerfile pour le Backend .NET

Créer `backend/Dockerfile.backend` :
```dockerfile
# Étape 1 : Build (comme mvn package)
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copier le .csproj et restaurer les dépendances (cache Docker)
COPY PokedexApi/*.csproj ./PokedexApi/
RUN dotnet restore "PokedexApi/PokedexApi.csproj"

# Copier tout le code source
COPY PokedexApi/ ./PokedexApi/
WORKDIR /src/PokedexApi

# Compiler en mode Release
RUN dotnet build "PokedexApi.csproj" -c Release -o /app/build

# Publier l'application (créer les binaires optimisés)
FROM build AS publish
RUN dotnet publish "PokedexApi.csproj" -c Release -o /app/publish

# Étape 2 : Runtime (image légère, seulement le runtime)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Copier les fichiers publiés depuis l'étape précédente
COPY --from=publish /app/publish .

# Exposer le port
EXPOSE 5000

# Variables d'environnement
ENV ASPNETCORE_URLS=http://+:5000
ENV ASPNETCORE_ENVIRONMENT=Production

# Point d'entrée
ENTRYPOINT ["dotnet", "PokedexApi.dll"]
```

**📝 Explication du Dockerfile multi-stage :**
- **Stage 1 (build)** : Image avec SDK complet (600 MB) pour compiler
- **Stage 2 (publish)** : Création du package de production
- **Stage 3 (final)** : Image légère avec seulement le runtime (200 MB)
- Résultat : Image finale optimisée, comme un JAR avec JRE minimal

### 2. Dockerfile pour le Frontend Angular

Créer `frontend/Dockerfile.frontend` :
```dockerfile
# Étape 1 : Build de l'application Angular
FROM node:18-alpine AS build
WORKDIR /app

# Copier package.json et installer les dépendances (cache Docker)
COPY pokedex-front/package*.json ./
RUN npm ci

# Copier le code source et compiler
COPY pokedex-front/ ./
RUN npm run build -- --configuration production

# Étape 2 : Serveur Nginx pour héberger les fichiers statiques
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Supprimer les fichiers par défaut
RUN rm -rf ./*

# Copier les fichiers compilés depuis l'étape build
COPY --from=build /app/dist/pokedex-front/browser ./

# Configuration Nginx pour Angular (gestion du routing)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exposer le port
EXPOSE 80

# Démarrer Nginx
CMD ["nginx", "-g", "daemon off;"]
```

### 3. Configuration Nginx pour Angular

Créer `frontend/nginx.conf` :
```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Gestion du routing Angular (toutes les routes vers index.html)
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Configuration CORS si nécessaire
    location /api {
        proxy_pass http://backend:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Cache des fichiers statiques
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### 4. Docker Compose (orchestration)

Créer `docker-compose.yml` à la racine :
```yaml
version: '3.8'

services:
  # Backend .NET API
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.backend
    container_name: pokedex-api
    ports:
      - "5000:5000"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ASPNETCORE_URLS=http://+:5000
    volumes:
      # Persister la base de données SQLite
      - ./data:/app/data
    networks:
      - pokedex-network
    restart: unless-stopped

  # Frontend Angular
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.frontend
    container_name: pokedex-front
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - pokedex-network
    restart: unless-stopped

networks:
  pokedex-network:
    driver: bridge

volumes:
  pokedex-data:
```

### 5. Fichier .dockerignore

Créer `.dockerignore` dans backend/ et frontend/ :
```
# Backend .dockerignore
bin/
obj/
*.db
*.db-shm
*.db-wal

# Frontend .dockerignore
node_modules/
dist/
.angular/
*.log
```

### 6. Commandes Docker

```bash
# Construire les images (comme mvn package)
docker-compose build

# Démarrer les conteneurs
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Arrêter les conteneurs
docker-compose down

# Reconstruire et redémarrer
docker-compose up -d --build

# Exécuter des commandes dans un conteneur
docker-compose exec backend dotnet --version
docker-compose exec backend bash

# Voir les conteneurs actifs
docker ps

# Supprimer tout (conteneurs, volumes, images)
docker-compose down -v --rmi all
```

**🔍 Vérifier le déploiement :**
- Frontend : `http://localhost`
- Backend API : `http://localhost:5000/swagger`

### 7. Modifier Program.cs pour utiliser un volume

Modifier `backend/PokedexApi/Program.cs` pour sauvegarder la base dans `/app/data` :
```csharp
// Changer la connexion SQLite pour utiliser un volume
builder.Services.AddDbContext<PokedexContext>(options =>
    options.UseSqlite("Data Source=/app/data/pokedex.db"));
```

### 8. Variables d'environnement avec .env

Créer `.env` à la racine (ne pas commiter avec git) :
```env
ASPNETCORE_ENVIRONMENT=Production
DATABASE_PATH=/app/data/pokedex.db
API_URL=http://backend:5000
```

Utiliser dans `docker-compose.yml` :
```yaml
services:
  backend:
    env_file:
      - .env
```

---

## 🐛 Bonus 2 : Debugging dans VS Code (10 min)

### Configuration du Debugger .NET

Créer `.vscode/launch.json` à la racine du projet :
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": ".NET Core Launch (Backend)",
      "type": "coreclr",
      "request": "launch",
      "preLaunchTask": "build-backend",
      "program": "${workspaceFolder}/backend/PokedexApi/bin/Debug/net8.0/PokedexApi.dll",
      "args": [],
      "cwd": "${workspaceFolder}/backend/PokedexApi",
      "stopAtEntry": false,
      "serverReadyAction": {
        "action": "openExternally",
        "pattern": "\\bNow listening on:\\s+(https?://\\S+)",
        "uriFormat": "%s/swagger"
      },
      "env": {
        "ASPNETCORE_ENVIRONMENT": "Development",
        "ASPNETCORE_URLS": "http://localhost:5000"
      },
      "sourceFileMap": {
        "/Views": "${workspaceFolder}/Views"
      }
    },
    {
      "name": ".NET Core Attach",
      "type": "coreclr",
      "request": "attach",
      "processId": "${command:pickProcess}"
    },
    {
      "name": "Angular (Chrome)",
      "type": "chrome",
      "request": "launch",
      "preLaunchTask": "start-frontend",
      "url": "http://localhost:4200",
      "webRoot": "${workspaceFolder}/frontend/pokedex-front",
      "sourceMaps": true,
      "sourceMapPathOverrides": {
        "webpack:/*": "${webRoot}/*",
        "/./*": "${webRoot}/*",
        "/src/*": "${webRoot}/*",
        "/*": "*",
        "/./~/*": "${webRoot}/node_modules/*"
      }
    },
    {
      "name": "Full Stack (Backend + Frontend)",
      "type": "node",
      "request": "launch",
      "name": "Launch Full Stack",
      "compounds": [
        ".NET Core Launch (Backend)",
        "Angular (Chrome)"
      ]
    }
  ],
  "compounds": [
    {
      "name": "Full Stack Debug",
      "configurations": [
        ".NET Core Launch (Backend)",
        "Angular (Chrome)"
      ],
      "stopAll": true
    }
  ]
}
```

### Configuration des tâches

Créer `.vscode/tasks.json` :
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "build-backend",
      "command": "dotnet",
      "type": "process",
      "args": [
        "build",
        "${workspaceFolder}/backend/PokedexApi/PokedexApi.csproj",
        "/property:GenerateFullPaths=true",
        "/consoleloggerparameters:NoSummary"
      ],
      "problemMatcher": "$msCompile",
      "group": {
        "kind": "build",
        "isDefault": true
      }
    },
    {
      "label": "publish-backend",
      "command": "dotnet",
      "type": "process",
      "args": [
        "publish",
        "${workspaceFolder}/backend/PokedexApi/PokedexApi.csproj",
        "/property:GenerateFullPaths=true",
        "/consoleloggerparameters:NoSummary"
      ],
      "problemMatcher": "$msCompile"
    },
    {
      "label": "watch-backend",
      "command": "dotnet",
      "type": "process",
      "args": [
        "watch",
        "run",
        "--project",
        "${workspaceFolder}/backend/PokedexApi/PokedexApi.csproj"
      ],
      "problemMatcher": "$msCompile"
    },
    {
      "label": "start-frontend",
      "type": "shell",
      "command": "npm",
      "args": ["start"],
      "options": {
        "cwd": "${workspaceFolder}/frontend/pokedex-front"
      },
      "isBackground": true,
      "problemMatcher": {
        "owner": "typescript",
        "pattern": "$tsc",
        "background": {
          "activeOnStart": true,
          "beginsPattern": "Compiling",
          "endsPattern": "Compiled successfully"
        }
      }
    },
    {
      "label": "build-frontend",
      "type": "shell",
      "command": "npm",
      "args": ["run", "build"],
      "options": {
        "cwd": "${workspaceFolder}/frontend/pokedex-front"
      },
      "problemMatcher": []
    }
  ]
}
```

### Utilisation du Debugger

**1. Debugger le Backend :**
- Placer un breakpoint dans `PokemonsController.cs` (clic sur la marge gauche)
- Appuyer sur `F5` ou sélectionner ".NET Core Launch (Backend)"
- Faire une requête depuis le frontend ou Swagger
- Le code s'arrêtera au breakpoint

**2. Debugger le Frontend :**
- Placer un breakpoint dans `pokemon-list.component.ts`
- Sélectionner "Angular (Chrome)" dans le menu debug
- Interagir avec l'interface
- Le code s'arrêtera au breakpoint dans VS Code

**3. Debugger Full Stack :**
- Sélectionner "Full Stack Debug"
- Lance backend + frontend simultanément
- Permet de debugger les deux en même temps

**🔍 Commandes utiles pendant le debug :**
- `F5` : Continue
- `F10` : Step Over (ligne suivante)
- `F11` : Step Into (entrer dans une fonction)
- `Shift+F11` : Step Out (sortir de la fonction)
- `Ctrl+Shift+F5` : Restart
- `Shift+F5` : Stop

### Configuration VS Code recommandée

Créer `.vscode/settings.json` :
```json
{
  "dotnet.defaultSolution": "backend/PokedexApi/PokedexApi.csproj",
  "omnisharp.enableRoslynAnalyzers": true,
  "omnisharp.enableEditorConfigSupport": true,
  "omnisharp.enableImportCompletion": true,
  "[csharp]": {
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": true
    }
  },
  "[typescript]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "files.exclude": {
    "**/bin": true,
    "**/obj": true,
    "**/.angular": true,
    "**/node_modules": true
  }
}
```

### Extensions VS Code recommandées

Créer `.vscode/extensions.json` :
```json
{
  "recommendations": [
    "ms-dotnettools.csharp",
    "ms-dotnettools.csdevkit",
    "angular.ng-template",
    "esbenp.prettier-vscode",
    "ms-azuretools.vscode-docker",
    "formulahendry.dotnet-test-explorer",
    "jchannon.csharpextensions",
    "kreativ-software.csharpextensions"
  ]
}
```

---

## 🎯 Récapitulatif Complet

### Structure finale du projet
```
pokedex-app/
├── .gitpod.yml                    # Configuration GitPod
├── .vscode/
│   ├── launch.json                # Configuration debug
│   ├── tasks.json                 # Tâches automatisées
│   ├── settings.json              # Paramètres VS Code
│   └── extensions.json            # Extensions recommandées
├── backend/
│   ├── Dockerfile.backend         # Image Docker backend
│   ├── .dockerignore
│   └── PokedexApi/
│       ├── PokedexApi.csproj      # Configuration du projet
│       ├── Program.cs             # Point d'entrée
│       ├── Controllers/
│       ├── Models/
│       ├── Data/
│       └── bin/                   # Fichiers compilés
├── frontend/
│   ├── Dockerfile.frontend        # Image Docker frontend
│   ├── nginx.conf                 # Configuration Nginx
│   ├── .dockerignore
│   └── pokedex-front/
│       ├── package.json
│       ├── angular.json
│       └── src/
├── docker-compose.yml             # Orchestration Docker
├── .env                           # Variables d'environnement
└── data/                          # Volume pour SQLite
```

**Bravo ! Vous maîtrisez maintenant le développement full stack avec .NET ! 🎊**
