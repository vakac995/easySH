
import React, { createContext, useContext, useEffect, useState, ReactNode, useCallback } from 'react';
import type { AppConfig, User, LogicOperator, MultiCheckConfig, ModuleConfig } from '@/types/config';
import ConfigService from '@/services/configService';

interface ConfigContextType {
  config: AppConfig | null;
  user: User;
  isModuleEnabled: (moduleId: string) => boolean;
  isFeatureEnabled: (featureName: string) => boolean;
  hasPermission: (permission: string) => boolean;
  checkMultiple: (config: MultiCheckConfig) => boolean;
}

const ConfigContext = createContext<ConfigContextType | undefined>(undefined);

interface ConfigProviderProps {
  children: ReactNode;
  user: User;
}

export const ConfigProvider: React.FC<ConfigProviderProps> = ({ children, user }) => {
  const [config, setConfig] = useState<AppConfig | null>(null);

  useEffect(() => {
    const loadConfig = async () => {
      const appConfig = await ConfigService.fetchConfig();
      setConfig(appConfig);
    };
    loadConfig();
  }, []);

  const isModuleEnabled = useCallback((moduleId: string): boolean => {
    const module = config?.modules.find(m => m.id === moduleId);
    return module ? module.enabled : false;
  }, [config]);

  const isFeatureEnabled = useCallback((featureName: string): boolean => {
    return config?.features[featureName] || false;
  }, [config]);

  const hasPermission = useCallback((permission: string): boolean => {
    return user.permissions.includes(permission);
  }, [user.permissions]);

  const checkMultiple = useCallback((checkConfig: MultiCheckConfig): boolean => {
    const { modules = [], features = [], permissions = [], logic = 'AND' } = checkConfig;

    const moduleChecks = modules.map(isModuleEnabled);
    const featureChecks = features.map(isFeatureEnabled);
    const permissionChecks = permissions.map(hasPermission);

    const allChecks = [...moduleChecks, ...featureChecks, ...permissionChecks];

    if (logic === 'AND') {
      return allChecks.every(Boolean);
    }
    return allChecks.some(Boolean);
  }, [isModuleEnabled, isFeatureEnabled, hasPermission]);

  if (!config) {
    return <div>Loading...</div>; // Or a proper loading spinner
  }

  const value = {
    config,
    user,
    isModuleEnabled,
    isFeatureEnabled,
    hasPermission,
    checkMultiple,
  };

  return <ConfigContext.Provider value={value}>{children}</ConfigContext.Provider>;
};

export const useConfig = (): ConfigContextType => {
  const context = useContext(ConfigContext);
  if (context === undefined) {
    throw new Error('useConfig must be used within a ConfigProvider');
  }
  return context;
};