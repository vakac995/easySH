# Step-by-step integration after running the createViteApp.sh script

# 1. Navigate to the created project
cd project-name

# 2. Install additional dependencies for the configuration system
npm install

# Add configuration-specific dependencies
npm install lodash papaparse
npm install -D @types/lodash

# 3. Create the configuration system folder structure
mkdir -p src/{config,hooks,providers,services,types,utils}

# 4. Create configuration types
cat >src/types/config.ts <<'EOF'
export interface ModuleConfig {
  id: string;
  name: string;
  enabled: boolean;
  environments: string[];
  permissions?: string[];
  metadata?: Record<string, any>;
  children?: ModuleConfig[];
}

export interface AppConfig {
  version: string;
  environment: string;
  modules: Record<string, ModuleConfig>;
  features: Record<string, boolean>;
  ui: {
    theme: string;
    layout: string;
    navigation: Record<string, any>;
  };
  api: {
    baseUrl: string;
    timeout: number;
    retries: number;
  };
}

export interface User {
  id: string;
  roles: string[];
  permissions: string[];
}

export type LogicOperator = 'AND' | 'OR';

export interface MultiCheckConfig {
  modules?: string | string[];
  permissions?: string | string[];
  environments?: string | string[];
  features?: string | string[];
  logic?: LogicOperator;
}
EOF

# 5. Create configuration service
cat >src/services/configService.ts <<'EOF'
import type { AppConfig } from '@/types/config';

class ConfigService {
  private static instance: ConfigService;
  private cache: Map<string, { data: AppConfig; timestamp: number }> = new Map();
  private readonly CACHE_TTL = 5 * 60 * 1000; // 5 minutes

  static getInstance(): ConfigService {
    if (!ConfigService.instance) {
      ConfigService.instance = new ConfigService();
    }
    return ConfigService.instance;
  }

  async fetchConfig(environment: string = 'production'): Promise<AppConfig> {
    const cacheKey = `config-${environment}`;
    const cached = this.cache.get(cacheKey);
    
    if (cached && Date.now() - cached.timestamp < this.CACHE_TTL) {
      return cached.data;
    }

    try {
      // Try remote config first
      const remoteConfig = await this.fetchRemoteConfig(environment);
      if (remoteConfig) {
        this.cache.set(cacheKey, { data: remoteConfig, timestamp: Date.now() });
        return remoteConfig;
      }
    } catch (error) {
      console.warn('Failed to fetch remote config, falling back to local:', error);
    }

    // Fallback to local config
    const localConfig = this.getLocalConfig(environment);
    this.cache.set(cacheKey, { data: localConfig, timestamp: Date.now() });
    return localConfig;
  }

  private async fetchRemoteConfig(environment: string): Promise<AppConfig | null> {
    try {
      const response = await fetch(`/api/config/${environment}`, {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      return await response.json();
    } catch (error) {
      console.error('Remote config fetch failed:', error);
      return null;
    }
  }

  private getLocalConfig(environment: string): AppConfig {
    return {
      version: '1.0.0',
      environment,
      modules: {
        fibi: {
          id: 'fibi',
          name: 'FIBI Module',
          enabled: ['DEV', 'TEST', 'PROD', 'LOCAL'].includes(environment.toUpperCase()),
          environments: ['DEV', 'TEST', 'PROD', 'LOCAL'],
          permissions: ['fibi.read', 'fibi.write'],
        },
        retention: {
          id: 'retention',
          name: 'Retention Module',
          enabled: ['TEST', 'LOCAL', 'DEV', 'PROD'].includes(environment.toUpperCase()),
          environments: ['TEST', 'LOCAL', 'DEV', 'PROD'],
          permissions: ['retention.read'],
        },
      },
      features: {
        darkMode: true,
        notifications: true,
        analytics: environment !== 'DEV',
      },
      ui: {
        theme: 'default',
        layout: 'sidebar',
        navigation: {},
      },
      api: {
        baseUrl: environment === 'production' ? '/api' : '/api/dev',
        timeout: 30000,
        retries: 3,
      },
    };
  }

  private getAuthToken(): string {
    return localStorage.getItem('authToken') || '';
  }

  clearCache(): void {
    this.cache.clear();
  }
}

export default ConfigService;
EOF

# 6. Create configuration provider
cat >src/providers/ConfigProvider.tsx <<'EOF'
import React, { createContext, useContext, useEffect, useState, ReactNode, useCallback } from 'react';
import type { AppConfig, User, LogicOperator, MultiCheckConfig, ModuleConfig } from '@/types/config';
import ConfigService from '@/services/configService';

interface ConfigContextType {
  config: AppConfig | null;
  loading: boolean;
  error: string | null;
  refreshConfig: () => Promise<void>;
  isModuleEnabled: (moduleId: string) => boolean;
  areModulesEnabled: (moduleIds: string[], logic?: LogicOperator) => boolean;
  hasPermission: (permission: string) => boolean;
  hasPermissions: (permissions: string[], logic?: LogicOperator) => boolean;
  isEnvironment: (environments: string | string[], logic?: LogicOperator) => boolean;
  hasFeature: (features: string | string[], logic?: LogicOperator) => boolean;
  checkMultiple: (config: MultiCheckConfig) => boolean;
  getModuleConfig: (moduleId: string) => ModuleConfig | null;
}

const ConfigContext = createContext<ConfigContextType | undefined>(undefined);

interface ConfigProviderProps {
  children: ReactNode;
  environment?: string;
  user?: User;
}

export const ConfigProvider: React.FC<ConfigProviderProps> = ({ 
  children, 
  environment = 'production',
  user 
}) => {
  const [config, setConfig] = useState<AppConfig | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [currentUser, setCurrentUser] = useState<User | null>(user || null);

  const configService = ConfigService.getInstance();

  const refreshConfig = useCallback(async (): Promise<void> => {
    try {
      setLoading(true);
      setError(null);
      const newConfig = await configService.fetchConfig(environment);
      setConfig(newConfig);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load configuration');
    } finally {
      setLoading(false);
    }
  }, [environment, configService]);

  const isModuleEnabled = useCallback((moduleId: string): boolean => {
    if (!config) return false;
    
    const module = getModuleConfig(moduleId);
    if (!module) return false;

    if (!module.environments.includes(config.environment.toUpperCase())) {
      return false;
    }

    if (currentUser && module.permissions) {
      const hasPermission = module.permissions.some(permission =>
        currentUser.permissions.includes(permission)
      );
      if (!hasPermission) return false;
    }

    return module.enabled;
  }, [config, currentUser]);

  const areModulesEnabled = useCallback((moduleIds: string[], logic: LogicOperator = 'AND'): boolean => {
    if (logic === 'OR') {
      return moduleIds.some(moduleId => isModuleEnabled(moduleId));
    }
    return moduleIds.every(moduleId => isModuleEnabled(moduleId));
  }, [isModuleEnabled]);

  const hasPermission = useCallback((permission: string): boolean => {
    if (!currentUser) return false;
    return currentUser.permissions.includes(permission);
  }, [currentUser]);

  const hasPermissions = useCallback((permissions: string[], logic: LogicOperator = 'AND'): boolean => {
    if (!currentUser) return false;
    
    if (logic === 'OR') {
      return permissions.some(permission => currentUser.permissions.includes(permission));
    }
    return permissions.every(permission => currentUser.permissions.includes(permission));
  }, [currentUser]);

  const isEnvironment = useCallback((environments: string | string[], logic: LogicOperator = 'OR'): boolean => {
    if (!config) return false;
    
    const envArray = Array.isArray(environments) ? environments : [environments];
    const currentEnv = config.environment.toUpperCase();
    
    if (logic === 'AND') {
      return envArray.every(env => env.toUpperCase() === currentEnv);
    }
    return envArray.some(env => env.toUpperCase() === currentEnv);
  }, [config]);

  const hasFeature = useCallback((features: string | string[], logic: LogicOperator = 'AND'): boolean => {
    if (!config) return false;
    
    const featureArray = Array.isArray(features) ? features : [features];
    
    if (logic === 'OR') {
      return featureArray.some(feature => config.features[feature] === true);
    }
    return featureArray.every(feature => config.features[feature] === true);
  }, [config]);

  const checkMultiple = useCallback((checkConfig: MultiCheckConfig): boolean => {
    const logic = checkConfig.logic || 'AND';
    const results: boolean[] = [];

    if (checkConfig.modules) {
      const moduleArray = Array.isArray(checkConfig.modules) ? checkConfig.modules : [checkConfig.modules];
      results.push(areModulesEnabled(moduleArray, logic));
    }

    if (checkConfig.permissions) {
      const permArray = Array.isArray(checkConfig.permissions) ? checkConfig.permissions : [checkConfig.permissions];
      results.push(hasPermissions(permArray, logic));
    }

    if (checkConfig.environments) {
      results.push(isEnvironment(checkConfig.environments, logic));
    }

    if (checkConfig.features) {
      results.push(hasFeature(checkConfig.features, logic));
    }

    if (logic === 'OR') {
      return results.some(result => result);
    }
    return results.every(result => result);
  }, [areModulesEnabled, hasPermissions, isEnvironment, hasFeature]);

  const getModuleConfig = useCallback((moduleId: string): ModuleConfig | null => {
    if (!config) return null;

    if (config.modules[moduleId]) {
      return config.modules[moduleId];
    }

    for (const module of Object.values(config.modules)) {
      if (module.children) {
        const childModule = module.children.find(child => child.id === moduleId);
        if (childModule) return childModule;
      }
    }

    return null;
  }, [config]);

  useEffect(() => {
    refreshConfig();
  }, [refreshConfig]);

  useEffect(() => {
    const interval = setInterval(refreshConfig, 10 * 60 * 1000);
    return () => clearInterval(interval);
  }, [refreshConfig]);

  const value: ConfigContextType = {
    config,
    loading,
    error,
    refreshConfig,
    isModuleEnabled,
    areModulesEnabled,
    hasPermission,
    hasPermissions,
    isEnvironment,
    hasFeature,
    checkMultiple,
    getModuleConfig,
  };

  return (
    <ConfigContext.Provider value={value}>
      {children}
    </ConfigContext.Provider>
  );
};

export const useConfig = (): ConfigContextType => {
  const context = useContext(ConfigContext);
  if (context === undefined) {
    throw new Error('useConfig must be used within a ConfigProvider');
  }
  return context;
};
EOF

# 7. Create configuration hooks
cat >src/hooks/useConfig.ts <<'EOF'
export { useConfig } from '@/providers/ConfigProvider';
import { useConfig } from '@/providers/ConfigProvider';
import type { LogicOperator, MultiCheckConfig } from '@/types/config';

export const useModule = (moduleId: string) => {
  const { isModuleEnabled, getModuleConfig } = useConfig();
  return {
    enabled: isModuleEnabled(moduleId),
    config: getModuleConfig(moduleId),
  };
};

export const useModules = (moduleIds: string[], logic: LogicOperator = 'AND') => {
  const { areModulesEnabled, getModuleConfig, isModuleEnabled } = useConfig();
  return {
    enabled: areModulesEnabled(moduleIds, logic),
    configs: moduleIds.map(id => getModuleConfig(id)),
    enabledModules: moduleIds.filter(id => isModuleEnabled(id)),
  };
};

export const useFeature = (featureName: string): boolean => {
  const { config } = useConfig();
  return config?.features[featureName] ?? false;
};

export const useFeatures = (featureNames: string[], logic: LogicOperator = 'AND'): boolean => {
  const { hasFeature } = useConfig();
  return hasFeature(featureNames, logic);
};

export const usePermissions = (permissions: string[], logic: LogicOperator = 'AND') => {
  const { hasPermissions, hasPermission } = useConfig();
  return {
    hasAll: hasPermissions(permissions, 'AND'),
    hasAny: hasPermissions(permissions, 'OR'),
    hasWithLogic: hasPermissions(permissions, logic),
    individual: permissions.map(perm => ({ permission: perm, granted: hasPermission(perm) })),
  };
};

export const useMultiCheck = (config: MultiCheckConfig) => {
  const { checkMultiple } = useConfig();
  return checkMultiple(config);
};
EOF

# 8. Create ConditionalRender component
cat >src/components/ConditionalRender.tsx <<'EOF'
import { ReactNode } from 'react';
import { useConfig } from '@/hooks/useConfig';
import type { LogicOperator, MultiCheckConfig } from '@/types/config';

interface ConditionalRenderProps {
  module?: string | string[];
  feature?: string | string[];
  permission?: string | string[];
  environment?: string | string[];
  logic?: LogicOperator;
  checkLogic?: LogicOperator;
  children: ReactNode;
  fallback?: ReactNode;
  config?: MultiCheckConfig;
}

export const ConditionalRender: React.FC<ConditionalRenderProps> = ({
  module,
  feature,
  permission,
  environment,
  logic = 'AND',
  checkLogic = 'OR',
  children,
  fallback = null,
  config: multiConfig,
}) => {
  const { 
    areModulesEnabled, 
    hasPermissions, 
    isEnvironment, 
    hasFeature,
    checkMultiple 
  } = useConfig();

  if (multiConfig) {
    const shouldRender = checkMultiple(multiConfig);
    return shouldRender ? <>{children}</> : <>{fallback}</>;
  }

  const results: boolean[] = [];

  if (module) {
    const moduleArray = Array.isArray(module) ? module : [module];
    results.push(areModulesEnabled(moduleArray, checkLogic));
  }

  if (permission) {
    const permArray = Array.isArray(permission) ? permission : [permission];
    results.push(hasPermissions(permArray, checkLogic));
  }

  if (environment) {
    results.push(isEnvironment(environment, checkLogic));
  }

  if (feature) {
    results.push(hasFeature(feature, checkLogic));
  }

  let shouldRender = true;
  if (results.length > 0) {
    if (logic === 'OR') {
      shouldRender = results.some(result => result);
    } else {
      shouldRender = results.every(result => result);
    }
  }

  return shouldRender ? <>{children}</> : <>{fallback}</>;
};
EOF

# 9. Update the existing App.tsx to include the ConfigProvider
cat >src/App.tsx <<'EOF'
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { ConfigProvider } from '@/providers/ConfigProvider';
import { Layout } from '@/components/Layout';
import { Home } from '@/pages/Home';
import { About } from '@/pages/About';
import { Contact } from '@/pages/Contact';

// Example user data - replace with the actual auth system
const mockUser = {
  id: 'user123',
  roles: ['admin', 'user'],
  permissions: ['fibi.read', 'fibi.write', 'retention.read', 'goals.read']
};

function App() {
  return (
    <ConfigProvider 
      environment={import.meta.env.MODE} 
      user={mockUser}
    >
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Layout />}>
            <Route index element={<Home />} />
            <Route path="about" element={<About />} />
            <Route path="contact" element={<Contact />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </ConfigProvider>
  );
}

export default App;
EOF

# 10. Update Home.tsx to demonstrate configuration usage
cat >src/pages/Home.tsx <<'EOF'
import { useState } from 'react';
import { cn } from '@/lib/utils';
import { useConfig, useModule, useFeature } from '@/hooks/useConfig';
import { ConditionalRender } from '@/components/ConditionalRender';

export function Home() {
  const [count, setCount] = useState(0);
  const { config, loading } = useConfig();
  const fibiModule = useModule('fibi');
  const isDarkMode = useFeature('darkMode');

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
        <span className="ml-2">Loading configuration...</span>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <h2 className="text-3xl font-bold tracking-tight">Welcome Home</h2>
      
      {/* Configuration Status */}
      <div className="bg-blue-50 p-4 rounded-lg border border-blue-200">
        <h3 className="font-semibold text-blue-900 mb-2">Configuration Status</h3>
        <p className="text-sm text-blue-700">
          Environment: <span className="font-mono">{config?.environment}</span> | 
          Version: <span className="font-mono">{config?.version}</span> |
          Dark Mode: <span className={cn("font-mono", isDarkMode ? "text-green-600" : "text-red-600")}>
            {isDarkMode ? "Enabled" : "Disabled"}
          </span>
        </p>
      </div>

      {/* Counter Example */}
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

      {/* Conditional Module Display */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <ConditionalRender module="fibi">
          <div className="bg-green-50 p-4 rounded-lg border border-green-200">
            <h3 className="font-semibold text-green-900">🏦 FIBI Module</h3>
            <p className="text-sm text-green-700">
              Financial module is enabled and ready to use.
            </p>
            <p className="text-xs text-green-600 mt-1">
              Config: {JSON.stringify(fibiModule.config?.permissions)}
            </p>
          </div>
        </ConditionalRender>

        <ConditionalRender module="retention">
          <div className="bg-blue-50 p-4 rounded-lg border border-blue-200">
            <h3 className="font-semibold text-blue-900">📊 Retention Module</h3>
            <p className="text-sm text-blue-700">
              Customer retention analytics available.
            </p>
          </div>
        </ConditionalRender>

        <ConditionalRender 
          module={["fibi", "retention"]} 
          checkLogic="OR"
        >
          <div className="bg-purple-50 p-4 rounded-lg border border-purple-200">
            <h3 className="font-semibold text-purple-900">🔗 Combined Features</h3>
            <p className="text-sm text-purple-700">
              Advanced features available when any financial module is active.
            </p>
          </div>
        </ConditionalRender>

        <ConditionalRender 
          feature="analytics"
          environment={["production", "test"]}
          logic="AND"
        >
          <div className="bg-orange-50 p-4 rounded-lg border border-orange-200">
            <h3 className="font-semibold text-orange-900">📈 Analytics</h3>
            <p className="text-sm text-orange-700">
              Analytics enabled for production/test environments.
            </p>
          </div>
        </ConditionalRender>
      </div>

      {/* Development Tools */}
      <ConditionalRender environment={["development", "test"]}>
        <div className="bg-yellow-50 p-4 rounded-lg border border-yellow-200">
          <h3 className="font-semibold text-yellow-900">🛠️ Development Tools</h3>
          <p className="text-sm text-yellow-700">
            Debug tools are available in development/test environments.
          </p>
          <button 
            className="mt-2 px-3 py-1 bg-yellow-200 text-yellow-800 rounded text-xs"
            onClick={() => console.log('Current config:', config)}
          >
            Log Config to Console
          </button>
        </div>
      </ConditionalRender>
    </div>
  );
}
EOF

# 11. Add environment variables support
cat >.env.example <<'EOF'
# Environment Configuration
VITE_APP_ENVIRONMENT=development
VITE_CONFIG_API_URL=http://localhost:3001/api/config
VITE_ENABLE_CONFIG_CACHE=true
VITE_CONFIG_REFRESH_INTERVAL=600000
EOF

# 12. Update package.json scripts to include config-related commands
echo "Adding configuration scripts to package.json..."

echo ""
echo "✅ Configuration system integration complete!"
echo ""
echo "Manual steps remaining:"
echo "1. Add these scripts to the package.json:"
echo '   "config:validate": "node scripts/validateConfig.js"'
echo '   "config:deploy": "node scripts/deployConfig.js"'
echo ""
echo "2. Create environment-specific config files in public/config/"
echo "3. Set up backend API endpoint for remote configuration"
echo ""
echo "Your project structure now includes:"
echo "  src/types/config.ts          - TypeScript definitions"
echo "  src/services/configService.ts - Configuration service"
echo "  src/providers/ConfigProvider.tsx - React context provider"
echo "  src/hooks/useConfig.ts       - Configuration hooks"
echo "  src/components/ConditionalRender.tsx - Conditional rendering"
echo ""
echo "Usage examples added to:"
echo "  src/App.tsx                  - Provider setup"
echo "  src/pages/Home.tsx           - Hook usage demonstrations"
EOF

# Make the script executable
chmod +x integration-script.sh

echo ""
echo "🎉 Integration script created!"
echo ""
echo "To integrate the configuration system into existing Vite project:"
echo "1. Run createViteApp.sh script first"
echo "2. Navigate to the project directory"
echo "3. Run the integration script"
echo ""
echo "Example:"
echo "  ./createViteApp.sh my-financial-app"
echo "  cd my-financial-app"
echo "  ../integration-script.sh"
echo ""
echo "The configuration system will be fully integrated and ready to use!"
