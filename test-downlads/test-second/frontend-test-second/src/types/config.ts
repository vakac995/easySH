
export interface ModuleConfig {
  id: string;
  name: string;
  requiredPermissions: string[];
  enabled: boolean;
}

export interface AppConfig {
  modules: ModuleConfig[];
  features: Record<string, boolean>;
}

export interface User {
  id: string;
  name: string;
  permissions: string[];
}

export type LogicOperator = 'AND' | 'OR';

export interface MultiCheckConfig {
  modules?: string[];
  features?: string[];
  permissions?: string[];
  logic?: LogicOperator;
}