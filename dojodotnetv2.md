# 🎯 Dojo Pokédex Full Stack (1 heure)

## 📋 Objectif
Créer une application CRUD complète pour gérer un Pokédex avec :
- Backend : Web API .NET avec Swagger + SQLite
- Frontend : Angular
- Environnement : Code-Server sur Debian 12

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

#### 📥 Installation pas à pas

```bash
# 1. Se placer dans le dossier utilisateur
cd /home/coder

# 2. Télécharger le SDK .NET 8.0 portable pour Linux x64 (environ 280 MB)
wget -q https://download.visualstudio.microsoft.com/download/pr/8f6c0ce2-cbbd-4c26-b6fe-2e8c02cfb9d4/6e9d5e0b0a6e2f4e5c3c6b0c4f3e6a8b/dotnet-sdk-8.0.403-linux-x64.tar.gz

# 3. Créer le dossier d'installation
mkdir -p /home/coder/.dotnet

# 4. Extraire l'archive
tar -xzf dotnet-sdk-8.0.403-linux-x64.tar.gz -C /home/coder/.dotnet

# 5. Nettoyer
rm dotnet-sdk-8.0.403-linux-x64.tar.gz

# 6. Configurer les variables d'environnement temporairement
export DOTNET_ROOT=/home/coder/.dotnet
export PATH=$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# 7. Persister dans .zshrc_custom (Code-Server utilise Zsh)
cat >> ~/.zshrc_custom << 'EOF'
# ============= .NET Configuration =============
export DOTNET_ROOT=/home/coder/.dotnet
export PATH=$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH
export DOTNET_CLI_TELEMETRY_OPTOUT=1
# ============================================
EOF

# 8. S'assurer que .zshrc charge le fichier custom
echo 'source ~/.zshrc_custom' >> ~/.zshrc

# 9. Recharger la configuration
source ~/.zshrc_custom

# 10. Vérifier l'installation
dotnet --version  # Devrait afficher 8.0.403
```

**📝 Ce que contient l'archive :**
- `sdk/8.0.403/` : Compilateur et outils (comme javac)
- `shared/` : Runtime .NET partagé (comme le JRE)
- `packs/` : Paquets de runtime supplémentaires
- `dotnet` : Exécutable principal

> **ℹ️ Info :** Code-Server utilise Zsh par défaut. Pour éviter de perdre votre configuration personnalisée lors des mises à jour, utilisez `.zshrc_custom` au lieu de `.zshrc`.

### Qu'est-ce que NuGet ?

**NuGet** est le gestionnaire de paquets de .NET, équivalent à **Maven Central** ou **npm** :

| NuGet (.NET) | Maven (Java) | npm (JavaScript) |
|--------------|--------------|------------------|
| `dotnet add package` | `mvn dependency:add` | `npm install` |
| `nuget.org` | `mvnrepository.com` | `npmjs.com` |
| `.csproj` | `pom.xml` | `package.json` |
| Packages dans `~/.nuget/packages` | `~/.m2/repository` | `node_modules` |

#### Commandes NuGet essentielles
```bash
# Ajouter un package
dotnet add package Newtonsoft.Json --version 13.0.1

# Restaurer les packages
dotnet restore

# Lister les packages installés
dotnet list package

# Lister les packages obsolètes
dotnet list package --outdated
```

### Commandes .NET essentielles

| Tâche | .NET | Java (Maven) | Explication |
|-------|------|--------------|-------------|
| **Compiler** | `dotnet build` | `mvn compile` | Compile le code source |
| **Compiler (Release)** | `dotnet build -c Release` | `mvn compile -Pproduction` | Mode optimisé |
| **Exécuter** | `dotnet run` | `mvn exec:java` | Compile et exécute |
| **Tester** | `dotnet test` | `mvn test` | Lance les tests unitaires |
| **Publier** | `dotnet publish` | `mvn package` | Crée un package déployable |
| **Nettoyer** | `dotnet clean` | `mvn clean` | Supprime les fichiers compilés |
| **Restaurer deps** | `dotnet restore` | `mvn dependency:resolve` | Télécharge les dépendances |
| **Auto-reload** | `dotnet watch run` | `mvn spring-boot:run` | Redémarre à chaque modification |

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
└── obj/                      ← Fichiers intermédiaires
```

---

## 🚀 Phase 1 : Configuration initiale (5 min)

### Installation rapide pour le dojo (copy-paste)

```bash
# Installation complète en une seule commande
cd /home/coder && \
wget -q https://download.visualstudio.microsoft.com/download/pr/8f6c0ce2-cbbd-4c26-b6fe-2e8c02cfb9d4/6e9d5e0b0a6e2f4e5c3c6b0c4f3e6a8b/dotnet-sdk-8.0.403-linux-x64.tar.gz && \
mkdir -p /home/coder/.dotnet && \
tar -xzf dotnet-sdk-8.0.403-linux-x64.tar.gz -C /home/coder/.dotnet && \
rm dotnet-sdk-8.0.403-linux-x64.tar.gz && \
cat >> ~/.zshrc_custom << 'EOF'
export DOTNET_ROOT=/home/coder/.dotnet
export PATH=$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH
export DOTNET_CLI_TELEMETRY_OPTOUT=1
EOF
echo 'source ~/.zshrc_custom' >> ~/.zshrc && \
source ~/.zshrc_custom && \
dotnet --version
```

### Vérifier les prérequis

```bash
# Vérifier .NET
dotnet --version  # Doit afficher 8.0.403

# Vérifier Node.js (Code-Server le fournit)
node --version    # v18+
npm --version
```

### Créer la structure du projet

```bash
# En Zsh, les accolades doivent être échappées ou désactivées
# Option 1 : Utiliser noglob (recommandé pour Zsh)
noglob mkdir -p pokedex-app/{backend,frontend}

# Option 2 : Échapper les accolades
mkdir -p pokedex-app/\{backend,frontend\}

# Option 3 : Créer les dossiers séparément (plus simple)
mkdir -p pokedex-app/backend pokedex-app/frontend

# Se placer dans le dossier
cd pokedex-app
```

**📝 Pourquoi ce problème en Zsh ?**
- En **Bash** : `{a,b}` est une expansion de brace (crée `a` et `b`)
- En **Zsh** : Les accolades sont réservées pour les patterns globaux
- Solution : Utiliser `noglob` pour désactiver temporairement le glob, ou créer les dossiers séparément

---

## 🔧 Phase 2 : Backend .NET (25 min)

### Étape 1 : Créer le projet API (3 min)
```bash
cd backend

# Créer un nouveau projet Web API
dotnet new webapi -n PokedexApi
cd PokedexApi

# Ajouter les packages NuGet nécessaires
dotnet add package Microsoft.EntityFrameworkCore.Sqlite
dotnet add package Microsoft.EntityFrameworkCore.Design

# Restaurer les packages
dotnet restore
```

**📝 Explication :**
- `dotnet new webapi` : Crée un projet Web API (templates: `console`, `webapi`, `mvc`)
- `Microsoft.EntityFrameworkCore.Sqlite` : ORM + driver SQLite (comme Hibernate + JDBC)
- `Microsoft.EntityFrameworkCore.Design` : Outils de migration

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
# Compiler et lancer en mode Watch (rechargement auto)
dotnet watch run

# OU simplement
dotnet build    # Compilation
dotnet run      # Exécution
```

**🔍 Observer les résultats :**
- L'API démarre sur `http://localhost:5000`
- Une base de données `pokedex.db` est créée automatiquement
- Swagger est disponible sur `/swagger`

**Variables d'environnement utiles :**
```bash
# Changer le port (si conflit)
export ASPNETCORE_URLS="http://localhost:5001"
dotnet run
```

**✅ Checkpoint** : Ouvrir Swagger (`http://localhost:5000/swagger`) et tester :
1. GET `/api/Pokemons` - Doit retourner les 3 Pokémons initiaux
2. POST pour créer un nouveau Pokémon

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
# Lancer en mode développement
ng serve

# Ou sur un port spécifique
ng serve --port 4200
```

**✅ Checkpoint final** : Ouvrir `http://localhost:4200` et tester :
1. Créer un nouveau Pokémon
2. Modifier un Pokémon
3. Supprimer un Pokémon
4. Vérifier dans Swagger que les données sont bien en base

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

**Erreur CORS** : Vérifier que le backend autorise `http://localhost:4200` dans `Program.cs`

**Port occupé** : 
```bash
# Backend
export ASPNETCORE_URLS="http://localhost:5001"
dotnet run

# Frontend
ng serve --port 4201
```

**Base de données** : Supprimer `pokedex.db` et relancer le backend

**HttpClient non trouvé** : Vérifier `provideHttpClient()` dans `app.config.ts`

**Erreur de compilation .NET** :
```bash
dotnet clean
dotnet restore
dotnet build
```

**Problème NuGet** :
```bash
# Nettoyer le cache
dotnet nuget locals all --clear
dotnet restore -v detailed
```

---

## 🐋 Bonus 1 : Déploiement avec Docker (15 min)

### Dockerfile Backend

Créer `backend/Dockerfile` :
```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY PokedexApi/*.csproj ./PokedexApi/
RUN dotnet restore "PokedexApi/PokedexApi.csproj"

COPY PokedexApi/ ./PokedexApi/
WORKDIR /src/PokedexApi
RUN dotnet build "PokedexApi.csproj" -c Release -o /app/build
RUN dotnet publish "PokedexApi.csproj" -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 5000
ENV ASPNETCORE_URLS=http://+:5000
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "PokedexApi.dll"]
```

### Dockerfile Frontend

Créer `frontend/Dockerfile` :
```dockerfile
# Build stage
FROM node:18-alpine AS build
WORKDIR /app

COPY pokedex-front/package*.json ./
RUN npm ci

COPY pokedex-front/ ./
RUN npm run build -- --configuration production

# Runtime stage with Nginx
FROM nginx:alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=build /app/dist/pokedex-front/browser ./
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Configuration Nginx

Créer `frontend/nginx.conf` :
```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://backend:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### Docker Compose

Créer `docker-compose.yml` :
```yaml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: pokedex-api
    ports:
      - "5000:5000"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ASPNETCORE_URLS=http://+:5000
    volumes:
      - ./data:/app/data
    networks:
      - pokedex-network
    restart: unless-stopped

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
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
```

### Commandes Docker

```bash
# Construire et démarrer
docker-compose up -d --build

# Voir les logs
docker-compose logs -f

# Arrêter
docker-compose down

# Nettoyer tout
docker-compose down -v --rmi all
```

---

## 🐛 Bonus 2 : Debugging dans VS Code (
