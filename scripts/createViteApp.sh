#!/bin/bash

# Modern React + TypeScript + Tailwind + Vite Template Setup Script
# Compatible with Git Bash on Windows 11
# Usage: ./create-modern-react-app.sh [project-name]
#
# Version: 1.1.0
# Tested on:
# - Windows 11 with Git Bash
# - macOS
# - Ubuntu/Debian Linux

set -e # Exit on error

# Handle potential line ending issues on Windows
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
  export SHELLOPTS
  set -o igncr
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output (cross-platform)
print_status() {
  if command -v printf >/dev/null 2>&1; then
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
  else
    echo -e "${BLUE}[INFO]${NC} $1"
  fi
}

print_success() {
  if command -v printf >/dev/null 2>&1; then
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
  else
    echo -e "${GREEN}[SUCCESS]${NC} $1"
  fi
}

print_error() {
  if command -v printf >/dev/null 2>&1; then
    printf "${RED}[ERROR]${NC} %s\n" "$1"
  else
    echo -e "${RED}[ERROR]${NC} $1"
  fi
}

print_warning() {
  if command -v printf >/dev/null 2>&1; then
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
  else
    echo -e "${YELLOW}[WARNING]${NC} $1"
  fi
}

# Check if project name is provided
if [ -z "$1" ]; then
  print_error "Please provide a project name"
  echo "Usage: ./create-modern-react-app.sh [project-name]"
  exit 1
fi

PROJECT_NAME=$1

# Check for required tools
print_status "Checking for required tools..."
if ! command -v node >/dev/null 2>&1; then
  print_error "Node.js is not installed. Please install Node.js 18+ first."
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  print_error "npm is not installed. Please install npm first."
  exit 1
fi

# Check Node version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
  print_warning "Node.js version is less than 18. Recommended: 18+"
fi

# Check if directory already exists
if [ -d "$PROJECT_NAME" ]; then
  print_error "Directory $PROJECT_NAME already exists"
  exit 1
fi

print_status "Creating modern React application: $PROJECT_NAME"

# Step 1: Create Vite project
print_status "Creating Vite project with React and TypeScript..."
if ! npm create vite@^6.3.5 "$PROJECT_NAME" -- --template react-ts; then
  print_error "Failed to create Vite project. Please check your npm installation."
  exit 1
fi

cd "$PROJECT_NAME" || exit 1

# Step 2: Install all dependencies
print_status "Installing dependencies..."
npm install react-router-dom clsx tailwind-merge

print_status "Installing dev dependencies..."
# Split into multiple commands to avoid Windows command length limits
npm install -D tailwindcss autoprefixer @types/react-router-dom

npm install -D eslint @eslint/js @types/eslint__js typescript-eslint \
  @typescript-eslint/eslint-plugin @typescript-eslint/parser

npm install -D eslint-plugin-react eslint-plugin-react-hooks \
  eslint-plugin-react-refresh

npm install -D prettier eslint-config-prettier eslint-plugin-prettier \
  prettier-plugin-tailwindcss

npm install -D husky lint-staged

# Verify critical packages are installed
print_status "Verifying package installation..."
if [ ! -d "node_modules/tailwindcss" ]; then
  print_warning "Tailwind CSS not found, reinstalling..."
  npm install -D tailwindcss
fi

# Step 3: Setup Tailwind CSS Configuration
print_status "Setting up Tailwind CSS configuration..."

# We'll create the config files directly rather than using the CLI
# This is more reliable across different environments

# Step 4: Create tailwind.config.js
print_status "Creating Tailwind configuration..."
cat >tailwind.config.js <<'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          300: '#93c5fd',
          400: '#60a5fa',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
          800: '#1e40af',
          900: '#1e3a8a',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
EOF

# Create postcss.config.js (needed for Vite to process Tailwind)
print_status "Creating PostCSS configuration..."
cat >postcss.config.js <<'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# Step 5: Update index.css
print_status "Updating CSS with Tailwind directives..."
cat >src/index.css <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html {
    @apply antialiased;
  }
  
  body {
    @apply text-gray-900 bg-white;
  }
}

@layer components {
  .btn-primary {
    @apply px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 transition-colors;
  }
  
  .btn-secondary {
    @apply px-4 py-2 bg-gray-200 text-gray-900 rounded-lg hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-colors;
  }
}
EOF

# Step 6: Create ESLint configuration
print_status "Creating ESLint configuration..."
cat >eslint.config.js <<'EOF'
import js from '@eslint/js';
import typescript from 'typescript-eslint';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';
import prettier from 'eslint-plugin-prettier';

export default [
  js.configs.recommended,
  ...typescript.configs.recommended,
  {
    files: ['**/*.{ts,tsx}'],
    plugins: {
      react,
      'react-hooks': reactHooks,
      'react-refresh': reactRefresh,
      prettier,
    },
    languageOptions: {
      parser: typescript.parser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: {
          jsx: true,
        },
      },
    },
    settings: {
      react: {
        version: 'detect',
      },
    },
    rules: {
      // React rules
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off',
      'react/jsx-uses-react': 'off',
      'react/jsx-uses-vars': 'error',
      
      // React Hooks rules
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',
      
      // React Refresh rules
      'react-refresh/only-export-components': [
        'warn',
        { allowConstantExport: true },
      ],
      
      // TypeScript rules
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
      '@typescript-eslint/explicit-module-boundary-types': 'off',
      '@typescript-eslint/no-explicit-any': 'warn',
      
      // Prettier
      'prettier/prettier': 'error',
    },
  },
  {
    ignores: ['dist', 'node_modules', '.git', 'coverage', '*.config.js'],
  },
];
EOF

# Step 7: Create Prettier configuration
print_status "Creating Prettier configuration..."
cat >.prettierrc.json <<'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "always",
  "endOfLine": "lf",
  "bracketSpacing": true,
  "jsxBracketSameLine": false,
  "jsxSingleQuote": false,
  "plugins": ["prettier-plugin-tailwindcss"]
}
EOF

cat >.prettierignore <<'EOF'
dist
node_modules
coverage
.git
*.md
pnpm-lock.yaml
package-lock.json
EOF

# Step 8: Initialize Husky
print_status "Setting up Husky and git hooks..."
npx husky init

# Create pre-commit hook
echo "npx lint-staged" >.husky/pre-commit

# Step 9: Update package.json
print_status "Updating package.json..."
cat >package.json <<'EOF'
{
  "name": "PROJECT_NAME_PLACEHOLDER",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "eslint . --max-warnings 0",
    "format": "prettier --write \"src/**/*.{js,jsx,ts,tsx,css,md}\"",
    "type-check": "tsc --noEmit",
    "prepare": "husky"
  },
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{css,md,json}": [
      "prettier --write"
    ]
  },
  "dependencies": {
    "clsx": "^2.1.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.21.0",
    "tailwind-merge": "^2.2.0"
  },
  "devDependencies": {
    "@eslint/js": "^9.0.0",
    "@types/eslint__js": "^8.42.3",
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "@types/react-router-dom": "^5.3.3",
    "@typescript-eslint/eslint-plugin": "^6.14.0",
    "@typescript-eslint/parser": "^6.14.0",
    "@vitejs/plugin-react": "^4.2.1",
    "autoprefixer": "^10.4.16",
    "eslint": "^8.55.0",
    "eslint-config-prettier": "^9.1.0",
    "eslint-plugin-prettier": "^5.0.1",
    "eslint-plugin-react": "^7.33.2",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.5",
    "husky": "^9.0.0",
    "lint-staged": "^15.2.0",
    "prettier": "^3.1.1",
    "prettier-plugin-tailwindcss": "^0.5.9",
    "tailwindcss": "^3.3.0",
    "typescript": "^5.2.2",
    "typescript-eslint": "^7.0.0",
    "vite": "^5.0.8"
  }
}
EOF

# Replace placeholder with actual project name (cross-platform compatible)
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
  # Windows Git Bash
  sed -i "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" package.json
else
  # macOS/Linux
  sed -i.bak "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" package.json && rm -f package.json.bak
fi

# Step 10: Update TypeScript configuration
print_status "Updating TypeScript configuration..."
cat >tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

# Step 11: Update Vite configuration
print_status "Updating Vite configuration..."
cat >vite.config.ts <<'EOF'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    port: 3000,
    open: true,
  },
});
EOF

# Step 12: Create project structure
print_status "Creating project structure..."
mkdir -p src/{components,pages,lib}

# Create utility functions
cat >src/lib/utils.ts <<'EOF'
import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatDate(date: Date | string): string {
  const d = new Date(date);
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  }).format(d);
}

export function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  return text.slice(0, maxLength) + '...';
}
EOF

# Create Layout component
cat >src/components/Layout.tsx <<'EOF'
import { Outlet, Link, useLocation } from 'react-router-dom';
import { cn } from '@/lib/utils';

export function Layout() {
  const location = useLocation();

  const navLinks = [
    { to: '/', label: 'Home' },
    { to: '/about', label: 'About' },
    { to: '/contact', label: 'Contact' },
  ];

  return (
    <div className="min-h-screen flex flex-col">
      <header className="bg-white shadow-sm border-b">
        <nav className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center">
              <h1 className="text-xl font-semibold">My App</h1>
            </div>
            <div className="flex space-x-4">
              {navLinks.map((link) => (
                <Link
                  key={link.to}
                  to={link.to}
                  className={cn(
                    'px-3 py-2 rounded-md text-sm font-medium transition-colors',
                    location.pathname === link.to
                      ? 'bg-primary-100 text-primary-700'
                      : 'text-gray-700 hover:bg-gray-100'
                  )}
                >
                  {link.label}
                </Link>
              ))}
            </div>
          </div>
        </nav>
      </header>
      <main className="flex-1 container mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <Outlet />
      </main>
      <footer className="bg-gray-50 border-t">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <p className="text-center text-sm text-gray-600">
            © 2025 My App. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}
EOF

# Create Home page
cat >src/pages/Home.tsx <<'EOF'
import { useState } from 'react';
import { cn } from '@/lib/utils';

export function Home() {
  const [count, setCount] = useState(0);

  return (
    <div className="space-y-6">
      <h2 className="text-3xl font-bold tracking-tight">Welcome Home</h2>
      <div className="bg-white p-6 rounded-lg shadow-sm border">
        <h3 className="text-lg font-semibold mb-4">Counter Example</h3>
        <div className="flex items-center space-x-4">
          <button
            onClick={() => setCount((c) => c - 1)}
            className="btn-secondary"
          >
            Decrement
          </button>
          <span className={cn(
            'text-2xl font-mono font-bold',
            count > 0 && 'text-green-600',
            count < 0 && 'text-red-600'
          )}>
            {count}
          </span>
          <button
            onClick={() => setCount((c) => c + 1)}
            className="btn-primary"
          >
            Increment
          </button>
        </div>
      </div>
    </div>
  );
}
EOF

# Create About page
cat >src/pages/About.tsx <<'EOF'
export function About() {
  return (
    <div className="prose prose-lg max-w-none">
      <h2 className="text-3xl font-bold tracking-tight mb-4">About Us</h2>
      <p className="text-gray-600 leading-relaxed">
        This is a modern React application template built with best practices
        in mind. It includes TypeScript for type safety, Tailwind CSS for
        styling, and a robust development setup.
      </p>
      <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">
        {['Fast', 'Secure', 'Scalable'].map((feature) => (
          <div key={feature} className="bg-gray-50 p-4 rounded-lg text-center">
            <h3 className="font-semibold text-lg">{feature}</h3>
            <p className="text-sm text-gray-600 mt-1">
              Built with modern tools and best practices
            </p>
          </div>
        ))}
      </div>
    </div>
  );
}
EOF

# Create Contact page
cat >src/pages/Contact.tsx <<'EOF'
import { FormEvent, useState } from 'react';

export function Contact() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: '',
  });

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    console.log('Form submitted:', formData);
    // Handle form submission
  };

  return (
    <div className="max-w-2xl mx-auto">
      <h2 className="text-3xl font-bold tracking-tight mb-6">Contact Us</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="name" className="block text-sm font-medium mb-1">
            Name
          </label>
          <input
            type="text"
            id="name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
            required
          />
        </div>
        <div>
          <label htmlFor="email" className="block text-sm font-medium mb-1">
            Email
          </label>
          <input
            type="email"
            id="email"
            value={formData.email}
            onChange={(e) => setFormData({ ...formData, email: e.target.value })}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
            required
          />
        </div>
        <div>
          <label htmlFor="message" className="block text-sm font-medium mb-1">
            Message
          </label>
          <textarea
            id="message"
            rows={4}
            value={formData.message}
            onChange={(e) => setFormData({ ...formData, message: e.target.value })}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
            required
          />
        </div>
        <button type="submit" className="btn-primary w-full">
          Send Message
        </button>
      </form>
    </div>
  );
}
EOF

# Update App.tsx
cat >src/App.tsx <<'EOF'
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Layout } from '@/components/Layout';
import { Home } from '@/pages/Home';
import { About } from '@/pages/About';
import { Contact } from '@/pages/Contact';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Home />} />
          <Route path="about" element={<About />} />
          <Route path="contact" element={<Contact />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
EOF

# Update main.tsx
cat >src/main.tsx <<'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.tsx';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

# Step 13: Create additional configuration files
print_status "Creating additional configuration files..."

# Create .editorconfig
cat >.editorconfig <<'EOF'
root = true

[*]
charset = utf-8
indent_style = space
indent_size = 2
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false
EOF

# Update .gitignore
cat >.gitignore <<'EOF'
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*

node_modules
dist
dist-ssr
*.local

# Editor directories and files
.vscode/*
!.vscode/extensions.json
!.vscode/settings.json
.idea
.DS_Store
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?

# Environment files
.env
.env.local
.env.*.local

# Test coverage
coverage
*.lcov
EOF

# Create VS Code configuration
mkdir -p .vscode

cat >.vscode/extensions.json <<'EOF'
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-typescript-next"
  ]
}
EOF

cat >.vscode/settings.json <<'EOF'
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ],
  "tailwindCSS.experimental.classRegex": [
    ["cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"]
  ]
}
EOF

# Step 14: Clean up default Vite files
print_status "Cleaning up default Vite files..."
rm -f src/App.css
rm -f public/vite.svg
rm -f src/assets/react.svg

# Step 15: Clean up and verify installation
print_status "Verifying installation..."
# Check if node_modules exists, if not, run install
if [ ! -d "node_modules" ]; then
  print_warning "node_modules not found, running npm install..."
  npm install
fi

# Step 16: Format code
print_status "Formatting code..."
if npm run format 2>/dev/null; then
  print_success "Code formatted successfully"
else
  print_warning "Code formatting skipped (prettier might not be fully configured yet)"
fi

# Step 17: Initialize git repository (if not already initialized)
if [ ! -d .git ]; then
  print_status "Initializing git repository..."
  git init
  git add .
  git commit -m "Initial commit: Modern React + TypeScript + Tailwind + Vite template"
fi

# Final success message
print_success "Project setup complete! 🎉"
echo ""
echo "Project created at: $(pwd)"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  npm run dev"
echo ""
echo "Available commands:"
echo "  npm run dev        - Start development server (http://localhost:3000)"
echo "  npm run build      - Build for production"
echo "  npm run preview    - Preview production build"
echo "  npm run lint       - Run ESLint"
echo "  npm run format     - Format code with Prettier"
echo "  npm run type-check - Run TypeScript type checking"
echo ""
echo "Features included:"
echo "  ✓ Vite + React + TypeScript"
echo "  ✓ Tailwind CSS (with clsx + tailwind-merge)"
echo "  ✓ React Router DOM"
echo "  ✓ ESLint + Prettier (with auto-fix on commit)"
echo "  ✓ Husky pre-commit hooks"
echo "  ✓ Path aliases (@/)"
echo "  ✓ VS Code settings"
echo ""
print_status "Happy coding! 🚀"
