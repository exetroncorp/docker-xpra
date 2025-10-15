# Pokedex App Recreation Guide

This is a dojo-style guide for recreating the Pokedex application from scratch. The project is a full-stack application with an ASP.NET Core Web API backend and an Angular frontend, featuring CRUD operations for Pokemon management.

## Prerequisites

Before starting, ensure you have the following installed:
- **.NET 8.0 SDK** (for the backend): The software development kit for building .NET applications. Includes the runtime, compilers, and tools needed to develop .NET apps.
- **Node.js 18+ and npm** (for the frontend): Node.js is a JavaScript runtime, and npm is its package manager for installing JavaScript libraries and tools.
- **A code editor** (VS Code recommended): Visual Studio Code is a free, open-source code editor with excellent support for both .NET and Angular development.

## Project Overview

The Pokedex app consists of:
- **Backend**: ASP.NET Core Web API with Entity Framework Core and SQLite
- **Frontend**: Angular 20 application with standalone components
- **Features**: List, create, update, and delete Pokemon entries

## Project Structure

```
pokedex-app/
├── backend/
│   └── PokedexApi/
│       ├── Controllers/
│       │   └── PokemonsController.cs
│       ├── Data/
│       │   └── PokedexContext.cs
│       ├── Models/
│       │   └── Pokemon.cs
│       ├── Properties/
│       │   └── launchSettings.json
│       ├── appsettings.Development.json
│       ├── appsettings.json
│       ├── PokedexApi.csproj
│       ├── PokedexApi.http
│       ├── Program.cs
│       └── pokedex.db
├── frontend/
│   └── pokedex-front/
│       ├── .angular/
│       ├── .vscode/
│       ├── public/
│       │   └── favicon.ico
│       ├── src/
│       │   ├── app/
│       │   │   ├── app.config.ts
│       │   │   ├── app.css
│       │   │   ├── app.html
│       │   │   ├── app.routes.ts
│       │   │   ├── app.ts
│       │   │   ├── components/
│       │   │   │   └── pokemon-list/
│       │   │   │       ├── pokemon-list.css
│       │   │   │       ├── pokemon-list.html
│       │   │   │       └── pokemon-list.ts
│       │   │   ├── models/
│       │   │   │   └── pokemon.ts
│       │   │   └── services/
│       │   │       └── pokemon.ts
│       │   ├── index.html
│       │   ├── main.ts
│       │   └── styles.css
│       ├── .editorconfig
│       ├── .gitignore
│       ├── angular.json
│       ├── package-lock.json
│       ├── package.json
│       ├── proxy.conf.json
│       ├── README.md
│       ├── tsconfig.app.json
│       ├── tsconfig.json
│       ├── tsconfig.spec.json
│       └── RECREATE.md
```

## Step-by-Step Recreation

### Step 1: Create the Project Structure

Create a new directory for your project and set up the basic folder structure:

```bash
mkdir pokedex-app
cd pokedex-app
mkdir backend frontend
```

### Step 2: Set Up the Backend (ASP.NET Core Web API)

Navigate to the backend directory and create a new ASP.NET Core Web API project:

```bash
cd backend
dotnet new webapi -n PokedexApi  # Creates a new ASP.NET Core Web API project template with the name PokedexApi
cd PokedexApi
```

**What happens here:**
- `dotnet new webapi` creates a new ASP.NET Core Web API project using Microsoft's project template
- The `-n PokedexApi` flag specifies the project name
- This generates a basic Web API structure with controllers, startup configuration, and necessary NuGet packages

#### Step 2.1: Update the Project File (PokedexApi.csproj)

Replace the contents of `PokedexApi.csproj` with:

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.OpenApi" Version="8.0.20" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="9.0.10">
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
      <PrivateAssets>all</PrivateAssets>
    </PackageReference>
    <PackageReference Include="Microsoft.EntityFrameworkCore.Sqlite" Version="9.0.10" />
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.6.2" />
  </ItemGroup>

</Project>
```

**What are NuGet packages?**
NuGet packages are .NET's package manager system, similar to npm for JavaScript. You can add NuGet packages in two ways:

1. **Via CLI**: `dotnet add package PackageName` (e.g., `dotnet add package Microsoft.EntityFrameworkCore.Sqlite`)
2. **Via .csproj file**: Add `<PackageReference>` elements as shown above

The packages added here are:
- **Microsoft.AspNetCore.OpenApi**: Enables OpenAPI/Swagger documentation for the API
- **Microsoft.EntityFrameworkCore.Design**: Provides design-time tools for Entity Framework Core (EF Core), the ORM
- **Microsoft.EntityFrameworkCore.Sqlite**: SQLite database provider for EF Core
- **Swashbuckle.AspNetCore**: Generates Swagger UI for testing API endpoints

**What happens when you update the .csproj file?**
The .csproj file defines the project configuration. When you add PackageReference elements, these NuGet packages will be downloaded and installed when you build the project. The `<IncludeAssets>` and `<PrivateAssets>` tags control which parts of the package are included in your project.

**Alternative: Adding packages via CLI**
Instead of manually editing the .csproj file, you could run these commands after creating the project:
```bash
dotnet add package Microsoft.EntityFrameworkCore.Sqlite
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Swashbuckle.AspNetCore
```

#### Step 2.2: Create the Pokemon Model

Create a `Models` directory and add `Pokemon.cs`:

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

#### Step 2.3: Create the Database Context

Create a `Data` directory and add `PokedexContext.cs`:

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
            // Initial data - these Pokemon will be seeded into the database on first run
            modelBuilder.Entity<Pokemon>().HasData(
                new Pokemon { Id = 1, Name = "Pikachu", Type = "Electric", Level = 25 },
                new Pokemon { Id = 2, Name = "Bulbasaur", Type = "Grass/Poison", Level = 15 },
                new Pokemon { Id = 3, Name = "Charmander", Type = "Fire", Level = 18 }
            );
        }
    }
}
```

#### Step 2.4: Create the Controller

Create a `Controllers` directory and add `PokemonsController.cs`:

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

#### Step 2.5: Update Program.cs

Replace the contents of `Program.cs` with:

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

### Step 2.6: Run the Backend (Optional - Test Before Continuing)

You can test the backend at this point before setting up the frontend:

```bash
cd pokedex-app/backend/PokedexApi
dotnet run
```

**What happens:**
- The API starts on `http://localhost:5055`
- Visit `http://localhost:5055/swagger` to see the API documentation
- You can test the endpoints directly in Swagger UI
- **Database seeding**: The SQLite database `pokedex.db` is created automatically with the 3 initial Pokemon (Pikachu, Bulbasaur, Charmander) that are seeded via the `HasData` method in the `PokedexContext`

Stop the server with `Ctrl+C` when done testing, then continue with the frontend setup.

### Step 3: Set Up the Frontend (Angular Application)

Navigate back to the project root and set up the Angular frontend:

```bash
cd ../frontend
npx @angular/cli@latest new pokedex-front --standalone --routing=false --style=css --skip-git  # Creates a new Angular project with standalone components, no routing, CSS styling, and skips git initialization
cd pokedex-front
```

**What happens here:**
- `npx @angular/cli@latest` runs the latest version of Angular CLI
- `new pokedex-front` creates a new Angular project named "pokedex-front"
- `--standalone` creates standalone components (Angular 14+ feature) instead of modules
- `--routing=false` disables routing since this is a simple single-page app
- `--style=css` sets CSS as the styling format
- `--skip-git` prevents automatic git repository initialization

#### Step 3.1: Update package.json

Add prettier configuration to `package.json`:

```json
{
  "name": "pokedex-front",
  "version": "0.0.0",
  "scripts": {
    "ng": "ng",
    "start": "ng serve",
    "build": "ng build",
    "watch": "ng build --watch --configuration development",
    "test": "ng test"
  },
  "prettier": {
    "printWidth": 100,
    "singleQuote": true,
    "overrides": [
      {
        "files": "*.html",
        "options": {
          "parser": "angular"
        }
      }
    ]
  },
  "private": true,
  "dependencies": {
    "@angular/common": "^20.3.0",
    "@angular/compiler": "^20.3.0",
    "@angular/core": "^20.3.0",
    "@angular/forms": "^20.3.0",
    "@angular/platform-browser": "^20.3.0",
    "@angular/router": "^20.3.0",
    "rxjs": "~7.8.0",
    "tslib": "^2.3.0",
    "zone.js": "~0.15.0"
  },
  "devDependencies": {
    "@angular/build": "^20.3.5",
    "@angular/cli": "^20.3.5",
    "@angular/compiler-cli": "^20.3.0",
    "@types/jasmine": "~5.1.0",
    "jasmine-core": "~5.9.0",
    "karma": "~6.4.0",
    "karma-chrome-launcher": "~3.2.0",
    "karma-coverage": "~2.2.0",
    "karma-jasmine": "~5.1.0",
    "karma-jasmine-html-reporter": "~2.1.0",
    "typescript": "~5.9.2"
  }
}
```

#### Step 3.2: Create the Pokemon Model

Create `src/app/models/pokemon.ts`:

```typescript
export interface Pokemon {
  id: number;
  name: string;
  type: string;
  level: number;
  imageUrl?: string;
}
```

#### Step 3.3: Create the Pokemon Service

Create `src/app/services/pokemon.ts`:

```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Pokemon } from '../models/pokemon';

@Injectable({
  providedIn: 'root'
})
export class PokemonService {
  private apiUrl = '/api/Pokemons';

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

#### Step 3.4: Create the Pokemon List Component

Generate the component:

```bash
ng generate component components/pokemon-list --standalone  # Creates a new standalone Angular component in the components directory
```

**What happens when you run `ng generate component`:**
- Angular CLI automatically creates the component files (TypeScript, HTML template, CSS, and test files)
- The `--standalone` flag creates a standalone component that doesn't need to be declared in an NgModule
- This generates: `pokemon-list.ts`, `pokemon-list.html`, `pokemon-list.css`, and `pokemon-list.spec.ts`

Update `src/app/components/pokemon-list/pokemon-list.ts`:

```typescript
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Pokemon } from '../../models/pokemon';
import { PokemonService } from '../../services/pokemon';

@Component({
  selector: 'app-pokemon-list',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './pokemon-list.html',
  styleUrls: ['./pokemon-list.css']
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

Create `src/app/components/pokemon-list/pokemon-list.html`:

```html
<div class="container">
  <h1>Pokedex</h1>

  <!-- Add Pokemon Form -->
  <div class="add-form">
    <h2>Ajouter un Pokémon</h2>
    <form (ngSubmit)="addPokemon()" #addForm="ngForm">
      <div class="form-group">
        <label for="name">Nom:</label>
        <input type="text" id="name" [(ngModel)]="newPokemon.name" name="name" required>
      </div>
      <div class="form-group">
        <label for="type">Type:</label>
        <input type="text" id="type" [(ngModel)]="newPokemon.type" name="type" required>
      </div>
      <div class="form-group">
        <label for="level">Niveau:</label>
        <input type="number" id="level" [(ngModel)]="newPokemon.level" name="level" required min="1">
      </div>
      <button type="submit" [disabled]="!addForm.form.valid">Ajouter</button>
    </form>
  </div>

  <!-- Pokemon List -->
  <div class="pokemon-list">
    <h2>Liste des Pokémon</h2>
    <div *ngFor="let pokemon of pokemons" class="pokemon-card">
      <div *ngIf="editingPokemon?.id !== pokemon.id" class="pokemon-info">
        <h3>{{ pokemon.name }}</h3>
        <p>Type: {{ pokemon.type }}</p>
        <p>Niveau: {{ pokemon.level }}</p>
        <div class="actions">
          <button (click)="editPokemon(pokemon)">Modifier</button>
          <button (click)="deletePokemon(pokemon.id)" class="delete">Supprimer</button>
        </div>
      </div>

      <!-- Edit Form -->
      <div *ngIf="editingPokemon?.id === pokemon.id" class="edit-form">
        <form (ngSubmit)="updatePokemon()" #editForm="ngForm">
          <div class="form-group">
            <label>Nom:</label>
            <input type="text" [(ngModel)]="editingPokemon.name" name="editName" required>
          </div>
          <div class="form-group">
            <label>Type:</label>
            <input type="text" [(ngModel)]="editingPokemon.type" name="editType" required>
          </div>
          <div class="form-group">
            <label>Niveau:</label>
            <input type="number" [(ngModel)]="editingPokemon.level" name="editLevel" required min="1">
          </div>
          <div class="actions">
            <button type="submit" [disabled]="!editForm.form.valid">Sauvegarder</button>
            <button type="button" (click)="cancelEdit()">Annuler</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
```

Create `src/app/components/pokemon-list/pokemon-list.css`:

```css
.container {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
  font-family: Arial, sans-serif;
}

h1 {
  text-align: center;
  color: #333;
}

.add-form, .pokemon-list {
  margin-bottom: 30px;
  padding: 20px;
  border: 1px solid #ddd;
  border-radius: 8px;
  background-color: #f9f9f9;
}

.form-group {
  margin-bottom: 15px;
}

label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
}

input {
  width: 100%;
  padding: 8px;
  border: 1px solid #ccc;
  border-radius: 4px;
  box-sizing: border-box;
}

button {
  padding: 10px 15px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

button[type="submit"] {
  background-color: #4CAF50;
  color: white;
}

button[type="submit"]:disabled {
  background-color: #cccccc;
  cursor: not-allowed;
}

button.delete {
  background-color: #f44336;
  color: white;
  margin-left: 10px;
}

.pokemon-card {
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 15px;
  background-color: white;
}

.pokemon-info h3 {
  margin-top: 0;
  color: #333;
}

.actions {
  margin-top: 10px;
}

.actions button {
  margin-right: 10px;
}

.edit-form {
  background-color: #fff3cd;
  padding: 15px;
  border-radius: 4px;
}
```

#### Step 3.5: Update the Main App Component

Update `src/app/app.ts`:

```typescript
import { Component } from '@angular/core';
import { PokemonListComponent } from './components/pokemon-list/pokemon-list';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [PokemonListComponent],
  template: '<app-pokemon-list></app-pokemon-list>',
  styleUrls: ['./app.css']
})
export class App {
  title = 'pokedex-front';
}
```

Update `src/app/app.config.ts`:

```typescript
import { ApplicationConfig, provideBrowserGlobalErrorListeners, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient()
  ]
};
```

#### Step 3.6: Set Up Proxy Configuration

Create `proxy.conf.json` in the project root:

```json
{
  "/api/": {
    "target": "http://localhost:5055",
    "secure": false,
    "changeOrigin": true,
    "logLevel": "debug"
  }
}
```

Update `angular.json` to include the proxy configuration in the serve options:

```json
"serve": {
  "builder": "@angular/build:dev-server",
  "options": {
    "host": "0.0.0.0",
    "proxyConfig": "proxy.conf.json"
  },
  ...
}
```

### Step 4: Running the Application

#### Step 4.1: Start the Backend

Navigate to the backend directory and run:

```bash
cd pokedex-app/backend/PokedexApi
dotnet run  # Builds and runs the ASP.NET Core application
```

**What happens when you run `dotnet run`:**
- Compiles the C# code into an executable
- Downloads and restores any missing NuGet packages
- Starts the web server (Kestrel) on the configured port (5055)
- **Database initialization**: Creates the SQLite database file (`pokedex.db`) and seeds it with the initial Pokemon data (Pikachu, Bulbasaur, Charmander) defined in `OnModelCreating`
- The API becomes available at `http://localhost:5055`
- Swagger UI (interactive API documentation) is available at `http://localhost:5055/swagger`

#### Step 4.2: Start the Frontend

In a new terminal, navigate to the frontend directory and run:

```bash
cd pokedex-app/frontend/pokedex-front
npm install  # Downloads and installs all dependencies listed in package.json
npm start    # Starts the Angular development server
```

**What happens when you run these commands:**
- `npm install` reads `package.json` and downloads all required Node.js packages from the npm registry
- `npm start` runs the Angular CLI development server, which:
  - Compiles TypeScript to JavaScript
  - Starts a local web server (usually on port 4200)
  - Enables hot module replacement (automatic browser refresh on code changes)
  - Applies the proxy configuration to forward API calls to the backend
- The Angular app becomes available at `http://localhost:4200`

### Step 5: Testing the Application

1. Open your browser and navigate to `http://localhost:4200`
2. You should see the Pokedex interface with 3 initial Pokemon
3. Try adding a new Pokemon using the form
4. Test editing and deleting existing Pokemon

## Key Concepts Learned

- Setting up a full-stack application with ASP.NET Core and Angular
- Using Entity Framework Core with SQLite for data persistence
- Implementing RESTful API endpoints
- Creating Angular services for API communication
- Building standalone Angular components
- Configuring CORS for cross-origin requests
- Setting up Angular proxy for development

## Troubleshooting

- If the backend doesn't start, ensure .NET 8.0 is installed and the port 5055 is available
- If the frontend doesn't connect to the backend, check that the proxy configuration is correct
- If you encounter CORS errors, verify the CORS policy in Program.cs
- Make sure both applications are running simultaneously

## Next Steps

- Add input validation and error handling
- Implement authentication and authorization
- Add image upload functionality for Pokemon
- Create additional views (Pokemon details, search, filtering)
- Add unit and integration tests
