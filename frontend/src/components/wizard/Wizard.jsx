/**
 * @file Wizard.jsx
 * @description This component is the main wizard interface for creating a new project.
 * It manages the state of the wizard, including the current step, configuration,
 * achievements, and power level. It also handles the logic for unlocking achievements
 * and calculating the power level based on the user's selections.
 * @requires react
 * @requires framer-motion
 * @requires ./WelcomeStep
 * @requires ./BackendStep
 * @requires ./DatabaseConfigStep
 * @requires ./FrontendStep
 * @requires ./ModuleStep
 * @requires ./ReviewStep
 * @requires ./ProgressBar
 * @requires ./AnimatedStep
 * @requires ../achievements/AchievementList
 * @requires ./Celebration
 * @requires ../gamification/GamificationPanel
 * @requires ./CompletionStep
 * @requires ../Layout
 * @requires ../Card
 * @requires ../../utils/soundEffects
 */

import React, { useState, useEffect, useCallback } from 'react';
import { AnimatePresence } from 'framer-motion';
import WelcomeStep from './WelcomeStep';
import BackendStep from './BackendStep';
import DatabaseConfigStep from './DatabaseConfigStep';
import FrontendStep from './FrontendStep';
import ModuleStep from './ModuleStep';
import ReviewStep from './ReviewStep';
import ProgressBar from './ProgressBar';
import AnimatedStep from './AnimatedStep';
import AchievementList from '../achievements/AchievementList';
import Celebration from './Celebration';
import GamificationPanel from '../gamification/GamificationPanel';
import CompletionStep from './CompletionStep';
import Layout from '../Layout';
import Card from '../Card';
import {
  playAchievementSound,
  playPowerUpSound,
  playCelebrationSound,
} from '../../utils/soundEffects';

const initialConfig = {
  projectName: 'new-project-name',
  backend: {
    include: true,
    framework: 'fastapi',
    database: 'postgresql',
    projectName: '',
    projectDescription: 'A robust backend service.',
    dbHost: 'postgres',
    dbPort: 5432,
    dbName: 'app_db',
    dbUser: 'db_user',
    dbPassword: 'secure_password_123',
    pgAdminEmail: 'admin@example.com',
    pgAdminPassword: 'admin123',
    debug: false,
    logLevel: 'INFO',
    modules: [],
    features: [],
  },
  frontend: {
    include: true,
    framework: 'react',
    projectName: '',
    projectDescription: 'A modern frontend application.',
    uiLibrary: 'none',
    includeExamplePages: true,
    includeHusky: false,
    modules: [],
    features: [],
  },
  modules: {
    authentication: false,
    notifications: false,
  },
};

/**
 * The main wizard component.
 * @returns {JSX.Element} The wizard interface.
 */
const Wizard = () => {
  const [step, setStep] = useState(1);
  const [showCelebration, setShowCelebration] = useState(false);
  const [isComplete, setIsComplete] = useState(false);
  const [achievements, setAchievements] = useState([]);
  const [powerLevel, setPowerLevel] = useState(0);
  const [config, setConfig] = useState(initialConfig);

  /**
   * Unlocks an achievement and adds it to the list of achievements.
   * Plays a sound effect and triggers a celebration for special achievements.
   * @param {object} achievement - The achievement to unlock.
   * @param {string} achievement.id - The unique ID of the achievement.
   * @param {string} achievement.title - The title of the achievement.
   * @param {string} achievement.icon - The icon for the achievement.
   * @param {string} achievement.description - The description of the achievement.
   * @param {boolean} [achievement.special=false] - Whether the achievement is special.
   */
  const unlockAchievement = useCallback((achievement) => {
    setAchievements((prev) => {
      if (prev.find((a) => a.id === achievement.id)) {
        return prev;
      }

      // Add timestamp and show notification
      const newAchievement = {
        ...achievement,
        timestamp: Date.now(),
        isNew: true,
      };      // Play achievement sound (async, fire-and-forget)
      playAchievementSound().catch(() => {
        // Silently handle audio failures
      });

      // Trigger celebration effect for certain achievements
      if (achievement.special) {
        setShowCelebration(true);
        setTimeout(() => setShowCelebration(false), 2000);
        playCelebrationSound().catch(() => {
          // Silently handle audio failures
        });
      }

      return [...prev, newAchievement];
    });
  }, []);

  /**
   * Tracks achievements based on configuration changes.
   */
  useEffect(() => {
    // Project naming achievement
    if (config.projectName !== 'MyNewProject' && config.projectName.length > 0) {
      unlockAchievement({
        id: 'project-named',
        title: 'Project Christened',
        icon: '🏷️',
        description: 'You gave your project a unique name!',
      });
    }

    // Database selection achievements
    if (config.backend.database === 'sqlite') {
      unlockAchievement({
        id: 'database-sqlite',
        title: 'Keep It Simple',
        icon: '💾',
        description: 'SQLite chosen - perfect for getting started!',
      });
    } else if (config.backend.database === 'postgresql') {
      unlockAchievement({
        id: 'database-postgresql',
        title: 'Production Ready',
        icon: '🐘',
        description: 'PostgreSQL chosen - enterprise grade!',
      });
    }

    // UI Library achievements
    if (config.frontend.uiLibrary === 'tailwindcss') {
      unlockAchievement({
        id: 'ui-tailwind',
        title: 'Style Master',
        icon: '🎨',
        description: 'Tailwind CSS - utility-first styling!',
      });
    } else if (config.frontend.uiLibrary === 'material-ui') {
      unlockAchievement({
        id: 'ui-material',
        title: 'Material Designer',
        icon: '🎭',
        description: "Material-UI - Google's design system!",
      });
    }

    // Power level milestones
    if (powerLevel >= 50) {
      unlockAchievement({
        id: 'power-50',
        title: 'Halfway There',
        icon: '⚡',
        description: "You've reached 50% power level!",
      });
    }
    if (powerLevel >= 100) {
      unlockAchievement({
        id: 'power-max',
        title: 'Maximum Power!',
        icon: '🔋',
        description: "Congratulations! You've maxed out your power level!",
        special: true,
      });      // Play special power up sound for max level (async, fire-and-forget)
      playPowerUpSound().catch(() => {
        // Silently handle audio failures
      });
    }
  }, [config, powerLevel, unlockAchievement]);

  /**
   * Calculates the power level based on the current configuration.
   */
  useEffect(() => {
    const calculatePowerLevel = () => {
      let level = 0;

      // Base points for project setup
      if (config.projectName !== 'MyNewProject') level += 20;

      // Database selection (SQLite gets more points as it's simpler for beginners)
      if (config.backend.database === 'sqlite') level += 15;
      else if (config.backend.database === 'postgresql') level += 10;

      // UI Library selection
      if (config.frontend.uiLibrary === 'tailwindcss') level += 20;
      else if (config.frontend.uiLibrary === 'material-ui') level += 15;

      // Module selections (major features)
      if (config.modules.authentication) level += 25;
      if (config.modules.notifications) level += 20;

      // Bonus for selecting both advanced modules
      if (config.modules.authentication && config.modules.notifications) level += 10;

      setPowerLevel(Math.min(level, 100));
    };

    calculatePowerLevel();
  }, [config]);

  /**
   * Triggers a celebration effect and marks the wizard as complete.
   */
  const triggerCelebration = () => {
    setShowCelebration(true);
    setTimeout(() => {
      setShowCelebration(false);
      setIsComplete(true);
    }, 6000); // Hide after 4 seconds and show completion
  };

  const startOver = () => {
    setStep(1);
    setConfig(initialConfig);
    setAchievements([]);
    setPowerLevel(0);
    setIsComplete(false);
  };

  const nextStep = () => setStep(step + 1);
  const prevStep = () => setStep(step - 1);
  const handleChange = (path) => (e) => {
    const { value, type, checked } = e.target;
    const keys = path.split('.');

    setConfig((prevConfig) => {
      let tempConfig = { ...prevConfig };
      let current = tempConfig;

      for (let i = 0; i < keys.length - 1; i++) {
        current = current[keys[i]];
      }

      current[keys[keys.length - 1]] = type === 'checkbox' ? checked : value;

      // Auto-update backend and frontend project names when main project name changes
      if (path === 'projectName') {
        tempConfig.backend.projectName = `${value}-backend`;
        tempConfig.frontend.projectName = `${value}-frontend`;
      }

      return tempConfig;
    });
  };
  const renderStep = () => {
    switch (step) {
      case 1:
        return <WelcomeStep nextStep={nextStep} handleChange={handleChange} config={config} />;
      case 2:
        return (
          <BackendStep
            nextStep={nextStep}
            prevStep={prevStep}
            handleChange={handleChange}
            config={config}
          />
        );
      case 3:
        return (
          <DatabaseConfigStep
            nextStep={nextStep}
            prevStep={prevStep}
            handleChange={handleChange}
            config={config}
          />
        );
      case 4:
        return (
          <FrontendStep
            nextStep={nextStep}
            prevStep={prevStep}
            handleChange={handleChange}
            config={config}
          />
        );
      case 5:
        return (
          <ModuleStep
            nextStep={nextStep}
            prevStep={prevStep}
            handleChange={handleChange}
            config={config}
          />
        );
      case 6:
        return <ReviewStep nextStep={triggerCelebration} prevStep={prevStep} config={config} />;
      default:
        return null;
    }
  };

  if (isComplete) {
    return (
      <Layout>
        <CompletionStep startOver={startOver} config={config} />
      </Layout>
    );
  }

  return (
    <Layout>
      <div className='relative'>
        <AnimatePresence>{showCelebration && <Celebration />}</AnimatePresence>

        <AchievementList achievements={achievements} />

        <div className='mb-6'>
          <GamificationPanel level={powerLevel} achievements={achievements} config={config} />
        </div>        <Card>
          <ProgressBar currentStep={step} totalSteps={6} />
          <AnimatePresence mode='wait'>
            <AnimatedStep key={step}>{renderStep()}</AnimatedStep>
          </AnimatePresence>
        </Card>
      </div>
    </Layout>
  );
};

export default Wizard;
