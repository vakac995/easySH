# easySH Project Generator - Overview

## What is easySH?

easySH is a web-based project generator designed specifically for FiBank Bulgaria to help developers quickly bootstrap new projects with predefined, production-ready configurations. It evolved from a collection of shell scripts into a modern, user-friendly web application.

## Problem Statement

Previously, junior developers at FiBank had to:

- Navigate complex shell scripts to set up new projects
- Manually configure backend and frontend dependencies
- Understand the intricacies of Docker, database configurations, and build tools
- Often struggle with initial project setup, leading to delays in development

## Solution

easySH provides:

- **Intuitive Web Interface**: A gamified, step-by-step wizard that guides users through project configuration
- **Pre-configured Templates**: Production-ready templates for both backend (FastAPI + PostgreSQL) and frontend (React + Vite) projects
- **One-Click Generation**: Generate and download a complete, ready-to-run project in seconds
- **Best Practices Built-in**: All generated projects follow FiBank's coding standards and include latest library versions

## Key Features

### For Developers

- **Guided Setup**: Step-by-step wizard with clear instructions
- **Instant Results**: Download a complete project in ZIP format
- **Ready to Run**: Generated projects include setup scripts and documentation
- **Customizable**: Choose database types, UI libraries, and additional modules

### For Organizations

- **Standardization**: Ensures all projects follow the same structure and best practices
- **Reduced Onboarding Time**: New developers can start productive work immediately
- **Consistency**: All projects use the same patterns, tools, and configurations
- **Maintainability**: Centralized template management for organization-wide updates

## Technology Stack

### Frontend

- **React 18** with **Vite** for fast development
- **Tailwind CSS** for modern, responsive styling
- **Framer Motion** for smooth animations
- **Gamification** elements to enhance user experience

### Backend

- **FastAPI** for high-performance API development
- **Jinja2** templating engine for code generation
- **Docker** and **Docker Compose** for containerization
- **PostgreSQL** as the primary database

## Generated Project Structure

When you use easySH, you get a complete project with:

```
project-name/
├── project-name-backend/     # FastAPI backend
│   ├── src/
│   ├── sql/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── requirements.txt
├── project-name-frontend/    # React frontend
│   ├── src/
│   ├── package.json
│   ├── vite.config.ts
│   └── tailwind.config.js
└── setup_environment.sh     # One-command setup script
```

## Benefits

1. **Faster Time to Market**: Reduce project setup time from hours to minutes
2. **Reduced Errors**: Eliminate common configuration mistakes
3. **Knowledge Sharing**: Embed best practices into every generated project
4. **Scalability**: Easy to add new templates and configurations
5. **Developer Experience**: Make project setup enjoyable rather than frustrating

## Next Steps

This documentation is organized into sections to help you understand and work with easySH:

1. **Architecture** - How the system works internally
2. **Frontend** - React application and gamification features
3. **Backend** - FastAPI service and template engine
4. **Development** - Setting up a development environment
5. **Fixes and Improvements** - Changelog and known issues
